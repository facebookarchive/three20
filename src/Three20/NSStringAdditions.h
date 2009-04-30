#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface NSString (TTCategory)

- (BOOL)isWhitespace;

- (BOOL)endsWithString:(NSString*)substring;

- (NSDictionary*)queryDictionaryUsingEncoding: (NSStringEncoding)encoding;

@end
