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
  TTLaunchTypeNone,
  TTLaunchTypeCreate,           // new controller is created and pushed
  TTLaunchTypeSingleton,        // the same controller is re-used
  TTLaunchTypeModal,            // new controller is created and displayed modally
} TTLaunchType;

@interface TTAppMap : NSObject {
  id<TTAppMapDelegate> _delegate;
  UIWindow* _mainWindow;
  UIViewController* _mainViewController;
  NSMutableDictionary* _singletons;
  TTAppMapPersistenceMode _persistenceMode;
  NSMutableArray* _patterns;
  TTURLPattern* _defaultPattern;
  BOOL _invalidPatterns;
  BOOL _supportsShakeToReload;
  BOOL _openExternalURLs;
}

@property(nonatomic,assign) id<TTAppMapDelegate> delegate;

/**
 * The window that contains the views of the controller hierarchy.
 */
@property(nonatomic,retain) UIWindow* mainWindow;

/**
 * The controller that is at the root of the controller hierarchy.
 */
@property(nonatomic,retain) UIViewController* mainViewController;

/**
 * The currently visible view controller.
 */
@property(nonatomic,readonly) UIViewController* visibleViewController;

/**
 * How controllers are automatically persisted on termination and restored on launch.
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
 * Loads and displays a controller with a pattern than matches the URL.
 *
 * If there is not yet a mainViewController, the controller loaded with this URL
 * will be assigned as the mainViewController and inserted into the keyWinodw.  If there is not
 * a keyWindow, a UIWindow will be created and displayed.
 */
- (UIViewController*)loadURL:(NSString*)URL;
- (UIViewController*)loadURL:(NSString*)URL animated:(BOOL)animated;

/**
 * Gets the controller with a pattern that matches the URL.
 */
- (UIViewController*)controllerForURL:(NSString*)URL;

/**
 * Tests if there is a pattern that matches the URL.
 */
- (TTLaunchType)launchTypeForURL:(NSString*)URL;

/**
 * Adds a URL pattern which will create and display a controller when loaded.
 */
- (void)addURL:(NSString*)URL create:(id)create;

/**
 * Adds a URL pattern which will create and display a controller when loaded.
 *
 * The selector will be called on the controller after is created, and arguments from
 * the URL will be extracted using the pattern and passed to the selector.
 *
 * target can be either a Class which is a subclass of UIViewController, or an object which
 * implements a method that returns a UIViewController instance.  If you use an object, the
 * selector will be called with arguments extracted from the URL, and the view controller that
 * you return will be the one that is displayed.
 */
- (void)addURL:(NSString*)URL create:(id)target selector:(SEL)selector;

/**
 * Adds a URL pattern which will create and display a controller when loaded.
 */
- (void)addURL:(NSString*)URL parent:(NSString*)parentURL create:(id)target selector:(SEL)selector;

/**
 * Adds a URL pattern which will create and display a singleton controller when loaded.
 *
 * The term 'singleton' means that if the controller exists when a URL tries to load it, it will
 * cause the existing controller to be displayed rather than creating a new one.
 */
- (void)addURL:(NSString*)URL singleton:(id)target;

/**
 * Adds a URL pattern which will create and display a singleton controller when loaded.
 */
- (void)addURL:(NSString*)URL singleton:(id)target selector:(SEL)selector;

/**
 * Adds a URL pattern which will create and display a singleton controller when loaded.
 */
- (void)addURL:(NSString*)URL parent:(NSString*)parentURL singleton:(id)target
        selector:(SEL)selector;

/**
 * Adds a URL pattern which will create and display a modal controller when loaded.
 */
- (void)addURL:(NSString*)URL modal:(id)target;

/**
 * Adds a URL pattern which will create and display a modal controller when loaded.
 */
- (void)addURL:(NSString*)URL modal:(id)target selector:(SEL)selector;

/**
 * Adds a URL pattern which will create and display a modal controller when loaded.
 */
- (void)addURL:(NSString*)URL parent:(NSString*)parentURL modal:(id)target selector:(SEL)selector;

/**
 * Removes a URL pattern.
 */
- (void)removeURL:(NSString*)URL;

/**
 * Assigns a controller to a specific URL.
 *
 * All requests to load this URL will display this controller instance rather than
 * going through the usual pattern matching to find a controller.
 */
- (void)setController:(UIViewController*)controller forURL:(NSString*)URL;

/**
 * Removes a controller from being assigned to a URL.
 */
- (void)removeControllerForURL:(NSString*)URL;

/** 
 * Erases all persisted controller data from preferences.
 */
- (void)removePersistedControllers;

/**
 * Persists a controller's state and recursively persists the next controller after it.
 */
- (void)persistController:(UIViewController*)controller path:(NSMutableArray*)path;

@end

///////////////////////////////////////////////////////////////////////////////////////////////////

@protocol TTAppMapDelegate <NSObject>

@optional

/**
 * Asks if the URL should be loaded and allows the delegate to stop it.
 */
- (BOOL)appMap:(TTAppMap*)appMap shouldLoadURL:(NSString*)URL;

/**
 * The URL is about to be opened in a controller.
 *
 * If the controller argument is nil, the URL will be opened externally.
 */
- (void)appMap:(TTAppMap*)appMap willLoadURL:(NSString*)URL
        inViewController:(UIViewController*)controller;

@end

///////////////////////////////////////////////////////////////////////////////////////////////////
// global 

/**
 * Shortcut for calling loading a URL in the shared app map.
 */
void TTLoadURL(NSString* URL);
