#import "Three20/T3Global.h"

@interface T3Theme : NSObject {
  UIColor* _linkTextColor;
}

+ (T3Theme*)theme;

@property(nonatomic,retain) UIColor* linkTextColor;

@end
