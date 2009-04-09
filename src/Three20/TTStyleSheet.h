#import "Three20/TTGlobal.h"

@class TTStyle;

@interface TTStyleSheet : NSObject {
  NSMutableDictionary* _styles;
}

+ (TTStyleSheet*)globalStyleSheet;
+ (void)setGlobalStyleSheet:(TTStyleSheet*)styleSheet;

- (TTStyle*)styleWithClassName:(NSString*)className;
- (TTStyle*)styleWithClassName:(NSString*)className forState:(UIControlState)state;

- (void)freeMemory;

@end
