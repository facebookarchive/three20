#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "Three20/NSObjectAdditions.h"
#import "Three20/NSStringAdditions.h"
#import "Three20/NSDateAdditions.h"
#import "Three20/NSArrayAdditions.h"
#import "Three20/UIColorAdditions.h"
#import "Three20/UIFontAdditions.h"
#import "Three20/UIImageAdditions.h"
#import "Three20/UIViewControllerAdditions.h"
#import "Three20/UINavigationControllerAdditions.h"
#import "Three20/UITabBarControllerAdditions.h"
#import "Three20/UIViewAdditions.h"
#import "Three20/UITableViewAdditions.h"
#import "Three20/UIWebViewAdditions.h"
#import "Three20/UIToolbarAdditions.h"

///////////////////////////////////////////////////////////////////////////////////////////////////
// Logging Helpers

#ifdef DEBUG
#define TTLOG NSLog
#else
#define TTLOG    
#endif

#define TTWARN TTLOG

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

#define TTLOGHSV(_COLOR) \
  TTLOG(@"%s h=%f, s=%f, v=%f", #_COLOR, _COLOR.hue, _COLOR.saturation, _COLOR.value)

///////////////////////////////////////////////////////////////////////////////////////////////////
// Errors

#define TT_ERROR_DOMAIN @"three20.net"

#define TT_EC_INVALID_IMAGE 101

///////////////////////////////////////////////////////////////////////////////////////////////////
// Dimensions of common iPhone OS Views

#define TT_ROW_HEIGHT 44
#define TT_KEYBOARD_HEIGHT 216
#define TT_ROUNDED -1

///////////////////////////////////////////////////////////////////////////////////////////////////
// Color helpers

#define RGBCOLOR(r,g,b) [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:1]
#define RGBACOLOR(r,g,b,a) [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:a]

#define HSVCOLOR(h,s,v) [UIColor colorWithHue:h saturation:s value:v alpha:1]
#define HSVACOLOR(h,s,v,a) [UIColor colorWithHue:h saturation:s value:v alpha:a]

#define RGBA(r,g,b,a) r/255.0, g/255.0, b/255.0, a

///////////////////////////////////////////////////////////////////////////////////////////////////
// Style helpers

#define TTSTYLE(_SELECTOR) [[TTStyleSheet globalStyleSheet] styleWithSelector:@#_SELECTOR]

#define TTSTYLESTATE(_SELECTOR, _STATE) [[TTStyleSheet globalStyleSheet] \
                                           styleWithSelector:@#_SELECTOR forState:_STATE]

#define TTSTYLESHEET ((id)[TTStyleSheet globalStyleSheet])

#define TTSTYLEVAR(_VARNAME) [TTSTYLESHEET _VARNAME]

#define TTLOGVIEWS(_VIEW) \
  { for (UIView* view = _VIEW; view; view = view.superview) { TTLOG(@"%@", view); } }

#define TTIMAGE(_URL) [[TTURLCache sharedCache] imageForURL:_URL]

typedef enum {
  TTPositionStatic,
  TTPositionAbsolute,
  TTPositionFloatLeft,
  TTPositionFloatRight,
} TTPosition;

///////////////////////////////////////////////////////////////////////////////////////////////////
// Networking

typedef enum {
   TTURLRequestCachePolicyNone = 0,
   TTURLRequestCachePolicyMemory = 1,
   TTURLRequestCachePolicyDisk = 2,
   TTURLRequestCachePolicyNetwork = 4,
   TTURLRequestCachePolicyNoCache = 8,    
   TTURLRequestCachePolicyLocal
    = (TTURLRequestCachePolicyMemory|TTURLRequestCachePolicyDisk),
   TTURLRequestCachePolicyDefault
    = (TTURLRequestCachePolicyMemory|TTURLRequestCachePolicyDisk|TTURLRequestCachePolicyNetwork),
} TTURLRequestCachePolicy;

#define TT_DEFAULT_CACHE_INVALIDATION_AGE (60*60*24) // 1 day
#define TT_DEFAULT_CACHE_EXPIRATION_AGE (60*60*24*7) // 1 week

///////////////////////////////////////////////////////////////////////////////////////////////////
// Time

#define TT_MINUTE 60
#define TT_HOUR (60*TT_MINUTE)
#define TT_DAY (24*TT_HOUR)
#define TT_WEEK (7*TT_DAY)
#define TT_MONTH (30.5*TT_DAY)
#define TT_YEAR (365*TT_DAY)

///////////////////////////////////////////////////////////////////////////////////////////////////
// Animation

/**
 * The standard duration for transition animations.
 */
#define TT_TRANSITION_DURATION 0.3

#define TT_FAST_TRANSITION_DURATION 0.2

#define TT_FLIP_TRANSITION_DURATION 0.7

///////////////////////////////////////////////////////////////////////////////////////////////////

#define TT_RELEASE_SAFELY(__POINTER) { [__POINTER release]; __POINTER = nil; }
#define TT_AUTORELEASE_SAFELY(__POINTER) { [__POINTER autorelease]; __POINTER = nil; }
#define TT_INVALIDATE_TIMER(__TIMER) { [__TIMER invalidate]; __TIMER = nil; }

///////////////////////////////////////////////////////////////////////////////////////////////////

/**
 * Creates a mutable array which does not retain references to the objects it contains.
 */
NSMutableArray* TTCreateNonRetainingArray();

/**
 * Creates a mutable dictionary which does not retain references to the values it contains.
 */
NSMutableDictionary* TTCreateNonRetainingDictionary();

/**
 * Tests if an object is an array which is empty.
 */
BOOL TTIsEmptyArray(id object);

/**
 * Tests if an object is a set which is empty.
 */
BOOL TTIsEmptyArray(id object);

/**
 * Tests if an object is a string which is empty.
 */
BOOL TTIsEmptyString(id object);

/**
 * Tests if the keyboard is visible.
 */
BOOL TTIsKeyboardVisible();

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
 * Gets the application frame below the navigation bar and above the keyboard.
 */
CGRect TTKeyboardNavigationFrame();

/**
 * Gets the application frame below the navigation bar and above a toolbar.
 */
CGRect TTToolbarNavigationFrame();

/**
 * The height of the area containing the status bar and possibly the in-call status bar.
 */
CGFloat TTStatusHeight();

/**
 * The height of the area containing the status bar and navigation bar.
 */
CGFloat TTBarsHeight();

/**
 * Returns a rectangle that is smaller or larger than the source rectangle.
 */
CGRect TTRectContract(CGRect rect, CGFloat dx, CGFloat dy);

/**
 * Returns a rectangle whose edges have been moved a distance and shortened by that distance.
 */
CGRect TTRectShift(CGRect rect, CGFloat dx, CGFloat dy);

/**
 * Returns a rectangle whose edges have been added to the insets.
 */
CGRect TTRectInset(CGRect rect, UIEdgeInsets insets);
 
/**
 * Increment the number of active network requests.
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
 * A convenient way to show a UIAlertView with a message;
 */
void TTAlert(NSString* message);
void TTAlertError(NSString* message);

/**
 * Gets the current runtime version of iPhone OS.
 */
float TTOSVersion();

/**
 * Checks if the link-time version of the OS is at least a certain version.
 */
BOOL TTOSVersionIsAtLeast(float version);

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

NSString* TTDescriptionForError(NSError* error);

NSString* TTFormatInteger(NSInteger num);

BOOL TTIsBundleURL(NSString* URL);

BOOL TTIsDocumentsURL(NSString* URL);

NSString* TTPathForBundleResource(NSString* relativePath);

NSString* TTPathForDocumentsResource(NSString* relativePath);

void TTSwapMethods(Class cls, SEL originalSel, SEL newSel);
