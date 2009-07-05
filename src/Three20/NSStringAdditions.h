#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface NSString (TTCategory)

- (BOOL)isWhitespace;

- (BOOL)isEmptyOrWhitespace;

/**
 * Parses a URL query string into a dictionary.
 */
- (NSDictionary*)queryDictionaryUsingEncoding:(NSStringEncoding)encoding;

- (NSString*)stringByRemovingHTMLTags;

@end
