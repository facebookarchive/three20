#import "Three20/TTStyledTextLabel.h"
#import "Three20/TTStyledNode.h"
#import "Three20/TTStyledFrame.h"
#import "Three20/TTStyledText.h"
#import "Three20/TTDefaultStyleSheet.h"
#import "Three20/TTTableView.h"

///////////////////////////////////////////////////////////////////////////////////////////////////
// global

static const CGFloat kCancelHighlightThreshold = 4;

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation TTStyledTextLabel

@synthesize text = _text, font = _font, textColor = _textColor,
            highlightedTextColor = _highlightedTextColor, textAlignment = _textAlignment,
            contentInset = _contentInset, highlighted = _highlighted,
            highlightedNode = _highlightedNode;

///////////////////////////////////////////////////////////////////////////////////////////////////
// private

// UITableView looks for this function and crashes if it is not found when you select a cell
- (BOOL)isHighlighted {
  return _highlighted;
}

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
// NSObject

- (id)initWithFrame:(CGRect)frame {
  if (self = [super initWithFrame:frame]) {
    _text = nil;
    _font = nil;
    _textColor = nil;
    _highlightedTextColor = nil;
    _textAlignment = UITextAlignmentLeft;
    _contentInset = UIEdgeInsetsZero;
    _highlighted = NO;
    _highlightedNode = nil;
    _highlightedFrame = nil;
    
    self.font = TTSTYLEVAR(font);
    self.backgroundColor = TTSTYLEVAR(backgroundColor);
    self.contentMode = UIViewContentModeRedraw;
  }
  return self;
}

- (void)dealloc {
  _text.delegate = nil;
  TT_RELEASE_SAFELY(_text);
  TT_RELEASE_SAFELY(_font);
  TT_RELEASE_SAFELY(_textColor);
  TT_RELEASE_SAFELY(_highlightedTextColor);
  TT_RELEASE_SAFELY(_highlightedNode);
  TT_RELEASE_SAFELY(_highlightedFrame);
  [super dealloc];
}

//////////////////////////////////////////////////////////////////////////////////////////////////
// UIResponder

/*
- (BOOL)canBecomeFirstResponder {
  return YES;
}

- (BOOL)becomeFirstResponder {
  BOOL became = [super becomeFirstResponder];

  UIMenuController* menu = [UIMenuController sharedMenuController];
  [menu setTargetRect:self.frame inView:self.superview];
  [menu setMenuVisible:YES animated:YES];

  self.highlighted = YES;
  return became;
}

- (BOOL)resignFirstResponder {
  self.highlighted = NO;
  BOOL resigned = [super resignFirstResponder];
  [[UIMenuController sharedMenuController] setMenuVisible:NO];
  return resigned;
}
*/

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

- (void)touchesMoved:(NSSet*)touches withEvent:(UIEvent*)event {
  [super touchesMoved:touches withEvent:event];
}

- (void)touchesEnded:(NSSet*)touches withEvent:(UIEvent*)event {
  TTTableView* tableView = (TTTableView*)[self ancestorOrSelfWithClass:[TTTableView class]];
  if (!tableView) {
    if (_highlightedNode) {
      [_highlightedNode performDefaultAction];    
      [self setHighlightedFrame:nil];
    }
  }

  // We definitely don't want to call this if the label is inside a TTTableView, because
  // it winds up calling touchesEnded on the table twice, triggering the link twice
  [super touchesEnded:touches withEvent:event];
}

- (void)touchesCancelled:(NSSet*)touches withEvent:(UIEvent*)event {
  [super touchesCancelled:touches withEvent:event];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// UIView

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

- (void)layoutSubviews {
  [super layoutSubviews];
  _text.width = self.width - (_contentInset.left + _contentInset.right);
}

- (CGSize)sizeThatFits:(CGSize)size {
  [self layoutIfNeeded];
  return CGSizeMake(_text.width + (_contentInset.left + _contentInset.right),
                    _text.height+ (_contentInset.top + _contentInset.bottom));
}

//////////////////////////////////////////////////////////////////////////////////////////////////
// UIResponderStandardEditActions

- (void)copy:(id)sender {
  NSString* text = _text.rootNode.outerText;
  UIPasteboard* pasteboard = [UIPasteboard generalPasteboard];
  [pasteboard setValue:text forPasteboardType:@"public.utf8-plain-text"];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// TTStyledTextDelegate

- (void)styledTextNeedsDisplay:(TTStyledText*)text {
  [self setNeedsDisplay];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// public

- (void)setText:(TTStyledText*)text {
  if (text != _text) {
    _text.delegate = nil;
    [_text release];
    _text = [text retain];
    _text.delegate = self;
    _text.font = _font;
    [self setNeedsLayout];
    [self setNeedsDisplay];
  }
}

- (NSString*)html {
  return [_text description];
}

- (void)setHtml:(NSString*)html {
  self.text = [TTStyledText textFromXHTML:html];
}

- (void)setFont:(UIFont*)font {
  if (font != _font) {
    [_font release];
    _font = [font retain];
    _text.font = _font;
    [self setNeedsLayout];
  }
}

- (UIColor*)textColor {
  if (!_textColor) {
    _textColor = [TTSTYLEVAR(textColor) retain];
  }
  return _textColor;
}

- (void)setTextColor:(UIColor*)textColor {
  if (textColor != _textColor) {
    [_textColor release];
    _textColor = [textColor retain];
    [self setNeedsDisplay];
  }
}

- (UIColor*)highlightedTextColor {
  if (!_highlightedTextColor) {
    _highlightedTextColor = [TTSTYLEVAR(highlightedTextColor) retain];
  }
  return _highlightedTextColor;
}

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
