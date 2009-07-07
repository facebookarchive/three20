#import "AppDelegate.h"
#import "CatalogController.h"
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

@implementation AppDelegate

///////////////////////////////////////////////////////////////////////////////////////////////////
// UIApplicationDelegate

- (void)applicationDidFinishLaunching:(UIApplication*)application {
  TTAppMap* appMap = [TTAppMap sharedMap];
  appMap.delegate = self;
  appMap.supportsShakeToReload = YES;
  appMap.persistenceMode = TTAppMapPersistenceModeAll;
  //appMap.launchExternalURLs = YES;
  
  [appMap addURL:@"*" create:[TTWebController class] selector:@selector(openURL:)];
  [appMap addURL:@"tt://catalog" create:[CatalogController class]];
  [appMap addURL:@"tt://photoTest1" create:[PhotoTest1Controller class]];
  [appMap addURL:@"tt://photoTest2" create:[PhotoTest2Controller class]];
  [appMap addURL:@"tt://imageTest1" create:[ImageTest1Controller class]];
  [appMap addURL:@"tt://tableTest" create:[TableTestController class]];
  [appMap addURL:@"tt://tableItemTest" create:[TableItemTestController class]];
  [appMap addURL:@"tt://tableControlsTest" create:[TableControlsTestController class]];
  [appMap addURL:@"tt://styledTextTableTest" create:[StyledTextTableTestController class]];
  [appMap addURL:@"tt://composerTest" create:[MessageTestController class]];
  [appMap addURL:@"tt://searchTest" create:[SearchTestController class]];
  [appMap addURL:@"tt://activityTest" create:[ActivityTestController class]];
  [appMap addURL:@"tt://styleTest" create:[StyleTestController class]];
  [appMap addURL:@"tt://styledTextTest" create:[StyledTextTestController class]];
  [appMap addURL:@"tt://buttonTest" create:[ButtonTestController class]];
  [appMap addURL:@"tt://tabBarTest" create:[TabBarTestController class]];
  [appMap addURL:@"tt://youTubeTest" create:[YouTubeTestController class]];
  [appMap addURL:@"tt://imageTest2" create:[TableImageTestController class]];
  [appMap addURL:@"tt://scrollViewTest" create:[ScrollViewTestController class]];

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
