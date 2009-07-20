#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface UIFont (TTCategory)

/**
 * Gets the height of a line of text with this font.
 *
 * Why this isn't part of UIFont is beyond me. This is the height you would expect to get
 * by calling sizeWithFont.
 */
- (CGFloat)lineHeight;

@end
