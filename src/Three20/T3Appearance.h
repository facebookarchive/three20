#import "Three20/T3Global.h"

@interface T3Appearance : NSObject {
  UIColor* _linkTextColor;
}

+ (T3Appearance*)appearance;
+ (void)setAppearance:(T3Appearance*)appearance;

@property(nonatomic,retain) UIColor* linkTextColor;

@end
