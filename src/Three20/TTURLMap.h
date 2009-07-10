#import "Three20/TTGlobal.h"

@class TTURLPattern;

typedef enum {
  TTNavigationModeNone,
  TTNavigationModeCreate,            // a new view controller is created each time
  TTNavigationModeShare,             // a new view controller is created, cached and re-used
  TTNavigationModeModal,             // a new view controller is created and presented modally
} TTNavigationMode;

@interface TTURLMap : NSObject {
  NSMutableDictionary* _bindings;
  NSMutableArray* _patterns;
  TTURLPattern* _defaultPattern;
  BOOL _invalidPatterns;
}

/**
 * Gets or creates the object with a pattern that matches the URL.
 *
 * Object bindings are checked first, and if no object is bound to the URL then pattern
 * matching is used to create a new object.
 */ 
- (id)objectForURL:(NSString*)URL;
- (id)objectForURL:(NSString*)URL query:(NSDictionary*)query;
- (id)objectForURL:(NSString*)URL query:(NSDictionary*)query pattern:(TTURLPattern**)pattern;

/**
 * Tests if there is a pattern that matches the URL and if so returns its navigation mode.
 */
- (TTNavigationMode)navigationModeForURL:(NSString*)URL;

/**
 * Adds a URL pattern which will create and present a view controller when loaded.
 */
- (void)from:(NSString*)URL toViewController:(id)target;

/**
 * Adds a URL pattern which will create and present a view controller when loaded.
 *
 * The selector will be called on the view controller after is created, and arguments from
 * the URL will be extracted using the pattern and passed to the selector.
 *
 * target can be either a Class which is a subclass of UIViewController, or an object which
 * implements a method that returns a UIViewController instance.  If you use an object, the
 * selector will be called with arguments extracted from the URL, and the view controller that
 * you return will be the one that is presented.
 */
- (void)from:(NSString*)URL toViewController:(id)target selector:(SEL)selector;

/**
 * Adds a URL pattern which will create and present a view controller when loaded.
 */
- (void)from:(NSString*)URL toViewController:(id)target selector:(SEL)selector
        parent:(NSString*)parentURL;

/**
 * Adds a URL pattern which will create and present a share view controller when loaded.
 *
 * Controllers created with the "share" mode, meaning that it will be created once and re-used
 * until it is destroyed.
 */
- (void)from:(NSString*)URL toSharedViewController:(id)target;

/**
 * Adds a URL pattern which will create and present a view controller when loaded.
 */
- (void)from:(NSString*)URL toSharedViewController:(id)target selector:(SEL)selector;

/**
 * Adds a URL pattern which will create and present a view controller when loaded.
 */
- (void)from:(NSString*)URL toSharedViewController:(id)target selector:(SEL)selector
        parent:(NSString*)parentURL;

/**
 * Adds a URL pattern which will create and present a modal view controller when loaded.
 */
- (void)from:(NSString*)URL toModalViewController:(id)target;

/**
 * Adds a URL pattern which will create and present a modal view controller when loaded.
 */
- (void)from:(NSString*)URL toModalViewController:(id)target selector:(SEL)selector;

/**
 * Adds a URL pattern which will create and present a modal view controller when loaded.
 */
- (void)from:(NSString*)URL toModalViewController:(id)target selector:(SEL)selector
        parent:(NSString*)parentURL ;

/**
 * 
 */
- (void)from:(id)object toURL:(NSString*)URL;

/**
 * 
 */
- (void)from:(id)object name:(NSString*)name toURL:(NSString*)URL;

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

@end
