#import "Three20/TTGlobal.h"

#define TT_NULL_URL @" "

@protocol TTAppMapDelegate;

@interface TTAppMap : NSObject {
  id<TTAppMapDelegate> _delegate;
  UIWindow* _mainWindow;
  UIViewController* _mainViewController;
  NSMutableDictionary* _singletons;
  BOOL _supportsShakeToReload;
  NSMutableArray* _patterns;
  BOOL _invalidPatterns;
}

@property(nonatomic,assign) id<TTAppMapDelegate> delegate;

@property(nonatomic,retain) UIWindow* mainWindow;

@property(nonatomic,retain) UIViewController* mainViewController;

@property(nonatomic,readonly) UIViewController* visibleViewController;

/**
 * Causes the current view controller to be reloaded when shaking the phone.
 */
@property(nonatomic) BOOL supportsShakeToReload;

+ (TTAppMap*)sharedMap;

/**
 * Loads and displays a controller with a pattern than matches the URL.
 *
 * If there is not yet a mainViewController, the controller loaded with this URL
 * will be assigned as the mainViewController and inserted into the keyWinodw.  If there is not
 * a keyWindow, a UIWindow will be created and displayed.
 */
- (UIViewController*)loadURL:(NSString*)URL;

/**
 * Gets the controller with a pattern that matches the URL.
 */
- (UIViewController*)controllerForURL:(NSString*)URL;

/**
 * Adds a URL pattern which will create and display a controller when loaded.
 */
- (void)addURL:(NSString*)URL controller:(Class)controller;

/**
 * Adds a URL pattern which will create and display a controller when loaded.
 *
 * The selector will be called on the controller after is created, and arguments from
 * the URL will be extracted using the pattern and passed to the selector.
 */
- (void)addURL:(NSString*)URL controller:(Class)controller selector:(SEL)selector;

/**
 * Adds a URL pattern which will create and display a controller when loaded.
 */
- (void)addURL:(NSString*)URL parent:(NSString*)parentURL controller:(Class)controller
        selector:(SEL)selector;

/**
 * Adds a URL pattern which will create and display a singleton controller when loaded.
 *
 * The term 'singleton' means that if the controller exists when a URL tries to load it, it will
 * cause the existing controller to be displayed rather than creating a new one.
 */
- (void)addURL:(NSString*)URL singleton:(Class)controller;

/**
 * Adds a URL pattern which will create and display a singleton controller when loaded.
 */
- (void)addURL:(NSString*)URL singleton:(Class)controller selector:(SEL)selector;

/**
 * Adds a URL pattern which will create and display a singleton controller when loaded.
 */
- (void)addURL:(NSString*)URL parent:(NSString*)parentURL singleton:(Class)controller
        selector:(SEL)selector;

/**
 * Adds a URL pattern which will create and display a modal controller when loaded.
 */
- (void)addURL:(NSString*)URL modal:(Class)controller;

/**
 * Adds a URL pattern which will create and display a modal controller when loaded.
 */
- (void)addURL:(NSString*)URL modal:(Class)controller selector:(SEL)selector;

/**
 * Adds a URL pattern which will create and display a modal controller when loaded.
 */
- (void)addURL:(NSString*)URL parent:(NSString*)parentURL modal:(Class)controller
        selector:(SEL)selector;

/**
 * Assigns a controller to a specific URL.
 *
 * All requests to load the URL will display the controller instead of performing the
 * usual pattern match.
 */
- (void)setController:(UIViewController*)controller forURL:(NSString*)URL;

/**
 * Removes a controller from being assigned to a URL.
 */
- (void)removeControllerForURL:(NSString*)URL;

@end

///////////////////////////////////////////////////////////////////////////////////////////////////

@protocol TTAppMapDelegate <NSObject>

@optional
  
@end

///////////////////////////////////////////////////////////////////////////////////////////////////
// global 

/**
 * Shortcut for calling loading a URL in the shared app map.
 */
void TTLoadURL(NSString* URL);
