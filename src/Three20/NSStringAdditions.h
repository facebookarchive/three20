#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface NSString (TTCategory)

- (BOOL)isWhitespace;

- (NSDictionary*)queryDictionaryUsingEncoding: (NSStringEncoding)encoding;

@end
