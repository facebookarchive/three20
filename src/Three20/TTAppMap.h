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
  TTDisplayModeCreate,            // new controller is created and pushed
  TTDisplayModeShare,             // the same controller is re-used
  TTDisplayModeModal,             // new controller is created and displayed modally
} TTDisplayMode;

@protocol TTURLObject

- (NSString*)formatURL:(NSString*)URLFormat;

@end

@interface TTAppMap : NSObject {
  id<TTAppMapDelegate> _delegate;
  UIWindow* _mainWindow;
  UIViewController* _mainViewController;
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
- (UIViewController*)openURL:(NSString*)URL;
- (UIViewController*)openURL:(NSString*)URL params:(NSDictionary*)params;
- (UIViewController*)openURL:(NSString*)URL animated:(BOOL)animated;
- (UIViewController*)openURL:(NSString*)URL parent:(NSString*)parentURL animated:(BOOL)animated;
- (UIViewController*)openURL:(NSString*)URL params:(NSDictionary*)params animated:(BOOL)animated;
- (UIViewController*)openURL:(NSString*)URL parent:(NSString*)parentURL
                     params:(NSDictionary*)params animated:(BOOL)animated;

/**
 * Gets or creates the object with a pattern that matches the URL.
 *
 * Object bindings are checked first, and if no object is bound to the URL then pattern
 * matching is used to create a new object.
 */ 
- (id)objectForURL:(NSString*)URL;

/**
 * Tests if there is a pattern that matches the URL.
 */
- (TTDisplayMode)displayModeForURL:(NSString*)URL;

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
 * Adds a URL pattern which will create and display a share controller when loaded.
 *
 * Controllers created with the "share" mode, meaning that it will be created once and re-used
 * until it is destroyed.
 */
- (void)addURL:(NSString*)URL share:(id)target;

/**
 * Adds a URL pattern which will create and display a controller when loaded.
 */
- (void)addURL:(NSString*)URL share:(id)target selector:(SEL)selector;

/**
 * Adds a URL pattern which will create and display a controller when loaded.
 */
- (void)addURL:(NSString*)URL parent:(NSString*)parentURL share:(id)target
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

/**
 * Persists a controller's state and recursively persists the next controller after it.
 */
- (void)persistController:(UIViewController*)controller path:(NSMutableArray*)path;

@end

///////////////////////////////////////////////////////////////////////////////////////////////////

@protocol TTAppMapDelegate <NSObject>

@optional

/**
 * Asks if the URL should be opened and allows the delegate to stop it.
 */
- (BOOL)appMap:(TTAppMap*)appMap shouldOpenURL:(NSURL*)URL;

/**
 * The URL is about to be opened in a controller.
 *
 * If the controller argument is nil, the URL will be opened externally.
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
