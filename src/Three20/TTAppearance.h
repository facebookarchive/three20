#import "Three20/TTGlobal.h"

typedef enum {
  TTDrawStyleNone,
  TTDrawFillRect,
  TTDrawFillRectInverted,
  TTDrawReflection,
  TTDrawInnerShadow,
  TTDrawRoundInnerShadow,
  TTDrawStrokeTop,
  TTDrawStrokeRight,
  TTDrawStrokeBottom,
  TTDrawStrokeLeft
} TTDrawStyle;

#define TT_RADIUS_ROUNDED NSIntegerMax

@interface TTAppearance : NSObject {
  UIColor* _navigationBarTintColor;
  UIColor* _barTintColor;
  UIColor* _linkTextColor;
  UIColor* _searchTableBackgroundColor;
  UIColor* _searchTableSeparatorColor;
  UIColor* _tableHeaderTextColor;
  UIColor* _tableHeaderShadowColor;
  UIColor* _tableHeaderTintColor;
}

+ (TTAppearance*)appearance;
+ (void)setAppearance:(TTAppearance*)appearance;

@property(nonatomic,retain) UIColor* navigationBarTintColor;
@property(nonatomic,retain) UIColor* barTintColor;

@property(nonatomic,retain) UIColor* linkTextColor;

@property(nonatomic,retain) UIColor* searchTableBackgroundColor;
@property(nonatomic,retain) UIColor* searchTableSeparatorColor;

@property(nonatomic,retain) UIColor* tableHeaderTextColor;
@property(nonatomic,retain) UIColor* tableHeaderShadowColor;
@property(nonatomic,retain) UIColor* tableHeaderTintColor;

- (void)draw:(TTDrawStyle)background rect:(CGRect)rect fill:(UIColor**)fillColor
  fillCount:(int)fillCount stroke:(UIColor*)strokeColor radius:(CGFloat)radius;

- (void)draw:(TTDrawStyle)background rect:(CGRect)rect;

- (void)drawLine:(CGPoint)from to:(CGPoint)to color:(UIColor*)color;

- (void)fill:(CGRect)rect fillColors:(UIColor**)fillColors count:(int)count;

- (void)stroke:(UIColor*)strokeColor;

@end
