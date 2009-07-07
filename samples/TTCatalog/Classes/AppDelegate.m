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

///////////////////////////////////////////////////////////////////////////////////////////////////
// UIApplicationDelegate

- (void)applicationDidFinishLaunching:(UIApplication*)application {
  TTAppMap* appMap = [TTAppMap sharedMap];
  appMap.delegate = self;
  appMap.supportsShakeToReload = YES;
  //appMap.persistenceMode = TTAppMapPersistenceModeAll;
  //appMap.launchExternalURLs = YES;
  
  [appMap addURL:@"*" controller:[TTWebController class] selector:@selector(openURL:)];
  [appMap addURL:@"tt://catalog" controller:[RootViewController class]];
  [appMap addURL:@"tt://photoTest1" controller:[PhotoTest1Controller class]];
  [appMap addURL:@"tt://photoTest2" controller:[PhotoTest2Controller class]];
  [appMap addURL:@"tt://imageTest1" controller:[ImageTest1Controller class]];
  [appMap addURL:@"tt://tableTest" controller:[TableTestController class]];
  [appMap addURL:@"tt://tableItemTest" controller:[TableItemTestController class]];
  [appMap addURL:@"tt://tableControlsTest" controller:[TableControlsTestController class]];
  [appMap addURL:@"tt://styledTextTableTest" controller:[StyledTextTableTestController class]];
  [appMap addURL:@"tt://composerTest" controller:[MessageTestController class]];
  [appMap addURL:@"tt://searchTest" controller:[SearchTestController class]];
  [appMap addURL:@"tt://activityTest" controller:[ActivityTestController class]];
  [appMap addURL:@"tt://styleTest" controller:[StyleTestController class]];
  [appMap addURL:@"tt://styledTextTest" controller:[StyledTextTestController class]];
  [appMap addURL:@"tt://buttonTest" controller:[ButtonTestController class]];
  [appMap addURL:@"tt://tabBarTest" controller:[TabBarTestController class]];
  [appMap addURL:@"tt://youTubeTest" controller:[YouTubeTestController class]];
  [appMap addURL:@"tt://imageTest2" controller:[TableImageTestController class]];
  [appMap addURL:@"tt://scrollViewTest" controller:[ScrollViewTestController class]];
  [appMap addURL:@"tt://webTest" controller:[WebTestController class]];

  TTLoadURL(@"tt://catalog");
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// TTAppMapDelegate

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
