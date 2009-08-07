#import "Three20/TTNavigator.h"
#import "Three20/TTURLMap.h"
#import "Three20/TTURLPattern.h"
#import "Three20/TTTableViewController.h"
#import "Three20/TTPopupViewController.h"
#import "Three20/TTSearchDisplayController.h"

///////////////////////////////////////////////////////////////////////////////////////////////////

@interface TTNavigatorWindow : UIWindow
@end

@implementation TTNavigatorWindow

- (void)motionBegan:(UIEventSubtype)motion withEvent:(UIEvent *)event {
  if (event.type == UIEventSubtypeMotionShake && [TTNavigator navigator].supportsShakeToReload) {
    [[TTNavigator navigator] reload];
  }
}

@end

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation TTNavigator

@synthesize delegate = _delegate, URLMap = _URLMap, window = _window,
            rootViewController = _rootViewController,
            persistenceExpirationAge = _persistenceExpirationAge,
            persistenceMode = _persistenceMode, supportsShakeToReload = _supportsShakeToReload,
            opensExternalURLs = _opensExternalURLs;

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

- (void)setRootViewController:(UIViewController*)controller {
  if (controller != _rootViewController) {
    [_rootViewController release];
    _rootViewController = [controller retain];
    [self.window addSubview:_rootViewController.view];
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
      UIViewController* parent = self.topViewController;
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
  [controller showInView:parentController.view animated:animated];
}

- (void)presentModalController:(UIViewController*)controller
        parent:(UIViewController*)parentController animated:(BOOL)animated
        transition:(NSInteger)transition {
  controller.modalTransitionStyle = transition;
  if ([controller isKindOfClass:[UINavigationController class]]) {
    [parentController presentModalViewController:controller animated:animated];
  } else {
    UINavigationController* navController = [[[UINavigationController alloc] init] autorelease];
    [navController pushViewController:controller animated:NO];
    [parentController presentModalViewController:navController animated:animated];
  }
}

- (BOOL)presentController:(UIViewController*)controller parent:(UIViewController*)parentController
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
      return NO;
    } else if (parentController) {
      if ([controller isKindOfClass:[TTPopupViewController class]]) {
        TTPopupViewController* popupViewController  = (TTPopupViewController*)controller;
        [self presentPopupController:popupViewController parent:parentController animated:animated];
      } else if (mode == TTNavigationModeModal) {
        [self presentModalController:controller parent:parentController animated:animated
              transition:transition];
      } else {
        [parentController addSubcontroller:controller animated:animated transition:transition];
      }
    }
  }
  return YES;
}

- (BOOL)presentController:(UIViewController*)controller parent:(NSString*)parentURL
        withPattern:(TTURLNavigatorPattern*)pattern animated:(BOOL)animated
        transition:(NSInteger)transition {
  if (controller) {
    UIViewController* topViewController = self.topViewController;
    if (controller && controller != topViewController) {
      UIViewController* parentController = [self parentForController:controller
                                                 parent:parentURL ? parentURL : pattern.parentURL];
      if (parentController && parentController != topViewController) {
        [self presentController:parentController parent:nil mode:TTNavigationModeNone
                     animated:NO transition:0];
      }
      return [self presentController:controller parent:parentController mode:pattern.navigationMode
                   animated:animated transition:transition];
    }
  }
  return NO;
}

- (UIViewController*)openURL:(NSString*)URL parent:(NSString*)parentURL query:(NSDictionary*)query
                     state:(NSDictionary*)state animated:(BOOL)animated
                     transition:(UIViewAnimationTransition)transition withDelay:(BOOL)withDelay {
  if (!URL) {
    return nil;
  }
  
  NSURL* theURL = [NSURL URLWithString:URL];
  if ([_URLMap isAppURL:theURL]) {
    [[UIApplication sharedApplication] openURL:theURL];
    return nil;
  }
  
  if (!theURL.scheme) {
    if (theURL.fragment) {
      URL = [self.URL stringByAppendingString:URL];
    } else {
      URL = [@"http://" stringByAppendingString:URL];
    }
    theURL = [NSURL URLWithString:URL];
  }
  
  if ([_delegate respondsToSelector:@selector(navigator:shouldOpenURL:)]) {
    if (![_delegate navigator:self shouldOpenURL:theURL]) {
      return nil;
    }
  }
  
  if (withDelay) {
    [self beginDelay];
  }

  TTLOG(@"OPENING URL %@", URL);
  
  TTURLNavigatorPattern* pattern = nil;
  UIViewController* controller = [self viewControllerForURL:URL query:query pattern:&pattern];
  if (controller) {
    if (state) {
      [controller restoreView:state];
      controller.frozenState = state;

      if ([controller isKindOfClass:[TTModelViewController class]]) {
        TTModelViewController* modelViewController = (TTModelViewController*)controller;
        modelViewController.model;
      }
    }
    
    if ([_delegate respondsToSelector:@selector(navigator:willOpenURL:inViewController:)]) {
      [_delegate navigator:self willOpenURL:theURL inViewController:controller];
    }

    BOOL wasNew = [self presentController:controller parent:parentURL withPattern:pattern
                        animated:animated transition:transition ? transition : pattern.transition];
  
    if (withDelay && !wasNew) {
      [self cancelDelay];
    }
  } else if (_opensExternalURLs) {
    if ([_delegate respondsToSelector:@selector(navigator:willOpenURL:inViewController:)]) {
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
    _delayedControllers = nil;
    _persistenceMode = TTNavigatorPersistenceModeNone;
    _persistenceExpirationAge = 0;
    _delayCount = 0;
    _supportsShakeToReload = NO;
    _opensExternalURLs = NO;
    
    // SwapMethods a new dealloc for UIViewController so it notifies us when it's going away.
    // We need to remove dying controllers from our binding cache.
    TTSwapMethods([UIViewController class], @selector(dealloc), @selector(ttdealloc));

    TTSwapMethods([UINavigationController class], @selector(popViewControllerAnimated:),
              @selector(popViewControllerAnimated2:));
    
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
  TT_RELEASE_SAFELY(_window);
  TT_RELEASE_SAFELY(_rootViewController);
  TT_RELEASE_SAFELY(_delayedControllers);
  TT_RELEASE_SAFELY(_URLMap);
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

- (UIWindow*)window {
  if (!_window) {
    UIWindow* keyWindow = [UIApplication sharedApplication].keyWindow;
    if (keyWindow) {
      _window = [keyWindow retain];
    } else {
      _window = [[TTNavigatorWindow alloc] initWithFrame:TTScreenBounds()];
      [_window makeKeyAndVisible];
    }
  }
  return _window;
}

- (UIViewController*)visibleViewController {
  UIViewController* controller = _rootViewController;
  while (controller) {
    UIViewController* child = controller.modalViewController;
    if (!child) {
      UISearchDisplayController* search = controller.searchDisplayController;
      if (search && search.active && [search isKindOfClass:[TTSearchDisplayController class]]) {
        TTSearchDisplayController* ttsearch = (TTSearchDisplayController*)search;
        child = ttsearch.searchResultsViewController;
      } else {
        child = controller.topSubcontroller;
      }
    }
    if (child) {
      controller = child;
    } else {
      return controller;
    }
  }
  return nil;
}

- (UIViewController*)topViewController {
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
  return self.topViewController.navigatorURL;
}

- (void)setURL:(NSString*)URL {
  [self openURL:URL animated:YES];
}

- (UIViewController*)openURL:(NSString*)URL animated:(BOOL)animated {
  return [self openURL:URL parent:nil query:nil state:nil animated:animated
               transition:UIViewAnimationTransitionNone withDelay:NO];
}

- (UIViewController*)openURL:(NSString*)URL animated:(BOOL)animated
                     transition:(UIViewAnimationTransition)transition {
  return [self openURL:URL parent:nil query:nil state:nil animated:animated
               transition:transition withDelay:NO];
}

- (UIViewController*)openURL:(NSString*)URL parent:(NSString*)parentURL animated:(BOOL)animated {
  return [self openURL:URL parent:parentURL query:nil state:nil animated:animated
               transition:UIViewAnimationTransitionNone withDelay:NO];
}

- (UIViewController*)openURL:(NSString*)URL query:(NSDictionary*)query animated:(BOOL)animated {
  return [self openURL:URL parent:nil query:query state:nil animated:animated
               transition:UIViewAnimationTransitionNone withDelay:NO];
}

- (UIViewController*)openURL:(NSString*)URL parent:(NSString*)parentURL query:(NSDictionary*)query
                     animated:(BOOL)animated {
  return [self openURL:URL parent:parentURL query:query state:nil animated:animated
               transition:UIViewAnimationTransitionNone withDelay:NO];
}

- (UIViewController*)openURL:(NSString*)URL parent:(NSString*)parentURL query:(NSDictionary*)query
                     animated:(BOOL)animated transition:(UIViewAnimationTransition)transition {
  return [self openURL:URL parent:parentURL query:query state:nil animated:animated
               transition:UIViewAnimationTransitionNone withDelay:NO];
}

- (UIViewController*)openURL:(NSString*)URL parent:(NSString*)parentURL query:(NSDictionary*)query
                     animated:(BOOL)animated transition:(UIViewAnimationTransition)transition
                     withDelay:(BOOL)withDelay {
  return [self openURL:URL parent:parentURL query:query state:nil animated:animated
               transition:UIViewAnimationTransitionNone withDelay:withDelay];
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
                     pattern:(TTURLNavigatorPattern**)pattern {
  NSRange fragmentRange = [URL rangeOfString:@"#" options:NSBackwardsSearch];
  if (fragmentRange.location != NSNotFound) {
    NSString* baseURL = [URL substringToIndex:fragmentRange.location];
    if ([self.URL isEqualToString:baseURL]) {
      UIViewController* controller = self.visibleViewController;
      id result = [_URLMap dispatchURL:URL toTarget:controller query:query];
      if ([result isKindOfClass:[UIViewController class]]) {
        return result;
      } else {
        return controller;
      }
    } else {
      id object = [_URLMap objectForURL:baseURL query:nil pattern:pattern];
      if (object) {
        id result = [_URLMap dispatchURL:URL toTarget:object query:query];
        if ([result isKindOfClass:[UIViewController class]]) {
          return result;
        } else {
          return object;
        }
      } else {
        return nil;
      }
    }
  }

  id object = [_URLMap objectForURL:URL query:query pattern:pattern];
  if (object) {
    UIViewController* controller = object;
    controller.originalNavigatorURL = URL;
    
    if (_delayCount) {
      if (!_delayedControllers) {
        _delayedControllers = [[NSMutableArray alloc] initWithObjects:controller,nil];
      } else {
        [_delayedControllers addObject:controller];
      }
    }
    
    return controller;
  } else {
    return nil;
  }
}

- (BOOL)isDelayed {
  return _delayCount > 0;
}

- (void)beginDelay {
  ++_delayCount;
}

- (void)endDelay {
  if (_delayCount && !--_delayCount) {
    for (UIViewController* controller in _delayedControllers) {
      [controller delayDidEnd];
    }
    
    TT_RELEASE_SAFELY(_delayedControllers);
  }
}

- (void)cancelDelay {
  if (_delayCount && !--_delayCount) {
    TT_RELEASE_SAFELY(_delayedControllers);
  }
}

- (void)persistViewControllers {
  NSMutableArray* path = [NSMutableArray array];
  [self persistController:_rootViewController path:path];
  TTLOG(@"DEBUG PERSIST %@", path);
  
  // Check if any of the paths were "important", and therefore unable to expire
  BOOL important = NO;
  for (NSDictionary* state in path) {
    if ([state objectForKey:@"__important__"]) {
      important = YES;
      break;
    }
  }
  
  NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
  if (path.count) {
    [defaults setObject:path forKey:@"TTNavigatorHistory"];
    [defaults setObject:[NSDate date] forKey:@"TTNavigatorHistoryTime"];
    [defaults setObject:[NSNumber numberWithInt:important] forKey:@"TTNavigatorHistoryImportant"];
  } else {
    [defaults removeObjectForKey:@"TTNavigatorHistory"];
    [defaults removeObjectForKey:@"TTNavigatorHistoryTime"];
    [defaults removeObjectForKey:@"TTNavigatorHistoryImportant"];
  }
  [defaults synchronize];
}

- (UIViewController*)restoreViewControllers { 
  NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
  NSDate* timestamp = [defaults objectForKey:@"TTNavigatorHistoryTime"];
  NSArray* path = [defaults objectForKey:@"TTNavigatorHistory"];
  BOOL important = [[defaults objectForKey:@"TTNavigatorHistoryImportant"] boolValue];
  TTLOG(@"DEBUG RESTORE %@ FROM %@", path, [timestamp formatRelativeTime]);
  
  BOOL expired = _persistenceExpirationAge
                 && -timestamp.timeIntervalSinceNow > _persistenceExpirationAge;
  if (expired && !important) {
    return nil;
  }

  UIViewController* controller = nil;
  BOOL passedContainer = NO;
  for (NSDictionary* state in path) {
    NSString* URL = [state objectForKey:@"__navigatorURL__"];
    controller = [self openURL:URL parent:nil query:nil state:state animated:NO transition:0
                      withDelay:NO];
    
    // Stop if we reach a model view controller whose model could not be synchronously loaded.
    // That is because the controller after it may depend on the data it could not load, so
    // we'd better not risk opening more controllers that may not be able to function.
//    if ([controller isKindOfClass:[TTModelViewController class]]) {
//      TTModelViewController* modelViewController = (TTModelViewController*)controller;
//      if (!modelViewController.model.isLoaded) {
//        break;
//      }
//    }

    // Stop after one controller if we are in "persist top" mode
    if (_persistenceMode == TTNavigatorPersistenceModeTop && passedContainer) {
      break;
    }
    
    passedContainer = [controller canContainControllers];
  }

  [self.window makeKeyAndVisible];
  
  return controller;
}

- (void)persistController:(UIViewController*)controller path:(NSMutableArray*)path {
  NSString* URL = controller.navigatorURL;
  if (URL) {
    // Let the controller persists its own arbitrary state
    NSMutableDictionary* state = [NSMutableDictionary dictionaryWithObject:URL  
                                                      forKey:@"__navigatorURL__"];
    if ([controller persistView:state]) {
      [path addObject:state];
    }
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
  [_rootViewController.view removeFromSuperview];
  TT_RELEASE_SAFELY(_rootViewController);
  [_URLMap removeAllObjects];
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
  [defaults removeObjectForKey:@"TTNavigatorHistoryTime"];
  [defaults removeObjectForKey:@"TTNavigatorHistoryImportant"];
  [defaults synchronize];
}

- (void)reload {
  UIViewController* controller = self.visibleViewController;
  if ([controller isKindOfClass:[TTModelViewController class]]) {
    TTModelViewController* ttcontroller = (TTModelViewController*)controller;
    [ttcontroller reload];
  }
}

@end

///////////////////////////////////////////////////////////////////////////////////////////////////
// global

UIViewController* TTOpenURL(NSString* URL) {
  return [[TTNavigator navigator] openURL:URL animated:YES];
}
