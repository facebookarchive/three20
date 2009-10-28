#import <Foundation/Foundation.h>

@interface NSMutableArray (TTCategory)

/**
 * Adds a string on the condition that it's non-nil and non-empty.
 */
- (void)addNonEmptyString:(NSString*)string;

@end
