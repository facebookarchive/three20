#import "Three20/T3Global.h"

typedef enum {
  T3BackgroundNone,
  T3BackgroundRoundedRect,
  T3BackgroundRoundedMask,
  T3BackgroundInnerShadow,
  T3BackgroundStrokeTop,
  T3BackgroundStrokeRight,
  T3BackgroundStrokeBottom,
  T3BackgroundStrokeLeft
} T3Background;

@interface T3Appearance : NSObject {
  UIColor* _linkTextColor;
}

+ (T3Appearance*)appearance;
+ (void)setAppearance:(T3Appearance*)appearance;

@property(nonatomic,retain) UIColor* linkTextColor;

- (void)drawBackground:(T3Background)background rect:(CGRect)rect fill:(UIColor**)fillColor
  fillCount:(int)fillCount stroke:(UIColor*)strokeColor radius:(CGFloat)radius;

- (void)drawBackground:(T3Background)background rect:(CGRect)rect;

- (void)drawLine:(CGPoint)from to:(CGPoint)to color:(UIColor*)color;

- (void)fill:(CGRect)rect fillColors:(UIColor**)fillColors count:(int)count;

- (void)stroke:(UIColor*)strokeColor;

@end
