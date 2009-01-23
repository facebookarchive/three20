#import "T3CatalogAppDelegate.h"
#import "RootViewController.h"

@implementation T3CatalogAppDelegate

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
