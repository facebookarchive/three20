#import "Three20/TTGlobal.h"

#define TT_NULL_URL @" "

@protocol TTAppBrowserDelegate;

@interface TTAppBrowser : NSObject {
  id<TTAppBrowserDelegate> _delegate;
  UIViewController* _mainViewController;
  BOOL _supportsShakeToReload;
  NSTimeInterval _persistStateAge;
}

@property(nonatomic,assign) id<TTAppBrowserDelegate> delegate;

@property(nonatomic,retain) UIViewController* mainViewController;

@property(nonatomic,readonly) UIViewController* visibleViewController;

/**
 * Causes the current view controller to be reloaded when shaking the phone.
 */
@property(nonatomic) BOOL supportsShakeToReload;

+ (TTAppBrowser*)sharedBrowser;

/**
 *
 */
- (void)loadURL:(NSString*)URL;

/**
 *
 */
- (void)addURL:(NSString*)URL controller:(Class)controller selector:(SEL)selector;

/**
 *
 */
- (void)addURL:(NSString*)URL parent:(NSString*)parentURL controller:(Class)controller
        selector:(SEL)selector;

/**
 *
 */
- (void)addURL:(NSString*)URL singleton:(Class)controller selector:(SEL)selector;

/**
 *
 */
- (void)addURL:(NSString*)URL parent:(NSString*)parentURL singleton:(Class)controller
        selector:(SEL)selector;

/**
 *
 */
- (void)addURL:(NSString*)URL modal:(Class)controller selector:(SEL)selector;

/**
 *
 */
- (void)addURL:(NSString*)URL parent:(NSString*)parentURL modal:(Class)controller
        selector:(SEL)selector;

/**
 * Assigns a controller to a specific URL.
 *
 * All requests to load the URL will display the controller instead of performing the
 * usual pattern match.
 */
- (void)setController:(UIViewController*)controller forURL:(NSURL*)URL;

/**
 * Removes a controller from being assigned to a URL.
 */
- (void)removeController:(UIViewController*)controller forURL:(NSURL*)URL;

@end

///////////////////////////////////////////////////////////////////////////////////////////////////

@protocol TTAppBrowserDelegate <NSObject>

@optional
  
@end

///////////////////////////////////////////////////////////////////////////////////////////////////

/**
 * Shortcut for calling loading a URL in the shared app browser.
 */
void TTLoadURL(NSString* URL);
