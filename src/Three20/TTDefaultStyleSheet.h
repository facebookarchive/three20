#import "Three20/TTStyleSheet.h"

@class TTShape;

@interface TTDefaultStyleSheet : TTStyleSheet

@property(nonatomic,readonly) UIColor* navigationBarTintColor;
@property(nonatomic,readonly) UIColor* toolbarTintColor;
@property(nonatomic,readonly) UIColor* searchBarTintColor;
@property(nonatomic,readonly) UIColor* linkTextColor;
@property(nonatomic,readonly) UIColor* moreLinkTextColor;
@property(nonatomic,readonly) UIColor* tableActivityTextColor;
@property(nonatomic,readonly) UIColor* tableErrorTextColor;
@property(nonatomic,readonly) UIColor* tableSubTextColor;
@property(nonatomic,readonly) UIColor* tableTitleTextColor;
@property(nonatomic,readonly) UIColor* placeholderTextColor;
@property(nonatomic,readonly) UIColor* searchTableBackgroundColor;
@property(nonatomic,readonly) UIColor* searchTableSeparatorColor;
@property(nonatomic,readonly) UIColor* tableHeaderTextColor;
@property(nonatomic,readonly) UIColor* tableHeaderShadowColor;
@property(nonatomic,readonly) UIColor* tableHeaderTintColor;
@property(nonatomic,readonly) UIColor* tabTintColor;
@property(nonatomic,readonly) UIColor* tabBarTintColor;

@property(nonatomic,readonly) UIFont* toolbarButtonFont;

- (TTStyle*)toolbarButtonForState:(UIControlState)state shape:(TTShape*)shape
            tintColor:(UIColor*)tintColor font:(UIFont*)font;

@end
