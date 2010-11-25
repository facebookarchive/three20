//
// Copyright 2009-2010 Facebook
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//    http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

#import "Three20UINavigator/TTBaseNavigator.h"

// UINavigator
#import "Three20UINavigator/TTGlobalNavigatorMetrics.h"
#import "Three20UINavigator/TTNavigatorDelegate.h"
#import "Three20UINavigator/TTBaseNavigationController.h"
#import "Three20UINavigator/TTURLAction.h"
#import "Three20UINavigator/TTURLMap.h"
#import "Three20UINavigator/TTURLNavigatorPattern.h"
#import "Three20UINavigator/UIViewController+TTNavigator.h"

// UINavigator (private)
#import "Three20UINavigator/private/TTBaseNavigatorInternal.h"

// UICommon
#import "Three20UICommon/UIViewControllerAdditions.h"

// Core
#import "Three20Core/TTGlobalCore.h"
#import "Three20Core/TTCorePreprocessorMacros.h"
#import "Three20Core/TTDebug.h"
#import "Three20Core/TTDebugFlags.h"
#import "Three20Core/NSDateAdditions.h"

static TTBaseNavigator* gNavigator = nil;

static NSString* kNavigatorHistoryKey           = @"TTNavigatorHistory";
static NSString* kNavigatorHistoryTimeKey       = @"TTNavigatorHistoryTime";
static NSString* kNavigatorHistoryImportantKey  = @"TTNavigatorHistoryImportant";

#ifdef __IPHONE_4_0
UIKIT_EXTERN NSString *const UIApplicationDidEnterBackgroundNotification __attribute__((weak_import));
UIKIT_EXTERN NSString *const UIApplicationWillEnterForegroundNotification __attribute__((weak_import));
#endif


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation TTBaseNavigator

@synthesize delegate                  = _delegate;
@synthesize URLMap                    = _URLMap;
@synthesize window                    = _window;
@synthesize rootViewController        = _rootViewController;
@synthesize persistenceExpirationAge  = _persistenceExpirationAge;
@synthesize persistenceMode           = _persistenceMode;
@synthesize supportsShakeToReload     = _supportsShakeToReload;
@synthesize opensExternalURLs         = _opensExternalURLs;


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)init {
  if (self = [super init]) {
    _URLMap = [[TTURLMap alloc] init];
    _persistenceMode = TTNavigatorPersistenceModeNone;

    NSNotificationCenter* center = [NSNotificationCenter defaultCenter];
    [center addObserver:self
               selector:@selector(applicationWillLeaveForeground:)
                   name:UIApplicationWillTerminateNotification
                 object:nil];
#ifdef __IPHONE_4_0
    if (nil != &UIApplicationDidEnterBackgroundNotification) {
      [center addObserver:self
                 selector:@selector(applicationWillLeaveForeground:)
                     name:UIApplicationDidEnterBackgroundNotification
                   object:nil];
    }
#endif
  }
  return self;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)dealloc {
  [[NSNotificationCenter defaultCenter] removeObserver:self];
  _delegate = nil;
  TT_RELEASE_SAFELY(_window);
  TT_RELEASE_SAFELY(_rootViewController);
  TT_RELEASE_SAFELY(_delayedControllers);
  TT_RELEASE_SAFELY(_URLMap);

  [super dealloc];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
+ (TTBaseNavigator*)globalNavigator {
  return gNavigator;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
+ (void)setGlobalNavigator:(TTBaseNavigator*)navigator {
  if (gNavigator != navigator) {
    [gNavigator release];
    gNavigator = [navigator retain];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Private


///////////////////////////////////////////////////////////////////////////////////////////////////
/**
 * The goal of this method is to return the currently visible view controller, referred to here as
 * the "front" view controller. Tab bar controllers and navigation controllers are special-cased,
 * and when a controller has a modal controller, the method recurses as necessary.
 *
 * @private
 */
+ (UIViewController*)frontViewControllerForController:(UIViewController*)controller {
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
    return [TTBaseNavigator frontViewControllerForController:controller.modalViewController];

  } else {
    return controller;
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
/**
 * Similar to frontViewControllerForController, this method attempts to return the "front"
 * navigation controller. This makes the assumption that a tab bar controller has navigation
 * controllers as children.
 * If the root controller isn't a tab controller or a navigation controller, then no navigation
 * controller will be returned.
 *
 * @private
 */
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


///////////////////////////////////////////////////////////////////////////////////////////////////
- (UIViewController*)frontViewController {
  UINavigationController* navController = self.frontNavigationController;
  if (navController) {
    return [TTBaseNavigator frontViewControllerForController:navController];

  } else {
    return [TTBaseNavigator frontViewControllerForController:_rootViewController];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setRootViewController:(UIViewController*)controller {
  if (controller != _rootViewController) {
    [_rootViewController release];
    _rootViewController = [controller retain];
    [self.window addSubview:_rootViewController.view];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
/**
 * Prepare the given controller's parent controller and return it. Ensures that the parent
 * controller exists in the navigation hierarchy. If it doesn't exist, and the given controller
 * isn't a container, then a UINavigationController will be made the root controller.
 *
 * @private
 */
- (UIViewController*)parentForController: (UIViewController*)controller
                             isContainer: (BOOL)isContainer
                           parentURLPath: (NSString*)parentURLPath {
  if (controller == _rootViewController) {
    return nil;

  } else {
    // If this is the first controller, and it is not a "container", forcibly put
    // a navigation controller at the root of the controller hierarchy.
    if (nil == _rootViewController && !isContainer) {
      [self setRootViewController:[[[[self navigationControllerClass] alloc] init] autorelease]];
    }

    if (nil != parentURLPath) {
      return [self openURLAction:[TTURLAction actionWithURLPath:parentURLPath]];

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


///////////////////////////////////////////////////////////////////////////////////////////////////
/**
 * A modal controller is a view controller that is presented over another controller and hides
 * the original controller completely. Classic examples include the Safari login controller when
 * authenticating on a network, creating a new contact in Contacts, and the Camera controller.
 *
 * If the controller that is being presented is not a UINavigationController, then a
 * UINavigationController is created and the controller is pushed onto the navigation controller.
 * The navigation controller is then displayed instead.
 *
 * @private
 */
- (void)presentModalController: (UIViewController*)controller
              parentController: (UIViewController*)parentController
                      animated: (BOOL)animated
                    transition: (NSInteger)transition {
  controller.modalTransitionStyle = transition;

  if ([controller isKindOfClass:[UINavigationController class]]) {
    [parentController presentModalViewController: controller
                                        animated: animated];

  } else {
    UINavigationController* navController = [[[[self navigationControllerClass] alloc] init] autorelease];
    [navController pushViewController: controller
                             animated: NO];
    [parentController presentModalViewController: navController
                                        animated: animated];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
/**
 * @return NO if the controller already has a super controller and is simply made visible.
 *         YES if the controller is the new root or if it did not have a super controller.
 *
 * @private
 */
- (BOOL)presentController: (UIViewController*)controller
         parentController: (UIViewController*)parentController
                     mode: (TTNavigationMode)mode
                 animated: (BOOL)animated
               transition: (NSInteger)transition {
  BOOL didPresentNewController = YES;

  if (nil == _rootViewController) {
    [self setRootViewController:controller];

  } else {
    UIViewController* previousSuper = controller.superController;
    if (nil != previousSuper) {
      if (previousSuper != parentController) {
        // The controller already exists, so we just need to make it visible
        for (UIViewController* superController = previousSuper; controller; ) {
          UIViewController* nextSuper = superController.superController;
          [superController bringControllerToFront: controller
                                         animated: !nextSuper];
          controller = superController;
          superController = nextSuper;
        }
      }
      didPresentNewController = NO;

    } else if (nil != parentController) {
      [self presentDependantController: controller
                      parentController: parentController
                                  mode: mode
                              animated: animated
                            transition: transition];
    }
  }

  return didPresentNewController;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)presentController: (UIViewController*)controller
            parentURLPath: (NSString*)parentURLPath
              withPattern: (TTURLNavigatorPattern*)pattern
                 animated: (BOOL)animated
               transition: (NSInteger)transition {
  BOOL didPresentNewController = NO;

  if (nil != controller) {
    UIViewController* topViewController = self.topViewController;

    if (controller != topViewController) {
      UIViewController* parentController = [self parentForController: controller
                                                         isContainer: [controller
                                                                       canContainControllers]
                                                       parentURLPath: parentURLPath
                                            ? parentURLPath
                                                                    : pattern.parentURL];

      if (nil != parentController && parentController != topViewController) {
        [self presentController: parentController
               parentController: nil
                           mode: TTNavigationModeNone
                       animated: NO
                     transition: 0];
      }

      didPresentNewController = [self
                                 presentController: controller
                                 parentController: parentController
                                 mode: pattern.navigationMode
                                 animated: animated
                                 transition: transition];
    }
  }
  return didPresentNewController;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
/**
 * @protected
 */
- (void)didRestoreController:(UIViewController*)controller {
  // Purposefully empty implementation. Meant to be overridden.
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (UIViewController*)openURLAction:(TTURLAction*)action {
  if (nil == action || nil == action.urlPath) {
    return nil;
  }

  // We may need to modify the urlPath, so let's create a local copy.
  NSString* urlPath = action.urlPath;

  NSURL* theURL = [NSURL URLWithString:urlPath];
  if ([_URLMap isAppURL:theURL]) {
    [[UIApplication sharedApplication] openURL:theURL];
    return nil;
  }

  if (nil == theURL.scheme) {
    if (nil != theURL.fragment) {
      urlPath = [self.URL stringByAppendingString:urlPath];
    } else {
      urlPath = [@"http://" stringByAppendingString:urlPath];
    }
    theURL = [NSURL URLWithString:urlPath];
  }

  // Allows the delegate to prevent opening this URL
  if ([_delegate respondsToSelector:@selector(navigator:shouldOpenURL:)]) {
    if (![_delegate navigator:self shouldOpenURL:theURL]) {
      return nil;
    }
  }

  // Allows the delegate to modify the URL to be opened, as well as reject it. This delegate
  // method is intended to supersede -navigator:shouldOpenURL:.
  if ([_delegate respondsToSelector:@selector(navigator:URLToOpen:)]) {
    NSURL *newURL = [_delegate navigator:self URLToOpen:theURL];
    if (!newURL) {
      return nil;
    } else {
      theURL = newURL;
      urlPath = newURL.absoluteString;
    }
  }

  if (action.withDelay) {
    [self beginDelay];
  }

  TTDCONDITIONLOG(TTDFLAG_NAVIGATOR, @"OPENING URL %@", urlPath);

  TTURLNavigatorPattern* pattern = nil;
  UIViewController* controller = [self viewControllerForURL: urlPath
                                                      query: action.query
                                                    pattern: &pattern];
  if (nil != controller) {
    if (nil != action.state) {
      [controller restoreView:action.state];
      controller.frozenState = action.state;

      [self didRestoreController:controller];
    }

    if ([_delegate respondsToSelector:@selector(navigator:willOpenURL:inViewController:)]) {
      [_delegate navigator: self
               willOpenURL: theURL
          inViewController: controller];
    }

    BOOL wasNew = [self presentController: controller
                            parentURLPath: action.parentURLPath
                              withPattern: pattern
                                 animated: action.animated
                               transition: action.transition ?
                   action.transition : pattern.transition];

    if (action.withDelay && !wasNew) {
      [self cancelDelay];
    }

  } else if (_opensExternalURLs) {
    if ([_delegate respondsToSelector:@selector(navigator:willOpenURL:inViewController:)]) {
      [_delegate navigator: self
               willOpenURL: theURL
          inViewController: nil];
    }

    [[UIApplication sharedApplication] openURL:theURL];
  }

  return controller;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
/**
 * @protected
 */
- (Class)windowClass {
  return [UIWindow class];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark NSNotifications


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)applicationWillLeaveForeground:(void *)ignored {
  if (_persistenceMode) {
    [self persistViewControllers];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Public


///////////////////////////////////////////////////////////////////////////////////////////////////
- (UIWindow*)window {
  if (nil == _window) {
    UIWindow* keyWindow = [UIApplication sharedApplication].keyWindow;
    if (nil != keyWindow) {
      _window = [keyWindow retain];

    } else {
      _window = [[[self windowClass] alloc] initWithFrame:TTScreenBounds()];
      [_window makeKeyAndVisible];
    }
  }
  return _window;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (UIViewController*)visibleViewController {
  UIViewController* controller = _rootViewController;
  while (nil != controller) {
    UIViewController* child = controller.modalViewController;

    if (nil == child) {
      child = [self getVisibleChildController:controller];
    }

    if (nil != child) {
      controller = child;

    } else {
      return controller;
    }
  }
  return nil;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (UIViewController*)topViewController {
  UIViewController* controller = _rootViewController;
  while (controller) {
    UIViewController* child = controller.popupViewController;
    if (!child || ![child canBeTopViewController]) {
      child = controller.modalViewController;
    }
    if (!child) {
      child = controller.topSubcontroller;
    }
    if (child) {
      if (child == _rootViewController) {
        return child;
      } else {
        controller = child;
      }
    } else {
      return controller;
    }
  }
  return nil;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSString*)URL {
  return self.topViewController.navigatorURL;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setURL:(NSString*)URLPath {
  [self openURLAction:[[TTURLAction actionWithURLPath: URLPath]
                       applyAnimated: YES]];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (UIViewController*)openURLs:(NSString*)URL,... {
  UIViewController* controller = nil;
  va_list ap;
  va_start(ap, URL);
  while (URL) {
    controller = [self openURLAction:[TTURLAction actionWithURLPath:URL]];
    URL = va_arg(ap, id);
  }
  va_end(ap);

  return controller;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (UIViewController*)viewControllerForURL:(NSString*)URL {
  return [self viewControllerForURL:URL query:nil pattern:nil];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (UIViewController*)viewControllerForURL:(NSString*)URL query:(NSDictionary*)query {
  return [self viewControllerForURL:URL query:query pattern:nil];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (UIViewController*)viewControllerForURL: (NSString*)URL
                                    query: (NSDictionary*)query
                                  pattern: (TTURLNavigatorPattern**)pattern {
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


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)isDelayed {
  return _delayCount > 0;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)beginDelay {
  ++_delayCount;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)endDelay {
  if (_delayCount && !--_delayCount) {
    for (UIViewController* controller in _delayedControllers) {
      [controller delayDidEnd];
    }

    TT_RELEASE_SAFELY(_delayedControllers);
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)cancelDelay {
  if (_delayCount && !--_delayCount) {
    TT_RELEASE_SAFELY(_delayedControllers);
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)persistViewControllers {
  NSMutableArray* path = [NSMutableArray array];
  [self persistController:_rootViewController path:path];
  TTDCONDITIONLOG(TTDFLAG_NAVIGATOR, @"DEBUG PERSIST %@", path);

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
    [defaults setObject:path forKey:kNavigatorHistoryKey];
    [defaults setObject:[NSDate date] forKey:kNavigatorHistoryTimeKey];
    [defaults setObject:[NSNumber numberWithInt:important] forKey:kNavigatorHistoryImportantKey];
  } else {
    [defaults removeObjectForKey:kNavigatorHistoryKey];
    [defaults removeObjectForKey:kNavigatorHistoryTimeKey];
    [defaults removeObjectForKey:kNavigatorHistoryImportantKey];
  }
  [defaults synchronize];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (UIViewController*)restoreViewControllers {
  NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
  NSDate* timestamp = [defaults objectForKey:kNavigatorHistoryTimeKey];
  NSArray* path = [defaults objectForKey:kNavigatorHistoryKey];
  BOOL important = [[defaults objectForKey:kNavigatorHistoryImportantKey] boolValue];
  TTDCONDITIONLOG(TTDFLAG_NAVIGATOR, @"DEBUG RESTORE %@ FROM %@",
                  path, [timestamp formatRelativeTime]);

  BOOL expired = _persistenceExpirationAge
  && -timestamp.timeIntervalSinceNow > _persistenceExpirationAge;
  if (expired && !important) {
    return nil;
  }

  UIViewController* controller = nil;
  BOOL passedContainer = NO;
  for (NSDictionary* state in path) {
    NSString* URL = [state objectForKey:@"__navigatorURL__"];
    controller = [self openURLAction:[[TTURLAction actionWithURLPath: URL]
                                      applyState: state]];

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


///////////////////////////////////////////////////////////////////////////////////////////////////
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


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)removeAllViewControllers {
  [_rootViewController.view removeFromSuperview];
  TT_RELEASE_SAFELY(_rootViewController);
  [_URLMap removeAllObjects];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
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


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)objectForPath:(NSString*)path {
  NSArray* keys = [path componentsSeparatedByString:@"/"];
  UIViewController* controller = _rootViewController;
  for (NSString* key in [keys reverseObjectEnumerator]) {
    controller = [controller subcontrollerForKey:key];
  }
  return controller;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)resetDefaults {
  NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
  [defaults removeObjectForKey:kNavigatorHistoryKey];
  [defaults removeObjectForKey:kNavigatorHistoryTimeKey];
  [defaults removeObjectForKey:kNavigatorHistoryImportantKey];
  [defaults synchronize];
}


@end


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation TTBaseNavigator (TTInternal)


///////////////////////////////////////////////////////////////////////////////////////////////////
/**
 * Present a view controller that strictly depends on the existence of the parent controller.
 */
- (void)presentDependantController: (UIViewController*)controller
                  parentController: (UIViewController*)parentController
                              mode: (TTNavigationMode)mode
                          animated: (BOOL)animated
                        transition: (NSInteger)transition {

  if (mode == TTNavigationModeModal) {
    [self presentModalController: controller
                parentController: parentController
                        animated: animated
                      transition: transition];

  } else {
    [parentController addSubcontroller: controller
                              animated: animated
                            transition: transition];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (UIViewController*)getVisibleChildController:(UIViewController*)controller {
  return controller.topSubcontroller;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (Class)navigationControllerClass {
  return [TTBaseNavigationController class];
}


@end
