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
  [map from:@"tt://about/(initWithAbout:)" parent:@"tt://menu/5"
       toViewController:[ContentController class] selector:nil];
  [map from:@"tt://order?waitress=(initWithWaitress:)"
       toModalViewController:[ContentController class] selector:@selector(initWithWaitress:query:)];
  [map from:@"tt://order?waitress=()#(orderAction:)" toViewController:[ContentController class]];
  [map from:@"tt://order/send" toPopupViewController:self selector:@selector(sendOrder)];

  if (![navigator restoreViewControllers]) {
    [navigator openURL:@"tt://tabBar" animated:NO];
  }
}

- (BOOL)application:(UIApplication*)application handleOpenURL:(NSURL*)URL {
  [[TTNavigator navigator] openURL:URL.absoluteString animated:NO];
  return YES;
}

///////////////////////////////////////////////////////////////////////////////////////////////////

- (UIViewController*)sendOrder {
  UIAlertView* alertView =
    [[[UIAlertView alloc] initWithTitle:@"Order"
                          message:@"Sure you want to order?"
                          delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil]
                          autorelease];
  return nil;//[[[TTAlertViewController alloc] initWithView:alertView] autorelease];
}

@end
