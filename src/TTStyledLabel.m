#import "Three20/TTStyledLabel.h"
#import "Three20/TTStyledTextNode.h"
#import "Three20/TTStyledText.h"
#import "Three20/TTAppearance.h"
#import "Three20/TTNavigationCenter.h"
#import "Three20/TTTableViewController.h"
#import "Three20/TTTableViewDelegate.h"

///////////////////////////////////////////////////////////////////////////////////////////////////
// global

static const CGFloat kCancelHighlightThreshold = 4;

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation TTStyledLabel

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
    
    self.font = [UIFont systemFontOfSize:14];
    self.textColor = [UIColor blackColor];
    self.highlightedTextColor = [UIColor whiteColor];
    self.backgroundColor = [UIColor whiteColor];
    self.opaque = YES;
  }
  return self;
}

- (void)dealloc {
  [_text release];
  [_font release];
  [_textColor release];
  [_highlightedTextColor release];
  [_highlightedNode release];
  [super dealloc];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// UIView

- (void)drawRect:(CGRect)rect {
  if (_highlighted) {
    [_highlightedTextColor setFill];
  } else {
    [_textColor setFill];
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
  //_text.width = size.width + (_contentInset.left + _contentInset.right);
  return CGSizeMake(_text.width + (_contentInset.left + _contentInset.right),
                    _text.height+ (_contentInset.top + _contentInset.bottom));
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// UIResponder

- (void)touchesBegan:(NSSet*)touches withEvent:(UIEvent*)event {
  UITouch* touch = [touches anyObject];
  CGPoint point = [touch locationInView:self];
  point.x -= _contentInset.left;
  point.y -= _contentInset.top;
  
  TTStyledTextFrame* frame = [_text hitTest:point];
  if (frame && [frame.node isKindOfClass:[TTStyledLinkNode class]]) {
    self.highlightedNode = (TTStyledLinkNode*)frame.node;
    
    TTStyledTextTableView* tableView
      = (TTStyledTextTableView*)[self firstParentOfClass:[TTStyledTextTableView class]];
    if (tableView) {
      tableView.highlightedLabel = self;
    }
  }
}

- (void)touchesEnded:(NSSet*)touches withEvent:(UIEvent*)event {
  if (_highlightedNode) {
    [[TTNavigationCenter defaultCenter] displayURL:_highlightedNode.url];
    
    self.highlightedNode = nil;

    TTStyledTextTableView* tableView
      = (TTStyledTextTableView*)[self firstParentOfClass:[TTStyledTextTableView class]];
    if (tableView) {
      tableView.highlightedLabel = nil;
    }
  }
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// public

- (void)setText:(TTStyledText*)text {
  if (text != _text) {
    [_text release];
    _text = [text retain];
    _text.font = _font;
    [self setNeedsDisplay];
  }
}

- (void)setFont:(UIFont*)font {
  if (font != _font) {
    [_font release];
    _font = [font retain];
    _text.font = _font;
    [self setNeedsDisplay];
  }
}

- (void)setTextColor:(UIColor*)textColor {
  if (textColor != _textColor) {
    [_textColor release];
    _textColor = [textColor retain];
    [self setNeedsDisplay];
  }
}

- (void)setHighlightedNode:(TTStyledLinkNode*)highlightedNode {
  if (highlightedNode != _highlightedNode) {
    _highlightedNode.highlighted = NO;
    [_highlightedNode release];
    _highlightedNode = [highlightedNode retain];
    _highlightedNode.highlighted = YES;
    [self setNeedsDisplay];
  }
}

@end

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation TTStyledTextTableView

@synthesize highlightedLabel = _highlightedLabel;

///////////////////////////////////////////////////////////////////////////////////////////////////
// NSObject

- (id)initWithFrame:(CGRect)frame style:(UITableViewStyle)style {
  if (self = [super initWithFrame:frame style:style]) {
    _highlightedLabel = nil;
    _highlightStartPoint = CGPointZero;
    _highlightTimer = nil;
    self.delaysContentTouches = NO;
  }
  return self;
}

- (void)dealloc {
  [_highlightedLabel release];
  [_highlightTimer invalidate];
  [super dealloc];
}

- (void)delayedTouchesEnded:(NSTimer*)timer {
  _highlightTimer = nil;
  
  self.highlightedLabel = nil;
  
  NSString* url = timer.userInfo;
  [[TTNavigationCenter defaultCenter] displayURL:url];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// UIResponder

- (void)touchesBegan:(NSSet*)touches withEvent:(UIEvent*)event {
  [super touchesBegan:touches withEvent:event];

  [_highlightTimer invalidate];
  _highlightTimer = nil;
  
  if (_highlightedLabel) {
    UITouch* touch = [touches anyObject];
    _highlightStartPoint = [touch locationInView:self];
  }
  
  if ([self.delegate isKindOfClass:[TTTableViewDelegate class]]) {
    TTTableViewDelegate* delegate = (TTTableViewDelegate*)self.delegate;
    [delegate.controller touchesBegan:touches withEvent:event];
  }
}

- (void)touchesMoved:(NSSet*)touches withEvent:(UIEvent*)event {
  [super touchesMoved:touches withEvent:event];

  if (_highlightedLabel) {
    UITouch* touch = [touches anyObject];
    CGPoint newPoint = [touch locationInView:self];
    CGFloat dx = newPoint.x - _highlightStartPoint.x;
    CGFloat dy = newPoint.y - _highlightStartPoint.y;
    CGFloat d = sqrt((dx*dx) + (dy+dy));
    if (d > kCancelHighlightThreshold) {
      _highlightedLabel.highlightedNode = nil;
      self.highlightedLabel = nil;
    }
  }
}

- (void)touchesEnded:(NSSet*)touches withEvent:(UIEvent*)event {
  if (_highlightedLabel) {
    NSString* url = _highlightedLabel.highlightedNode.url;
    _highlightedLabel.highlightedNode = nil;

    _highlightTimer = [NSTimer scheduledTimerWithTimeInterval:0.2 target:self
             selector:@selector(delayedTouchesEnded:) userInfo:url repeats:NO];
  } else {
    [super touchesEnded:touches withEvent:event];

    if ([self.delegate isKindOfClass:[TTTableViewDelegate class]]) {
      TTTableViewDelegate* delegate = (TTTableViewDelegate*)self.delegate;
      [delegate.controller touchesEnded:touches withEvent:event];
    }
  }
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// UITableView

- (void)selectRowAtIndexPath:(NSIndexPath *)indexPath animated:(BOOL)animated
        scrollPosition:(UITableViewScrollPosition)scrollPosition {
  if (!_highlightedLabel) {
    [super selectRowAtIndexPath:indexPath animated:animated scrollPosition:scrollPosition];
  }
}

@end
