#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface NSString (TTCategory)

- (BOOL)isWhitespace;

- (BOOL)isEmptyOrWhitespace;

- (NSDictionary*)queryDictionaryUsingEncoding: (NSStringEncoding)encoding;

- (NSString*)stringByRemovingHTMLTags;

@end
