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

/**
 * TTAppearance is a singleton which holds all of the standard visual styles used by various views.
 *
 * When you'd like to "skin" your app by changing some of the colors and styles that are used
 * by standard Three20 components, you can just modify the properties of TTAppearance.
 */
@interface TTAppearance : NSObject {
  UIColor* _navigationBarTintColor;
  UIColor* _toolbarTintColor;
  UIColor* _linkTextColor;
  UIColor* _moreLinkTextColor;
  UIColor* _tableActivityTextColor;
  UIColor* _tableErrorTextColor;
  UIColor* _tableSubTextColor;
  UIColor* _tableTitleTextColor;
  UIColor* _placeholderTextColor;
  UIColor* _searchTableBackgroundColor;
  UIColor* _searchTableSeparatorColor;
  UIColor* _tableHeaderTextColor;
  UIColor* _tableHeaderShadowColor;
  UIColor* _tableHeaderTintColor;
  UIImage* _blackButtonImage;
}

+ (TTAppearance*)appearance;

+ (void)setAppearance:(TTAppearance*)appearance;

/**
 * Color used for tinting all navigation bars.
 */
@property(nonatomic,retain) UIColor* navigationBarTintColor;

/**
 * Color used for tinting toolbars and searchbars.
 */
@property(nonatomic,retain) UIColor* toolbarTintColor;

/**
 * Color used for hyperlinks.
 */
@property(nonatomic,retain) UIColor* linkTextColor;

/**
 * Color used for the "load more" links in table views.
 */
@property(nonatomic,retain) UIColor* moreLinkTextColor;

/**
 * Color used for the text describing errors in a table view.
 */
@property(nonatomic,retain) UIColor* tableActivityTextColor;

/**
 * Color used for the text describing errors in a table view.
 */
@property(nonatomic,retain) UIColor* tableErrorTextColor;

/**
 * Color used for subtext in a table view.
 */
@property(nonatomic,retain) UIColor* tableSubTextColor;

/**
 * Color used for titels (the left side of a titled field cell) in a table view.
 */
@property(nonatomic,retain) UIColor* tableTitleTextColor;

/**
 * Color used for placeholder text in text fields.
 */
@property(nonatomic,retain) UIColor* placeholderTextColor;

/**
 * Color used for the background of search result tables.
 */
@property(nonatomic,retain) UIColor* searchTableBackgroundColor;

/**
 * Color used for the separators in search result tables.
 */
@property(nonatomic,retain) UIColor* searchTableSeparatorColor;

/**
 * Color used for text in table header views.
 */
@property(nonatomic,retain) UIColor* tableHeaderTextColor;

/**
 * Color used for text shadow in table header views.
 */
@property(nonatomic,retain) UIColor* tableHeaderShadowColor;

/**
 * Color used for tinting table header views.
 */
@property(nonatomic,retain) UIColor* tableHeaderTintColor;


/**
 * Image used for the background of black buttons.
 */
@property(nonatomic,retain) UIImage* blackButtonImage;

- (void)draw:(TTDrawStyle)background rect:(CGRect)rect fill:(UIColor**)fillColor
        fillCount:(int)fillCount stroke:(UIColor*)strokeColor radius:(CGFloat)radius;

- (void)draw:(TTDrawStyle)background rect:(CGRect)rect fill:(UIColor**)fillColor
        fillCount:(int)fillCount stroke:(UIColor*)strokeColor thickness:(CGFloat)thickness
        radius:(CGFloat)radius;

- (void)draw:(TTDrawStyle)background rect:(CGRect)rect;

- (void)drawLine:(CGPoint)from to:(CGPoint)to color:(UIColor*)color thickness:(CGFloat)thickness;

- (void)fill:(CGRect)rect fillColors:(UIColor**)fillColors count:(int)count;

- (void)stroke:(UIColor*)strokeColor thickness:(CGFloat)thickness;

@end
