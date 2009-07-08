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

/**
 * Opens a URL with the string using TTAppMap.
 */
- (void)openURL;

/**
 * Converts the string to an object using TTAppMap.
 */
- (id)objectValue;

/**
 * Formats a URL using an object that conforms to the TTURLObject protocol.
 */
- (NSString*)objectURL:(id)object;

@end
