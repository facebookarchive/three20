#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface NSString (TTCategory)

/**
 * Determines if the string contains only whitespace.
 */ 
- (BOOL)isWhitespace;

/**
 * Determines if the string is empty or contains only whitespace.
 */ 
- (BOOL)isEmptyOrWhitespace;

/**
 * Parses a URL query string into a dictionary.
 */
- (NSDictionary*)queryDictionaryUsingEncoding:(NSStringEncoding)encoding;

/**
 * Parses a URL, adds query parameters to its query, and re-encodes it as a new URL.
 */
- (NSString*)stringByAddingQueryDictionary:(NSDictionary*)query;

/**
 * Returns a string with all HTML tags removed.
 */
- (NSString*)stringByRemovingHTMLTags;

/**
 * Converts the string to an object using TTURLMap.
 */
- (id)objectValue;

/**
 * Opens a URL with the string using TTURLMap.
 */
- (void)openURL;
- (void)openURLFromButton:(UIView*)button;

@end
