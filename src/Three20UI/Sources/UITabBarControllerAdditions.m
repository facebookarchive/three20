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

#import "Three20UI/UITabBarControllerAdditions.h"

// Core
#import "Three20Core/TTCorePreprocessorMacros.h"

// UI
#import "Three20UI/TTNavigator.h"
#import "Three20UI/TTNavigationController.h"

// UICommon
#import "Three20UICommon/UIViewControllerAdditions.h"


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
/**
 * Additions.
 */
TT_FIX_CATEGORY_BUG(UITabBarControllerAdditions)

@implementation UITabBarController (TTCategory)


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Private


///////////////////////////////////////////////////////////////////////////////////////////////////
- (UIViewController*)rootControllerForController:(UIViewController*)controller {
  if ([controller canContainControllers]) {
    return controller;

  } else {
    TTNavigationController* navController = [[[TTNavigationController alloc] init] autorelease];
    [navController pushViewController:controller animated:NO];
    return navController;
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark UIViewController (TTCategory)


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)canContainControllers {
  return YES;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (UIViewController*)topSubcontroller {
  if (self.tabBar.selectedItem == self.moreNavigationController.tabBarItem) {
    return self.moreNavigationController;
  }
  else {
    return self.selectedViewController;
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)addSubcontroller:(UIViewController*)controller animated:(BOOL)animated
        transition:(UIViewAnimationTransition)transition {
  self.selectedViewController = controller;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)bringControllerToFront:(UIViewController*)controller animated:(BOOL)animated {
  self.selectedViewController = controller;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSString*)keyForSubcontroller:(UIViewController*)controller {
  return nil;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (UIViewController*)subcontrollerForKey:(NSString*)key {
  return nil;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)persistNavigationPath:(NSMutableArray*)path {
  UIViewController* controller = self.selectedViewController;
  [[TTNavigator navigator] persistController:controller path:path];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Public


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setTabURLs:(NSArray*)URLs {
  NSMutableArray* controllers = [NSMutableArray array];
  for (NSString* URL in URLs) {
    UIViewController* controller = [[TTNavigator navigator] viewControllerForURL:URL];
    if (controller) {
      UIViewController* tabController = [self rootControllerForController:controller];
      [controllers addObject:tabController];
    }
  }
  self.viewControllers = controllers;
}


@end
