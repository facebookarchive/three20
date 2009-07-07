#import "Three20/TTAppMap.h"

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation UITabBarController (TTCategory)

///////////////////////////////////////////////////////////////////////////////////////////////////
// UIViewController (TTCategory)

- (void)presentController:(UIViewController*)controller animated:(BOOL)animated {
  self.selectedViewController = controller;
}

- (void)bringControllerToFront:(UIViewController*)controller animated:(BOOL)animated {
  self.selectedViewController = controller;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// public

- (void)setTabURLs:(NSArray*)URLs {
  NSMutableArray* controllers = [NSMutableArray array];
  for (NSString* URL in URLs) {
    UIViewController* controller = [[TTAppMap sharedMap] controllerForURL:URL];
    if (controller) {
      UINavigationController* navController = [[[UINavigationController alloc] init] autorelease];
      [navController pushViewController:controller animated:NO];
      [controllers addObject:navController];
    }
  }
  self.viewControllers = controllers;
}

@end
