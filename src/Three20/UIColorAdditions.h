#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface UIColor (TTCategory)

- (UIColor*)transformHue:(CGFloat)hd saturation:(CGFloat)sd value:(CGFloat)vd;

- (UIColor*)highlight;

- (UIColor*)shadow;

@end
