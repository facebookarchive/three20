#import "Three20/TTNavigator.h"
#import "Three20/TTURLMap.h"
#import "Three20/TTURLPattern.h"
#import "Three20/TTPopupViewController.h"

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
  if (controller == _rootViewController) {
    return nil;
  } else {
    // If this is the first controller, and it is not a "container", forcibly put
    // a navigation controller at the root of the controller hierarchy.
    if (!_rootViewController && ![controller canContainControllers]) {
      [self setRootViewController:[[[UINavigationController alloc] init] autorelease]];
    }

    if (parentURL) {
      return [self openURL:parentURL parent:nil animated:NO];
    } else {
      UIViewController* parent = self.visibleViewController;
      if (parent != controller) {
        return parent;
      } else {
        return nil;
      }
    }
  }
}

- (void)presentPopupController:(TTPopupViewController*)controller
        parent:(UIViewController*)parentController animated:(BOOL)animated {
  parentController.popupViewController = controller;
  controller.superController = parentController;
  [controller showInViewController:parentController animated:animated];
}

- (void)presentModalController:(UIViewController*)controller
        parent:(UIViewController*)parentController animated:(BOOL)animated
        transition:(NSInteger)transition {
  controller.modalTransitionStyle = transition;
  if ([controller isKindOfClass:[TTPopupViewController class]]) {
    TTPopupViewController* popupViewController  = (TTPopupViewController*)controller;
    [self presentPopupController:popupViewController parent:parentController animated:animated];
  } else if ([controller isKindOfClass:[UINavigationController class]]) {
    [parentController presentModalViewController:controller animated:animated];
  } else {
    UINavigationController* navController = [[[UINavigationController alloc] init] autorelease];
    [navController pushViewController:controller animated:NO];
    [parentController presentModalViewController:navController animated:animated];
  }
}

- (void)presentController:(UIViewController*)controller parent:(UIViewController*)parentController
        mode:(TTNavigationMode)mode animated:(BOOL)animated transition:(NSInteger)transition {
  if (!_rootViewController) {
    [self setRootViewController:controller];
  } else {
    UIViewController* previousSuper = controller.superController;
    if (previousSuper) {
      if (previousSuper != parentController) {
        // The controller already exists, so we just need to make it visible
        for (UIViewController* superController = previousSuper; controller; ) {
          UIViewController* nextSuper = superController.superController;
          [superController bringControllerToFront:controller animated:!nextSuper];
          controller = superController;
          superController = nextSuper;
        }
      }
    } else if (parentController) {
      if (mode == TTNavigationModeModal) {
        [self presentModalController:controller parent:parentController animated:animated
              transition:transition];
      } else {
        [parentController addSubcontroller:controller animated:animated transition:transition];
      }
    }
  }
}

- (void)presentController:(UIViewController*)controller parent:(NSString*)parentURL
        withPattern:(TTURLPattern*)pattern animated:(BOOL)animated
        transition:(NSInteger)transition {
  if (controller) {
    UIViewController* visibleViewController = self.visibleViewController;
    if (controller && controller != visibleViewController) {
      UIViewController* parentController = [self parentForController:controller
                                                 parent:parentURL ? parentURL : pattern.parentURL];
      if (parentController && parentController != visibleViewController) {
        [self presentController:parentController parent:nil mode:TTNavigationModeNone
              animated:NO transition:0];
      }
      [self presentController:controller parent:parentController mode:pattern.navigationMode
            animated:animated transition:transition];
    }
  }
}

- (UIViewController*)openURL:(NSString*)URL parent:(NSString*)parentURL query:(NSDictionary*)query
                     state:(NSDictionary*)state animated:(BOOL)animated
                     transition:(UIViewAnimationTransition)transition {
  if (!URL) {
    return nil;
  }
  
  NSURL* theURL = [NSURL URLWithString:URL];
  if (theURL.fragment && !theURL.scheme) {
    URL = [self.URL stringByAppendingString:URL];
    theURL = [NSURL URLWithString:URL];
  }
  
  if ([_delegate respondsToSelector:@selector(navigator:shouldOpenURL:)]) {
    if (![_delegate navigator:self shouldOpenURL:theURL]) {
      return nil;
    }
  }

  TTURLPattern* pattern = nil;
  UIViewController* controller = [self viewControllerForURL:URL query:query pattern:&pattern];
  if (controller) {
    if (state) {
      [controller restoreView:state];
//      controller.frozenState = state;

      if ([controller isKindOfClass:[TTViewController class]]) {
        TTViewController* ttcontroller = (TTViewController*)controller;
        [ttcontroller validateModel];
      }
    }
    if ([_delegate respondsToSelector:@selector(navigator:wilOpenURL:inViewController:)]) {
      [_delegate navigator:self willOpenURL:theURL inViewController:controller];
    }

    [self presentController:controller parent:parentURL withPattern:pattern
          animated:animated transition:transition ? transition : pattern.transition];
  } else if (_opensExternalURLs) {
    if ([_delegate respondsToSelector:@selector(navigator:wilOpenURL:inViewController:)]) {
      [_delegate navigator:self willOpenURL:theURL inViewController:nil];
    }

    [[UIApplication sharedApplication] openURL:theURL];
  }
  return controller;
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
      child = controller.topSubcontroller;
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
  return [self openURL:URL parent:nil query:nil state:nil animated:animated
               transition:UIViewAnimationTransitionNone];
}

- (UIViewController*)openURL:(NSString*)URL animated:(BOOL)animated
                     transition:(UIViewAnimationTransition)transition {
  return [self openURL:URL parent:nil query:nil state:nil animated:YES transition:transition];
}

- (UIViewController*)openURL:(NSString*)URL parent:(NSString*)parentURL animated:(BOOL)animated {
  return [self openURL:URL parent:parentURL query:nil state:nil animated:animated
               transition:UIViewAnimationTransitionNone];
}

- (UIViewController*)openURL:(NSString*)URL query:(NSDictionary*)query animated:(BOOL)animated {
  return [self openURL:URL parent:nil query:query state:nil animated:animated
               transition:UIViewAnimationTransitionNone];
}

- (UIViewController*)openURL:(NSString*)URL parent:(NSString*)parentURL query:(NSDictionary*)query
                     animated:(BOOL)animated {
  return [self openURL:URL parent:parentURL query:query state:nil animated:animated
               transition:UIViewAnimationTransitionNone];
}

- (UIViewController*)openURL:(NSString*)URL parent:(NSString*)parentURL query:(NSDictionary*)query
                     animated:(BOOL)animated transition:(UIViewAnimationTransition)transition {
  return [self openURL:URL parent:parentURL query:query state:nil animated:animated
               transition:UIViewAnimationTransitionNone];
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
  NSRange fragmentRange = [URL rangeOfString:@"#" options:NSBackwardsSearch];
  if (fragmentRange.location != NSNotFound) {
    NSString* baseURL = [URL substringToIndex:fragmentRange.location];
    if ([self.URL isEqualToString:baseURL]) {
      UIViewController* controller = self.visibleViewController;
      [_URLMap dispatchURL:URL toTarget:controller query:query];
      return controller;
    } else {
      id object = [_URLMap objectForURL:baseURL query:nil pattern:pattern];
      [_URLMap dispatchURL:URL toTarget:object query:query];
      return object;
    }
  }

  id object = [_URLMap objectForURL:URL query:query pattern:pattern];
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
    controller = [self openURL:URL parent:nil query:nil state:state animated:NO transition:0];
    if (_persistenceMode == TTNavigatorPersistenceModeTop && passedContainer) {
      break;
    }
    passedContainer = [controller canContainControllers];
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
  } else if (controller.popupViewController
      && controller.popupViewController.superController == controller) {
    [self persistController:controller.popupViewController path:path];
  }
}

- (void)removeAllViewControllers {
  // XXXjoe Implement me
}

- (NSString*)pathForObject:(id)object {
  if ([object isKindOfClass:[UIViewController class]]) {
    NSMutableArray* paths = [NSMutableArray array];
    for (UIViewController* controller = object; controller; ) {
      UIViewController* superController = controller.superController;
      NSString* key = [superController keyForSubcontroller:controller];
      if (key) {
        [paths addObject:key];
      }
      controller = superController;
    }
    
    return [paths componentsJoinedByString:@"/"];
  } else {
    return nil;
  }
}

- (id)objectForPath:(NSString*)path {
  NSArray* keys = [path componentsSeparatedByString:@"/"];
  UIViewController* controller = _rootViewController;
  for (NSString* key in [keys reverseObjectEnumerator]) {
    controller = [controller subcontrollerForKey:key];
  }
  return controller;
}

- (void)resetDefaults {
  NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
  [defaults removeObjectForKey:@"TTNavigatorHistory"];
  [defaults synchronize];
}

- (void)reload {
  UIViewController* controller = self.visibleViewController;
  if ([controller isKindOfClass:[TTViewController class]]) {
    TTViewController* ttcontroller = (TTViewController*)controller;
    [ttcontroller reload];
  }
}

@end

///////////////////////////////////////////////////////////////////////////////////////////////////
// global

UIViewController* TTOpenURL(NSString* URL) {
  return [[TTNavigator navigator] openURL:URL animated:YES];
}
