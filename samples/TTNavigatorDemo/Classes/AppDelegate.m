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
  [map from:@"tt://tabBar" toSharedViewController:[TabBarController class]];
  [map from:@"tt://menu/(initWithMenu:)" toSharedViewController:[MenuController class]];
  [map from:@"tt://food/(initWithFood:)" toSharedViewController:[ContentController class]];
  [map from:@"tt://about/(initWithAbout:)" toViewController:[ContentController class] selector:nil
       parent:@"tt://menu/5"];
  [map from:@"tt://order?waitress=(initWithWaitress:)"
       toModalViewController:[ContentController class] selector:@selector(initWithWaitress:query:)];

  if (![navigator restoreViewControllers]) {
    [navigator openURL:@"tt://tabBar" animated:NO];
  }
}

- (BOOL)application:(UIApplication*)application handleOpenURL:(NSURL*)URL {
  [[TTNavigator navigator] openURL:URL.absoluteString animated:NO];
  return YES;
}

@end
