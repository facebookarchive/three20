#import "Three20/TTGlobal.h"

@class TTStyle;

@interface TTStyleSheet : NSObject {
  NSMutableDictionary* _styles;
}

+ (TTStyleSheet*)globalStyleSheet;
+ (void)setGlobalStyleSheet:(TTStyleSheet*)styleSheet;

- (TTStyle*)styleWithSelector:(NSString*)selector;
- (TTStyle*)styleWithSelector:(NSString*)selector forState:(UIControlState)state;

- (void)freeMemory;

@end
