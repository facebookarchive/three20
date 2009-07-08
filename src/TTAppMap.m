#import "Three20/TTAppMap.h"
#import "Three20/TTURLPattern.h"
#import "Three20/TTViewController.h"
#import <objc/runtime.h>

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation TTAppMap

@synthesize delegate = _delegate, mainWindow = _mainWindow,
            mainViewController = _mainViewController, persistenceMode = _persistenceMode,
            supportsShakeToReload = _supportsShakeToReload, openExternalURLs = _openExternalURLs;

///////////////////////////////////////////////////////////////////////////////////////////////////
// class public

+ (TTAppMap*)sharedMap {
  static TTAppMap* sharedMap = nil;
  if (!sharedMap) {
    sharedMap = [[TTAppMap alloc] init];
  }
  return sharedMap;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// private

- (void)addPattern:(TTURLPattern*)pattern forURL:(NSString*)URL {
  pattern.URL = URL;

  if (pattern.isUniversal) {
    [_defaultPattern release];
    _defaultPattern = [pattern retain];
  } else {
    _invalidPatterns = YES;
        
    if (!_patterns) {
      _patterns = [[NSMutableArray alloc] init];
    }
    
    [_patterns addObject:pattern];
  }
}

- (TTURLPattern*)matchPattern:(NSURL*)URL {
  if (_invalidPatterns) {
    [_patterns sortUsingSelector:@selector(compareSpecificity:)];
    _invalidPatterns = NO;
  }
  
  for (TTURLPattern* pattern in _patterns) {
    if ([pattern matchURL:URL]) {
      return pattern;
    }
  }
  return _defaultPattern;
}

- (UIViewController*)controllerForURL:(NSURL*)URL withPattern:(TTURLPattern*)pattern {
  if (_singletons) {
    // XXXjoe Normalize the URL first
    NSString* URLString = [URL absoluteString];
    UIViewController* controller = [_singletons objectForKey:URLString];
    if (controller) {
      return controller;
    }
  }

  id target = nil;
  UIViewController* controller = nil;

  if (pattern.targetClass) {
    target = [[[pattern.targetClass alloc] init] autorelease];
    controller = target;
  } else {
    target = pattern.targetObject;
  }
  
  if (pattern.selector) {
    NSMethodSignature *sig = [target methodSignatureForSelector:pattern.selector];
    if (sig) {
      NSInvocation* invocation = [NSInvocation invocationWithMethodSignature:sig];
      [invocation setTarget:target];
      [invocation setSelector:pattern.selector];
      if (pattern == _defaultPattern) {
        [invocation setArgument:&URL atIndex:2];
      } else {
        [pattern setArgumentsFromURL:URL forInvocation:invocation];
      }
      [invocation invoke];
      
      if (pattern.targetObject && sig.methodReturnLength) {
        [invocation getReturnValue:&controller];
      }
    }
  }
  
  if (pattern.launchType == TTLaunchTypeSingleton && controller) {
    [self setController:controller forURL:[URL absoluteString]];
  }

  return controller;
}

- (UIViewController*)controllerForURL:(NSURL*)URL pattern:(TTURLPattern**)outPattern {
  TTURLPattern* pattern = [self matchPattern:URL];
  if (pattern) {
    if (outPattern) {
      *outPattern = pattern;
    }
    return [self controllerForURL:URL withPattern:pattern];
  } else {
    return nil;
  }
}

- (UIViewController*)parentControllerForController:(UIViewController*)controller
                     withPattern:(TTURLPattern*)pattern {
  UIViewController* parentController = nil;
  if (pattern.parentURL) {
    parentController = [self controllerForURL:pattern.parentURL pattern:nil];
  }

  // If this is the first controller, and it is not a "container", forcibly put
  // a navigation controller at the root of the controller hierarchy.
  if (!_mainViewController && ![controller isContainerController]) {
    self.mainViewController = [[[UINavigationController alloc] init] autorelease];
  }

  return parentController ? parentController : self.visibleViewController;
}

- (void)presentModalController:(UIViewController*)controller
        parent:(UIViewController*)parentController animated:(BOOL)animated {
  if ([controller isKindOfClass:[UINavigationController class]]) {
    [parentController presentModalViewController:controller animated:animated];
  } else {
    UINavigationController* navController = [[[UINavigationController alloc] init] autorelease];
    [navController pushViewController:controller animated:NO];
    [parentController presentModalViewController:navController animated:animated];
  }
}

- (void)presentController:(UIViewController*)controller
        parent:(UIViewController*)parentController modal:(BOOL)modal animated:(BOOL)animated {
  if (!_mainViewController) {
    self.mainViewController = controller;
  } else if (controller.parentViewController) {
    // The controller already exists, so we just need to make it visible
    while (controller) {
      UIViewController* parent = controller.parentViewController;
      [parent bringControllerToFront:controller animated:NO];
      controller = parent;
    }
  } else if (parentController) {
    [self presentController:parentController parent:nil modal:NO animated:NO];
    if (modal) {
      [self presentModalController:controller parent:parentController animated:animated];
    } else {
      [parentController presentController:controller animated:animated];
    }
  }
}

- (void)presentController:(UIViewController*)controller forURL:(NSURL*)URL
        withPattern:(TTURLPattern*)pattern animated:(BOOL)animated {
  UIViewController* parentController = [self parentControllerForController:controller
                                             withPattern:pattern];
  [self presentController:controller parent:parentController
        modal:pattern.launchType == TTLaunchTypeModal animated:animated];
}

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
    controller = navController.topViewController;
  }
  
  if (controller.modalViewController) {
    return [self frontViewControllerForController:controller.modalViewController];
  } else {
    return controller;
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

- (UIViewController*)loadControllerWithURL:(NSString*)URL display:(BOOL)display
                    animated:(BOOL)animated {
  if ([_delegate respondsToSelector:@selector(appMap:shouldLoadURL:)]) {
    if ([_delegate appMap:self shouldLoadURL:URL]) {
      return nil;
    }
  }

  NSURL* theURL = [NSURL URLWithString:URL];
  TTURLPattern* pattern = nil;
  UIViewController* controller = [self controllerForURL:theURL pattern:&pattern];
  if (controller) {
    if ([_delegate respondsToSelector:@selector(appMap:wilLoadURL:inViewController:)]) {
      [_delegate appMap:self willLoadURL:URL inViewController:controller];
    }

    controller.appMapURL = URL;
    if (display) {
      [self presentController:controller forURL:theURL withPattern:pattern animated:animated];
    }
  } else if (_openExternalURLs) {
    if ([_delegate respondsToSelector:@selector(appMap:wilLoadURL:inViewController:)]) {
      [_delegate appMap:self willLoadURL:URL inViewController:nil];
    }

    [[UIApplication sharedApplication] openURL:theURL];
  }
  return controller;
}

- (void)persistControllers {
  NSMutableArray* path = [NSMutableArray array];
  [self persistController:_mainViewController path:path];

  if (_mainViewController.modalViewController) {
    [self persistController:_mainViewController.modalViewController path:path];
  }
  
  NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
  [defaults setObject:path forKey:@"TTAppMapNavigation"];
  [defaults synchronize];
}

- (BOOL)restoreControllersStartingWithURL:(NSString*)startURL {
  NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
  NSArray* path = [defaults objectForKey:@"TTAppMapNavigation"];
  NSInteger pathIndex = 0;
  for (NSDictionary* state in path) {
    NSString* URL = [state objectForKey:@"__appMapURL__"];
    
    if (!_mainViewController && ![URL isEqualToString:startURL]) {
      // If the start URL is not the same as the persisted start URL, then don't restore
      // because the app wants to start with a different URL.
      return NO;
    }
    
    UIViewController* controller = [self loadControllerWithURL:URL display:YES animated:NO];
    controller.frozenState = state;
    
    if (_persistenceMode == TTAppMapPersistenceModeTop && pathIndex++ == 1) {
      break;
    }
  }

  return path.count > 0;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// NSObject

- (id)init {
  if (self = [super init]) {
    _delegate = nil;
    _mainWindow = nil;
    _mainViewController = nil;
    _singletons = nil;
    _patterns = nil;
    _defaultPattern = nil;
    _persistenceMode = TTAppMapPersistenceModeNone;
    _invalidPatterns = NO;
    _supportsShakeToReload = NO;
    _openExternalURLs = NO;
    
    // Swizzle a new dealloc for UIViewController so it notifies us when it's going away.
    // We need to remove dying controllers from our singleton cache.
    TTSwizzle([UIViewController class], @selector(dealloc), @selector(ttdealloc));
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                          selector:@selector(applicationWillTerminateNotification:)
                                          name:UIApplicationWillTerminateNotification
                                          object:nil];
  }
  return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                          name:UIApplicationWillTerminateNotification
                                          object:nil];
  _delegate = nil;
  TT_RELEASE_MEMBER(_mainWindow);
  TT_RELEASE_MEMBER(_mainViewController);
  TT_RELEASE_MEMBER(_singletons);
  TT_RELEASE_MEMBER(_patterns);
  TT_RELEASE_MEMBER(_defaultPattern);
  [super dealloc];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// NSNotifications

- (void)applicationWillTerminateNotification:(void*)info {
  if (_persistenceMode) {
    [self persistControllers];
  }
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// public

- (void)setMainViewController:(UIViewController*)controller {
  if (controller != _mainViewController) {
    [_mainViewController release];
    _mainViewController = [controller retain];
    
    UIView* mainView = controller.view;
    if (!mainView.superview) {
      if (!_mainWindow) {
        UIWindow* keyWindow = [UIApplication sharedApplication].keyWindow;
        if (keyWindow) {
          _mainWindow = [keyWindow retain];
        } else {
          _mainWindow = [[UIWindow alloc] initWithFrame:TTScreenBounds()];
          [_mainWindow makeKeyAndVisible];
        }
      }
      [_mainWindow addSubview:controller.view];
    }
  }
}

- (UIViewController*)visibleViewController {
  UINavigationController* navController = self.frontNavigationController;
  if (navController) {
    UIViewController* controller = navController.visibleViewController;
    return controller ? controller : navController;
  } else {
    return [self frontViewControllerForController:_mainViewController];
  }
}

- (UIViewController*)loadURL:(NSString*)URL {
  return [self loadURL:URL animated:YES];
}

- (UIViewController*)loadURL:(NSString*)URL animated:(BOOL)animated {
  if (!_mainViewController && _persistenceMode && [self restoreControllersStartingWithURL:URL]) {
    return _mainViewController;
  } else {
    return [self loadControllerWithURL:URL display:YES animated:animated];
  }
}

- (UIViewController*)controllerForURL:(NSString*)URL {
  return [self loadControllerWithURL:URL display:NO animated:NO];
}

- (TTLaunchType)launchTypeForURL:(NSString*)URL {
  TTURLPattern* pattern = [self matchPattern:[NSURL URLWithString:URL]];
  return pattern.launchType;
}

- (void)addURL:(NSString*)URL create:(id)target {
  TTURLPattern* pattern = [[TTURLPattern alloc] initWithType:TTLaunchTypeCreate];
  [pattern setTargetOrClass:target];
  [self addPattern:pattern forURL:URL];
  [pattern release];
}

- (void)addURL:(NSString*)URL create:(id)target selector:(SEL)selector {
  TTURLPattern* pattern = [[TTURLPattern alloc] initWithType:TTLaunchTypeCreate];
  [pattern setTargetOrClass:target];
  pattern.selector = selector;
  [self addPattern:pattern forURL:URL];
  [pattern release];
}

- (void)addURL:(NSString*)URL parent:(NSString*)parentURL create:(id)target
        selector:(SEL)selector {
  TTURLPattern* pattern = [[TTURLPattern alloc] initWithType:TTLaunchTypeCreate];
  pattern.parentURL = [NSURL URLWithString:parentURL];
  [pattern setTargetOrClass:target];
  pattern.selector = selector;
  [self addPattern:pattern forURL:URL];
  [pattern release];
}

- (void)addURL:(NSString*)URL singleton:(id)target {
  TTURLPattern* pattern = [[TTURLPattern alloc] initWithType:TTLaunchTypeSingleton];
  [pattern setTargetOrClass:target];
  [self addPattern:pattern forURL:URL];
  [pattern release];
}

- (void)addURL:(NSString*)URL singleton:(id)target selector:(SEL)selector {
  TTURLPattern* pattern = [[TTURLPattern alloc] initWithType:TTLaunchTypeSingleton];
  [pattern setTargetOrClass:target];
  pattern.selector = selector;
  [self addPattern:pattern forURL:URL];
  [pattern release];
}

- (void)addURL:(NSString*)URL parent:(NSString*)parentURL singleton:(id)target
        selector:(SEL)selector {
  TTURLPattern* pattern = [[TTURLPattern alloc] initWithType:TTLaunchTypeSingleton];
  pattern.parentURL = [NSURL URLWithString:parentURL];
  [pattern setTargetOrClass:target];
  pattern.selector = selector;
  [self addPattern:pattern forURL:URL];
  [pattern release];
}

- (void)addURL:(NSString*)URL modal:(id)target {
  TTURLPattern* pattern = [[TTURLPattern alloc] initWithType:TTLaunchTypeModal];
  [pattern setTargetOrClass:target];
  [self addPattern:pattern forURL:URL];
  [pattern release];
}

- (void)addURL:(NSString*)URL modal:(id)target selector:(SEL)selector {
  TTURLPattern* pattern = [[TTURLPattern alloc] initWithType:TTLaunchTypeModal];
  [pattern setTargetOrClass:target];
  pattern.selector = selector;
  [self addPattern:pattern forURL:URL];
  [pattern release];
}

- (void)addURL:(NSString*)URL parent:(NSString*)parentURL modal:(id)target
        selector:(SEL)selector {
  TTURLPattern* pattern = [[TTURLPattern alloc] initWithType:TTLaunchTypeModal];
  pattern.parentURL = [NSURL URLWithString:parentURL];
  [pattern setTargetOrClass:target];
  pattern.selector = selector;
  [self addPattern:pattern forURL:URL];
  [pattern release];
}

- (void)removeURL:(NSString*)URL {
  for (TTURLPattern* pattern in _patterns) {
    if ([URL isEqualToString:pattern.URL]) {
      [_patterns removeObject:pattern];
      break;
    }
  }
}

- (void)setController:(UIViewController*)controller forURL:(NSString*)URL {
  if (!_singletons) {
    _singletons = TTCreateNonRetainingDictionary();
  }
  // XXXjoe Normalize the URL first
  [_singletons setObject:controller forKey:URL];
}

- (void)removeControllerForURL:(NSString*)URL {
  [_singletons removeObjectForKey:URL];
}

- (void)removePersistedControllers {
  NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
  [defaults removeObjectForKey:@"TTAppMapNavigation"];
  [defaults synchronize];
}

- (void)persistController:(UIViewController*)controller path:(NSMutableArray*)path {
  NSString* URL = controller.appMapURL;
  if (URL) {
    // Let the controller persists its own arbitrary state
    NSMutableDictionary* state = [NSMutableDictionary dictionaryWithObject:URL  
                                                      forKey:@"__appMapURL__"];
    [controller persistView:state];

    [path addObject:state];
  }
  [controller persistNavigationPath:path];
}

@end

///////////////////////////////////////////////////////////////////////////////////////////////////
// global

void TTLoadURL(NSString* URL) {
  [[TTAppMap sharedMap] loadURL:URL];
}
