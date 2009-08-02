#import <Foundation/Foundation.h>

@interface NSArray (TTCategory)

/**
 * Calls performSelector on all objects in the array.
 */
- (void)perform:(SEL)selector;
- (void)perform:(SEL)selector withObject:(id)p1;
- (void)perform:(SEL)selector withObject:(id)p1 withObject:(id)p2;
- (void)perform:(SEL)selector withObject:(id)p1 withObject:(id)p2 withObject:(id)p3;

- (id)objectWithValue:(id)value forKey:(id)key;
- (id)objectWithClass:(Class)cls;

@end
