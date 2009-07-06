#import "AppDelegate.h"
#import "RootViewController.h"
#import "PhotoTest1Controller.h"
#import "PhotoTest2Controller.h"
#import "ImageTest1Controller.h"
#import "TableImageTestController.h"
#import "YouTubeTestController.h"
#import "TableItemTestController.h"
#import "TableControlsTestController.h"
#import "TableTestController.h"
#import "SearchTestController.h"
#import "MessageTestController.h"
#import "ActivityTestController.h"
#import "ScrollViewTestController.h"
#import "StyledTextTestController.h"
#import "StyledTextTableTestController.h"
#import "StyleTestController.h"
#import "ButtonTestController.h"
#import "TabBarTestController.h"
#import "WebTestController.h"

@implementation AppDelegate

@synthesize window, navigationController;

- (void)applicationDidFinishLaunching:(UIApplication*)application {
  TTNavigationCenter* nav = [TTNavigationCenter defaultCenter];
  nav.mainViewController = self.navigationController;
  nav.delegate = self;
  nav.URLSchemes = [NSArray arrayWithObject:@"tt"];
  nav.supportsShakeToReload = YES;
  
  [nav addView:@"photoTest1" controller:[PhotoTest1Controller class]];
  [nav addView:@"photoTest2" controller:[PhotoTest2Controller class]];
  [nav addView:@"imageTest1" controller:[ImageTest1Controller class]];
  [nav addView:@"tableTest" controller:[TableTestController class]];
  [nav addView:@"tableItemTest" controller:[TableItemTestController class]];
  [nav addView:@"tableControlsTest" controller:[TableControlsTestController class]];
  [nav addView:@"styledTextTableTest" controller:[StyledTextTableTestController class]];
  [nav addView:@"composerTest" controller:[MessageTestController class]];
  [nav addView:@"searchTest" controller:[SearchTestController class]];
  [nav addView:@"activityTest" controller:[ActivityTestController class]];
  [nav addView:@"styleTest" controller:[StyleTestController class]];
  [nav addView:@"styledTextTest" controller:[StyledTextTestController class]];
  [nav addView:@"buttonTest" controller:[ButtonTestController class]];
  [nav addView:@"tabBarTest" controller:[TabBarTestController class]];
  [nav addView:@"youTubeTest" controller:[YouTubeTestController class]];
  [nav addView:@"imageTest2" controller:[TableImageTestController class]];
  [nav addView:@"scrollViewTest" controller:[ScrollViewTestController class]];
  [nav addView:@"webTest" controller:[WebTestController class]];

	[window addSubview:[navigationController view]];
	[window makeKeyAndVisible];
}

- (void)dealloc {
	TT_RELEASE_MEMBER(navigationController);
	TT_RELEASE_MEMBER(window);
	[super dealloc];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// TTNavigationDelegate

- (void)willNavigateToObject:(id)object inView:(NSString*)viewType
    withController:(UIViewController*)viewController {
//  NSIndexPath* indexPath = self.tableView.indexPathForSelectedRow;
//  TTTableTextItem* item = [self.dataSource tableView:self.tableView
//                                           objectForRowAtIndexPath:indexPath];
//  
//  viewController.title = item.text;
}

- (BOOL)shouldLoadExternalURL:(NSURL*)URL {
  NSString* message = [NSString stringWithFormat:@"You touched a link to %@", URL];
  UIAlertView* alertView = [[[UIAlertView alloc] initWithTitle:@"Link"
    message:message delegate:nil cancelButtonTitle:NSLocalizedString(@"Ok", @"")
    otherButtonTitles:nil] autorelease];
  [alertView show];

  return NO;
}

@end
