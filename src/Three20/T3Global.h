#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

///////////////////////////////////////////////////////////////////////////////////////////////////
// Logging Helpers

#ifdef DEBUG
#define T3LOG NSLog
#else
#define T3LOG    
#endif

#define T3LOGRECT(rect) \
  T3LOG(@"RECT x=%f, y=%f, w=%f, h=%f", rect.origin.x, rect.origin.y, \
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
// Cache times

#define T3_SKIP_CACHE CGFLOAT_MAX
#define T3_ALWAYS_USE_CACHE 0
#define T3_DEFAULT_CACHE_AGE 60*3 // 3 minutes
#define T3_LONG_CACHE_AGE 60*60*24*7 // 1 week

///////////////////////////////////////////////////////////////////////////////////////////////////
// Animation

/**
 * The standard duration for transition animations.
 */
#define T3_TRANSITION_DURATION 0.3

///////////////////////////////////////////////////////////////////////////////////////////////////

/**
 * Creates a mutable array which does not retain references to the objects it contains.
 */
NSMutableArray* T3CreateNonRetainingArray();

/**
 * Gets the current device orientation.
 */
UIInterfaceOrientation T3DeviceOrientation();

///////////////////////////////////////////////////////////////////////////////////////////////////

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

///////////////////////////////////////////////////////////////////////////////////////////////////

@interface NSObject (T3Extensions)

/**
 * Additional performSelector signatures that support up to 7 arguments.
 */
- (id)performSelector:(SEL)selector withObject:(id)p1 withObject:(id)p2 withObject:(id)p3;
- (id)performSelector:(SEL)selector withObject:(id)p1 withObject:(id)p2 withObject:(id)p3
  withObject:(id)p4;
- (id)performSelector:(SEL)selector withObject:(id)p1 withObject:(id)p2 withObject:(id)p3
  withObject:(id)p4 withObject:(id)p5;
- (id)performSelector:(SEL)selector withObject:(id)p1 withObject:(id)p2 withObject:(id)p3
  withObject:(id)p4 withObject:(id)p5 withObject:(id)p6;
- (id)performSelector:(SEL)selector withObject:(id)p1 withObject:(id)p2 withObject:(id)p3
  withObject:(id)p4 withObject:(id)p5 withObject:(id)p6 withObject:(id)p7;

@end

///////////////////////////////////////////////////////////////////////////////////////////////////

@interface UIView (T3Extensions)

@property(nonatomic) CGFloat x;
@property(nonatomic) CGFloat y;
@property(nonatomic) CGFloat width;
@property(nonatomic) CGFloat height;

@property(nonatomic, readonly) CGFloat right;
@property(nonatomic, readonly) CGFloat bottom;

@property(nonatomic, readonly) CGFloat screenX;
@property(nonatomic, readonly) CGFloat screenY;

@property(nonatomic, readonly) CGFloat screenViewX;
@property(nonatomic, readonly) CGFloat screenViewY;

- (UIScrollView*)findFirstScrollView;
- (UIView*)firstViewOfClass:(Class)cls;
- (UIView*)firstParentOfClass:(Class)cls;
- (UIView*)childWithDescendant:(UIView*)descendant;

/**
 * WARNING: This depends on undocumented APIs and may be fragile.
 */
- (void)simulateTapAtPoint:(CGPoint)location;

@end

@interface UITableView (T3Extensions)

/**
 * The view that contains the "index" along the right side of the table.
 */
@property(nonatomic, readonly) UIView* indexView;

@end
@interface UIWebView (T3Extensions)

- (CGRect)frameOfElement:(NSString*)query;

@end

@interface UIViewController (T3Extensions)

/**
 * The view controller that comes before this one in a navigation controller.
 */
- (UIViewController*)previousViewController;
- (UIViewController*)nextViewController;

- (void)alert:(NSString*)message title:(NSString*)title delegate:(id)delegate;
- (void)alert:(NSString*)message;
- (void)alertError:(NSString*)message;

@end
