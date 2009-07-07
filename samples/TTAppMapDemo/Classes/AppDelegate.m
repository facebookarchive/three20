#import "AppDelegate.h"
#import "TabBarController.h"
#import "MenuController.h"
#import "ContentController.h"

@implementation AppDelegate

///////////////////////////////////////////////////////////////////////////////////////////////////
// UIViewController

- (void)applicationDidFinishLaunching:(UIApplication*)application {
  TTAppMap* appMap = [TTAppMap sharedMap];
  appMap.persistenceMode = TTAppMapPersistenceModeAll;
  
  [appMap addURL:@"tt://tabBar"
//          tabs:[NSArray arrayWithObjects:@"tt://menu/1",
//                                         @"tt://menu/2",
//                                         @"tt://menu/3",
//                                         @"tt://menu/4",
//                                         @"tt://menu/5", nil]],
          controller:[TabBarController class]];
  [appMap addURL:@"tt://menu/(showMenu)"
          singleton:[MenuController class] selector:@selector(showMenu:)];
  [appMap addURL:@"tt://food/(showFood)"
          controller:[ContentController class] selector:@selector(showFood:)];
  [appMap addURL:@"tt://about/(showAbout)" parent:@"tt://menu/5"
          controller:[ContentController class] selector:@selector(showAbout:)];
  [appMap addURL:@"tt://order?waitress=(orderWithWaitress)"
          modal:[ContentController class] selector:@selector(orderWithWaitress:params:)];
  
  TTLoadURL(@"tt://tabBar");
}

@end
