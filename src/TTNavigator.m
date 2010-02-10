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

#import "Three20/TTNavigator.h"

#import "Three20/TTGlobalUI.h"
#import "Three20/TTGlobalUINavigator.h"
#import "Three20/TTDebugFlags.h"

#import "Three20/TTURLAction.h"
#import "Three20/TTURLMap.h"
#import "Three20/TTURLNavigatorPattern.h"

#import "Three20/TTPopupViewController.h"
#import "Three20/TTSearchDisplayController.h"
#import "Three20/TTTableViewController.h"


///////////////////////////////////////////////////////////////////////////////////////////////////
UIViewController* TTOpenURL(NSString* URL) {
  return [[TTNavigator navigator] openURLAction:
    [[TTURLAction actionWithURLPath:URL]
                      applyAnimated:YES]];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@interface TTNavigatorWindow : UIWindow
@end


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation TTNavigatorWindow


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)motionBegan:(UIEventSubtype)motion withEvent:(UIEvent *)event {
  if (event.type == UIEventSubtypeMotionShake && [TTNavigator navigator].supportsShakeToReload) {
    [[TTNavigator navigator] reload];
  }
}


@end


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation TTNavigator

@synthesize delegate                  = _delegate;
@synthesize URLMap                    = _URLMap;
@synthesize window                    = _window;
@synthesize rootViewController        = _rootViewController;
@synthesize persistenceExpirationAge  = _persistenceExpirationAge;
@synthesize persistenceMode           = _persistenceMode;
@synthesize supportsShakeToReload     = _supportsShakeToReload;
@synthesize opensExternalURLs         = _opensExternalURLs;


///////////////////////////////////////////////////////////////////////////////////////////////////
+ (TTNavigator*)navigator {
  static TTNavigator* navigator = nil;
  if (!navigator) {
    navigator = [[TTNavigator alloc] init];
  }
  return navigator;
}


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
    return [TTNavigator frontViewControllerForController:controller.modalViewController];
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
/**
 * @private
 */
- (UIViewController*)frontViewController {
  UINavigationController* navController = self.frontNavigationController;
  if (navController) {
    return [TTNavigator frontViewControllerForController:navController];
  } else {
    return [TTNavigator frontViewControllerForController:_rootViewController];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
/**
 * @private
 */
- (void)setRootViewController:(UIViewController*)controller {
  if (controller != _rootViewController) {
    [_rootViewController release];
    _rootViewController = [controller retain];
    [self.window addSubview:_rootViewController.view];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
/**
 * @private
 */
- (UIViewController*)parentForController: (UIViewController*)controller
                           parentURLPath: (NSString*)parentURLPath {
  if (controller == _rootViewController) {
    return nil;
  } else {
    // If this is the first controller, and it is not a "container", forcibly put
    // a navigation controller at the root of the controller hierarchy.
    if (!_rootViewController && ![controller canContainControllers]) {
      [self setRootViewController:[[[UINavigationController alloc] init] autorelease]];
    }

    if (parentURLPath) {
      return [self openURLAction:[TTURLAction actionWithURLPath: parentURLPath]];
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
 * A popup controller is a view controller that is presented over another controller, but doesn't
 * necessarily completely hide the original controller (like a modal controller would). A classic
 * example is a status indicator while something is loading.
 *
 * @private
 */
- (void)presentPopupController: (TTPopupViewController*)controller
              parentController: (UIViewController*)parentController
                      animated: (BOOL)animated {
  parentController.popupViewController = controller;
  controller.superController = parentController;
  [controller showInView: parentController.view
                animated: animated];
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
    UINavigationController* navController = [[[UINavigationController alloc] init] autorelease];
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
      if ([controller isKindOfClass:[TTPopupViewController class]]) {
        TTPopupViewController* popupViewController = (TTPopupViewController*)controller;
        [self presentPopupController: popupViewController
                    parentController: parentController
                            animated: animated];

      } else if (mode == TTNavigationModeModal) {
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
  }

  return didPresentNewController;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
/**
 * @private
 */
- (BOOL)presentController: (UIViewController*)controller
            parentURLPath: (NSString*)parentURLPath
              withPattern: (TTURLNavigatorPattern*)pattern
                 animated: (BOOL)animated
               transition: (NSInteger)transition {
  BOOL didPresentNewController = NO;

  if (nil != controller) {
    UIViewController* topViewController = self.topViewController;

    if (controller != topViewController) {
      UIViewController* parentController = [self
        parentForController: controller
              parentURLPath: parentURLPath ? parentURLPath : pattern.parentURL];

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
 * @private
 */
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
  
  if ([_delegate respondsToSelector:@selector(navigator:shouldOpenURL:)]) {
    if (![_delegate navigator:self shouldOpenURL:theURL]) {
      return nil;
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

      if ([controller isKindOfClass:[TTModelViewController class]]) {
        TTModelViewController* modelViewController = (TTModelViewController*)controller;
        modelViewController.model;
      }
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
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark NSObject


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)init {
  if (self = [super init]) {
    _URLMap = [[TTURLMap alloc] init];
    _persistenceMode = TTNavigatorPersistenceModeNone;
    
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


///////////////////////////////////////////////////////////////////////////////////////////////////
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
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark NSNotifications


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)applicationWillTerminateNotification:(void*)info {
  if (_persistenceMode) {
    [self persistViewControllers];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Public methods


///////////////////////////////////////////////////////////////////////////////////////////////////
/**
 * @public
 */
- (UIWindow*)window {
  if (nil == _window) {
    UIWindow* keyWindow = [UIApplication sharedApplication].keyWindow;
    if (nil != keyWindow) {
      _window = [keyWindow retain];

    } else {
      _window = [[TTNavigatorWindow alloc] initWithFrame:TTScreenBounds()];
      [_window makeKeyAndVisible];
    }
  }
  return _window;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
/**
 * @public
 */
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


///////////////////////////////////////////////////////////////////////////////////////////////////
/**
 * @public
 */
- (UIViewController*)topViewController {
  UIViewController* controller = _rootViewController;
  while (controller) {
    UIViewController* child = controller.modalViewController;
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
/**
 * @public
 */
- (NSString*)URL {
  return self.topViewController.navigatorURL;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
/**
 * @public
 */
- (void)setURL:(NSString*)URLPath {
  [self openURLAction:[[TTURLAction actionWithURLPath: URLPath]
                                        applyAnimated: YES]];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
/**
 * @public
 */
- (UIViewController*)openURL: (NSString*)URL
                    animated: (BOOL)animated {
  return [self openURLAction:[[TTURLAction actionWithURLPath: URL]
                                               applyAnimated: animated]];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
/**
 * @public
 */
- (UIViewController*)openURL: (NSString*)URL
                    animated: (BOOL)animated
                  transition: (UIViewAnimationTransition)transition {
  return [self openURLAction:[[[TTURLAction actionWithURLPath: URL]
                                                applyAnimated: animated]
                                              applyTransition: transition]];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
/**
 * @public
 */
- (UIViewController*)openURL: (NSString*)URL
                      parent: (NSString*)parentURL
                    animated: (BOOL)animated {
  return [self openURLAction:[[[TTURLAction actionWithURLPath: URL]
                                           applyParentURLPath: parentURL]
                                                applyAnimated: animated]];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
/**
 * @public
 */
- (UIViewController*)openURL: (NSString*)URL
                       query: (NSDictionary*)query
                    animated: (BOOL)animated {
  return [self openURLAction:[[[TTURLAction actionWithURLPath: URL]
                                                   applyQuery: query]
                                                applyAnimated: animated]];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
/**
 * @public
 */
- (UIViewController*)openURL: (NSString*)URL
                      parent: (NSString*)parentURL
                       query: (NSDictionary*)query
                    animated: (BOOL)animated {
  return [self openURLAction:[[[[TTURLAction actionWithURLPath: URL]
                                            applyParentURLPath: parentURL]
                                                    applyQuery: query]
                                                 applyAnimated: animated]];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
/**
 * @public
 */
- (UIViewController*)openURL: (NSString*)URL
                      parent: (NSString*)parentURL
                       query: (NSDictionary*)query
                    animated: (BOOL)animated
                  transition: (UIViewAnimationTransition)transition {
  return [self openURLAction:[[[[[TTURLAction actionWithURLPath: URL]
                                             applyParentURLPath: parentURL]
                                                     applyQuery: query]
                                                  applyAnimated: animated]
                                                applyTransition: transition]];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
/**
 * @public
 */
- (UIViewController*)openURL: (NSString*)URL
                      parent: (NSString*)parentURL
                       query: (NSDictionary*)query
                    animated: (BOOL)animated
                  transition: (UIViewAnimationTransition)transition
                   withDelay: (BOOL)withDelay {
  return [self openURLAction:[[[[[[TTURLAction actionWithURLPath: URL]
                                              applyParentURLPath: parentURL]
                                                      applyQuery: query]
                                                   applyAnimated: animated]
                                                 applyTransition: transition]
                                                  applyWithDelay: withDelay]];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
/**
 * @public
 */
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
/**
 * @public
 */
- (UIViewController*)viewControllerForURL:(NSString*)URL {
  return [self viewControllerForURL:URL query:nil pattern:nil];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
/**
 * @public
 */
- (UIViewController*)viewControllerForURL:(NSString*)URL query:(NSDictionary*)query {
  return [self viewControllerForURL:URL query:query pattern:nil];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
/**
 * @public
 */
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
/**
 * @public
 */
- (BOOL)isDelayed {
  return _delayCount > 0;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
/**
 * @public
 */
- (void)beginDelay {
  ++_delayCount;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
/**
 * @public
 */
- (void)endDelay {
  if (_delayCount && !--_delayCount) {
    for (UIViewController* controller in _delayedControllers) {
      [controller delayDidEnd];
    }
    
    TT_RELEASE_SAFELY(_delayedControllers);
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
/**
 * @public
 */
- (void)cancelDelay {
  if (_delayCount && !--_delayCount) {
    TT_RELEASE_SAFELY(_delayedControllers);
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
/**
 * @public
 */
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


///////////////////////////////////////////////////////////////////////////////////////////////////
/**
 * @public
 */
- (UIViewController*)restoreViewControllers { 
  NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
  NSDate* timestamp = [defaults objectForKey:@"TTNavigatorHistoryTime"];
  NSArray* path = [defaults objectForKey:@"TTNavigatorHistory"];
  BOOL important = [[defaults objectForKey:@"TTNavigatorHistoryImportant"] boolValue];
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
/**
 * @public
 */
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
/**
 * @public
 */
- (void)removeAllViewControllers {
  [_rootViewController.view removeFromSuperview];
  TT_RELEASE_SAFELY(_rootViewController);
  [_URLMap removeAllObjects];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
/**
 * @public
 */
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
/**
 * @public
 */
- (id)objectForPath:(NSString*)path {
  NSArray* keys = [path componentsSeparatedByString:@"/"];
  UIViewController* controller = _rootViewController;
  for (NSString* key in [keys reverseObjectEnumerator]) {
    controller = [controller subcontrollerForKey:key];
  }
  return controller;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
/**
 * @public
 */
- (void)resetDefaults {
  NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
  [defaults removeObjectForKey:@"TTNavigatorHistory"];
  [defaults removeObjectForKey:@"TTNavigatorHistoryTime"];
  [defaults removeObjectForKey:@"TTNavigatorHistoryImportant"];
  [defaults synchronize];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
/**
 * @public
 */
- (void)reload {
  UIViewController* controller = self.visibleViewController;
  if ([controller isKindOfClass:[TTModelViewController class]]) {
    TTModelViewController* ttcontroller = (TTModelViewController*)controller;
    [ttcontroller reload];
  }
}


@end
