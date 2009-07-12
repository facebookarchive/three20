#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface UIViewController (TTCategory)

/**
 * The URL that was used to load this controller through TTNavigator.
 */
@property(nonatomic,copy) NSString* navigatorURL;

/**
 * A temporary holding place for persisted view state waiting to be restored.
 *
 * While restoring controllers, TTURLMap will assign this the dictionary created by persistView.
 * Ultimately, this state is bound for the restoreView call, but it is up to subclasses to
 * call restoreView at the appropriate time -- usually after the view has been created.
 *
 * After you've restored the state, you should set frozenState to nil.
 */
@property(nonatomic,retain) NSDictionary* frozenState;

/**
 * The view controller that contains this view controller.
 *
 * This is just like parentViewController, except that it is not readonly.  This property offers
 * custom UIViewController subclasses the chance to tell TTNavigator how to follow the hierarchy
 * of view controllers.
 */
@property(nonatomic,retain) UIViewController* superviewController;

/**
 * The child of this view controller which is most visible.
 *
 * This would be the selected view controller of a tab bar controller, or the top 
 * view controller of a navigation controller.  This property offers custom UIViewController
 * subclasses the chance to tell TTNavigator how to follow the hierarchy of view controllers.
 
 */
- (UIViewController*)subviewController;

/**
 * The view controller that comes before this one in a navigation controller's history.
 */
- (UIViewController*)previousViewController;

/**
 * The view controller that comes after this one in a navigation controller's history.
 */
- (UIViewController*)nextViewController;

/**
 * A popup view controller that is presented on top of this view controller. 
 */
@property(nonatomic,retain) UIViewController* popupViewController;

/**
 * Displays a controller inside this controller.
 *
 * TTURLMap uses this to display newly created controllers.  The default does nothing --
 * UIViewController categories and subclasses should implement to display the controller
 * in a manner specific to them.  
 */
- (void)presentController:(UIViewController*)controller animated:(BOOL)animated
        transition:(UIViewAnimationTransition)transition;

/**
 * Brings a controller that is a child of this controller to the front.
 *
 * TTURLMap uses this to display controllers that exist already, but may not be visible.
 * The default does nothing -- UIViewController categories and subclasses should implement
 * to display the controller in a manner specific to them.  
 */
- (void)bringControllerToFront:(UIViewController*)controller animated:(BOOL)animated;

/**
 * Dismisses a view controller using the opposite transition it was presented with.
 */
- (void)dismissViewController;
- (void)dismissViewControllerAnimated:(BOOL)animated;

- (void)dismissModalViewController;

/**
 * Determines whether a controller is primarily a container of other controllers.
 */
- (BOOL)isContainerController;

- (void)persistNavigationPath:(NSMutableArray*)path;

- (void)persistView:(NSMutableDictionary*)state;

- (void)restoreView:(NSDictionary*)state;

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
