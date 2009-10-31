#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


@interface UIWindow (TTCategory)

- (UIView*)findFirstResponder;

- (UIView*)findFirstResponderInView:(UIView*)topView;

@end
