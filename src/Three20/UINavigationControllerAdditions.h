#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface UINavigationController (TTCategory)

/**
 * Pushes a view controller with a transition other than the standard sliding animation.
 */
- (void)pushViewController:(UIViewController*)controller
        animatedWithTransition:(UIViewAnimationTransition)transition;

/**
 * Pops a view controller with a transition other than the standard sliding animation.
 */
- (UIViewController*)popViewControllerAnimatedWithTransition:(UIViewAnimationTransition)transition;

@end
