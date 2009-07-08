#import "Three20/TTGlobal.h"

#define TT_NULL_URL @" "

@protocol TTAppMapDelegate;
@class TTURLPattern;

typedef enum {
  TTAppMapPersistenceModeNone,  // no persistence
  TTAppMapPersistenceModeTop,   // persists only the top-level controller
  TTAppMapPersistenceModeAll,   // persists all navigation paths
} TTAppMapPersistenceMode;

typedef enum {
  TTDisplayModeNone,
  TTDisplayModeCreate,            // a new controller is created each time
  TTDisplayModeShare,             // the same controller is cached and re-used
  TTDisplayModeModal,             // a new controller is created and displayed modally
} TTDisplayMode;

@protocol TTURLObject

- (NSString*)formatURL:(NSString*)URLFormat;

@end

@interface TTAppMap : NSObject {
  id<TTAppMapDelegate> _delegate;
  UIWindow* _window;
  UIViewController* _rootViewController;
  NSMutableDictionary* _bindings;
  TTAppMapPersistenceMode _persistenceMode;
  NSMutableArray* _patterns;
  TTURLPattern* _defaultPattern;
  BOOL _invalidPatterns;
  BOOL _supportsShakeToReload;
  BOOL _openExternalURLs;
}

@property(nonatomic,assign) id<TTAppMapDelegate> delegate;

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
 * How view controllers are automatically persisted on termination and restored on launch.
 */
@property(nonatomic) TTAppMapPersistenceMode persistenceMode;

/**
 * Causes the current view controller to be reloaded when shaking the phone.
 */
@property(nonatomic) BOOL supportsShakeToReload;

/**
 * Opens URLs externally if they don't match any patterns.
 *
 * The default value is NO.
 */
@property(nonatomic) BOOL openExternalURLs;

+ (TTAppMap*)sharedMap;

/**
 * Loads and displays a view controller with a pattern than matches the URL.
 *
 * If there is not yet a rootViewController, the view controller loaded with this URL
 * will be assigned as the rootViewController and inserted into the keyWinodw.  If there is not
 * a keyWindow, a UIWindow will be created and displayed.
 */
- (UIViewController*)openURL:(NSString*)URL animated:(BOOL)animated;
- (UIViewController*)openURL:(NSString*)URL parent:(NSString*)parentURL animated:(BOOL)animated;
- (UIViewController*)openURL:(NSString*)URL params:(NSDictionary*)params animated:(BOOL)animated;
- (UIViewController*)openURL:(NSString*)URL parent:(NSString*)parentURL
                     params:(NSDictionary*)params animated:(BOOL)animated;

/** 
 * Opens a sequence of URLs, with only the last one being animated.
 */
- (UIViewController*)openURLs:(NSString*)URL,...;

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
 * Gets or creates the object with a pattern that matches the URL.
 *
 * Object bindings are checked first, and if no object is bound to the URL then pattern
 * matching is used to create a new object.
 */ 
- (id)objectForURL:(NSString*)URL;

/**
 * Tests if there is a pattern that matches the URL and if so returns its display mode.
 */
- (TTDisplayMode)displayModeForURL:(NSString*)URL;

/**
 * Adds a URL pattern which will create and display a view controller when loaded.
 */
- (void)addURL:(NSString*)URL create:(id)create;

/**
 * Adds a URL pattern which will create and display a view controller when loaded.
 *
 * The selector will be called on the view controller after is created, and arguments from
 * the URL will be extracted using the pattern and passed to the selector.
 *
 * target can be either a Class which is a subclass of UIViewController, or an object which
 * implements a method that returns a UIViewController instance.  If you use an object, the
 * selector will be called with arguments extracted from the URL, and the view controller that
 * you return will be the one that is displayed.
 */
- (void)addURL:(NSString*)URL create:(id)target selector:(SEL)selector;

/**
 * Adds a URL pattern which will create and display a view controller when loaded.
 */
- (void)addURL:(NSString*)URL parent:(NSString*)parentURL create:(id)target selector:(SEL)selector;

/**
 * Adds a URL pattern which will create and display a share view controller when loaded.
 *
 * Controllers created with the "share" mode, meaning that it will be created once and re-used
 * until it is destroyed.
 */
- (void)addURL:(NSString*)URL share:(id)target;

/**
 * Adds a URL pattern which will create and display a view controller when loaded.
 */
- (void)addURL:(NSString*)URL share:(id)target selector:(SEL)selector;

/**
 * Adds a URL pattern which will create and display a view controller when loaded.
 */
- (void)addURL:(NSString*)URL parent:(NSString*)parentURL share:(id)target
        selector:(SEL)selector;

/**
 * Adds a URL pattern which will create and display a modal view controller when loaded.
 */
- (void)addURL:(NSString*)URL modal:(id)target;

/**
 * Adds a URL pattern which will create and display a modal view controller when loaded.
 */
- (void)addURL:(NSString*)URL modal:(id)target selector:(SEL)selector;

/**
 * Adds a URL pattern which will create and display a modal view controller when loaded.
 */
- (void)addURL:(NSString*)URL parent:(NSString*)parentURL modal:(id)target selector:(SEL)selector;

/**
 * Removes a URL pattern.
 */
- (void)removeURL:(NSString*)URL;

/**
 * Binds a URL to an object.
 *
 * Bindings are weak, meaning that the app map will not retain your object.  You are
 * responsible for removing the binding when the object is destroyed.
 *
 * All requests to open this URL will return the object bound to it, rather than going
 * through the pattern matching process to create a new object.
 */
- (void)bindObject:(id)object toURL:(NSString*)URL;

/**
 * Removes the binding a URL.
 */
- (void)removeBindingForURL:(NSString*)URL;

/**
 * Removes the binding a object.
 */
- (void)removeBindingForObject:(id)object;

/** 
 * Erases all data stored in user defaults.
 */
- (void)resetDefaults;

@end

///////////////////////////////////////////////////////////////////////////////////////////////////

@protocol TTAppMapDelegate <NSObject>

@optional

/**
 * Asks if the URL should be opened and allows the delegate to prevent it.
 */
- (BOOL)appMap:(TTAppMap*)appMap shouldOpenURL:(NSURL*)URL;

/**
 * The URL is about to be opened in a controller.
 *
 * If the controller argument is nil, the URL is going to be opened externally.
 */
- (void)appMap:(TTAppMap*)appMap willOpenURL:(NSURL*)URL
        inViewController:(UIViewController*)controller;

@end

///////////////////////////////////////////////////////////////////////////////////////////////////
// global 

/**
 * Shortcut for calling [[TTAppMap sharedMap] openURL:]
 */
UIViewController* TTOpenURL(NSString* URL);
