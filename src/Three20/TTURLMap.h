#import "Three20/TTGlobal.h"

@class TTURLPattern;

typedef enum {
  TTNavigationModeNone,
  TTNavigationModeCreate,            // a new controller is created each time
  TTNavigationModeShare,             // the same controller is cached and re-used
  TTNavigationModeModal,             // a new controller is created and displayed modally
} TTNavigationMode;

@protocol TTURLObject

/**
 * Converts the object to a URL using TTURLMap.
 */
@property(nonatomic,readonly) NSString* URLValue;

/**
 * Converts the object to a specially-named URL using TTURLMap.
 */
- (NSString*)URLValueWithName:(NSString*)name;

@end

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
- (id)objectForURL:(NSString*)URL params:(NSDictionary*)params;
- (id)objectForURL:(NSString*)URL params:(NSDictionary*)params pattern:(TTURLPattern**)pattern;

/**
 * Tests if there is a pattern that matches the URL and if so returns its display mode.
 */
- (TTNavigationMode)navigationModeForURL:(NSString*)URL;

/**
 * Adds a URL pattern which will create and display a view controller when loaded.
 */
- (void)create:(NSString*)URL target:(id)target;

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
- (void)create:(NSString*)URL target:(id)target selector:(SEL)selector;

/**
 * Adds a URL pattern which will create and display a view controller when loaded.
 */
- (void)create:(NSString*)URL parent:(NSString*)parentURL target:(id)target selector:(SEL)selector;

/**
 * Adds a URL pattern which will create and display a share view controller when loaded.
 *
 * Controllers created with the "share" mode, meaning that it will be created once and re-used
 * until it is destroyed.
 */
- (void)share:(NSString*)URL target:(id)target;

/**
 * Adds a URL pattern which will create and display a view controller when loaded.
 */
- (void)share:(NSString*)URL target:(id)target selector:(SEL)selector;

/**
 * Adds a URL pattern which will create and display a view controller when loaded.
 */
- (void)share:(NSString*)URL parent:(NSString*)parentURL target:(id)target
        selector:(SEL)selector;

/**
 * Adds a URL pattern which will create and display a modal view controller when loaded.
 */
- (void)modal:(NSString*)URL target:(id)target;

/**
 * Adds a URL pattern which will create and display a modal view controller when loaded.
 */
- (void)modal:(NSString*)URL target:(id)target selector:(SEL)selector;

/**
 * Adds a URL pattern which will create and display a modal view controller when loaded.
 */
- (void)modal:(NSString*)URL parent:(NSString*)parentURL target:(id)target selector:(SEL)selector;

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
