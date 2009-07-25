#import "Three20/TTGlobal.h"

@protocol TTNavigatorDelegate;
@class TTURLMap;
@class TTURLPattern;

typedef enum {
  TTNavigatorPersistenceModeNone,  // no persistence
  TTNavigatorPersistenceModeTop,   // persists only the top-level controller
  TTNavigatorPersistenceModeAll,   // persists all navigation paths
} TTNavigatorPersistenceMode;

@interface TTNavigator : NSObject {
  id<TTNavigatorDelegate> _delegate;
  TTURLMap* _URLMap;
  UIWindow* _window;
  UIViewController* _rootViewController;
  NSMutableArray* _delayedControllers;
  TTNavigatorPersistenceMode _persistenceMode;
  NSTimeInterval _persistenceExpirationAge;
  BOOL _delayCount;
  BOOL _supportsShakeToReload;
  BOOL _opensExternalURLs;
}

@property(nonatomic,assign) id<TTNavigatorDelegate> delegate;

/**
 * The URL map used to translate between URLs and view controllers.
 */
@property(nonatomic,readonly) TTURLMap* URLMap;

/**
 * The window that contains the views view controller hierarchy.
 */
@property(nonatomic,retain) UIWindow* window;

/**
 * The controller that is at the root of the view controller hierarchy.
 */
@property(nonatomic,readonly) UIViewController* rootViewController;

/**
 * The currently visible view controller.
 */
@property(nonatomic,readonly) UIViewController* visibleViewController;

/**
 * The view controller that is currently on top of the navigation stack.
 *
 * This differs from visibleViewController in that it ignores things like search
 * display controllers which are visible, but not part of navigation.
 */
@property(nonatomic,readonly) UIViewController* topViewController;

/**
 * The URL of the currently visible view controller;
 *
 * Setting this property will open a new URL.
 */
@property(nonatomic,copy) NSString* URL;

/**
 * How view controllers are automatically persisted on termination and restored on launch.
 */
@property(nonatomic) TTNavigatorPersistenceMode persistenceMode;

/**
 * The age at which persisted view controllers are too old to be restored.
 *
 * In some cases, it is a good practice not to restore really old navigation paths, because
 * the user probably won't remember how they got there, and would prefer to start from the
 * beginning.
 *
 * Set this to 0 to restore from any age. The default value is 0.
 */
@property(nonatomic) NSTimeInterval persistenceExpirationAge;

/**
 * Causes the current view controller to be reloaded when shaking the phone.
 */
@property(nonatomic) BOOL supportsShakeToReload;

/**
 * Allows URLs to be opened externally if they don't match any patterns.
 *
 * The default value is NO.
 */
@property(nonatomic) BOOL opensExternalURLs;

/**
 * Indicates that we asking controllers to delay heavy operations until a later time.
 *
 * The default value is NO.
 */
@property(nonatomic,readonly) BOOL isDelayed;

+ (TTNavigator*)navigator;

/**
 * Loads and displays a view controller with a pattern than matches the URL.
 *
 * If there is not yet a rootViewController, the view controller loaded with this URL
 * will be assigned as the rootViewController and inserted into the keyWinodw.  If there is not
 * a keyWindow, a UIWindow will be created and displayed.
 */
- (UIViewController*)openURL:(NSString*)URL animated:(BOOL)animated;
- (UIViewController*)openURL:(NSString*)URL animated:(BOOL)animated
                     transition:(UIViewAnimationTransition)transition;
- (UIViewController*)openURL:(NSString*)URL parent:(NSString*)parentURL animated:(BOOL)animated;
- (UIViewController*)openURL:(NSString*)URL query:(NSDictionary*)query animated:(BOOL)animated;
- (UIViewController*)openURL:(NSString*)URL parent:(NSString*)parentURL query:(NSDictionary*)query
                     animated:(BOOL)animated;
- (UIViewController*)openURL:(NSString*)URL parent:(NSString*)parentURL query:(NSDictionary*)query
                     animated:(BOOL)animated transition:(UIViewAnimationTransition)transition;
- (UIViewController*)openURL:(NSString*)URL parent:(NSString*)parentURL query:(NSDictionary*)query
                     animated:(BOOL)animated transition:(UIViewAnimationTransition)transition
                     withDelay:(BOOL)withDelay;

/** 
 * Opens a sequence of URLs, with only the last one being animated.
 */
- (UIViewController*)openURLs:(NSString*)URL,...;

/**
 * Gets a view controller for the URL without opening it.
 */
- (UIViewController*)viewControllerForURL:(NSString*)URL;
- (UIViewController*)viewControllerForURL:(NSString*)URL query:(NSDictionary*)query;
- (UIViewController*)viewControllerForURL:(NSString*)URL query:(NSDictionary*)query
                     pattern:(TTURLPattern**)pattern;

/**
 * Tells the navigator to delay heavy operations.
 *
 * Initializing controllers can be very expensive, so if you are going to do some animation
 * while this might be happening, this will tell controllers created through the navigator
 * that they should hold off so as not to slow down the operations.
 */
- (void)beginDelay;

/**
 * Tells controllers that were created during the delay to finish what they were planning to do.
 */
- (void)endDelay;

/**
 * Cancels the delay without notifying delayed controllers.
 */
- (void)cancelDelay;

/** 
 * Persists all view controllers to user defaults.
 */
- (void)persistViewControllers;

/** 
 * Persists all view controllers to user defaults.
 */
- (void)persistViewControllers;

/** 
 * Restores all view controllers from user defaults and returns the last one.
 */
- (UIViewController*)restoreViewControllers;

/**
 * Persists a view controller's state and recursively persists the next view controller after it.
 *
 * Do not call this directly except from within a view controller that is being directed
 * by the app map to persist itself.
 */
- (void)persistController:(UIViewController*)controller path:(NSMutableArray*)path;

/** 
 * Removes all view controllers from the window and releases them.
 */
- (void)removeAllViewControllers;

/**
 * Gets a navigation path which can be used to locate an object.
 */
- (NSString*)pathForObject:(id)object;

/**
 * Finds an object using its navigation path.
 */
- (id)objectForPath:(NSString*)path;

/** 
 * Erases all data stored in user defaults.
 */
- (void)resetDefaults;

/**
 * Reloads the content in the visible view controller.
 */
- (void)reload;

@end

///////////////////////////////////////////////////////////////////////////////////////////////////

@protocol TTNavigatorDelegate <NSObject>

@optional

/**
 * Asks if the URL should be opened and allows the delegate to prevent it.
 */
- (BOOL)navigator:(TTNavigator*)navigator shouldOpenURL:(NSURL*)URL;

/**
 * The URL is about to be opened in a controller.
 *
 * If the controller argument is nil, the URL is going to be opened externally.
 */
- (void)navigator:(TTNavigator*)navigator willOpenURL:(NSURL*)URL
        inViewController:(UIViewController*)controller;

@end

///////////////////////////////////////////////////////////////////////////////////////////////////
// global 

/**
 * Shortcut for calling [[TTNavigator navigator] openURL:]
 */
UIViewController* TTOpenURL(NSString* URL);
