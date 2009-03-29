#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface UIColor (TTCategory)

- (UIColor*)transformHue:(CGFloat)hd saturation:(CGFloat)sd value:(CGFloat)vd;

/**
 * Uses transformHue to create a lighter version of the color.
 */
- (UIColor*)highlight;

/**
 * Uses transformHue to create a darker version of the color.
 */
- (UIColor*)shadow;

- (CGFloat)hue;

- (CGFloat)saturation;

- (CGFloat)value;

@end
