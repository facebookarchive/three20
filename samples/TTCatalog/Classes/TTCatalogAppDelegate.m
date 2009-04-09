#import "TTCatalogAppDelegate.h"
#import "RootViewController.h"

@implementation TTCatalogAppDelegate

@synthesize window, navigationController;

- (void)applicationDidFinishLaunching:(UIApplication*)application {
	[window addSubview:[navigationController view]];
	[window makeKeyAndVisible];
}

- (void)applicationDidReceiveMemoryWarning:(UIApplication*)application {  
  [[TTStyleSheet globalStyleSheet] freeMemory];
  [[TTURLCache sharedCache] removeAll:NO];
}

- (void)dealloc {
	[navigationController release];
	[window release];
	[super dealloc];
}

@end
