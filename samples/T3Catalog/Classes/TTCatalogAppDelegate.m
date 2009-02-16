#import "TTCatalogAppDelegate.h"
#import "RootViewController.h"

@implementation TTCatalogAppDelegate

@synthesize window;
@synthesize navigationController;

- (void)applicationDidFinishLaunching:(UIApplication *)application {
	[window addSubview:[navigationController view]];
	[window makeKeyAndVisible];
}

- (void)dealloc {
	[navigationController release];
	[window release];
	[super dealloc];
}

@end
