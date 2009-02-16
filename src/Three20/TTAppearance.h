#import "Three20/TTGlobal.h"

typedef enum {
  TTBackgroundNone,
  TTBackgroundRoundedRect,
  TTBackgroundRoundedMask,
  TTBackgroundInnerShadow,
  TTBackgroundStrokeTop,
  TTBackgroundStrokeRight,
  TTBackgroundStrokeBottom,
  TTBackgroundStrokeLeft
} TTBackground;

#define TT_RADIUS_ROUNDED NSUIntegerMax

@interface TTAppearance : NSObject {
  UIColor* _navigationBarTintColor;
  UIColor* _linkTextColor;
  UIColor* _searchTableBackgroundColor;
  UIColor* _searchTableSeparatorColor;
}

+ (TTAppearance*)appearance;
+ (void)setAppearance:(TTAppearance*)appearance;

@property(nonatomic,retain) UIColor* navigationBarTintColor;

@property(nonatomic,retain) UIColor* linkTextColor;

@property(nonatomic,retain) UIColor* searchTableBackgroundColor;
@property(nonatomic,retain) UIColor* searchTableSeparatorColor;

- (void)drawBackground:(TTBackground)background rect:(CGRect)rect fill:(UIColor**)fillColor
  fillCount:(int)fillCount stroke:(UIColor*)strokeColor radius:(CGFloat)radius;

- (void)drawBackground:(TTBackground)background rect:(CGRect)rect;

- (void)drawLine:(CGPoint)from to:(CGPoint)to color:(UIColor*)color;

- (void)fill:(CGRect)rect fillColors:(UIColor**)fillColors count:(int)count;

- (void)stroke:(UIColor*)strokeColor;

@end
