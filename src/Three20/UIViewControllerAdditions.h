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

/**
 * Displays a controller inside this controller.
 *
 * TTAppMap uses this to display newly created controllers.  The default does nothing --
 * UIViewController categories and subclasses should implement to display the controller
 * in a manner specific to them.  
 */
- (void)presentController:(UIViewController*)controller animated:(BOOL)animated;

/**
 * Brings a controller that is a child of this controller to the front.
 *
 * TTAppMap uses this to display controllers that exist already, but may not be visible.
 * The default does nothing -- UIViewController categories and subclasses should implement
 * to display the controller in a manner specific to them.  
 */
- (void)bringControllerToFront:(UIViewController*)controller animated:(BOOL)animated;

@end
