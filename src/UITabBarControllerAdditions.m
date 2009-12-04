/**
 * Copyright 2009 Facebook
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#import "Three20/TTNavigator.h"

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation UITabBarController (TTCategory)

///////////////////////////////////////////////////////////////////////////////////////////////////
// private

- (UIViewController*)rootControllerForController:(UIViewController*)controller {
  if ([controller canContainControllers]) {
    return controller;
  } else {
    UINavigationController* navController = [[[UINavigationController alloc] init] autorelease];
    [navController pushViewController:controller animated:NO];
    return navController;
  }
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// UIViewController (TTCategory)

- (BOOL)canContainControllers {
  return YES;
}

- (UIViewController*)topSubcontroller {
  return self.selectedViewController;
}

- (void)addSubcontroller:(UIViewController*)controller animated:(BOOL)animated
        transition:(UIViewAnimationTransition)transition {
  self.selectedViewController = controller;
}

- (void)bringControllerToFront:(UIViewController*)controller animated:(BOOL)animated {
  self.selectedViewController = controller;
}

- (NSString*)keyForSubcontroller:(UIViewController*)controller {
  return nil;
}

- (UIViewController*)subcontrollerForKey:(NSString*)key {
  return nil;
}

- (void)persistNavigationPath:(NSMutableArray*)path {
  UIViewController* controller = self.selectedViewController;
  [[TTNavigator navigator] persistController:controller path:path];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// public

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
