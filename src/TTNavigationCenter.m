#import "Three20/TTNavigationCenter.h"
#import "Three20/TTViewController.h"

///////////////////////////////////////////////////////////////////////////////////////////////////

static NSTimeInterval kPersistStateAge = 60 * 60 * 4;

static const int kAccelerometerFrequency = 25; //Hz
static const float kFilteringFactor = 0.1;
static const float kMinEraseInterval = 0.5;
static const float kEraseAccelerationThreshold = 3.0;

static TTNavigationCenter* gDefaultCenter = nil;

///////////////////////////////////////////////////////////////////////////////////////////////////

@interface TTNavigationEntry : NSObject {
  id _target;
  SEL _action;
  Class _cls;
  TTNavigationRule _rule;
}

@property(nonatomic,readonly) id target;
@property(nonatomic,readonly) SEL action;
@property(nonatomic,readonly) Class cls;
@property(nonatomic,readonly) TTNavigationRule rule;

- (id)initWithTarget:(id)target action:(SEL)action;

- (id)initWithClass:(Class)cls rule:(TTNavigationRule)rule;

@end

@implementation TTNavigationEntry

@synthesize target = _target, action = _action, cls = _cls, rule = _rule;

- (id)initWithTarget:(id)target action:(SEL)action {
  if (self = [super init]) {
    _target = target;
    _action = action;
    _cls = nil;
    _rule = 0;
  }
  return self;
}

- (id)initWithClass:(Class)controllerClass rule:(TTNavigationRule)rule {
  if (self = [super init]) {
    _cls = controllerClass;
    _rule = rule;
    _target = nil;
    _action = nil;
  }
  return self;
}

@end

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation TTNavigationCenter

@synthesize delegate = _delegate, urlSchemes = _urlSchemes,
  mainViewController = _mainViewController, supportsShakeToReload = _supportsShakeToReload;

+ (TTNavigationCenter*)defaultCenter {
  if (!gDefaultCenter) {
    return [[[TTNavigationCenter alloc] init] autorelease];
  }
  return gDefaultCenter;
}

+ (void)setDefaultCenter:(TTNavigationCenter*)center {
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

- (TTViewController*)frontTTViewController {
  UIViewController* controller = self.frontViewController;
  if ([controller isKindOfClass:[TTViewController class]]) {
    return (TTViewController*)controller;
  } else {
    return nil;
  }
}

- (UIViewController*)frontViewControllerForController:(UIViewController*)controller {
  if ([controller isKindOfClass:[UITabBarController class]]) {
    UITabBarController* tabBarController = (UITabBarController*)controller;
    if (tabBarController.selectedViewController) {
      controller = tabBarController.selectedViewController;
    } else {
      controller = [tabBarController.viewControllers objectAtIndex:0];
    }
  } else if ([controller isKindOfClass:[UINavigationController class]]) {
    UINavigationController* navController = (UINavigationController*)controller;
    controller = [navController.viewControllers lastObject];
  }
  
  if (controller.modalViewController) {
    return [self frontViewControllerForController:controller.modalViewController];
  } else {
    return controller;
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
    NSString* key = [NSString stringWithFormat:@"TTNavigationState%d", index];
    NSArray* state = [defaults arrayForKey:key];
    if (state) {
      [defaults removeObjectForKey:key];
      return state;
    }
  }

  return nil;
}

- (BOOL)dispatchLink:(id)object inView:(NSString*)viewType animated:(BOOL)animated {
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

    [self.frontTTViewController reloadContent];
	}
}
///////////////////////////////////////////////////////////////////////////////////////////////////

- (UINavigationController*)frontNavigationController {
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

- (UIViewController*)frontViewController {
  UINavigationController* navController = self.frontNavigationController;
  if (navController) {
    return [self frontViewControllerForController:navController];
  } else {
    return [self frontViewControllerForController:_mainViewController];
  }
}

- (UIViewController*)visibleViewController {
  UINavigationController* navController = self.frontNavigationController;
  if (navController) {
    UIViewController* controller = navController.topViewController;
    while (controller) {
      if ([controller isKindOfClass:[TTViewController class]]) {
        TTViewController* ttcontroller = (TTViewController*)controller;
        if (!ttcontroller.appearing) {
          controller = ttcontroller.previousViewController;
        } else {
          break;
        }
      } else {
        break;
      }
    }
    return controller;
  } else {
    return [self frontViewControllerForController:_mainViewController];
  }
}

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

- (void)addView:(NSString*)viewType target:(id)target action:(SEL)action {
  TTNavigationEntry* entry = [[[TTNavigationEntry alloc] initWithTarget:target action:action]
    autorelease];
  [_viewLoaders setObject:entry forKey:viewType];
}

- (void)addView:(NSString*)viewType controller:(Class)cls {
  [self addView:viewType controller:cls rule:TTNavigationCreate];
}

- (void)addView:(NSString*)viewType controller:(Class)cls rule:(TTNavigationRule)rule {
  TTNavigationEntry* entry = [[[TTNavigationEntry alloc] initWithClass:cls rule:rule] autorelease];
  [_viewLoaders setObject:entry forKey:viewType];
}

- (void)removeView:(NSString*)viewType {
  [_viewLoaders removeObjectForKey:viewType];
}

- (void)addObjectLoader:(Class)cls name:(NSString*)name {
  [_objectLoaders setObject:cls forKey:name];
}

- (void)removeObjectLoader:(NSString*)name {
  [_objectLoaders removeObjectForKey:name];
}

- (id<TTPersistable>)locateObject:(NSURL*)url {
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
  if ([controller isKindOfClass:[TTViewController class]]) {
    TTViewController* viewController = (TTViewController*)controller;
    id<TTPersistable> object = viewController.viewObject;
    if (object) {
      NSString* url = [self urlForObject:object inView:viewController.viewType];
      if (url) {
        [states addObject:url];

        if (viewController.frozenState) {
          [states addObject:viewController.frozenState];
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
  NSDate* persistedTime = [defaults objectForKey:@"TTNavigationStateTime"];
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
    
    TTViewController* topController = (TTViewController*)navController.topViewController;
    [topController validateView];
    if (!topController.viewState & TTViewDataLoaded) {
      break;
    }
  }

  _defaultNavigationController = nil;
}

- (void)persistControllers {
  NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
  [defaults setObject:[NSDate date] forKey:@"TTNavigationStateTime"];
  
  if ([_mainViewController isKindOfClass:[UITabBarController class]]) {
    UITabBarController* tabBarController = (UITabBarController*)_mainViewController;
    for (int i = 0; i < tabBarController.viewControllers.count; ++i) {
      UINavigationController* controller = [tabBarController.viewControllers objectAtIndex:i];
      NSArray* state = [self stateFromNavigationController:controller];
      if (state.count) {
        NSString* key = [NSString stringWithFormat:@"TTNavigationState%d", i];
        [defaults setObject:state forKey:key];
      }
    }
  } else if ([_mainViewController isKindOfClass:[UINavigationController class]]) {
    UINavigationController* controller = (UINavigationController*)_mainViewController;
    NSArray* state = [self stateFromNavigationController:controller];
    if (state.count) {
      NSString* key = [NSString stringWithFormat:@"TTNavigationState%d", 0];
      [defaults setObject:state forKey:key];
    }
  }
}

- (void)unpersistControllers {
  NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
  [defaults removeObjectForKey:@"TTNavigationStateTime"];

  for (int i = 0; i < 5; ++i) {
    NSString* key = [NSString stringWithFormat:@"TTNavigationState%d", i];
    [defaults removeObjectForKey:key];
  }
}

- (NSString*)urlForObject:(id<TTPersistable>)object inView:(NSString*)viewType {
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

- (TTViewController*)displayURL:(NSString*)url {
  return [self displayURL:url withState:nil animated:YES];
}

- (TTViewController*)displayURL:(NSString*)url animated:(BOOL)animated {
  return [self displayURL:url withState:nil animated:animated];
}

- (TTViewController*)displayURL:(NSString*)url withState:(NSDictionary*)state
    animated:(BOOL)animated {
  NSURL* u = [NSURL URLWithString:url];
  if ([_urlSchemes indexOfObject:u.scheme] == NSNotFound) {
    [[UIApplication sharedApplication] openURL:u];
  } else if (_viewLoaders) {
    id<TTPersistable> object = [self locateObject:u];
    NSString* viewType = object && u.query ? u.query : u.host;
    if (![self dispatchLink:object inView:viewType animated:animated]) {
      return nil;
    }

    TTNavigationEntry* entry = [_viewLoaders objectForKey:viewType];
    if (!entry) {
      return nil;
    } else if (entry.target) {
      if (entry.action && [entry.target respondsToSelector:entry.action]) {
        [entry.target performSelector:entry.action withObject:object withObject:viewType
          withObject:state];
      }
      return nil;
    } else {
      UINavigationController* navController = nil;
      
      if ([_delegate respondsToSelector:@selector(navigationControllerForObject:inView:)]) {
        navController = [_delegate navigationControllerForObject:object inView:viewType];
      }
      
      if (!navController) {
        navController = self.frontNavigationController;
      }
          
      TTViewController* viewController = nil;
      if (entry.rule == TTNavigationSingleton) {
        for (int i = 0; i < navController.viewControllers.count; ++i) {
          UIViewController* controller = [navController.viewControllers objectAtIndex:i];
          if ([controller isKindOfClass:entry.cls]) {
            viewController = (TTViewController*)controller;
          }
        }
      } else if (entry.rule == TTNavigationUpdate) {
        if ([navController.topViewController isKindOfClass:entry.cls]) {
          TTViewController* topViewController = (TTViewController*)navController.topViewController;
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
      
      if (entry.rule == TTNavigationModal) {
        [navController presentModalViewController:viewController animated:animated];
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
  }
  
  return nil;
}

- (TTViewController*)displayObject:(id)object {
  return [self displayObject:object inView:nil withState:nil animated:YES];
}

- (TTViewController*)displayObject:(id)object inView:(NSString*)viewType {
  return [self displayObject:object inView:viewType withState:nil animated:YES];
}

- (TTViewController*)displayObject:(id<TTPersistable>) object inView:(NSString*)viewType
    animated:(BOOL)animated {
  return [self displayObject:object inView:viewType withState:nil animated:animated];
}

- (TTViewController*)displayObject:(id)object inView:(NSString*)viewType 
  withState:(NSDictionary*)state animated:(BOOL)animated {
  if ([object isKindOfClass:[NSString class]]) {
    return [self displayURL:object withState:state animated:animated];
  } else if ([object conformsToProtocol:@protocol(TTPersistable)]) {
    NSString* url = [self urlForObject:object inView:viewType];
    
    return url ? [self displayURL:url withState:state animated:animated] : nil;
  } else {
    return nil;
  }
}

@end
