#import "Three20/T3Object.h"

typedef enum {
  T3NavigationCreate,
  T3NavigationUpdate,
  T3NavigationSingleton,
  T3NavigationModal,
  T3NavigationCommand
} T3NavigationRule;

@protocol T3NavigationDelegate;
@class T3ViewController;

@interface T3NavigationCenter : NSObject <UIAccelerometerDelegate> {
  id<T3NavigationDelegate> _delegate;
  BOOL _supportsShakeToReload;
  NSArray* _urlSchemes;
  UIViewController* _mainViewController;
  UINavigationController* _defaultNavigationController;
  NSMutableDictionary* _viewLoaders;
  NSMutableDictionary* _objectLoaders;
  NSMutableArray* _linkObservers;
  NSTimeInterval _persistStateAge;
	CFTimeInterval _lastShakeTime;
	UIAccelerationValue	_accel[3];
}

@property(nonatomic,assign) id<T3NavigationDelegate> delegate;
@property(nonatomic,retain) UIViewController* mainViewController;

/**
 * The URL schemes used by the application.
 *
 * When displaying a URL, if the URL scheme is in this array it will be mapped to a controller.
 * Otherwise, it will be passed to the OS for external use.
 */
@property(nonatomic,retain) NSArray* urlSchemes;

/**
 * Causes the current view controller to be reloaded when shaking the phone.
 */
@property(nonatomic) BOOL supportsShakeToReload;

+ (T3NavigationCenter*)defaultCenter;

- (void)addController:(Class)cls forView:(NSString*)viewType;
- (void)addController:(Class)cls forView:(NSString*)viewType rule:(T3NavigationRule)rule;
- (void)removeController:(NSString*)name;

- (void)addObjectLoader:(Class)cls name:(NSString*)name;
- (void)removeObjectLoader:(NSString*)name;
- (id<T3Object>)locateObject:(NSURL*)url;

- (void)addLinkObserver:(id)observer;
- (void)removeLinkObserver:(id)observer;

- (BOOL)serializeController:(UIViewController*)controller states:(NSMutableArray*)states;
- (void)restoreController:(UINavigationController*)navController;

- (void)persistControllers;
- (void)unpersistControllers;

- (NSString*)urlForObject:(id<T3Object>)object inView:(NSString*)viewType;
- (BOOL)urlIsSupported:(NSString*)url;

- (T3ViewController*)displayURL:(NSString*)url;
- (T3ViewController*)displayURL:(NSString*)url animated:(BOOL)animated;
- (T3ViewController*)displayURL:(NSString*)url withState:(NSDictionary*)state animated:(BOOL)animated;

- (T3ViewController*)displayObject:(id<T3Object>)object;
- (T3ViewController*)displayObject:(id<T3Object>)object inView:(NSString*)viewType;
- (T3ViewController*)displayObject:(id<T3Object>) object inView:(NSString*)viewType
  animated:(BOOL)animated;
- (T3ViewController*)displayObject:(id<T3Object>)object inView:(NSString*)viewType 
  withState:(NSDictionary*)state animated:(BOOL)animated;

@end

@protocol T3NavigationDelegate <NSObject>

@optional

- (UINavigationController*)navigationControllerForObject:(id<T3Object>)object
  inView:(NSString*)viewType;

- (void)willNavigateToObject:(id<T3Object>)object inView:(NSString*)viewType
  withController:(UIViewController*)viewController;

- (void)didNavigateToObject:(id<T3Object>)object inView:(NSString*)viewType
  withController:(UIViewController*)viewController;
  
@end
