#import "AppDelegate.h"
#import "TabBarController.h"
#import "TestController.h"

@implementation AppDelegate

///////////////////////////////////////////////////////////////////////////////////////////////////
// UIViewController

- (void)applicationDidFinishLaunching:(UIApplication*)application {
  TTAppMap* appMap = [TTAppMap sharedMap];
  appMap.delegate = self;
  appMap.supportsShakeToReload = YES;
  
  [appMap addURL:@"tt://tabBar" controller:[TabBarController class]];
  [appMap addURL:@"tt://test/(showCaption)/" controller:[TestController class]
          selector:@selector(showCaption:)];
  
  TTLoadURL(@"tt://tabBar");
}

@end
