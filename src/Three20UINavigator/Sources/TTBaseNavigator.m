//
// Copyright 2009-2011 Facebook
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
#import "Three20UINavigator/TTNavigatorPopoverProtocol.h"
#import "Three20UINavigator/TTNavigatorDisplayProtocol.h"
#import "Three20UINavigator/TTNavigatorRootContainer.h"
#import "Three20UINavigator/TTBaseNavigationController.h"
#import "Three20UINavigator/TTURLAction.h"
#import "Three20UINavigator/TTURLMap.h"
#import "Three20UINavigator/TTURLNavigatorPattern.h"
#import "Three20UINavigator/UIViewController+TTNavigator.h"

// UINavigator (private)
#import "Three20UINavigator/private/TTBaseNavigatorInternal.h"

// UICommon
#import "Three20UICommon/TTGlobalUICommon.h"
#import "Three20UICommon/UIView+TTUICommon.h"
#import "Three20UICommon/UIViewControllerAdditions.h"

// Core
#import "Three20Core/TTGlobalCore.h"
#import "Three20Core/TTCorePreprocessorMacros.h"
#import "Three20Core/TTDebug.h"
#import "Three20Core/TTDebugFlags.h"
#import "Three20Core/NSDateAdditions.h"

static TTBaseNavigator* gNavigator = nil;
static UIPopoverController* gPopoverController = nil;
static TTURLAction*         gPopoverAction = nil;

static NSString* kNavigatorHistoryKey           = @"TTNavigatorHistory";
static NSString* kNavigatorHistoryTimeKey       = @"TTNavigatorHistoryTime";
static NSString* kNavigatorHistoryImportantKey  = @"TTNavigatorHistoryImportant";

NSString* TTBaseNavigatorWillShowPopoverNotification =
  @"TTBaseNavigatorWillShowPopoverNotification";

#ifdef __IPHONE_4_0
UIKIT_EXTERN NSString *const UIApplicationDidEnterBackgroundNotification
__attribute__((weak_import));
UIKIT_EXTERN NSString *const UIApplicationWillEnterForegroundNotification
__attribute__((weak_import));
#endif


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation TTBaseNavigator

@synthesize delegate                  = _delegate;
@synthesize URLMap                    = _URLMap;
@synthesize window                    = _window;
@synthesize rootViewController        = _rootViewController;
@synthesize persistenceKey            = _persistenceKey;
@synthesize persistenceExpirationAge  = _persistenceExpirationAge;
@synthesize persistenceMode           = _persistenceMode;
@synthesize supportsShakeToReload     = _supportsShakeToReload;
@synthesize opensExternalURLs         = _opensExternalURLs;
@synthesize rootContainer             = _rootContainer;


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
  TT_RELEASE_SAFELY(_persistenceKey);

  [super dealloc];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
+ (TTBaseNavigator*)globalNavigator {
  return gNavigator;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
+ (void)setGlobalNavigator:(TTBaseNavigator*)navigator {
  if (gNavigator != navigator) {
    [[NSNotificationCenter defaultCenter] removeObserver: gNavigator
                                                    name: UIDeviceOrientationDidChangeNotification
                                                  object: nil];
    [[NSNotificationCenter defaultCenter] addObserver: navigator
                                             selector: @selector(orientationChanged:)
                                                 name: UIDeviceOrientationDidChangeNotification
                                               object: nil];
    [gNavigator release];
    gNavigator = [navigator retain];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
+ (TTBaseNavigator*)navigatorForView:(UIView*)view {
  // If this is called with a UIBarButtonItem, we can't traverse a view hierarchy to find the
  // navigator, return the global navigator as a fallback.
  if (![view isKindOfClass:[UIView class]]) {
    return [TTBaseNavigator globalNavigator];
  }

  id<TTNavigatorRootContainer>  container = nil;
  UIViewController*             controller = nil;
  UIViewController*             childController = nil;

  for (controller = view.viewController;
       nil != controller;
       controller = controller.superController) {
    if ([controller conformsToProtocol:@protocol(TTNavigatorRootContainer)]) {
      container = (id<TTNavigatorRootContainer>)controller;
      break;
    }

    childController = controller;
  }

  TTBaseNavigator* navigator = [container navigatorForRootController:childController];
  if (nil == navigator) {
    navigator = [TTBaseNavigator globalNavigator];
  }

  return navigator;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark UIPopoverControllerDelegate


///////////////////////////////////////////////////////////////////////////////////////////////////
+ (BOOL)popoverControllerShouldDismissPopover:(UIPopoverController *)popoverController {
  if (popoverController == [TTBaseNavigator popoverController]) {
    id visibleViewController = [[TTBaseNavigator popoverController] contentViewController];
    if ([visibleViewController isKindOfClass:[UINavigationController class]]) {
      visibleViewController = [visibleViewController visibleViewController];
    }
    if ([visibleViewController
         respondsToSelector:@selector(shouldDismissPopover:)]) {
      return [visibleViewController shouldDismissPopover:popoverController];
    }
  }

  return YES;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
+ (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController {
  // If we're getting this notification but the popover controller differs, it means at least
  // one of the following:
  // - TTBaseNavigator wasn't made aware of the popover controller that is being dismissed, but for
  //   some reason its delegate was set to [TTBaseNavigator class]
  // - TTBaseNavigator was assigned a new popover controller before this message was received.
  //
  // Either way, if you've hit this assertion you need to determine why the popover controller
  // isn't stored in TTBaseNavigator.
  TTDASSERT(popoverController == [TTBaseNavigator popoverController]);

  if (popoverController == [TTBaseNavigator popoverController]) {
    [TTBaseNavigator setPopoverController:nil];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Popover Support


///////////////////////////////////////////////////////////////////////////////////////////////////
+ (UIPopoverController*)popoverController {
  return gPopoverController;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
+ (void)setPopoverController:(UIPopoverController*)popoverController {
  if (gPopoverController != popoverController) {
    [self dismissPopoverAnimated:NO];

    // dismissPopoverAnimated will release this popover, but if, in the future, it doesn't for
    // any reason, we release the popover here as well to be safe.
    TT_RELEASE_SAFELY(gPopoverController);

    gPopoverController = [popoverController retain];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
+ (TTURLAction*)popoverAction {
  return gPopoverAction;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
+ (void)setPopoverAction:(TTURLAction*)action {
  if (gPopoverAction != action) {
    [gPopoverAction release];
    gPopoverAction = [action retain];

    // We should never be setting the popover action without an active popover.
    TTDASSERT(nil == gPopoverAction
              || nil != gPopoverController);
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
+ (BOOL)dismissPopoverAnimated:(BOOL)isAnimated forced:(BOOL)isForced {
  if (isForced || [self popoverControllerShouldDismissPopover:[self popoverController]]) {
    // Don't use self dismissPopoverAnimated: here because that will cause an infinite loop.
    [[self popoverController] dismissPopoverAnimated:isAnimated];

    // popoverControllerDidDismissPopover: is not called when we programmatically dismiss a popover,
    // so we must be sure to release the popover ourselves.
    TT_RELEASE_SAFELY(gPopoverController);
    TT_RELEASE_SAFELY(gPopoverAction);
    return YES;

  } else {
    return NO;
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
+ (void)dismissPopoverAnimated:(BOOL)isAnimated {
  [self dismissPopoverAnimated:isAnimated forced:YES];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
+ (UIPopoverController*)popoverControllerForView:(UIView*)view {
  if (nil == [self popoverController] || ![view isKindOfClass:[UIView class]]) {
    // Bail out early, there's no known popover or it's not a view.
    return nil;
  }

  UIViewController* controller = nil;      // The iterator.

  for (controller = view.viewController;
       nil != controller;
       controller = controller.superController) {
    if (controller == gPopoverController.contentViewController) {
      break;
    }
  }

  if (nil != controller) {
    return [self popoverController];

  } else {
    return nil;
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)presentPopoverController:(UIPopoverController*)controller fromAction:(TTURLAction*)action {
  TTDASSERT(nil != action);
  if (nil == action) {
    return;
  }

  controller.passthroughViews = action.passthroughViews;

  // TODO (jverkoey Dec. 15, 2010): Debatable what order of priority these should be in.
  // Perhaps we should simply TTDASSERT that only one or the other is provided?
  if (nil != action.sourceButton) {
    [controller presentPopoverFromBarButtonItem: action.sourceButton
                       permittedArrowDirections: UIPopoverArrowDirectionAny
                                       animated: NO];

  } else {
    CGRect sourceRect = action.sourceRect;
    if (CGRectIsEmpty(action.sourceRect)) {
      sourceRect = action.sourceView.frame;
    }
    [controller presentPopoverFromRect: sourceRect
                                inView: action.sourceView.superview
              permittedArrowDirections: UIPopoverArrowDirectionAny
                              animated: NO];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)updatePopoverForNewOrientation {
  if (nil != [TTBaseNavigator popoverController] && nil != [TTBaseNavigator popoverAction]) {
    [self presentPopoverController: [TTBaseNavigator popoverController]
                        fromAction: [TTBaseNavigator popoverAction]];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)orientationChanged:(NSNotification*)notification {
  if (nil != [TTBaseNavigator popoverController]) {
    // We need to update the popover orientation after this run loop has finished so that
    // we give the iPad time to change its orientation - and subsequently the location
    // of the source view or button.
    [self performSelector: @selector(updatePopoverForNewOrientation)
               withObject: nil
               afterDelay: 0];
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

    if (nil != _rootContainer) {
      [_rootContainer navigator:self setRootViewController:_rootViewController];

    } else {
      [self.window addSubview:_rootViewController.view];
    }
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
                        action: (TTURLAction*)action {
  controller.modalTransitionStyle = action.transition;

  if ([controller isKindOfClass:[UINavigationController class]]) {
    [[self.rootContainer rootViewController] presentModalViewController: controller
                                                               animated: action.animated];

  } else {
    UINavigationController* navController = [[[[self navigationControllerClass] alloc] init]
                                             autorelease];
    [navController pushViewController: controller
                             animated: NO];
    navController.modalPresentationStyle = controller.modalPresentationStyle;
    [[self.rootContainer rootViewController] presentModalViewController: navController
                                                               animated: action.animated];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)presentPopoverController: (UIViewController*)controller
                          action: (TTURLAction*)action
                            mode: (TTNavigationMode)mode {
  BOOL isModal = (mode == TTNavigationModeModal);

  TTDASSERT(action.isPopoverAction);

  // Note for the above assertion:
  // When using popover controllers you need to provide either a source button or a
  // source view + source rect in the TTURLAction. We don't know what to do without it here,
  // so we're just going to bail out. Come back when you're ready.
  //
  // Oh. While you're here, you may as well check the stack trace from this breakpoint and
  // figure out where you're opening this URL from. The TTURLAction that you're passing to
  // the TTNavigator system has three properties (mentioned above) that you can provide.
  // Set them before you pass the TTURLAction object into the TTNavigator and you should be
  // good from there.
  //
  // If the TTURLAction is coming from within Three20 you'll have to work a bit harder.
  //
  // For table views, it's debatable whether you should be using a popover controller here in
  // the first place. If you really are intending to do this, subclass one of the table delegate
  // objects and implement -tableView:didSelectRowAtIndexPath:.
  // You'll then implement the -createDelegate method in your table view controller and return
  // an autoreleased object of the delegate.

  if (!action.isPopoverAction) {
    return;
  }

  // If the user taps the same button twice, we should try to hide the popover controller.
  if (nil != [TTBaseNavigator popoverController]) {
    UIViewController* contentController =
      [TTBaseNavigator popoverController].contentViewController;
    if ([contentController isKindOfClass:[UINavigationController class]]) {
      UINavigationController* navController = (UINavigationController*)contentController;
      if ([navController.topViewController.originalNavigatorURL isEqualToString:action.urlPath]
          && [TTBaseNavigator dismissPopoverAnimated:action.animated forced:NO]) {
        return;
      }
    }
  }

  // If there is an active popover and we're not targetting it, see if we are allowed to dismiss
  // it. If not, we bail out early.
  if (nil != [TTBaseNavigator popoverController]
      && [TTBaseNavigator popoverController] != action.targetPopoverController
      && ![TTBaseNavigator dismissPopoverAnimated:action.animated forced:NO]) {
    // Not allowed to dismiss the active popover.
    return;
  }

  UIViewController* contentController = nil;

  // We place the given controller within a navigation controller, unless it's a container
  // controller or an image picker controller (which hates being in a nav controller and will,
  // in fact, crash if you try otherwise).
  // Target popover controllers are a special case where we assume that the popover has a
  // navigation controller within it that we can push the controller onto.
  if ((nil != action.targetPopoverController && !isModal)
      || [controller canContainControllers]
      || [controller isKindOfClass:[UIImagePickerController class]]) {
    contentController = controller;

  } else {
    contentController = [[[[self navigationControllerClass] alloc]
                          initWithRootViewController:controller]
                         autorelease];
  }

  if (nil != [TTBaseNavigator popoverController] && isModal) {
    // Present the content controller on this popover and bail out immediately.
    if ([controller respondsToSelector:@selector(viewWillAppearInPopover:)]) {
      [(id)controller viewWillAppearInPopover:[TTBaseNavigator popoverController]];
    }

    contentController.modalPresentationStyle = UIModalPresentationCurrentContext;

    // Allow stacked modal controllers by traversing the currently visible modal view controllers
    // and finding the visible one.
    UIViewController* visibleContentController =
    [TTBaseNavigator popoverController].contentViewController;
    while (nil != visibleContentController.modalViewController) {
      visibleContentController = visibleContentController.modalViewController;
    }
    [visibleContentController presentModalViewController: contentController
                                                animated: action.animated];
    return;
  }

  if (nil != action.targetPopoverController) {
    id popoverContentController = [action.targetPopoverController
                                                  contentViewController];
    if ([popoverContentController isKindOfClass:[UINavigationController class]]) {
      UINavigationController* navController = popoverContentController;

      // Inform the controller that it is being displayed within a popover controller.
      if ([controller respondsToSelector:@selector(viewWillAppearInPopover:)]) {
        [(id)controller viewWillAppearInPopover:action.targetPopoverController];
      }

      [navController pushViewController: contentController
                               animated: action.animated];
      return;

    } else {
      // This is an unhandled type of controller.
      TTDASSERT(NO);
      return;
    }
  }

  [TTBaseNavigator dismissPopoverAnimated:action.animated];

  [TTBaseNavigator setPopoverController:[[UIPopoverController alloc]
                                         initWithContentViewController:contentController]];
  [TTBaseNavigator setPopoverAction:action];

  // We want to receive notifications when this popover is dismissed so that we can properly
  // release it.

  [TTBaseNavigator popoverController].delegate =
    (id<UIPopoverControllerDelegate>)([TTBaseNavigator class]);

  // Inform the controller that it is being displayed within a popover controller.
  if ([controller respondsToSelector:@selector(viewWillAppearInPopover:)]) {
    [(id)controller viewWillAppearInPopover:[TTBaseNavigator popoverController]];
  }

  [[NSNotificationCenter defaultCenter]
    postNotificationName: TTBaseNavigatorWillShowPopoverNotification
                  object: nil];

  [self presentPopoverController:[TTBaseNavigator popoverController] fromAction:action];
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
                   action: (TTURLAction*)action {
  BOOL didPresentNewController = YES;

  if (nil == _rootViewController) {
    [self setRootViewController:controller];

  } else {
    UIViewController* previousSuper = controller.superController;
    // We can't make controllers visible for popover actions in this way, so ignore this logic.
    if (!action.isPopoverAction && nil != previousSuper) {
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

      [TTBaseNavigator dismissPopoverAnimated:YES];

    } else if (nil != parentController) {
      BOOL didPresent = NO;
      if ([controller respondsToSelector:
           @selector(navigator:presentController:parentController:action:)]) {
        didPresent = [(id)controller navigator: self
                             presentController: controller
                              parentController: parentController
                                        action: action];
      }
      if (!didPresent) {
        [self presentDependantController: controller
                        parentController: parentController
                                    mode: mode
                                  action: action];
      }
    }
  }

  return didPresentNewController;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)presentController: (UIViewController*)controller
            parentURLPath: (NSString*)parentURLPath
              withPattern: (TTURLNavigatorPattern*)pattern
                   action: (TTURLAction*)action {
  BOOL didPresentNewController = NO;

  if (nil != controller) {
    if ([self.rootContainer respondsToSelector:@selector(navigator:presentController:action:)]) {
      didPresentNewController = [self.rootContainer navigator: self
                                            presentController: controller
                                                       action: action];
    }

    if (!didPresentNewController) {
      UIViewController* topViewController = self.topViewController;

      if (controller != topViewController) {
        UIViewController* parentController = [self parentForController: controller
                                                           isContainer: [controller
                                                                         canContainControllers]
                                                         parentURLPath: parentURLPath
                                              ? parentURLPath : pattern.parentURL];

        if (nil != parentController && parentController != topViewController) {
          [self presentController: parentController
                 parentController: nil
                             mode: TTNavigationModeNone
                           action: [TTURLAction actionWithURLPath:nil]];
        }

        didPresentNewController = [self presentController: controller
                                         parentController: parentController
                                                     mode: pattern.navigationMode
                                                   action: action];
      }
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

    action.transition = action.transition ? action.transition : pattern.transition;

    BOOL wasNew = [self presentController: controller
                            parentURLPath: action.parentURLPath
                              withPattern: pattern
                                   action: action];

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

  // Modal view controllers are presented (and stacked) from TTRootViewController
  // Use its modalViewController when available as start to find top view controller
  if (self.rootContainer != nil) {
    UIViewController *modalRootController = [self.rootContainer rootViewController];
    if (modalRootController.modalViewController) {
      controller = modalRootController.modalViewController;
    }
  }

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
    NSDate* historyTime = [NSDate date];
    NSNumber* historyImportant = [NSNumber numberWithInt:important];

    if (TTIsStringWithAnyText(_persistenceKey)) {
      NSDictionary* persistedValues = [NSDictionary dictionaryWithObjectsAndKeys:
                                       path, kNavigatorHistoryKey,
                                       historyTime, kNavigatorHistoryTimeKey,
                                       historyImportant, kNavigatorHistoryImportantKey,
                                       nil];
      [defaults setObject:persistedValues forKey:_persistenceKey];

    } else {
      [defaults setObject:path forKey:kNavigatorHistoryKey];
      [defaults setObject:historyTime forKey:kNavigatorHistoryTimeKey];
      [defaults setObject:historyImportant forKey:kNavigatorHistoryImportantKey];
    }

    [defaults synchronize];

  } else {
    [self resetDefaults];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (UIViewController*)restoreViewControllers {
  NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
  NSDate* timestamp = nil;
  NSArray* path = nil;
  BOOL important = NO;

  if (TTIsStringWithAnyText(_persistenceKey)) {
    NSDictionary* persistedValues = [defaults objectForKey:_persistenceKey];

    timestamp = [persistedValues objectForKey:kNavigatorHistoryTimeKey];
    path = [persistedValues objectForKey:kNavigatorHistoryKey];
    important = [[persistedValues objectForKey:kNavigatorHistoryImportantKey] boolValue];

  } else {
    timestamp = [defaults objectForKey:kNavigatorHistoryTimeKey];
    path = [defaults objectForKey:kNavigatorHistoryKey];
    important = [[defaults objectForKey:kNavigatorHistoryImportantKey] boolValue];
  }
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

  if (TTIsStringWithAnyText(_persistenceKey)) {
    [defaults removeObjectForKey:_persistenceKey];

  } else {
    [defaults removeObjectForKey:kNavigatorHistoryKey];
    [defaults removeObjectForKey:kNavigatorHistoryTimeKey];
    [defaults removeObjectForKey:kNavigatorHistoryImportantKey];
  }

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
                            action: (TTURLAction*)action {

  if (TTIsPad() && action.isPopoverAction) {
    [self presentPopoverController: controller
                            action: action
                              mode: mode];

  } else if (mode == TTNavigationModeModal) {
    [self presentModalController: controller
                parentController: parentController
                          action: action];

    [TTBaseNavigator dismissPopoverAnimated:YES];

  } else {
    [parentController addSubcontroller: controller
                              animated: action.animated
                            transition: action.transition];

    [TTBaseNavigator dismissPopoverAnimated:YES];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (UIViewController*)getVisibleChildController:(UIViewController*)controller {
  return (nil != controller.popupViewController)
    ? controller.popupViewController
    : controller.topSubcontroller;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (Class)navigationControllerClass {
  return [TTBaseNavigationController class];
}


@end
