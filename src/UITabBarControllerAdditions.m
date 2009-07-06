#import "Three20/TTAppMap.h"

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation UITabBarController (TTCategory)

- (void)setTabURLs:(NSArray*)URLs {
  NSMutableArray* controllers = [NSMutableArray array];
  for (NSString* URL in URLs) {
    UIViewController* controller = [[TTAppMap sharedMap] controllerForURL:URL];
    if (controller) {
      [controllers addObject:controller];
    }
  }
  self.viewControllers = controllers;
}

@end
