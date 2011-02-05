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

#import "Three20UI/TTNavigator.h"

// UI
#import "Three20UI/TTPopupViewController.h"
#import "Three20UI/TTSearchDisplayController.h"
#import "Three20UI/TTTableViewController.h"
#import "Three20UI/TTNavigationController.h"

// UI (private)
#import "Three20UI/private/TTNavigatorWindow.h"

// UINavigator
#import "Three20UINavigator/TTURLMap.h"
#import "Three20UINavigator/TTURLAction.h"

// UINavigator (private)
#import "Three20UINavigator/private/TTBaseNavigatorInternal.h"

// UICommon
#import "Three20UICommon/UIViewControllerAdditions.h"

// Core
#import "Three20Core/TTDebug.h"


///////////////////////////////////////////////////////////////////////////////////////////////////
UIViewController* TTOpenURL(NSString* URL) {
  return [[TTNavigator navigator] openURLAction:
          [[TTURLAction actionWithURLPath:URL]
           applyAnimated:YES]];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
UIViewController* TTOpenURLFromView(NSString* URL, UIView* view) {
  return [[TTBaseNavigator navigatorForView:view] openURLAction:
          [[TTURLAction actionWithURLPath:URL]
           applyAnimated:YES]];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation TTNavigator


///////////////////////////////////////////////////////////////////////////////////////////////////
+ (TTNavigator*)navigator {
  TTBaseNavigator* navigator = [TTBaseNavigator globalNavigator];
  if (nil == navigator) {
    navigator = [[[TTNavigator alloc] init] autorelease];
    // setNavigator: retains.
    [super setGlobalNavigator:navigator];
  }
  // If this asserts, it's likely that you're attempting to use two different navigator
  // implementations simultaneously. Be consistent!
  TTDASSERT([navigator isKindOfClass:[TTNavigator class]]);
  return (TTNavigator*)navigator;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (Class)windowClass {
  return [TTNavigatorWindow class];
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
                        action: (TTURLAction*)action {
  if (nil != action.sourceButton) {
    [controller showFromBarButtonItem: action.sourceButton
                             animated: action.animated];

  } else {
    parentController.popupViewController = controller;
    controller.superController = parentController;
    [controller showInView: parentController.view
                  animated: action.animated];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
/**
 * Present a view controller that strictly depends on the existence of the parent controller.
 *
 * @protected
 */
- (void)presentDependantController: (UIViewController*)controller
                  parentController: (UIViewController*)parentController
                              mode: (TTNavigationMode)mode
                            action: (TTURLAction*)action {

  if ([controller isKindOfClass:[TTPopupViewController class]]) {
    TTPopupViewController* popupViewController = (TTPopupViewController*)controller;
    [self presentPopupController: popupViewController
                parentController: parentController
                          action: action];

  } else {
    [super presentDependantController: controller
                     parentController: parentController
                                 mode: mode
                               action: action];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
/**
 * @protected
 */
- (void)didRestoreController:(UIViewController*)controller {
  if ([controller isKindOfClass:[TTModelViewController class]]) {
    TTModelViewController* modelViewController = (TTModelViewController*)controller;
    modelViewController.model;
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
/**
 * @protected
 */
- (UIViewController*)getVisibleChildController:(UIViewController*)controller {
  UISearchDisplayController* search = controller.searchDisplayController;
  if (search && search.active && [search isKindOfClass:[TTSearchDisplayController class]]) {
    TTSearchDisplayController* ttsearch = (TTSearchDisplayController*)search;
    return ttsearch.searchResultsViewController;

  } else {
    return [super getVisibleChildController:controller];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)reload {
  UIViewController* controller = self.visibleViewController;
  if ([controller isKindOfClass:[TTModelViewController class]]) {
    TTModelViewController* ttcontroller = (TTModelViewController*)controller;
    [ttcontroller reload];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (Class)navigationControllerClass {
  return [TTNavigationController class];
}


@end
