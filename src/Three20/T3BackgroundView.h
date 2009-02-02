#import "Three20/T3Global.h"

typedef enum {
  T3BackgroundNone,
  T3BackgroundGrayBar,
  T3BackgroundInnerShadow,
  T3BackgroundRoundedRect,
  T3BackgroundPointedRect,
  T3BackgroundRoundedMask,
  T3BackgroundStrokeTop,
  T3BackgroundStrokeRight,
  T3BackgroundStrokeBottom,
  T3BackgroundStrokeLeft
} T3Background;

/**
 * A decorational view that can painted using a variety of visual properties.
 */
@interface T3BackgroundView : UIView {
  T3Background _background;
  UIColor* _fillColor;
  UIColor* _fillColor2;
  UIColor* _strokeColor;
  int _strokeRadius;
}

@property(nonatomic) T3Background background;
@property(nonatomic,retain) UIColor* fillColor;
@property(nonatomic,retain) UIColor* fillColor2;
@property(nonatomic,retain) UIColor* strokeColor;
@property(nonatomic) int strokeRadius;

@end
