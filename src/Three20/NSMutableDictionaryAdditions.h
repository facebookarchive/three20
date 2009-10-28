#import <Foundation/Foundation.h>

@interface NSMutableDictionary (TTCategory)

/**
 * Adds a string on the condition that it's non-nil and non-empty.
 */
- (void)setNonEmptyString:(NSString*)string forKey:(id)key;

@end
