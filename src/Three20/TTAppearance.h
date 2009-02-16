#import "Three20/TTGlobal.h"

typedef enum {
  TTDrawStyleNone,
  TTDrawFillRect,
  TTDrawFillRectInverted,
  TTDrawInnerShadow,
  TTDrawStrokeTop,
  TTDrawStrokeRight,
  TTDrawStrokeBottom,
  TTDrawStrokeLeft
} TTDrawStyle;

#define TT_RADIUS_ROUNDED NSUIntegerMax

@interface TTAppearance : NSObject {
  UIColor* _navigationBarTintColor;
  UIColor* _barTintColor;
  UIColor* _linkTextColor;
  UIColor* _searchTableBackgroundColor;
  UIColor* _searchTableSeparatorColor;
}

+ (TTAppearance*)appearance;
+ (void)setAppearance:(TTAppearance*)appearance;

@property(nonatomic,retain) UIColor* navigationBarTintColor;
@property(nonatomic,retain) UIColor* barTintColor;

@property(nonatomic,retain) UIColor* linkTextColor;

@property(nonatomic,retain) UIColor* searchTableBackgroundColor;
@property(nonatomic,retain) UIColor* searchTableSeparatorColor;

- (void)draw:(TTDrawStyle)background rect:(CGRect)rect fill:(UIColor**)fillColor
  fillCount:(int)fillCount stroke:(UIColor*)strokeColor radius:(CGFloat)radius;

- (void)draw:(TTDrawStyle)background rect:(CGRect)rect;

- (void)drawLine:(CGPoint)from to:(CGPoint)to color:(UIColor*)color;

- (void)fill:(CGRect)rect fillColors:(UIColor**)fillColors count:(int)count;

- (void)stroke:(UIColor*)strokeColor;

@end
