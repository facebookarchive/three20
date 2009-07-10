#import "AppDelegate.h"
#import "TabBarController.h"
#import "MenuController.h"
#import "ContentController.h"

@implementation AppDelegate

///////////////////////////////////////////////////////////////////////////////////////////////////
// UIApplicationDelegate

- (void)applicationDidFinishLaunching:(UIApplication*)application {
  TTNavigator* navigator = [TTNavigator navigator];
  navigator.persistenceMode = TTNavigatorPersistenceModeAll;

  TTURLMap* map = navigator.URLMap;
  [map share:@"tt://tabBar" target:[TabBarController class]];
  [map share:@"tt://menu/(initWithMenu:)" target:[MenuController class]];
  [map share:@"tt://food/(initWithFood:)" target:[ContentController class]];
  [map create:@"tt://about/(initWithAbout:)" parent:@"tt://menu/5"
       target:[ContentController class] selector:nil];
  [map modal:@"tt://order?waitress=(initWithWaitress:)"
       target:[ContentController class] selector:@selector(initWithWaitress:params:)];

  if (![navigator restoreViewControllers]) {
    [navigator openURL:@"tt://tabBar" animated:NO];
  }
}

- (BOOL)application:(UIApplication*)application handleOpenURL:(NSURL*)URL {
  [[TTNavigator navigator] openURL:URL.absoluteString animated:NO];
  return YES;
}

@end
