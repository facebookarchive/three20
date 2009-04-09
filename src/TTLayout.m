#import "Three20/TTLayout.h"

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation TTLayout

///////////////////////////////////////////////////////////////////////////////////////////////////
// public

- (CGSize)layoutSubviews:(NSArray*)subviews forView:(UIView*)view {
  return CGSizeZero;
}

@end

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation TTFlowLayout

@synthesize padding = _padding, spacing = _spacing;

///////////////////////////////////////////////////////////////////////////////////////////////////
// NSObject

- (id)init {
  if (self = [super init]) {
    _padding = 0;
    _spacing = 0;
  }
  return self;
}

- (void)dealloc {
  [super dealloc];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// public

- (CGSize)layoutSubviews:(NSArray*)subviews forView:(UIView*)view {
  CGFloat x = _padding, y = _padding;
  CGFloat maxX = 0, lastHeight = 0;
  CGFloat maxWidth = view.width - _padding*2;
  for (UIView* subview in subviews) {
    if (x + subview.width > maxWidth) {
      x = _padding;
      y += subview.height + _spacing;
    }
    subview.left = x;
    subview.top = y;
    x += subview.width + _spacing;
    if (x > maxX) {
      maxX = x;
    }
    lastHeight = subview.height;
  }
  
  return CGSizeMake(maxX+_padding, y+lastHeight+_padding);
}

@end

