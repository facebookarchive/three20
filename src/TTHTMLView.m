#import "Three20/TTHTMLView.h"
#import "Three20/TTHTMLNode.h"
#import "Three20/TTHTMLLayout.h"
#import "Three20/TTAppearance.h"

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation TTHTMLView

@synthesize html = _html, font = _font, textColor = _textColor, linkTextColor = _linkTextColor,
            highlightedTextColor = _highlightedTextColor, highlighted = _highlighted;

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
    _html = nil;
    _layout = nil;
    _highlighted = NO;
    _highlightedNode = nil;
    
    self.font = [UIFont systemFontOfSize:14];
    self.textColor = [UIColor blackColor];
    self.highlightedTextColor = [UIColor whiteColor];
    self.linkTextColor = [TTAppearance appearance].linkTextColor;
    self.backgroundColor = [UIColor whiteColor];
    self.opaque = YES;
  }
  return self;
}

- (void)dealloc {
  [_html release];
  [_layout release];
  [_font release];
  [_textColor release];
  [_linkTextColor release];
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
  
  [self.layout drawAtPoint:rect.origin highlighted:_highlighted];
}

- (void)layoutSubviews {
  [super layoutSubviews];
  self.layout.width = self.width;
}

- (CGSize)sizeThatFits:(CGSize)size {
  return CGSizeMake(floor(self.layout.width), floor(self.layout.height));
}

- (void)touchesBegan:(NSSet*)touches withEvent:(UIEvent*)event {
  UITouch* touch = [touches anyObject];
  CGPoint point = [touch locationInView:self];
  TTHTMLFrame* frame = [self.layout hitTest:point];
  if (frame && [frame.node isKindOfClass:[TTHTMLLinkNode class]]) {
    [_highlightedNode release];
    _highlightedNode = [(TTHTMLLinkNode*)frame.node retain];
    _highlightedNode.highlighted = YES;
    
    TTHTMLTableView* tableView
      = (TTHTMLTableView*)[self firstParentOfClass:[TTHTMLTableView class]];
    if (tableView) {
      tableView.scrollEnabled = NO;
    }
    
    [self setNeedsDisplay];
  }
}

- (void)touchesEnded:(NSSet*)touches withEvent:(UIEvent*)event {
  if (_highlightedNode) {
    _highlightedNode.highlighted = NO;
    [_highlightedNode release];
    _highlightedNode = nil;

    TTHTMLTableView* tableView
      = (TTHTMLTableView*)[self firstParentOfClass:[TTHTMLTableView class]];
    if (tableView) {
      tableView.scrollEnabled = YES;
    }

    [self setNeedsDisplay];
  }
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// public

- (void)setHTML:(TTHTMLNode*)html {
  if (html != _html) {
    [_html release];
    _html = [html retain];
    [_layout release];
    _layout = nil;
    
    [self setNeedsDisplay];
  }
}

- (TTHTMLLayout*)layout {
  if (!_layout && _html) {
    _layout = [[TTHTMLLayout alloc] initWithHTML:_html];
    _layout.font = _font;
  }
  return _layout;
}

- (void)setLayout:(TTHTMLLayout*)layout {
  if (layout != _layout) {
    [_layout release];
    _layout = [layout retain];
    if (_html != layout.html) {
      [_html release];
      _html = [layout.html retain];
    }
    [self setNeedsDisplay];
  }
}

@end

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation TTHTMLTableView

///////////////////////////////////////////////////////////////////////////////////////////////////
// UIView

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
  for (UITableViewCell* cell in self.visibleCells) {
    CGPoint cellPoint = [self convertPoint:point toView:cell];
    if ([cell pointInside:cellPoint withEvent:event]) {
      UIView* hitView = [cell hitTest:cellPoint withEvent:event];
      if ([hitView isKindOfClass:[TTHTMLView class]]) {
        TTHTMLView* htmlView = (TTHTMLView*)hitView;
        CGPoint htmlPoint = [cell convertPoint:cellPoint toView:htmlView];
        TTHTMLFrame* frame = [htmlView.layout hitTest:htmlPoint];
        if ([frame.node isKindOfClass:[TTHTMLLinkNode class]]) {
          return htmlView;
        }
      }
    }
  }
  return [super hitTest:point withEvent:event];
}

@end
