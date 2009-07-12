#import "Three20/TTNavigator.h"

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation UITabBarController (TTCategory)

///////////////////////////////////////////////////////////////////////////////////////////////////
// private

- (UIViewController*)rootControllerForController:(UIViewController*)controller {
  if ([controller isContainerController]) {
    return controller;
  } else {
    UINavigationController* navController = [[[UINavigationController alloc] init] autorelease];
    [navController pushViewController:controller animated:NO];
    return navController;
  }
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// UIViewController (TTCategory)

- (UIViewController*)subviewController {
  return self.selectedViewController;
}

- (void)presentController:(UIViewController*)controller animated:(BOOL)animated
        transition:(UIViewAnimationTransition)transition {
  self.selectedViewController = controller;
}

- (void)bringControllerToFront:(UIViewController*)controller animated:(BOOL)animated {
  self.selectedViewController = controller;
}

- (BOOL)isContainerController {
  return YES;
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
