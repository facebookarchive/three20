#import "RootViewController.h"
#import "PhotoTest1Controller.h"
#import "PhotoTest2Controller.h"
#import "ImageTest1Controller.h"
#import "TableImageTestController.h"
#import "YouTubeTestController.h"
#import "TableFieldTestController.h"
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
#import "Three20/developer.h"

@implementation RootViewController

///////////////////////////////////////////////////////////////////////////////////////////////////
// UIViewController

- (void)loadView {
  [super loadView];

  self.tableView = [[[UITableView alloc] initWithFrame:self.view.bounds
    style:UITableViewStyleGrouped] autorelease];
	self.tableView.autoresizingMask = 
    UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
  [self.view addSubview:self.tableView];
}

- (void)viewDidLoad {
  TTNavigationCenter* nav = [TTNavigationCenter defaultCenter];
  nav.mainViewController = self.navigationController;
  nav.delegate = self;
  nav.URLSchemes = [NSArray arrayWithObject:@"tt"];
  nav.supportsShakeToReload = YES;
  
  [nav addView:@"photoTest1" controller:[PhotoTest1Controller class]];
  [nav addView:@"photoTest2" controller:[PhotoTest2Controller class]];
  [nav addView:@"imageTest1" controller:[ImageTest1Controller class]];
  [nav addView:@"tableTest" controller:[TableTestController class]];
  [nav addView:@"tableFieldTest" controller:[TableFieldTestController class]];
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

#ifdef JOE
  [self validateView];
  NSIndexPath* indexPath = [NSIndexPath indexPathForRow:TEST_ROW inSection:TEST_SECTION];
  [self.tableView touchRowAtIndexPath:indexPath animated:NO];
#endif
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// TTTableViewController

- (id<TTTableViewDataSource>)createDataSource {
  return [TTSectionedDataSource dataSourceWithObjects:
    @"Photos",
    [[[TTTableField alloc] initWithText:@"Photo Browser"
      URL:@"tt://photoTest1"] autorelease],
    [[[TTTableField alloc] initWithText:@"Photo Thumbnails"
      URL:@"tt://photoTest2"] autorelease],

    @"Text Fields",
    [[[TTTableField alloc] initWithText:@"Message Composer"
      URL:@"tt://composerTest"] autorelease],
    [[[TTTableField alloc] initWithText:@"Search Bar"
      URL:@"tt://searchTest"] autorelease],

    @"Styles",
    [[[TTTableField alloc] initWithText:@"Styled Views"
      URL:@"tt://styleTest"] autorelease],
    [[[TTTableField alloc] initWithText:@"Styled Labels"
      URL:@"tt://styledTextTest"] autorelease],

    @"Controls",
    [[[TTTableField alloc] initWithText:@"Buttons"
      URL:@"tt://buttonTest"] autorelease],
    [[[TTTableField alloc] initWithText:@"Tabs"
      URL:@"tt://tabBarTest"] autorelease],

    @"Tables",
    [[[TTTableField alloc] initWithText:@"Table States"
      URL:@"tt://tableTest"] autorelease],
    [[[TTTableField alloc] initWithText:@"Table Items"
      URL:@"tt://tableFieldTest"] autorelease],
    [[[TTTableField alloc] initWithText:@"Table Controls"
      URL:@"tt://tableControlsTest"] autorelease],
    [[[TTTableField alloc] initWithText:@"Styled Labels in Table"
      URL:@"tt://styledTextTableTest"] autorelease],
    [[[TTTableField alloc] initWithText:@"Web Images in Table"
      URL:@"tt://imageTest2"] autorelease],

    @"General",
    [[[TTTableField alloc] initWithText:@"Web Image"
      URL:@"tt://imageTest1"] autorelease],
    [[[TTTableField alloc] initWithText:@"YouTube Player"
      URL:@"tt://youTubeTest"] autorelease],
    [[[TTTableField alloc] initWithText:@"Web Browser"
      URL:@"tt://webTest"] autorelease],
    [[[TTTableField alloc] initWithText:@"Activity Labels"
      URL:@"tt://activityTest"] autorelease],
    [[[TTTableField alloc] initWithText:@"Scroll View"
      URL:@"tt://scrollViewTest"] autorelease],
    nil];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// TTNavigationDelegate

- (void)willNavigateToObject:(id)object inView:(NSString*)viewType
    withController:(UIViewController*)viewController {
  NSIndexPath* indexPath = self.tableView.indexPathForSelectedRow;
  TTLinkTableField* field = [self.dataSource tableView:self.tableView
    objectForRowAtIndexPath:indexPath];
  
  viewController.title = field.text;
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
