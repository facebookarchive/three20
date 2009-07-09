#import "AppDelegate.h"
#import "TabBarController.h"
#import "MenuController.h"
#import "ContentController.h"

@implementation AppDelegate

///////////////////////////////////////////////////////////////////////////////////////////////////
// UIApplicationDelegate

- (void)applicationDidFinishLaunching:(UIApplication*)application {
  TTURLMap* urls = [TTURLMap urlMap];
  [urls addURL:@"tt://tabBar" share:[TabBarController class]];
  [urls addURL:@"tt://menu/(initWithMenu:)" share:[MenuController class]];
  [urls addURL:@"tt://food/(initWithFood:)" create:[ContentController class]];
  [urls addURL:@"tt://about/(initWithAbout:)" parent:@"tt://menu/5"
        create:[ContentController class] selector:nil];
  [urls addURL:@"tt://order?waitress=(initWithWaitress:)"
        modal:[ContentController class] selector:@selector(initWithWaitress:params:)];

  TTNavigator* navigator = [TTNavigator navigator];
  navigator.persistenceMode = TTNavigatorPersistenceModeAll;
  if (![navigator restoreViewControllers]) {
    [navigator openURL:@"tt://tabBar" animated:NO];
  }
}

- (BOOL)application:(UIApplication*)application handleOpenURL:(NSURL*)URL {
  [[TTNavigator navigator] openURL:URL.absoluteString animated:NO];
  return YES;
}

@end
