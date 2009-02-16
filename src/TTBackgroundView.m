#import "Three20/TTBackgroundView.h"

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation TTBackgroundView

@synthesize background = _background, fillColor = _fillColor, fillColor2 = _fillColor2,
  strokeColor = _strokeColor, strokeRadius = _strokeRadius;

///////////////////////////////////////////////////////////////////////////////////////////////////

- (id)initWithFrame:(CGRect)frame {
  if (self = [super initWithFrame:frame]) {
    _background = 0;
    _fillColor = nil;
    _fillColor2 = nil;
    _strokeColor = nil;
    _strokeRadius = 0;
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
  if (_background) {
    if (_fillColor2 && _fillColor) {
      UIColor* fillColors[] = {_fillColor, _fillColor2};
      [[TTAppearance appearance] drawBackground:_background rect:rect fill:fillColors fillCount:2
        stroke:_strokeColor radius:_strokeRadius];
    } else if (_fillColor) {
      [[TTAppearance appearance] drawBackground:_background rect:rect fill:&_fillColor fillCount:1
        stroke:_strokeColor radius:_strokeRadius];
    } else {
      [[TTAppearance appearance] drawBackground:_background rect:rect fill:nil fillCount:0
        stroke:_strokeColor radius:_strokeRadius];
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

