#import "Three20/TTBackgroundView.h"

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation TTBackgroundView

@synthesize style = _style, fillColor = _fillColor, fillColor2 = _fillColor2,
  strokeColor = _strokeColor, borderRadius = _borderRadius, backgroundInset = _backgroundInset;

///////////////////////////////////////////////////////////////////////////////////////////////////

- (id)initWithFrame:(CGRect)frame {
  if (self = [super initWithFrame:frame]) {
    _style = TTDrawStyleNone;
    _fillColor = nil;
    _fillColor2 = nil;
    _strokeColor = nil;
    _borderRadius = 0;
    _backgroundInset = UIEdgeInsetsZero;
    self.contentMode = UIViewContentModeRedraw;
  }
  return self;
}

- (void)dealloc {
  [_fillColor release];
  [_fillColor2 release];
  [_strokeColor release];
  [super dealloc];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// UIView

- (void)drawRect:(CGRect)rect {
  if (_style) {
    CGRect frame = CGRectMake(rect.origin.x + _backgroundInset.left,
      rect.origin.y + _backgroundInset.top,
      rect.size.width - (_backgroundInset.left + _backgroundInset.right),
      rect.size.height - (_backgroundInset.top + _backgroundInset.bottom));

    if (_fillColor2 && _fillColor) {
      UIColor* fillColors[] = {_fillColor, _fillColor2};
      [[TTAppearance appearance] draw:_style rect:frame fill:fillColors fillCount:2
        stroke:_strokeColor radius:_borderRadius];
    } else if (_fillColor) {
      [[TTAppearance appearance] draw:_style rect:frame fill:&_fillColor fillCount:1
        stroke:_strokeColor radius:_borderRadius];
    } else {
      [[TTAppearance appearance] draw:_style rect:frame fill:nil fillCount:0
        stroke:_strokeColor radius:_borderRadius];
    }
  }
}

///////////////////////////////////////////////////////////////////////////////////////////////////

- (void)setFillColor:(UIColor*)color {
  [_fillColor release];
  _fillColor = [color retain];
  
  [self setNeedsDisplay];
}

@end

