#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface UIViewController (TTCategory)

/**
 * The default initializer sent to view controllers opened through TTNavigator.
 */
- (id)initWithNavigatorURL:(NSURL*)URL query:(NSDictionary*)query;

/**
 * The current URL that this view controller represents.
 */
@property(nonatomic,readonly) NSString* navigatorURL;

/**
 * The URL that was used to load this controller through TTNavigator.
 *
 * Do not ever change the value of this property.  TTNavigator will assign this
 * when creating your view controller, and it expects it to remain constant throughout
 * the view controller's life.  You can override navigatorURL if you want to specify
 * a different URL for your view controller to use when persisting and restoring it.
 */
@property(nonatomic,copy) NSString* originalNavigatorURL;

/**
 * Determines whether a controller is primarily a container of other controllers.
 */
@property(nonatomic,readonly) BOOL canContainControllers;

/**
 * The view controller that contains this view controller.
 *
 * This is just like parentViewController, except that it is not readonly.  This property offers
 * custom UIViewController subclasses the chance to tell TTNavigator how to follow the hierarchy
 * of view controllers.
 */
@property(nonatomic,retain) UIViewController* superController;

/**
 * The child of this view controller which is most visible.
 *
 * This would be the selected view controller of a tab bar controller, or the top 
 * view controller of a navigation controller.  This property offers custom UIViewController
 * subclasses the chance to tell TTNavigator how to follow the hierarchy of view controllers.
 
 */
- (UIViewController*)topSubcontroller;

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
- (void)addSubcontroller:(UIViewController*)controller animated:(BOOL)animated
        transition:(UIViewAnimationTransition)transition;

/**
 * Dismisses a view controller using the opposite transition it was presented with.
 */
- (void)removeFromSupercontroller;
- (void)removeFromSupercontrollerAnimated:(BOOL)animated;

/**
 * Brings a controller that is a child of this controller to the front.
 *
 * TTURLMap uses this to display controllers that exist already, but may not be visible.
 * The default does nothing -- UIViewController categories and subclasses should implement
 * to display the controller in a manner specific to them.  
 */
- (void)bringControllerToFront:(UIViewController*)controller animated:(BOOL)animated;

/**
 * Gets a key that can be used to identify a subcontroller in subcontrollerForKey.
 */
- (NSString*)keyForSubcontroller:(UIViewController*)controller;

/**
 * Gets a subcontroller with the key that was returned from keyForSubcontroller.
 */
- (UIViewController*)subcontrollerForKey:(NSString*)key;

/**
 * Persists aspects of the view state to a dictionary that can later be used to restore it.
 *
 * This will be called when TTNavigator is persisting the navigation history so that it
 * can later be restored.  This usually happens when the app quits, or when there is a low
 * memory warning.
 */
- (BOOL)persistView:(NSMutableDictionary*)state;

/**
 * Restores aspects of the view state from a dictionary populated by persistView.
 *
 * This will be called when TTNavigator is restoring the navigation history.  This may 
 * happen after launch, or when the controller appears again after a low memory warning.
 */
- (void)restoreView:(NSDictionary*)state;

/**
 * XXXjoe Not documenting this in the hopes that I can eliminate it ;)
 */
- (void)persistNavigationPath:(NSMutableArray*)path;

/**
 * Finishes initializing the controller after a TTNavigator-coordinated delay.
 *
 * If the controller was created in between calls to TTNavigator beginDelay and endDelay, then
 * this will be called after endDelay.
 */
- (void)delayDidEnd;

/**
 * Shows or hides the navigation and status bars.
 */
- (void)showBars:(BOOL)show animated:(BOOL)animated;

/**
 * Shortcut for its animated-optional cousin.
 */
- (void)dismissModalViewController;

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

@end
