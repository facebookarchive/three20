#import "AppDelegate.h"
#import "TabBarController.h"
#import "MenuController.h"
#import "ContentController.h"

@implementation AppDelegate

///////////////////////////////////////////////////////////////////////////////////////////////////
// UIApplicationDelegate

- (void)applicationDidFinishLaunching:(UIApplication*)application {
  TTAppMap* appMap = [TTAppMap sharedMap];
  appMap.persistenceMode = TTAppMapPersistenceModeAll;
  
  [appMap addURL:@"tt://tabBar"
          create:[TabBarController class]];
  [appMap addURL:@"tt://menu/(showMenu)"
          singleton:[MenuController class] selector:@selector(showMenu:)];
  [appMap addURL:@"tt://food/(showFood)"
          create:[ContentController class] selector:@selector(showFood:)];
  [appMap addURL:@"tt://about/(showAbout)" parent:@"tt://menu/5"
          create:[ContentController class] selector:@selector(showAbout:)];
  [appMap addURL:@"tt://order?waitress=(orderWithWaitress)"
          modal:[ContentController class] selector:@selector(orderWithWaitress:params:)];
  
  TTOpenURL(@"tt://tabBar");
}

@end
