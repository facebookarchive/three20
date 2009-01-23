#import "Three20/T3Painter.h"

/**
 * A decorational view that can painted using a variety of visual properties.
 */
@interface T3PaintedView : UIView {
  T3Background background;
  UIColor* fillColor;
  UIColor* strokeColor;
  int strokeRadius;
}

@property(nonatomic) T3Background background;
@property(nonatomic, retain) UIColor* fillColor;
@property(nonatomic, retain) UIColor* strokeColor;
@property(nonatomic) int strokeRadius;

@end
