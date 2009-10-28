#import "Three20/TTGlobal.h"

@implementation NSMutableDictionary (TTCategory)

- (void)setNonEmptyString:(NSString*)string forKey:(id)key {
  if (nil != string && !TTIsEmptyString(string)) {
    [self setObject:string forKey:key];
  }
}

@end
