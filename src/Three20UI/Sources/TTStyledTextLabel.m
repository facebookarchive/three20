//
// Copyright 2009-2011 Facebook
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//    http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

#import "Three20UI/TTStyledTextLabel.h"

// UI
#import "Three20UI/TTNavigator.h"
#import "Three20UI/TTTableView.h"
#import "Three20UI/UIViewAdditions.h"

// Style
#import "Three20Style/TTGlobalStyle.h"
#import "Three20Style/TTStyledText.h"
#import "Three20Style/TTStyledNode.h"
#import "Three20Style/TTStyleSheet.h"
#import "Three20Style/TTStyledElement.h"
#import "Three20Style/TTStyledLinkNode.h"
#import "Three20Style/TTStyledButtonNode.h"
#import "Three20Style/TTStyledTextNode.h"

// - Styled frames
#import "Three20Style/TTStyledInlineFrame.h"
#import "Three20Style/TTStyledTextFrame.h"

// Core
#import "Three20Core/TTCorePreprocessorMacros.h"
#import "Three20Core/TTDebug.h"

static const CGFloat kCancelHighlightThreshold = 4;


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation TTStyledTextLabel

@synthesize text                  = _text;
@synthesize textColor             = _textColor;
@synthesize highlightedTextColor  = _highlightedTextColor;
@synthesize font                  = _font;
@synthesize textAlignment         = _textAlignment;
@synthesize contentInset          = _contentInset;
@synthesize highlighted           = _highlighted;
@synthesize highlightedNode       = _highlightedNode;


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithFrame:(CGRect)frame {
  if (self = [super initWithFrame:frame]) {
    _textAlignment  = UITextAlignmentLeft;
    _contentInset   = UIEdgeInsetsZero;

    self.font = TTSTYLEVAR(font);
    self.backgroundColor = TTSTYLEVAR(backgroundColor);
    self.contentMode = UIViewContentModeRedraw;
  }

  return self;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)dealloc {
  _text.delegate = nil;
  TT_RELEASE_SAFELY(_text);
  TT_RELEASE_SAFELY(_font);
  TT_RELEASE_SAFELY(_textColor);
  TT_RELEASE_SAFELY(_highlightedTextColor);
  TT_RELEASE_SAFELY(_highlightedNode);
  TT_RELEASE_SAFELY(_highlightedFrame);
  TT_RELEASE_SAFELY(_accessibilityElements);

  [super dealloc];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Private


///////////////////////////////////////////////////////////////////////////////////////////////////
/**
 * UITableView looks for this function and crashes if it is not found when you select a cell
 */
- (BOOL)isHighlighted {
  return _highlighted;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setStyle:(TTStyle*)style forFrame:(TTStyledBoxFrame*)frame {
  if ([frame isKindOfClass:[TTStyledInlineFrame class]]) {
    TTStyledInlineFrame* inlineFrame = (TTStyledInlineFrame*)frame;
    while (inlineFrame.inlinePreviousFrame) {
      inlineFrame = inlineFrame.inlinePreviousFrame;
    }
    while (inlineFrame) {
      inlineFrame.style = style;
      inlineFrame = inlineFrame.inlineNextFrame;
    }

  } else {
    frame.style = style;
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setHighlightedFrame:(TTStyledBoxFrame*)frame{
  if (frame != _highlightedFrame) {
    TTTableView* tableView = (TTTableView*)[self ancestorOrSelfWithClass:[TTTableView class]];

    TTStyledBoxFrame* affectFrame = frame ? frame : _highlightedFrame;
    NSString* className = affectFrame.element.className;
    if (!className && [affectFrame.element isKindOfClass:[TTStyledLinkNode class]]) {
      className = @"linkText:";
    }

    if (className && [className rangeOfString:@":"].location != NSNotFound) {
      if (frame) {
        TTStyle* style = [TTSTYLESHEET styleWithSelector:className
                                       forState:UIControlStateHighlighted];
        [self setStyle:style forFrame:frame];

        [_highlightedFrame release];
        _highlightedFrame = [frame retain];
        [_highlightedNode release];
        _highlightedNode = [frame.element retain];
        tableView.highlightedLabel = self;

      } else {
        TTStyle* style = [TTSTYLESHEET styleWithSelector:className forState:UIControlStateNormal];
        [self setStyle:style forFrame:_highlightedFrame];

        TT_RELEASE_SAFELY(_highlightedFrame);
        TT_RELEASE_SAFELY(_highlightedNode);
        tableView.highlightedLabel = nil;
      }

      [self setNeedsDisplay];
    }
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSString*)combineTextFromFrame:(TTStyledTextFrame*)fromFrame
                          toFrame:(TTStyledTextFrame*)toFrame {
  NSMutableArray* strings = [NSMutableArray array];
  for (TTStyledTextFrame* frame = fromFrame; frame && frame != toFrame;
       frame = (TTStyledTextFrame*)frame.nextFrame) {
    [strings addObject:frame.text];
  }
  return [strings componentsJoinedByString:@""];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)addAccessibilityElementFromFrame:(TTStyledTextFrame*)fromFrame
        toFrame:(TTStyledTextFrame*)toFrame withEdges:(UIEdgeInsets)edges {
  CGRect rect = CGRectMake(edges.left, edges.top,
                           edges.right-edges.left, edges.bottom-edges.top);

  UIAccessibilityElement* acc = [[[UIAccessibilityElement alloc]
                                initWithAccessibilityContainer:self] autorelease];
  acc.accessibilityFrame = CGRectOffset(rect, self.screenViewX, self.screenViewY);
  acc.accessibilityTraits = UIAccessibilityTraitStaticText;
  if (fromFrame == toFrame) {
    acc.accessibilityLabel = fromFrame.text;

  } else {
    acc.accessibilityLabel = [self combineTextFromFrame:fromFrame toFrame:toFrame];
  }
  [_accessibilityElements addObject:acc];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (UIEdgeInsets)edgesForRect:(CGRect)rect {
  return UIEdgeInsetsMake(rect.origin.y, rect.origin.x,
                          rect.origin.y+rect.size.height,
                          rect.origin.x+rect.size.width);
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)addAccessibilityElementsForNode:(TTStyledNode*)node {
  if ([node isKindOfClass:[TTStyledLinkNode class]]) {
    UIAccessibilityElement* acc = [[[UIAccessibilityElement alloc]
                                  initWithAccessibilityContainer:self] autorelease];
    TTStyledFrame* frame = [_text getFrameForNode:node];
    acc.accessibilityFrame = CGRectOffset(frame.bounds, self.screenViewX, self.screenViewY);
    acc.accessibilityTraits = UIAccessibilityTraitLink;
    acc.accessibilityLabel = [node outerText];
    [_accessibilityElements addObject:acc];

  } else if ([node isKindOfClass:[TTStyledTextNode class]]) {
    TTStyledTextFrame* startFrame = (TTStyledTextFrame*)[_text getFrameForNode:node];
    UIEdgeInsets edges = [self edgesForRect:startFrame.bounds];

    TTStyledTextFrame* frame = (TTStyledTextFrame*)startFrame.nextFrame;
    for (;
         [frame isKindOfClass:[TTStyledTextFrame class]];
         frame = (TTStyledTextFrame*)frame.nextFrame) {
      if (frame.bounds.origin.x < edges.left) {
        [self addAccessibilityElementFromFrame:startFrame toFrame:frame withEdges:edges];
        edges = [self edgesForRect:frame.bounds];
        startFrame = frame;

      } else {
        if (frame.bounds.origin.x+frame.bounds.size.width > edges.right) {
          edges.right = frame.bounds.origin.x+frame.bounds.size.width;
        }
        if (frame.bounds.origin.y+frame.bounds.size.height > edges.bottom) {
          edges.bottom = frame.bounds.origin.y+frame.bounds.size.height;
        }
      }
    }

    if (frame != startFrame) {
      [self addAccessibilityElementFromFrame:startFrame toFrame:frame withEdges:edges];
    }

  } else if ([node isKindOfClass:[TTStyledElement class]]) {
    TTStyledElement* element = (TTStyledElement*)node;
    for (TTStyledNode* child = element.firstChild; child; child = child.nextSibling) {
      [self addAccessibilityElementsForNode:child];
    }
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSMutableArray*)accessibilityElements {
  if (!_accessibilityElements) {
    _accessibilityElements = [[NSMutableArray alloc] init];
    [self addAccessibilityElementsForNode:_text.rootNode];
  }
  return _accessibilityElements;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark UIResponder

/*
///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)canBecomeFirstResponder {
  return YES;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)becomeFirstResponder {
  BOOL became = [super becomeFirstResponder];

  UIMenuController* menu = [UIMenuController sharedMenuController];
  [menu setTargetRect:self.frame inView:self.superview];
  [menu setMenuVisible:YES animated:YES];

  self.highlighted = YES;
  return became;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)resignFirstResponder {
  self.highlighted = NO;
  BOOL resigned = [super resignFirstResponder];
  [[UIMenuController sharedMenuController] setMenuVisible:NO];
  return resigned;
}
*/


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)touchesBegan:(NSSet*)touches withEvent:(UIEvent*)event {
  UITouch* touch = [touches anyObject];
  CGPoint point = [touch locationInView:self];
  point.x -= _contentInset.left;
  point.y -= _contentInset.top;

  TTStyledBoxFrame* frame = [_text hitTest:point];
  if (frame) {
    [self setHighlightedFrame:frame];
  }

  //[self performSelector:@selector(becomeFirstResponder) withObject:nil afterDelay:0.5];

  [super touchesBegan:touches withEvent:event];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)touchesMoved:(NSSet*)touches withEvent:(UIEvent*)event {
  [super touchesMoved:touches withEvent:event];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)touchesEnded:(NSSet*)touches withEvent:(UIEvent*)event {
  TTTableView* tableView = (TTTableView*)[self ancestorOrSelfWithClass:[TTTableView class]];
  if (!tableView) {
    if (_highlightedNode) {
      // This is a dirty hack to decouple the UI from Style. TTOpenURL was originally within
      // the node implementation. One potential fix would be to provide some protocol for these
      // nodes to converse with.
      if ([_highlightedNode isKindOfClass:[TTStyledLinkNode class]]) {
        TTOpenURL([(TTStyledLinkNode*)_highlightedNode URL]);

      } else if ([_highlightedNode isKindOfClass:[TTStyledButtonNode class]]) {
        TTOpenURL([(TTStyledButtonNode*)_highlightedNode URL]);

      } else {
        [_highlightedNode performDefaultAction];
      }
      [self setHighlightedFrame:nil];
    }
  }

  // We definitely don't want to call this if the label is inside a TTTableView, because
  // it winds up calling touchesEnded on the table twice, triggering the link twice
  [super touchesEnded:touches withEvent:event];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)touchesCancelled:(NSSet*)touches withEvent:(UIEvent*)event {
  [super touchesCancelled:touches withEvent:event];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark UIView


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)drawRect:(CGRect)rect {
  if (_highlighted) {
    [self.highlightedTextColor setFill];

  } else {
    [self.textColor setFill];
  }

  CGPoint origin = CGPointMake(rect.origin.x + _contentInset.left,
                               rect.origin.y + _contentInset.top);
  [_text drawAtPoint:origin highlighted:_highlighted];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)layoutSubviews {
  [super layoutSubviews];
  CGFloat newWidth = self.width - (_contentInset.left + _contentInset.right);
  if (newWidth != _text.width) {
    // Remove the highlighted node+frame when resizing the text
    self.highlightedNode = nil;
  }

  _text.width = newWidth;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (CGSize)sizeThatFits:(CGSize)size {
  [self layoutIfNeeded];
  return CGSizeMake(_text.width + (_contentInset.left + _contentInset.right),
                    _text.height+ (_contentInset.top + _contentInset.bottom));
}


///////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark UIAccessibilityContainer


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)accessibilityElementAtIndex:(NSInteger)elementIndex {
  return [[self accessibilityElements] objectAtIndex:elementIndex];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSInteger)accessibilityElementCount {
  return [self accessibilityElements].count;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSInteger)indexOfAccessibilityElement:(id)element {
  return [[self accessibilityElements] indexOfObject:element];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark UIResponderStandardEditActions


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)copy:(id)sender {
  NSString* text = _text.rootNode.outerText;
  UIPasteboard* pasteboard = [UIPasteboard generalPasteboard];
  [pasteboard setValue:text forPasteboardType:@"public.utf8-plain-text"];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark TTStyledTextDelegate


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)styledTextNeedsDisplay:(TTStyledText*)text {
  [self setNeedsDisplay];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Public


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setText:(TTStyledText*)text {
  if (text != _text) {
    _text.delegate = nil;
    [_text release];
    TT_RELEASE_SAFELY(_accessibilityElements);
    _text = [text retain];
    _text.delegate = self;
    _text.font = _font;
    [self setNeedsLayout];
    [self setNeedsDisplay];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSString*)html {
  return [_text description];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setHtml:(NSString*)html {
  self.text = [TTStyledText textFromXHTML:html];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setFont:(UIFont*)font {
  if (font != _font) {
    [_font release];
    _font = [font retain];
    _text.font = _font;
    [self setNeedsLayout];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (UIColor*)textColor {
  if (!_textColor) {
    _textColor = [TTSTYLEVAR(textColor) retain];
  }
  return _textColor;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setTextColor:(UIColor*)textColor {
  if (textColor != _textColor) {
    [_textColor release];
    _textColor = [textColor retain];
    [self setNeedsDisplay];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (UIColor*)highlightedTextColor {
  if (!_highlightedTextColor) {
    _highlightedTextColor = [TTSTYLEVAR(highlightedTextColor) retain];
  }
  return _highlightedTextColor;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setHighlightedNode:(TTStyledElement*)node {
  if (node != _highlightedNode) {
    if (!node) {
      [self setHighlightedFrame:nil];

    } else {
      [_highlightedNode release];
      _highlightedNode = [node retain];
    }
  }
}


@end
