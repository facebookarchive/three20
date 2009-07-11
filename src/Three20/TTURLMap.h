#import "Three20/TTGlobal.h"

@class TTURLPattern;

typedef enum {
  TTNavigationModeNone,
  TTNavigationModeCreate,            // a new view controller is created each time
  TTNavigationModeShare,             // a new view controller is created, cached and re-used
  TTNavigationModeModal,             // a new view controller is created and presented modally
} TTNavigationMode;

@interface TTURLMap : NSObject {
  NSMutableDictionary* _objectMappings;
  NSMutableArray* _objectPatterns;
  NSMutableDictionary* _stringPatterns;
  TTURLPattern* _defaultObjectPattern;
  BOOL _invalidPatterns;
}

/**
 * Adds a direct mapping from a literal URL to an object.
 *
 * The URL must not be a pattern - it must be the a URL. All requests to open this URL will
 * return the object bound to it, rather than going through the pattern matching process to create
 * a new object.
 * 
 * Mapped objects are not retained.  You are responsible for removing the mapping when the object
 * is destroyed, or risk crashes.
 */
- (void)from:(NSString*)URL toObject:(id)object;

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
- (void)from:(NSString*)URL parent:(NSString*)parentURL
        toViewController:(id)target selector:(SEL)selector;

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
- (void)from:(NSString*)URL parent:(NSString*)parentURL
        toSharedViewController:(id)target selector:(SEL)selector;

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
- (void)from:(NSString*)URL parent:(NSString*)parentURL
        toModalViewController:(id)target selector:(SEL)selector;

/**
 * Adds a mapping from a class to a generated URL.
 */
- (void)from:(Class)object toURL:(NSString*)URL;

/**
 * Adds a mapping from a class and a special name to a generated URL.
 */
- (void)from:(Class)cls name:(NSString*)name toURL:(NSString*)URL;

/**
 * Removes all objects and patterns mapped to a URL.
 */
- (void)removeURL:(NSString*)URL;

/**
 * Removes all URLs bound to an object.
 */
- (void)removeObject:(id)object;

/**
 * Removes objects bound literally to the URL.
 */
- (void)removeObjectWithURL:(NSString*)URL;

/**
 * Gets or creates the object with a pattern that matches the URL.
 *
 * Object mappings are checked first, and if no object is bound to the URL then pattern
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
 * Gets a URL that has been mapped to the object.
 */
- (NSString*)URLForObject:(id)object;
- (NSString*)URLForObject:(id)object withName:(NSString*)name;

@end
