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

@interface T3NavigationCenter : NSObject {
  id<T3NavigationDelegate> _delegate;
  UIViewController* _mainViewController;
  UINavigationController* _defaultNavigationController;
  NSMutableDictionary* _viewLoaders;
  NSMutableDictionary* _objectLoaders;
  NSMutableArray* _linkObservers;
  NSTimeInterval _persistStateAge;
}

@property(nonatomic,assign) id<T3NavigationDelegate> delegate;
@property(nonatomic,retain) UIViewController* mainViewController;

+ (T3NavigationCenter*)defaultCenter;

- (void)addController:(Class)cls name:(NSString*)name rule:(T3NavigationRule)rule;
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

- (UINavigationController*)getNavigationControllerForObject:(id<T3Object>)object
  view:(NSString*)viewType;

@end
