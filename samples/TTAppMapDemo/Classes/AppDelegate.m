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
  
  [appMap addURL:@"tt://tabBar" share:[TabBarController class]];
  [appMap addURL:@"tt://menu/(initWithMenu:)" share:[MenuController class]];
  [appMap addURL:@"tt://food/(initWithFood:)" create:[ContentController class]];
  [appMap addURL:@"tt://about/(initWithAbout:)" parent:@"tt://menu/5"
          create:[ContentController class] selector:nil];
  [appMap addURL:@"tt://order?waitress=(initWithWaitress:)"
          modal:[ContentController class] selector:@selector(initWithWaitress:params:)];
  
  [appMap openURL:@"tt://tabBar"];
}

@end
