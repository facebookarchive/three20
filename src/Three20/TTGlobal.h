#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "Three20/TT+NSObject.h"
#import "Three20/TT+NSArray.h"
#import "Three20/TT+UIColor.h"
#import "Three20/TT+UIImage.h"
#import "Three20/TT+UIViewController.h"
#import "Three20/TT+UIView.h"
#import "Three20/TT+UITableView.h"
#import "Three20/TT+UIWebView.h"
#import "Three20/TT+UIToolbar.h"

///////////////////////////////////////////////////////////////////////////////////////////////////
// Logging Helpers

#ifdef DEBUG
#define TTLOG NSLog
#else
#define TTLOG    
#endif

#define TTLOGRECT(rect) \
  TTLOG(@"%s x=%f, y=%f, w=%f, h=%f", #rect, rect.origin.x, rect.origin.y, \
    rect.size.width, rect.size.height)

#define TTLOGPOINT(pt) \
  TTLOG(@"%s x=%f, y=%f", #pt, pt.x, pt.y)

#define TTLOGSIZE(size) \
  TTLOG(@"%s w=%f, h=%f", #size, size.width, size.height)

#define TTLOGEDGES(edges) \
  TTLOG(@"%s left=%f, right=%f, top=%f, bottom=%f", #edges, edges.left, edges.right, \
    edges.top, edges.bottom)

///////////////////////////////////////////////////////////////////////////////////////////////////
// Errors

#define TT_ERROR_DOMAIN @"three20i.org"

#define TT_EC_INVALID_IMAGE 101

///////////////////////////////////////////////////////////////////////////////////////////////////
// Dimensions of common iPhone OS Views

#define STATUS_HEIGHT 20
#define TOOLBAR_HEIGHT 44
#define KEYBOARD_HEIGHT 216
#define TABLE_GROUPED_PADDING 10
#define CHROME_HEIGHT (STATUS_HEIGHT + TOOLBAR_HEIGHT)

///////////////////////////////////////////////////////////////////////////////////////////////////
// Color helpers

#define RGBA(r,g,b,a) r/256.0, g/256.0, b/256.0, a
#define RGBCOLOR(r,g,b) [UIColor colorWithRed:r/256.0 green:g/256.0 blue:b/256.0 alpha:1]
#define RGBACOLOR(r,g,b,a) [UIColor colorWithRed:r/256.0 green:g/256.0 blue:b/256.0 alpha:a]

///////////////////////////////////////////////////////////////////////////////////////////////////
// Networking

typedef enum {
   TTURLRequestCachePolicyNone = 0,
   TTURLRequestCachePolicyMemory = 1,
   TTURLRequestCachePolicyDisk = 2,
   TTURLRequestCachePolicyNetwork = 4,
   TTURLRequestCachePolicyAny
    = (TTURLRequestCachePolicyMemory|TTURLRequestCachePolicyDisk|TTURLRequestCachePolicyNetwork),
   TTURLRequestCachePolicyNoCache = 8,    
   TTURLRequestCachePolicyDefault = TTURLRequestCachePolicyAny,
} TTURLRequestCachePolicy;

///////////////////////////////////////////////////////////////////////////////////////////////////
// Animation

/**
 * The standard duration for transition animations.
 */
#define TT_TRANSITION_DURATION 0.3

#define TT_FLIP_TRANSITION_DURATION 0.7

///////////////////////////////////////////////////////////////////////////////////////////////////

/**
 * Creates a mutable array which does not retain references to the objects it contains.
 */
NSMutableArray* TTCreateNonRetainingArray();

/**
 * Tests if an object is an array which is empty.
 */
BOOL TTIsEmptyArray(NSObject* object);

/**
 * Tests if an object is a string which is empty.
 */
BOOL TTIsEmptyString(NSObject* object);
/**
 * Gets the current device orientation.
 */
UIInterfaceOrientation TTDeviceOrientation();

/**
 * Gets the bounds of the screen with device orientation factored in.
 */
CGRect TTScreenBounds();

/**
 * Gets the application frame.
 */
CGRect TTApplicationFrame();

/**
 * Gets the application frame below the navigation bar.
 */
CGRect TTNavigationFrame();

/**
 * Returns a rectangle that is smaller or larger than the source rectangle.
 */
CGRect TTRectContract(CGRect rect, CGFloat dx, CGFloat dy);
 
/**
 * Increment the number of active network request.
 *
 * The status bar activity indicator will be spinning while there are active requests.
 */
void TTNetworkRequestStarted();

/**
 * Decrement the number of active network requests.
 *
 * The status bar activity indicator will be spinning while there are active requests.
 */
void TTNetworkRequestStopped();

/**
 * Gets the current system locale chosen by the user.
 *
 * This is necessary because [NSLocale currentLocale] always returns en_US.
 */
NSLocale* TTCurrentLocale();

/**
 * Returns a localized string from the Three20 bundle.
 */
NSString* TTLocalizedString(NSString* key, NSString* comment);

///////////////////////////////////////////////////////////////////////////////////////////////////

@protocol TTPersistable <NSObject>

@property(nonatomic,readonly) NSString* viewURL;

+ (id<TTPersistable>)fromURL:(NSURL*)url;

@end

///////////////////////////////////////////////////////////////////////////////////////////////////

@protocol TTLoadable <NSObject>

@property(nonatomic,readonly) NSMutableArray* delegates;
@property(nonatomic,readonly) NSDate* loadedTime;
@property(nonatomic,readonly) BOOL isLoaded;
@property(nonatomic,readonly) BOOL isLoading;
@property(nonatomic,readonly) BOOL isLoadingMore;
@property(nonatomic,readonly) BOOL isEmpty;

- (void)invalidate:(BOOL)erase;
- (void)cancel;

@end

