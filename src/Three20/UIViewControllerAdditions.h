#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface UIViewController (TTCategory)

/**
 * The view controller that comes before this one in a navigation controller's history.
 */
- (UIViewController*)previousViewController;

/**
 * The view controller that comes after this one in a navigation controller's history.
 */
- (UIViewController*)nextViewController;

/**
 * Shows a UIAlertView with a message and title.
 *
 * @delegate A UIAlertView delegate
 */ 
- (void)alert:(NSString*)message title:(NSString*)title delegate:(id)delegate;

/**
 * Shows a UIAlertView with a message.
 */ 
- (void)alert:(NSString*)message;

/**
 * Shows a UIAlertView with an error message.
 */ 
- (void)alertError:(NSString*)message;

/**
 * Shows or hides the navigation and status bars.
 */
- (void)showBars:(BOOL)show animated:(BOOL)animated;

@end
