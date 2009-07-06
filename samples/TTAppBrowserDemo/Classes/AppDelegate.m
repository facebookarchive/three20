#import "AppDelegate.h"
#import "RootViewController.h"

@implementation AppDelegate

@synthesize window, navigationController;

- (void)applicationDidFinishLaunching:(UIApplication*)application {
	[window addSubview:[navigationController view]];
	[window makeKeyAndVisible];
}

- (void)dealloc {
	[navigationController release];
	[window release];
	[super dealloc];
}

@end
