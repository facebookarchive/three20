#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "Three20/T3+UIViewController.h"

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
// Errors

#define T3_ERROR_DOMAIN @"three20i.org"

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

#define T3_FLIP_TRANSITION_DURATION 0.7

///////////////////////////////////////////////////////////////////////////////////////////////////
// URL Cache

typedef enum {
   T3URLRequestCachePolicyNone = 0,
   T3URLRequestCachePolicyMemory = 1,
   T3URLRequestCachePolicyDisk = 2,
   T3URLRequestCachePolicyNetwork = 4,
   T3URLRequestCachePolicyAny
    = (T3URLRequestCachePolicyMemory|T3URLRequestCachePolicyDisk|T3URLRequestCachePolicyNetwork),
   T3URLRequestCachePolicyNoCache = 8,    
} T3URLRequestCachePolicy;

#define T3_DEFAULT_CACHE_AGE (60*3)

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

///////////////////////////////////////////////////////////////////////////////////////////////////

@interface NSObject (T3Category)

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

@interface UIView (T3Category)

@property(nonatomic) CGFloat x;
@property(nonatomic) CGFloat y;
@property(nonatomic) CGFloat width;
@property(nonatomic) CGFloat height;

@property(nonatomic,readonly) CGFloat right;
@property(nonatomic,readonly) CGFloat bottom;

@property(nonatomic,readonly) CGFloat screenX;
@property(nonatomic,readonly) CGFloat screenY;

@property(nonatomic,readonly) CGFloat screenViewX;
@property(nonatomic,readonly) CGFloat screenViewY;

@property(nonatomic,readonly) CGFloat orientationWidth;
@property(nonatomic,readonly) CGFloat orientationHeight;

- (UIScrollView*)findFirstScrollView;

- (UIView*)firstViewOfClass:(Class)cls;

- (UIView*)firstParentOfClass:(Class)cls;

- (UIView*)findChildWithDescendant:(UIView*)descendant;

/**
 *
 */
- (void)removeSubviews;

/**
 * WARNING: This depends on undocumented APIs and may be fragile.  For testing only.
 */
- (void)simulateTapAtPoint:(CGPoint)location;

- (void)sizeToFitKeyboard:(BOOL)keyboard animated:(BOOL)animated;

@end

///////////////////////////////////////////////////////////////////////////////////////////////////

@interface UITableView (T3Category)

/**
 * The view that contains the "index" along the right side of the table.
 */
@property(nonatomic,readonly) UIView* indexView;

- (void)touchRowAtIndexPath:(NSIndexPath*)indexPath animated:(BOOL)animated;

/**
 * Expand or contract the table to fit the keyboard.
 *
 * @param indexPath The index path to make visible after the expansion.
 */
- (void)sizeToFitKeyboard:(BOOL)keyboard atIndexPath:(NSIndexPath*)indexPath
    animated:(BOOL)animated;

@end

///////////////////////////////////////////////////////////////////////////////////////////////////

@interface UIWebView (T3Category)

/**
 * Gets the frame of a DOM element in the page.
 *
 * @query A JavaScript expression that evaluates to a single DOM element.
 */
- (CGRect)frameOfElement:(NSString*)query;

@end

///////////////////////////////////////////////////////////////////////////////////////////////////

@interface UIToolbar (T3Category)

- (UIBarButtonItem*)itemWithTag:(NSInteger)tag;

- (void)replaceItemWithTag:(NSInteger)tag withItem:(UIBarButtonItem*)item;

@end
