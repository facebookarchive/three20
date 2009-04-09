#import "Three20/TTGlobal.h"

@class TTStyle;

/**
 * TTAppearance is a singleton which holds all of the standard visual styles used by various views.
 *
 * When you'd like to "skin" your app by changing some of the colors and styles that are used
 * by standard Three20 components, you can just modify the properties of TTAppearance.
 */
@interface TTAppearance : NSObject {
  NSMutableArray* _styleSheets;
  NSMutableDictionary* _styles;
  UIColor* _navigationBarTintColor;
  UIColor* _toolbarTintColor;
  UIColor* _searchBarTintColor;
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
  
  TTStyle* _linkStyle;
  TTStyle* _linkHighlightedStyle;
  TTStyle* _searchTextFieldStyle;
  TTStyle* _searchBarStyle;
  TTStyle* _tableHeaderStyle;
  TTStyle* _pickerCellStyle;
  TTStyle* _pickerCellSelectedStyle;
  TTStyle* _searchTableShadowStyle;
  TTStyle* _blackBezelStyle;
  TTStyle* _whiteBezelStyle;
}

+ (TTAppearance*)appearance;

+ (void)setAppearance:(TTAppearance*)appearance;

/**
 * Color used for tinting all navigation bars.
 */
@property(nonatomic,retain) UIColor* navigationBarTintColor;

/**
 * Color used for tinting toolbars.
 */
@property(nonatomic,retain) UIColor* toolbarTintColor;

/**
 * Color used for tinting search bars.
 */
@property(nonatomic,retain) UIColor* searchBarTintColor;

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
 * Color used for titles (the left side of a titled field cell) in a table view.
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

@property(nonatomic,retain) TTStyle* linkStyle;
@property(nonatomic,retain) TTStyle* linkHighlightedStyle;
@property(nonatomic,retain) TTStyle* searchTextFieldStyle;
@property(nonatomic,retain) TTStyle* searchBarStyle;
@property(nonatomic,retain) TTStyle* tableHeaderStyle;
@property(nonatomic,retain) TTStyle* pickerCellStyle;
@property(nonatomic,retain) TTStyle* pickerCellSelectedStyle;
@property(nonatomic,retain) TTStyle* searchTableShadowStyle;
@property(nonatomic,retain) TTStyle* blackBezelStyle;
@property(nonatomic,retain) TTStyle* whiteBezelStyle;

- (void)addStyleSheet:(Class)styleSheet;
- (void)removeStyleSheet:(Class)styleSheet;

- (TTStyle*)styleWithClassName:(NSString*)className;
- (TTStyle*)styleWithClassName:(NSString*)className forState:(UIControlState)state;

@end
