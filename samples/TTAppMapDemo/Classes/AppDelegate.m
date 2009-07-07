#import "AppDelegate.h"
#import "TabBarController.h"
#import "MenuController.h"
#import "ContentController.h"

@implementation AppDelegate

///////////////////////////////////////////////////////////////////////////////////////////////////
// UIViewController

- (void)applicationDidFinishLaunching:(UIApplication*)application {
  TTAppMap* appMap = [TTAppMap sharedMap];
  appMap.delegate = self;
  appMap.supportsShakeToReload = YES;
  
  [appMap addURL:@"tt://tabBar"
          controller:[TabBarController class]];
  [appMap addURL:@"tt://menu/(showMenu)"
          singleton:[MenuController class] selector:@selector(showMenu:)];
  [appMap addURL:@"tt://food/(showFood)"
          controller:[ContentController class] selector:@selector(showFood:)];
  [appMap addURL:@"tt://about/(showAbout)" parent:@"tt://menu/5"
          controller:[ContentController class] selector:@selector(showAbout:)];
  [appMap addURL:@"tt://order?waitress=(orderWithWaitress)"
          modal:[ContentController class] selector:@selector(orderWithWaitress:)];
  
  TTLoadURL(@"tt://tabBar");
}

@end
