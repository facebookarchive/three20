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
  [map from:@"*" toViewController:[TTWebController class] selector:@selector(initWithURL:)];
  [map from:@"tt://tabBar" toSharedViewController:[TabBarController class]];
  [map from:@"tt://menu/(initWithMenu:)" toSharedViewController:[MenuController class]];
  [map from:@"tt://food/(initWithFood:)" toViewController:[ContentController class]];
  [map from:@"tt://about/(initWithAbout:)" parent:@"tt://menu/5"
       toViewController:[ContentController class] selector:nil transition:0];
  [map from:@"tt://order?waitress=(initWithWaitress:)"
       toModalViewController:[ContentController class]];
  [map from:@"tt://order?waitress=()#(orderAction:)" toViewController:[ContentController class]];
  [map from:@"tt://order/confirm" toViewController:self selector:@selector(confirmOrder)];
  [map from:@"tt://order/send" toObject:self selector:@selector(sendOrder)];

  if (![navigator restoreViewControllers]) {
    [navigator openURL:@"tt://tabBar" animated:NO];
  }
}

- (BOOL)application:(UIApplication*)application handleOpenURL:(NSURL*)URL {
  [[TTNavigator navigator] openURL:URL.absoluteString animated:NO];
  return YES;
}

///////////////////////////////////////////////////////////////////////////////////////////////////

- (UIViewController*)confirmOrder {
  TTAlertViewController* alert = [[[TTAlertViewController alloc]
                                 initWithTitle:@"Are you sure?"
                                 message:@"Sure you want to order?"] autorelease];
  [alert addButtonWithTitle:@"Yes" URL:@"tt://order/send"];
  [alert addCancelButtonWithTitle:@"No" URL:nil];
  return alert;
}

- (void)sendOrder {
  TTLOG(@"SENDING THE ORDER...");
}

@end
