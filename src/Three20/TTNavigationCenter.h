#import "Three20/TTObject.h"

typedef enum {
  TTNavigationCreate,
  TTNavigationUpdate,
  TTNavigationSingleton,
  TTNavigationModal,
  TTNavigationCommand
} TTNavigationRule;

@protocol TTNavigationDelegate;
@class TTViewController;

@interface TTNavigationCenter : NSObject <UIAccelerometerDelegate> {
  id<TTNavigationDelegate> _delegate;
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

@property(nonatomic,assign) id<TTNavigationDelegate> delegate;
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

+ (TTNavigationCenter*)defaultCenter;
+ (void)setDefaultCenter:(TTNavigationCenter*)center;

- (void)addController:(Class)cls forView:(NSString*)viewType;
- (void)addController:(Class)cls forView:(NSString*)viewType rule:(TTNavigationRule)rule;
- (void)removeController:(NSString*)name;

- (void)addObjectLoader:(Class)cls name:(NSString*)name;
- (void)removeObjectLoader:(NSString*)name;
- (id<TTObject>)locateObject:(NSURL*)url;

- (void)addLinkObserver:(id)observer;
- (void)removeLinkObserver:(id)observer;

- (BOOL)serializeController:(UIViewController*)controller states:(NSMutableArray*)states;
- (void)restoreController:(UINavigationController*)navController;

- (void)persistControllers;
- (void)unpersistControllers;

- (NSString*)urlForObject:(id<TTObject>)object inView:(NSString*)viewType;
- (BOOL)urlIsSupported:(NSString*)url;

- (TTViewController*)displayURL:(NSString*)url;
- (TTViewController*)displayURL:(NSString*)url animated:(BOOL)animated;
- (TTViewController*)displayURL:(NSString*)url withState:(NSDictionary*)state animated:(BOOL)animated;

- (TTViewController*)displayObject:(id<TTObject>)object;
- (TTViewController*)displayObject:(id<TTObject>)object inView:(NSString*)viewType;
- (TTViewController*)displayObject:(id<TTObject>) object inView:(NSString*)viewType
  animated:(BOOL)animated;
- (TTViewController*)displayObject:(id<TTObject>)object inView:(NSString*)viewType 
  withState:(NSDictionary*)state animated:(BOOL)animated;

@end

@protocol TTNavigationDelegate <NSObject>

@optional

- (UINavigationController*)navigationControllerForObject:(id<TTObject>)object
  inView:(NSString*)viewType;

- (void)willNavigateToObject:(id<TTObject>)object inView:(NSString*)viewType
  withController:(UIViewController*)viewController;

- (void)didNavigateToObject:(id<TTObject>)object inView:(NSString*)viewType
  withController:(UIViewController*)viewController;
  
@end
