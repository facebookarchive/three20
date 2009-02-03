#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "Three20/T3+NSObject.h"
#import "Three20/T3+UIViewController.h"
#import "Three20/T3+UIView.h"
#import "Three20/T3+UITableView.h"
#import "Three20/T3+UIWebView.h"

///////////////////////////////////////////////////////////////////////////////////////////////////
// Logging Helpers

#ifdef DEBUG
#define T3LOG NSLog
#else
#define T3LOG    
#endif

#define T3LOGRECT(rect) \
  T3LOG(@"%s x=%f, y=%f, w=%f, h=%f", #rect, rect.origin.x, rect.origin.y, \
    rect.size.width, rect.size.height)

#define T3LOGEDGES(edges) \
  T3LOG(@"%s left=%f, right=%f, top=%f, bottom=%f", #edges, edges.left, edges.right, \
    edges.top, edges.bottom)

///////////////////////////////////////////////////////////////////////////////////////////////////
// Dimensions of common iPhone OS Views

#define STATUS_HEIGHT 20
#define TOOLBAR_HEIGHT 44
#define TABBAR_HEIGHT 47
#define PROMPT_HEIGHT 30
#define CHROME_HEIGHT 64
#define KEYBOARD_HEIGHT 216
#define CONTENT_HEIGHT (KEYBOARD_HEIGHT - TOOLBAR_HEIGHT)

///////////////////////////////////////////////////////////////////////////////////////////////////
// Color helpers

#define RGBA(r,g,b,a) r/256.0, g/256.0, b/256.0, a
#define RGBCOLOR(r,g,b) [UIColor colorWithRed:r/256.0 green:g/256.0 blue:b/256.0 alpha:1]
#define RGBACOLOR(r,g,b,a) [UIColor colorWithRed:r/256.0 green:g/256.0 blue:b/256.0 alpha:a]

///////////////////////////////////////////////////////////////////////////////////////////////////
// Animation

/**
 * The standard duration for transition animations.
 */
#define T3_TRANSITION_DURATION 0.3

///////////////////////////////////////////////////////////////////////////////////////////////////
// URL Cache

typedef enum {
   T3URLRequestCachePolicyNone = 0,
   T3URLRequestCachePolicyMemory = 1,
   T3URLRequestCachePolicyDisk = 2,
   T3URLRequestCachePolicyNetwork = 4,
   T3URLRequestCachePolicyAny
    = (T3URLRequestCachePolicyMemory|T3URLRequestCachePolicyDisk|T3URLRequestCachePolicyNetwork)
} T3URLRequestCachePolicy;

#define T3_SKIP_CACHE CGFLOAT_MAX
#define T3_ALWAYS_USE_CACHE 0
#define T3_DEFAULT_CACHE_AGE (60*3)
#define T3_LONG_CACHE_AGE (60*60*24*7)

///////////////////////////////////////////////////////////////////////////////////////////////////

/**
 * Creates a mutable array which does not retain references to the objects it contains.
 */
NSMutableArray* T3CreateNonRetainingArray();

/**
 * Tests if an object is an array which is empty.
 */
BOOL T3EmptyArray(NSObject* object);

/**
 * Tests if an object is a string which is empty.
 */
BOOL T3EmptyString(NSObject* object);
/**
 * Gets the current device orientation.
 */
UIInterfaceOrientation T3DeviceOrientation();

/**
 * Gets the bounds of the screen with device orientation factored in.
 */
CGRect T3ScreenBounds();
 
/**
 * Increment the number of active network request.
 *
 * The status bar activity indicator will be spinning while there are active requests.
 */
void T3NetworkRequestStarted();

/**
 * Decrement the number of active network requests.
 *
 * The status bar activity indicator will be spinning while there are active requests.
 */
void T3NetworkRequestStopped();

/*
 * Resizes and/or rotates an image.
 */
UIImage* T3TransformImage(UIImage* image, CGFloat width, CGFloat height, BOOL rotate);
