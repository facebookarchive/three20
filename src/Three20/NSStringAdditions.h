#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface NSString (TTCategory)

- (BOOL)isWhitespace;

- (BOOL)beginsWithString:(NSString*)substring;
- (BOOL)endsWithString:(NSString*)substring;

- (NSDictionary*)queryDictionaryUsingEncoding: (NSStringEncoding)encoding;

@end
