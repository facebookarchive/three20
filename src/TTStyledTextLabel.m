#import "Three20/TTStyledTextLabel.h"
#import "Three20/TTStyledNode.h"
#import "Three20/TTStyledFrame.h"
#import "Three20/TTStyledText.h"
#import "Three20/TTDefaultStyleSheet.h"
#import "Three20/TTNavigationCenter.h"
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
    
    self.font = TTSTYLEVAR(font);
    self.backgroundColor = TTSTYLEVAR(backgroundColor);
    self.contentMode = UIViewContentModeRedraw;
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
  
  TTStyledFrame* frame = [_text hitTest:point];
  if (frame) {
    TTStyledLinkNode* linkNode = [frame.element firstParentOfClass:[TTStyledLinkNode class]];
    if (linkNode) {
      self.highlightedNode = linkNode;
      
      TTTableView* tableView = (TTTableView*)[self firstParentOfClass:[TTTableView class]];
      if (tableView) {
        tableView.highlightedLabel = self;
      }
    }
  }
}

- (void)touchesEnded:(NSSet*)touches withEvent:(UIEvent*)event {
  if (_highlightedNode) {
    [[TTNavigationCenter defaultCenter] displayURL:_highlightedNode.url];
    
    self.highlightedNode = nil;

    TTTableView* tableView = (TTTableView*)[self firstParentOfClass:[TTTableView class]];
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

- (UIColor*)textColor {
  if (!_textColor) {
    _textColor = TTSTYLEVAR(textColor);
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
    _highlightedTextColor = TTSTYLEVAR(highlightedTextColor);
  }
  return _highlightedTextColor;
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
