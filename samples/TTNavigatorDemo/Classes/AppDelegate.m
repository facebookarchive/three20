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
  navigator.window = [[[UIWindow alloc] initWithFrame:TTScreenBounds()] autorelease];
  
  TTURLMap* map = navigator.URLMap;
  
  // Any URL that doesn't match will fall back on this one, and open in the web browser
  [map from:@"*" toViewController:[TTWebController class]];
  
  // The tab bar controller is shared, meaning there will only ever be one created.  Loading
  // This URL will make the existing tab bar controller appear if it was not visible.
  [map from:@"tt://tabBar" toSharedViewController:[TabBarController class]];
  
  // Menu controllers are also shared - we only create one to show in each tab, so opening
  // these URLs will switch to the tab containing the menu
  [map from:@"tt://menu/(initWithMenu:)" toSharedViewController:[MenuController class]];
  
  // A new food controllers will be created each time you open a food URL
  [map from:@"tt://food/(initWithFood:)" toViewController:[ContentController class]];
  
  // By specifying the parent URL, we are saying that the tab containing menu #5 will be
  // selected before opening this URL, ensuring that about controllers are only pushed
  // inside the tab containing the about menu
  [map from:@"tt://about/(initWithAbout:)" parent:@"tt://menu/5"
       toViewController:[ContentController class] selector:nil transition:0];
  
  // This is an example of how to use a transition.  Opening the nutrition page will do a flip
  [map from:@"tt://food/(initWithNutrition:)/nutrition" toViewController:[ContentController class]
       transition:UIViewAnimationTransitionFlipFromLeft];
       
  // The ordering controller will appear as a modal view controller, animated from bottom to top
  [map from:@"tt://order?waitress=(initWithWaitress:)"
       toModalViewController:[ContentController class]];
  
  // This is a hash URL - it will simply invoke the method orderAction: on the order controller,
  // and it will open the order controller first if it was not already visible
  [map from:@"tt://order?waitress=()#(orderAction:)" toViewController:[ContentController class]];
  
  // This will show the post controller to prompt to type in their order
  [map from:@"tt://order/food" toViewController:[TTPostController class]];
  
  // This will call the confirmOrder method on this app delegate and ask it to return a
  // view controller to be opened.  In this case, it will return an alert view controller. 
  // This kind of URL mapping gives you the chance to configure your controller before
  // it is opened.
  [map from:@"tt://order/confirm" toViewController:self selector:@selector(confirmOrder)];
  
  // This will simply call the sendOrder method on this app delegate
  [map from:@"tt://order/send" toObject:self selector:@selector(sendOrder)];

  // Before opening the tab bar, we see if the controller history was persisted the last time
  if (![navigator restoreViewControllers]) {
    // This is the first launch, so we just start with the tab bar
    [navigator openURLAction:[TTURLAction actionWithURLPath:@"tt://tabBar"]];
  }
}

- (BOOL)application:(UIApplication*)application handleOpenURL:(NSURL*)URL {
  [[TTNavigator navigator] openURLAction:[TTURLAction actionWithURLPath:URL.absoluteString]];
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
  TTDINFO(@"SENDING THE ORDER...");
}

@end
