#import "Three20/TTAppBrowser.h"
#import "Three20/TTViewController.h"

///////////////////////////////////////////////////////////////////////////////////////////////////

typedef enum {
  TTURLPatternTypeDefault,
  TTURLPatternTypeSingleton,
  TTURLPatternTypeModal,
} TTURLPatternType;

@interface TTURLPattern : NSObject {
  TTURLPatternType _patternType;
  id _target;
  SEL _action;
  Class _controllerClass;
}

@property(nonatomic,readonly) TTURLPatternType patternType;
@property(nonatomic,readonly) id target;
@property(nonatomic,readonly) SEL action;
@property(nonatomic,readonly) Class controllerClass;

- (id)initWithTarget:(id)target action:(SEL)action;

- (id)initWithClass:(Class)controllerClass patternType:(TTURLPatternType)patternType;

@end

@implementation TTURLPattern

@synthesize target = _target, action = _action, controllerClass = _controllerClass,
            patternType = _patternType;

- (id)initWithTarget:(id)target action:(SEL)action {
  if (self = [super init]) {
    _target = target;
    _action = action;
    _controllerClass = nil;
    _patternType = 0;
  }
  return self;
}

- (id)initWithClass:(Class)controllerClass patternType:(TTURLPatternType)patternType {
  if (self = [super init]) {
    _controllerClass = controllerClass;
    _patternType = patternType;
    _target = nil;
    _action = nil;
  }
  return self;
}

- (void)dealloc {
  [super dealloc];
}

@end

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation TTAppBrowser

@synthesize delegate = _delegate, mainViewController = _mainViewController,
            supportsShakeToReload = _supportsShakeToReload;

///////////////////////////////////////////////////////////////////////////////////////////////////
// class public

+ (TTAppBrowser*)sharedBrowser {
  static TTAppBrowser* sharedBrowser = nil;
  if (!sharedBrowser) {
    sharedBrowser = [[TTAppBrowser alloc] init];
  }
  return sharedBrowser;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// private

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
    controller = [navController.viewControllers lastObject];
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

- (TTViewController*)frontTTViewController {
  UIViewController* controller = self.frontViewController;
  if ([controller isKindOfClass:[TTViewController class]]) {
    return (TTViewController*)controller;
  } else {
    return nil;
  }
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// NSObject

- (id)init {
  if (self = [super init]) {
    _mainViewController = nil;
    _delegate = nil;
    _supportsShakeToReload = NO;
  }
  return self;
}

- (void)dealloc {
  TT_RELEASE_MEMBER(_mainViewController);
  [super dealloc];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// public

- (UIViewController*)visibleViewController {
  UINavigationController* navController = self.frontNavigationController;
  if (navController) {
    UIViewController* controller = navController.topViewController;
    while (controller) {
      if ([controller isKindOfClass:[TTViewController class]]) {
        TTViewController* ttcontroller = (TTViewController*)controller;
        if (!ttcontroller.isViewAppearing) {
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

- (void)loadURL:(NSString*)URL {
}

- (void)addURL:(NSString*)URL controller:(Class)controller selector:(SEL)selector {
}

- (void)addURL:(NSString*)URL parent:(NSString*)parentURL controller:(Class)controller
        selector:(SEL)selector {
}

- (void)addURL:(NSString*)URL singleton:(Class)controller selector:(SEL)selector {
}

- (void)addURL:(NSString*)URL parent:(NSString*)parentURL singleton:(Class)controller
        selector:(SEL)selector {
}

- (void)addURL:(NSString*)URL modal:(Class)controller selector:(SEL)selector {
}

- (void)addURL:(NSString*)URL parent:(NSString*)parentURL modal:(Class)controller
        selector:(SEL)selector {
}

- (void)setController:(UIViewController*)controller forURL:(NSURL*)URL {
}

- (void)removeController:(UIViewController*)controller forURL:(NSURL*)URL {
}

@end

///////////////////////////////////////////////////////////////////////////////////////////////////

void TTLoadURL(NSString* URL) {
  [[TTAppBrowser sharedBrowser] loadURL:URL];
}
