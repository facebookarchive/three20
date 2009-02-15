#import "Three20/T3NavigationCenter.h"
#import "Three20/T3ViewController.h"
#import "Three20/T3Object.h"

///////////////////////////////////////////////////////////////////////////////////////////////////

static NSTimeInterval kPersistStateAge = 60 * 60 * 4;

static const int kAccelerometerFrequency = 25; //Hz
static const float kFilteringFactor = 0.1;
static const float kMinEraseInterval = 0.5;
static const float kEraseAccelerationThreshold = 3.0;

static T3NavigationCenter* gDefaultCenter = nil;

///////////////////////////////////////////////////////////////////////////////////////////////////

@interface T3NavigationEntry : NSObject {
  Class _cls;
  T3NavigationRule _rule;
}

@property(nonatomic,readonly) Class cls;
@property(nonatomic,readonly) T3NavigationRule rule;

- (id)initWithClass:(Class)cls rule:(T3NavigationRule)rule;

@end

@implementation T3NavigationEntry

@synthesize cls = _cls, rule = _rule;

- (id)initWithClass:(Class)controllerClass rule:(T3NavigationRule)rule {
  if (self = [super init]) {
    _cls = controllerClass;
    _rule = rule;
  }
  return self;
}

@end

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation T3NavigationCenter

@synthesize delegate = _delegate, urlSchemes = _urlSchemes,
  mainViewController = _mainViewController, supportsShakeToReload = _supportsShakeToReload;

+ (T3NavigationCenter*)defaultCenter {
  if (!gDefaultCenter) {
    return [[[T3NavigationCenter alloc] init] autorelease];
  }
  return gDefaultCenter;
}

+ (void)setDefaultCenter:(T3NavigationCenter*)center {
  if (gDefaultCenter != center) {
    [gDefaultCenter release];
    gDefaultCenter = [center retain];
  }
}

///////////////////////////////////////////////////////////////////////////////////////////////////

- (id)init {
  if (self = [super init]) {
    _mainViewController = nil;
    _delegate = nil;
    _urlSchemes = nil;
    _supportsShakeToReload = NO;
    _linkObservers = [[NSMutableArray alloc] init];
    _objectLoaders = [[NSMutableDictionary alloc] init];
    _viewLoaders = [[NSMutableDictionary alloc] init];
    _persistStateAge = kPersistStateAge;
    _lastShakeTime = 0;
    
    if (!gDefaultCenter) {
      gDefaultCenter = [self retain];
    }
  }
  return self;
}

- (void)dealloc {
  [_urlSchemes release];
  [_mainViewController release];
  [_linkObservers release];
  [_viewLoaders release];
  [super dealloc];
}

///////////////////////////////////////////////////////////////////////////////////////////////////

- (UINavigationController*)topNavigationController {
  if ([_mainViewController isKindOfClass:[UITabBarController class]]) {
    UITabBarController* tabBarController = (UITabBarController*)_mainViewController;
    if (tabBarController.selectedViewController) {
      return (UINavigationController*)tabBarController.selectedViewController;
    } else {
      return (UINavigationController*)[tabBarController.viewControllers objectAtIndex:0];
    }
  } else if ([_mainViewController isKindOfClass:[UINavigationController class]]) {
    return (UINavigationController*)_mainViewController;
  } else {
    return nil;
  }
}

- (T3ViewController*)currentViewController {
  UIViewController* controller = nil;
  UINavigationController* navController = [self topNavigationController];
  if (navController) {
    controller = [navController.viewControllers lastObject];
  } else {
    controller = _mainViewController;
  }
  if ([controller isKindOfClass:[T3ViewController class]]) {
    return (T3ViewController*)controller;
  } else {
    return nil;
  }
}

- (NSArray*)stateFromNavigationController:(UINavigationController*)navController {
  NSMutableArray* states = [NSMutableArray array];

  for (UIViewController* controller in navController.viewControllers) {
    if (![self serializeController:controller states:states])
      break;
  }
    
  if ([_mainViewController isKindOfClass:[UITabBarController class]]) {
    UITabBarController* tabBarController = (UITabBarController*)_mainViewController;
    if (navController == tabBarController.selectedViewController
        && navController.modalViewController) {
      [self serializeController:navController.modalViewController states:states];
    }
  }
  
  return states;
}

- (NSArray*)stateForNavigationController:(UINavigationController*)navController {
  NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
  int index = 0;
  if ([_mainViewController isKindOfClass:[UITabBarController class]]) {
    UITabBarController* tabBarController = (UITabBarController*)_mainViewController;
    index = [tabBarController.viewControllers indexOfObject:navController];
  }
  if (index != NSNotFound) {
    NSString* key = [NSString stringWithFormat:@"T3NavigationState%d", index];
    NSArray* state = [defaults arrayForKey:key];
    if (state) {
      [defaults removeObjectForKey:key];
      return state;
    }
  }

  return nil;
}

- (BOOL)dispatchLink:(id<T3Object>)object inView:(NSString*)viewType animated:(BOOL)animated {
  if (_linkObservers) {
    SEL selector = @selector(linkVisited:viewType:animated:);
    for (int i = 0; i < _linkObservers.count; ++i) {
      id observer = [_linkObservers objectAtIndex:i];
      if ([observer respondsToSelector:selector]) {
        if (![observer performSelector:selector withObject:object withObject:viewType
            withObject:(id)(int)animated]) {
          return NO;
        }
      }
    }
  }
  
  return YES;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// UIAccelerometerDelegate

- (void)accelerometer:(UIAccelerometer *)accelerometer
    didAccelerate:(UIAcceleration *)acceleration {
	UIAccelerationValue length, x, y, z;
	_accel[0] = acceleration.x * kFilteringFactor + _accel[0] * (1.0 - kFilteringFactor);
	_accel[1] = acceleration.y * kFilteringFactor + _accel[1] * (1.0 - kFilteringFactor);
	_accel[2] = acceleration.z * kFilteringFactor + _accel[2] * (1.0 - kFilteringFactor);
	x = acceleration.x - _accel[0];
	y = acceleration.y - _accel[0];
	z = acceleration.z - _accel[0];
	length = sqrt(x * x + y * y + z * z);
  
	if((length >= kEraseAccelerationThreshold)
      && (CFAbsoluteTimeGetCurrent() > _lastShakeTime + kMinEraseInterval)) {
		_lastShakeTime = CFAbsoluteTimeGetCurrent();

    [self.currentViewController reloadContent];
	}
}
///////////////////////////////////////////////////////////////////////////////////////////////////

- (void)setSupportsShakeToReload:(BOOL)supports {
  _supportsShakeToReload = supports;

  UIAccelerometer* accelerometer = [UIAccelerometer sharedAccelerometer];
  if (_supportsShakeToReload) {
    accelerometer.updateInterval = 1.0 / kAccelerometerFrequency;
    accelerometer.delegate = self;
  } else {
    accelerometer.delegate = nil;
  }
}

- (void)addController:(Class)cls forView:(NSString*)viewType {
  [self addController:cls forView:viewType rule:T3NavigationCreate];
}

- (void)addController:(Class)cls forView:(NSString*)viewType rule:(T3NavigationRule)rule {
  T3NavigationEntry* entry = [[[T3NavigationEntry alloc] initWithClass:cls rule:rule] autorelease];
  [_viewLoaders setObject:entry forKey:viewType];
}

- (void)removeController:(NSString*)viewType {
  [_viewLoaders removeObjectForKey:viewType];
}

- (void)addObjectLoader:(Class)cls name:(NSString*)name {
  [_objectLoaders setObject:cls forKey:name];
}

- (void)removeObjectLoader:(NSString*)name {
  [_objectLoaders removeObjectForKey:name];
}

- (id<T3Object>)locateObject:(NSURL*)url {
  if (_objectLoaders) {
    Class cls = [_objectLoaders objectForKey:url.host];
    if (cls) {
      return [cls fromURL:url];
    }
  }
  
  return nil;
}

- (void)addLinkObserver:(id)observer {
  [_linkObservers addObject:observer];
}

- (void)removeLinkObserver:(id)observer {
  [_linkObservers removeObject:observer];
}

- (BOOL)serializeController:(UIViewController*)controller states:(NSMutableArray*)states {
  if ([controller isKindOfClass:[T3ViewController class]]) {
    T3ViewController* viewController = (T3ViewController*)controller;
    id<T3Object> object = viewController.viewObject;
    if (object) {
      NSString* url = [self urlForObject:object inView:viewController.viewType];
      if (url) {
        [states addObject:url];

        if (viewController.viewState) {
          [states addObject:viewController.viewState];
        } else {
          NSMutableDictionary* viewState = [NSMutableDictionary dictionary];
          if (viewController.appeared) {
            [viewController persistView:viewState];
          }
          [states addObject:viewState];
        }
        return YES;
      }
    }
  }

  return NO;
}

- (void)restoreController:(UINavigationController*)navController { 
  NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
  NSDate* persistedTime = [defaults objectForKey:@"T3NavigationStateTime"];
  if (-[persistedTime timeIntervalSinceNow] > _persistStateAge) {
    return;
  }

  NSArray* state = [self stateForNavigationController:navController];
  _defaultNavigationController = navController;
  
  for (int i = 0; i < state.count; i += 2) {
    NSString* url = [state objectAtIndex:i];
    NSDictionary* viewState = [state objectAtIndex:i+1];
    if ((NSNull*)viewState == [NSNull null]) {
      viewState = nil;
    }
    
    if (![self displayURL:url withState:viewState animated:NO])
      break;
    
    T3ViewController* topController = (T3ViewController*)navController.topViewController;
    [topController updateContent];
    if (!topController.contentState & T3ContentReady) {
      break;
    }
  }

  _defaultNavigationController = nil;
}

- (void)persistControllers {
  NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
  [defaults setObject:[NSDate date] forKey:@"T3NavigationStateTime"];
  
  if ([_mainViewController isKindOfClass:[UITabBarController class]]) {
    UITabBarController* tabBarController = (UITabBarController*)_mainViewController;
    for (int i = 0; i < tabBarController.viewControllers.count; ++i) {
      UINavigationController* controller = [tabBarController.viewControllers objectAtIndex:i];
      NSArray* state = [self stateFromNavigationController:controller];
      if (state.count) {
        NSString* key = [NSString stringWithFormat:@"T3NavigationState%d", i];
        [defaults setObject:state forKey:key];
      }
    }
  } else if ([_mainViewController isKindOfClass:[UINavigationController class]]) {
    UINavigationController* controller = (UINavigationController*)_mainViewController;
    NSArray* state = [self stateFromNavigationController:controller];
    if (state.count) {
      NSString* key = [NSString stringWithFormat:@"T3NavigationState%d", 0];
      [defaults setObject:state forKey:key];
    }
  }
}

- (void)unpersistControllers {
  NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
  [defaults removeObjectForKey:@"T3NavigationStateTime"];

  for (int i = 0; i < 5; ++i) {
    NSString* key = [NSString stringWithFormat:@"T3NavigationState%d", i];
    [defaults removeObjectForKey:key];
  }
}

- (NSString*)urlForObject:(id<T3Object>)object inView:(NSString*)viewType {
  if (viewType) {
    return [NSString stringWithFormat:@"%@?%@", object.viewURL, viewType];
  } else {
    return object.viewURL;
  }
}

- (BOOL)urlIsSupported:(NSString*)u {
  NSURL* url = [NSURL URLWithString:u];
  if (_urlSchemes) {
    return [_urlSchemes indexOfObject:url.scheme] != NSNotFound;
  } else {
    return NO;
  }
}

- (T3ViewController*)displayURL:(NSString*)url {
  return [self displayURL:url withState:nil animated:YES];
}

- (T3ViewController*)displayURL:(NSString*)url animated:(BOOL)animated {
  return [self displayURL:url withState:nil animated:animated];
}

- (T3ViewController*)displayURL:(NSString*)u withState:(NSDictionary*)state
    animated:(BOOL)animated {
  NSURL* url = [NSURL URLWithString:u];
  if ([_urlSchemes indexOfObject:url.scheme] == NSNotFound) {
    [[UIApplication sharedApplication] openURL:url];
  } else if (_viewLoaders) {
    id<T3Object> object = [self locateObject:url];
    NSString* viewType = object && url.query ? url.query : url.host;
    if (![self dispatchLink:object inView:viewType animated:animated]) {
      return nil;
    }
    
    UINavigationController* navController = nil;
    
    if ([_delegate respondsToSelector:@selector(navigationControllerForObject:inView:)]) {
      navController = [_delegate navigationControllerForObject:object inView:viewType];
    }
    
    if (!navController) {
      navController = self.topNavigationController;
    }
    
    T3NavigationEntry* entry = [_viewLoaders objectForKey:viewType];
    if (!entry)
      return nil;
    
    T3ViewController* viewController = nil;
    if (entry.rule == T3NavigationSingleton) {
      for (int i = 0; i < navController.viewControllers.count; ++i) {
        UIViewController* controller = [navController.viewControllers objectAtIndex:i];
        if ([controller isKindOfClass:entry.cls]) {
          viewController = (T3ViewController*)controller;
        }
      }
    } else if (entry.rule == T3NavigationUpdate) {
      if ([navController.topViewController isKindOfClass:entry.cls]) {
        T3ViewController* topViewController = (T3ViewController*)navController.topViewController;
        if (topViewController.viewObject == object) {
          viewController = topViewController;
        }
      }
    }

    if (!viewController) {
      viewController = [[[entry.cls alloc] init] autorelease];
    }
    
    if (object) {
      [viewController showObject:object inView:viewType withState:state];
    }
    
    if ([_delegate respondsToSelector:@selector(willNavigateToObject:inView:withController:)]) {
      [_delegate willNavigateToObject:object inView:viewType withController:viewController];
    }
    
    if (entry.rule == T3NavigationModal) {
      [navController presentModalViewController:viewController animated:animated];
    } else if (entry.rule == T3NavigationCommand) {
      if ([viewController respondsToSelector:@selector(performCommand:)]) {
        [viewController performSelector:@selector(performCommand:) withObject:navController];
      }
    } else {
      if (!state && navController.tabBarController) {
        navController.tabBarController.selectedViewController = navController;
      }
      
      if (!viewController.parentViewController) {
        for (UIViewController* c in navController.viewControllers) {
          if (c.hidesBottomBarWhenPushed) {
            viewController.hidesBottomBarWhenPushed = NO;
            break;
          }
        }

        [navController pushViewController:viewController animated:animated];
      } else {
        [navController popToViewController:viewController animated:animated];
      }
    }

    if ([_delegate respondsToSelector:@selector(didNavigateToObject:inView:withController:)]) {
      [_delegate didNavigateToObject:object inView:viewType withController:viewController];
    }
    
    return viewController;
  }
  
  return nil;
}

- (T3ViewController*)displayObject:(id<T3Object>)object {
  return [self displayObject:object inView:nil withState:nil animated:YES];
}

- (T3ViewController*)displayObject:(id<T3Object>)object inView:(NSString*)viewType {
  return [self displayObject:object inView:viewType withState:nil animated:YES];
}

- (T3ViewController*)displayObject:(id<T3Object>) object inView:(NSString*)viewType
    animated:(BOOL)animated {
  return [self displayObject:object inView:viewType withState:nil animated:animated];
}

- (T3ViewController*)displayObject:(id<T3Object>)object inView:(NSString*)viewType 
  withState:(NSDictionary*)state animated:(BOOL)animated {
  NSString* url = [object isKindOfClass:[NSString class]]
    ? (NSString*)object
    : [self urlForObject:object inView:viewType];
  return url ? [self displayURL:url withState:state animated:animated] : nil;
}

@end
