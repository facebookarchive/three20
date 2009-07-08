#import "Three20/TTAppMap.h"
#import "Three20/TTURLPattern.h"
#import "Three20/TTViewController.h"
#import <objc/runtime.h>

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation TTAppMap

@synthesize delegate = _delegate, window = _window,
            rootViewController = _rootViewController, persistenceMode = _persistenceMode,
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

- (void)addPattern:(TTURLPattern*)pattern forURL:(NSString*)URL {
  pattern.URL = URL;
  [pattern compile];
  
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

- (id)objectForURL:(NSString*)URL theURL:(NSURL*)theURL params:(NSDictionary*)params
      outPattern:(TTURLPattern**)outPattern {
  if (_bindings) {
    // XXXjoe Normalize the URL first
    id object = [_bindings objectForKey:URL];
    if (object) {
      return object;
    }
  }

  TTURLPattern* pattern = [self matchPattern:theURL];
  if (pattern) {
    id target = nil;
    UIViewController* controller = nil;

    if (pattern.targetClass) {
      target = [pattern.targetClass alloc];
    } else {
      target = [pattern.targetObject retain];
    }
    
    if (pattern.selector) {
      controller = [pattern invoke:target withURL:theURL params:params];
    } else if (pattern.targetClass) {
      controller = [target init];
    }
    
    if (pattern.displayMode == TTDisplayModeShare && controller) {
      [self bindObject:controller toURL:URL];
    }
    
    [target autorelease];

    if (outPattern) {
      *outPattern = pattern;
    }
    return controller;
  } else {
    return nil;
  }
}

- (void)setRootViewController:(UIViewController*)controller {
  if (controller != _rootViewController) {
    [_rootViewController release];
    _rootViewController = [controller retain];
    
    UIView* mainView = controller.view;
    if (!mainView.superview) {
      if (!_window) {
        UIWindow* keyWindow = [UIApplication sharedApplication].keyWindow;
        if (keyWindow) {
          _window = [keyWindow retain];
        } else {
          _window = [[UIWindow alloc] initWithFrame:TTScreenBounds()];
          //_window.autoresizesSubviews = NO;
          [_window makeKeyAndVisible];
        }
      }
      [_window addSubview:controller.view];
    }
  }
}

- (UIViewController*)parentForController:(UIViewController*)controller parent:(NSURL*)parentURL {
  UIViewController* parentController = nil;
  if (parentURL) {
    parentController = [self objectForURL:parentURL.absoluteString theURL:parentURL params:nil
                             outPattern:nil];
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

- (void)presentController:(UIViewController*)controller forURL:(NSURL*)URL
        parent:(NSString*)parentURL withPattern:(TTURLPattern*)pattern animated:(BOOL)animated {
  NSURL* parent = parentURL ? [NSURL URLWithString:parentURL] : pattern.parentURL;
  UIViewController* parentController = [self parentForController:controller parent:parent];
  [self presentController:controller parent:parentController
        modal:pattern.displayMode == TTDisplayModeModal animated:animated];
}

- (UIViewController*)openControllerWithURL:(NSString*)URL parent:(NSString*)parentURL
                     params:(NSDictionary*)params display:(BOOL)display animated:(BOOL)animated {
  NSURL* theURL = [NSURL URLWithString:URL];

  if (display && [_delegate respondsToSelector:@selector(appMap:shouldOpenURL:)]) {
    if (![_delegate appMap:self shouldOpenURL:theURL]) {
      return nil;
    }
  }

  TTURLPattern* pattern = nil;
  UIViewController* controller = [self objectForURL:URL theURL:theURL params:params
                                       outPattern:&pattern];
  if (controller) {
    if (display && [_delegate respondsToSelector:@selector(appMap:wilOpenURL:inViewController:)]) {
      [_delegate appMap:self willOpenURL:theURL inViewController:controller];
    }

    controller.appMapURL = URL;
    if (display) {
      [self presentController:controller forURL:theURL parent:parentURL withPattern:pattern
            animated:animated];
    }
  } else if (display && _openExternalURLs) {
    if ([_delegate respondsToSelector:@selector(appMap:wilOpenURL:inViewController:)]) {
      [_delegate appMap:self willOpenURL:theURL inViewController:nil];
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
    _window = nil;
    _rootViewController = nil;
    _bindings = nil;
    _patterns = nil;
    _defaultPattern = nil;
    _persistenceMode = TTAppMapPersistenceModeNone;
    _invalidPatterns = NO;
    _supportsShakeToReload = NO;
    _openExternalURLs = NO;
    
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
  TT_RELEASE_MEMBER(_window);
  TT_RELEASE_MEMBER(_rootViewController);
  TT_RELEASE_MEMBER(_bindings);
  TT_RELEASE_MEMBER(_patterns);
  TT_RELEASE_MEMBER(_defaultPattern);
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
    UIViewController* child = controller.childViewController;
    if (child) {
      controller = child;
    } else {
      return controller;
    }
  }
  return nil;
}

- (UIViewController*)openURL:(NSString*)URL animated:(BOOL)animated {
  return [self openURL:URL parent:nil params:nil animated:animated];
}

- (UIViewController*)openURL:(NSString*)URL parent:(NSString*)parentURL animated:(BOOL)animated {
  return [self openURL:URL parent:parentURL params:nil animated:animated];
}

- (UIViewController*)openURL:(NSString*)URL params:(NSDictionary*)params animated:(BOOL)animated {
  return [self openURL:URL parent:nil params:nil animated:animated];
}

- (UIViewController*)openURL:(NSString*)URL parent:(NSString*)parentURL params:(NSDictionary*)params
                     animated:(BOOL)animated {
  return [self openControllerWithURL:URL parent:parentURL params:params display:YES
               animated:animated];
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

- (void)removeAllViewControllers {
  // XXXjoe Implement me
}

- (id)objectForURL:(NSString*)URL {
  return [self openControllerWithURL:URL parent:nil params:nil display:NO animated:NO];
}

- (TTDisplayMode)displayModeForURL:(NSString*)URL {
  TTURLPattern* pattern = [self matchPattern:[NSURL URLWithString:URL]];
  return pattern.displayMode;
}

- (void)addURL:(NSString*)URL create:(id)target {
  TTURLPattern* pattern = [[TTURLPattern alloc] initWithType:TTDisplayModeCreate target:target];
  [self addPattern:pattern forURL:URL];
  [pattern release];
}

- (void)addURL:(NSString*)URL create:(id)target selector:(SEL)selector {
  TTURLPattern* pattern = [[TTURLPattern alloc] initWithType:TTDisplayModeCreate target:target];
  pattern.selector = selector;
  [self addPattern:pattern forURL:URL];
  [pattern release];
}

- (void)addURL:(NSString*)URL parent:(NSString*)parentURL create:(id)target
        selector:(SEL)selector {
  TTURLPattern* pattern = [[TTURLPattern alloc] initWithType:TTDisplayModeCreate target:target];
  pattern.parentURL = [NSURL URLWithString:parentURL];
  pattern.selector = selector;
  [self addPattern:pattern forURL:URL];
  [pattern release];
}

- (void)addURL:(NSString*)URL share:(id)target {
  TTURLPattern* pattern = [[TTURLPattern alloc] initWithType:TTDisplayModeShare target:target];
  [self addPattern:pattern forURL:URL];
  [pattern release];
}

- (void)addURL:(NSString*)URL share:(id)target selector:(SEL)selector {
  TTURLPattern* pattern = [[TTURLPattern alloc] initWithType:TTDisplayModeShare target:target];
  pattern.selector = selector;
  [self addPattern:pattern forURL:URL];
  [pattern release];
}

- (void)addURL:(NSString*)URL parent:(NSString*)parentURL share:(id)target selector:(SEL)selector {
  TTURLPattern* pattern = [[TTURLPattern alloc] initWithType:TTDisplayModeShare target:target];
  pattern.parentURL = [NSURL URLWithString:parentURL];
  pattern.selector = selector;
  [self addPattern:pattern forURL:URL];
  [pattern release];
}

- (void)addURL:(NSString*)URL modal:(id)target {
  TTURLPattern* pattern = [[TTURLPattern alloc] initWithType:TTDisplayModeModal target:target];
  [self addPattern:pattern forURL:URL];
  [pattern release];
}

- (void)addURL:(NSString*)URL modal:(id)target selector:(SEL)selector {
  TTURLPattern* pattern = [[TTURLPattern alloc] initWithType:TTDisplayModeModal target:target];
  pattern.selector = selector;
  [self addPattern:pattern forURL:URL];
  [pattern release];
}

- (void)addURL:(NSString*)URL parent:(NSString*)parentURL modal:(id)target selector:(SEL)selector {
  TTURLPattern* pattern = [[TTURLPattern alloc] initWithType:TTDisplayModeModal target:target];
  pattern.parentURL = [NSURL URLWithString:parentURL];
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

- (void)bindObject:(id)object toURL:(NSString*)URL {
  if (!_bindings) {
    _bindings = TTCreateNonRetainingDictionary();
  }
  // XXXjoe Normalize the URL first
  [_bindings setObject:object forKey:URL];
}

- (void)removeBindingForURL:(NSString*)URL {
  [_bindings removeObjectForKey:URL];
}

- (void)removeBindingForObject:(id)object {
  // XXXjoe IMPLEMENT ME
}

- (void)resetDefaults {
  NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
  [defaults removeObjectForKey:@"TTAppMapNavigation"];
  [defaults synchronize];
}

- (void)persistViewControllers {
  NSMutableArray* path = [NSMutableArray array];
  [self persistController:_rootViewController path:path];

  if (_rootViewController.modalViewController) {
    [self persistController:_rootViewController.modalViewController path:path];
  }
  
  NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
  [defaults setObject:path forKey:@"TTAppMapNavigation"];
  [defaults synchronize];
}

- (UIViewController*)restoreViewControllers { 
  NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
  NSArray* path = [defaults objectForKey:@"TTAppMapNavigation"];
  
  UIViewController* controller = nil;
  BOOL passedContainer = NO;
  for (NSDictionary* state in path) {
    NSString* URL = [state objectForKey:@"__appMapURL__"];
    controller = [self openControllerWithURL:URL parent:nil params:nil display:YES animated:NO];
    controller.frozenState = state;
    
    if (_persistenceMode == TTAppMapPersistenceModeTop && passedContainer) {
      break;
    }
    passedContainer = [controller isContainerController];
  }

  return controller;
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

UIViewController* TTOpenURL(NSString* URL) {
  return [[TTAppMap sharedMap] openURL:URL animated:YES];
}
