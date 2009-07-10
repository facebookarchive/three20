#import "Three20/TTNavigator.h"
#import "Three20/TTURLMap.h"
#import "Three20/TTURLPattern.h"
#import "Three20/TTViewController.h"

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation TTNavigator

@synthesize delegate = _delegate, URLMap = _URLMap, window = _window,
            rootViewController = _rootViewController, persistenceMode = _persistenceMode,
            supportsShakeToReload = _supportsShakeToReload, opensExternalURLs = _opensExternalURLs;

///////////////////////////////////////////////////////////////////////////////////////////////////
// class public

+ (TTNavigator*)navigator {
  static TTNavigator* navigator = nil;
  if (!navigator) {
    navigator = [[TTNavigator alloc] init];
  }
  return navigator;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// private

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

- (UINavigationController*)frontNavigationController {
  if ([_rootViewController isKindOfClass:[UITabBarController class]]) {
    UITabBarController* tabBarController = (UITabBarController*)_rootViewController;
    if (tabBarController.selectedViewController) {
      return (UINavigationController*)tabBarController.selectedViewController;
    } else {
      return (UINavigationController*)[tabBarController.viewControllers objectAtIndex:0];
    }
  } else if ([_rootViewController isKindOfClass:[UINavigationController class]]) {
    return (UINavigationController*)_rootViewController;
  } else {
    return nil;
  }
}

- (UIViewController*)frontViewController {
  UINavigationController* navController = self.frontNavigationController;
  if (navController) {
    return [self frontViewControllerForController:navController];
  } else {
    return [self frontViewControllerForController:_rootViewController];
  }
}

- (void)ensureWindow {
  if (!_window) {
    UIWindow* keyWindow = [UIApplication sharedApplication].keyWindow;
    if (keyWindow) {
      _window = [keyWindow retain];
    } else {
      _window = [[UIWindow alloc] initWithFrame:TTScreenBounds()];
      [_window makeKeyAndVisible];
    }
  }
  [_window addSubview:_rootViewController.view];
}

- (void)setRootViewController:(UIViewController*)controller {
  if (controller != _rootViewController) {
    [_rootViewController release];
    _rootViewController = [controller retain];
    [self ensureWindow];
  }
}

- (UIViewController*)parentForController:(UIViewController*)controller parent:(NSString*)parentURL {
  UIViewController* parentController = nil;
  if (parentURL) {
    parentController = [[TTNavigator navigator].URLMap objectForURL:parentURL];
  }

  // If this is the first controller, and it is not a "container", forcibly put
  // a navigation controller at the root of the controller hierarchy.
  if (!_rootViewController && ![controller isContainerController]) {
    [self setRootViewController:[[[UINavigationController alloc] init] autorelease]];
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
  if (!_rootViewController) {
    [self setRootViewController:controller];
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

- (void)presentController:(UIViewController*)controller parent:(NSString*)parentURL
        withPattern:(TTURLPattern*)pattern animated:(BOOL)animated {
  NSString* parent = parentURL ? parentURL : pattern.parentURL;
  UIViewController* parentController = [self parentForController:controller parent:parent];
  [self presentController:controller parent:parentController
        modal:pattern.navigationMode == TTNavigationModeModal animated:animated];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// NSObject

- (id)init {
  if (self = [super init]) {
    _delegate = nil;
    _URLMap = [[TTURLMap alloc] init];
    _window = nil;
    _rootViewController = nil;
    _persistenceMode = TTNavigatorPersistenceModeNone;
    _supportsShakeToReload = NO;
    _opensExternalURLs = NO;
    
    // Swizzle a new dealloc for UIViewController so it notifies us when it's going away.
    // We need to remove dying controllers from our binding cache.
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
  TT_RELEASE_MEMBER(_URLMap);
  TT_RELEASE_MEMBER(_window);
  TT_RELEASE_MEMBER(_rootViewController);
  [super dealloc];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// NSNotifications

- (void)applicationWillTerminateNotification:(void*)info {
  if (_persistenceMode) {
    [self persistViewControllers];
  }
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// public

- (UIViewController*)visibleViewController {
  UIViewController* controller = _rootViewController;
  while (controller) {
    UIViewController* child = controller.modalViewController;
    if (!child) {
      child = controller.childViewController;
    }
    if (child) {
      controller = child;
    } else {
      return controller;
    }
  }
  return nil;
}

- (NSString*)URL {
  return self.visibleViewController.navigatorURL;
}

- (void)setURL:(NSString*)URL {
  [self openURL:URL animated:YES];
}

- (UIViewController*)openURL:(NSString*)URL animated:(BOOL)animated {
  return [self openURL:URL parent:nil query:nil animated:animated];
}

- (UIViewController*)openURL:(NSString*)URL parent:(NSString*)parentURL animated:(BOOL)animated {
  return [self openURL:URL parent:parentURL query:nil animated:animated];
}

- (UIViewController*)openURL:(NSString*)URL query:(NSDictionary*)query animated:(BOOL)animated {
  return [self openURL:URL parent:nil query:query animated:animated];
}

- (UIViewController*)openURL:(NSString*)URL parent:(NSString*)parentURL query:(NSDictionary*)query
                     animated:(BOOL)animated {
  NSURL* theURL = [NSURL URLWithString:URL];

  if ([_delegate respondsToSelector:@selector(navigator:shouldOpenURL:)]) {
    if (![_delegate navigator:self shouldOpenURL:theURL]) {
      return nil;
    }
  }

  TTURLPattern* pattern = nil;
  UIViewController* controller = [self viewControllerForURL:URL query:query pattern:&pattern];
  if (controller) {
    if ([_delegate respondsToSelector:@selector(navigator:wilOpenURL:inViewController:)]) {
      [_delegate navigator:self willOpenURL:theURL inViewController:controller];
    }

    [self presentController:controller parent:parentURL withPattern:pattern animated:animated];
  } else if (_opensExternalURLs) {
    if ([_delegate respondsToSelector:@selector(navigator:wilOpenURL:inViewController:)]) {
      [_delegate navigator:self willOpenURL:theURL inViewController:nil];
    }

    [[UIApplication sharedApplication] openURL:theURL];
  }
  return controller;
}

- (UIViewController*)openURLs:(NSString*)URL,... {
  UIViewController* controller = nil;
  va_list ap;
  va_start(ap, URL);
  while (URL) {
    controller = [self openURL:URL animated:NO];
    URL = va_arg(ap, id);
  }
  va_end(ap); 

  return controller;
}

- (UIViewController*)viewControllerForURL:(NSString*)URL {
  return [self viewControllerForURL:URL query:nil pattern:nil];
}

- (UIViewController*)viewControllerForURL:(NSString*)URL query:(NSDictionary*)query {
  return [self viewControllerForURL:URL query:query pattern:nil];
}

- (UIViewController*)viewControllerForURL:(NSString*)URL query:(NSDictionary*)query
                     pattern:(TTURLPattern**)pattern {
  id object = [[TTNavigator navigator].URLMap objectForURL:URL query:query pattern:pattern];
  if (object) {
    UIViewController* controller = object;
    controller.navigatorURL = URL;
    return controller;
  } else {
    return nil;
  }
}

- (void)persistViewControllers {
  NSMutableArray* path = [NSMutableArray array];
  [self persistController:_rootViewController path:path];
  TTLOG(@"DEBUG PERSIST %@", path);
  
  NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
  [defaults setObject:path forKey:@"TTNavigatorHistory"];
  [defaults synchronize];
}

- (UIViewController*)restoreViewControllers { 
  NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
  NSArray* path = [defaults objectForKey:@"TTNavigatorHistory"];
  TTLOG(@"DEBUG RESTORE %@", path);
  
  UIViewController* controller = nil;
  BOOL passedContainer = NO;
  for (NSDictionary* state in path) {
    NSString* URL = [state objectForKey:@"__navigatorURL__"];
    controller = [self openURL:URL parent:nil query:nil animated:NO];
    controller.frozenState = state;
    
    if (_persistenceMode == TTNavigatorPersistenceModeTop && passedContainer) {
      break;
    }
    passedContainer = [controller isContainerController];
  }

  return controller;
}

- (void)persistController:(UIViewController*)controller path:(NSMutableArray*)path {
  NSString* URL = controller.navigatorURL;
  if (URL) {
    // Let the controller persists its own arbitrary state
    NSMutableDictionary* state = [NSMutableDictionary dictionaryWithObject:URL  
                                                      forKey:@"__navigatorURL__"];
    [controller persistView:state];

    [path addObject:state];
  }
  [controller persistNavigationPath:path];

  if (controller.modalViewController
      && controller.modalViewController.parentViewController == controller) {
    [self persistController:controller.modalViewController path:path];
  }
}

- (void)removeAllViewControllers {
  // XXXjoe Implement me
}

- (void)resetDefaults {
  NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
  [defaults removeObjectForKey:@"TTNavigatorHistory"];
  [defaults synchronize];
}

- (void)reloadContent {
  UIViewController* controller = self.visibleViewController;
  if ([controller isKindOfClass:[TTViewController class]]) {
    TTViewController* ttcontroller = (TTViewController*)controller;
    [ttcontroller reloadContent];
  }
}

@end

///////////////////////////////////////////////////////////////////////////////////////////////////
// global

UIViewController* TTOpenURL(NSString* URL) {
  return [[TTNavigator navigator] openURL:URL animated:YES];
}
