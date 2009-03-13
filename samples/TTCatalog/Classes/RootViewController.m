#import "RootViewController.h"
#import "PhotoTest1Controller.h"
#import "PhotoTest2Controller.h"
#import "ImageTest1Controller.h"
#import "ImageTest2Controller.h"
#import "YouTubeTestController.h"
#import "TableFieldTestController.h"
#import "TableTestController.h"
#import "SearchTestController.h"
#import "ComposerTestController.h"
#import "TabBarTestController.h"
#import "ActivityTestController.h"
#import "ScrollViewTestController.h"

@implementation RootViewController

///////////////////////////////////////////////////////////////////////////////////////////////////
// UIViewController

- (void)loadView {
  [super loadView];

  self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds
    style:UITableViewStyleGrouped];
	self.tableView.autoresizingMask = 
    UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
  [self.view addSubview:self.tableView];
}

- (void)viewDidLoad {
  TTNavigationCenter* nav = [TTNavigationCenter defaultCenter];
  nav.mainViewController = self.navigationController;
  nav.delegate = self;
  nav.urlSchemes = [NSArray arrayWithObject:@"tt"];
  nav.supportsShakeToReload = YES;
  
  [nav addView:@"photoTest1" controller:[PhotoTest1Controller class]];
  [nav addView:@"photoTest2" controller:[PhotoTest2Controller class]];
  [nav addView:@"imageTest1" controller:[ImageTest1Controller class]];
  [nav addView:@"imageTest2" controller:[ImageTest2Controller class]];
  [nav addView:@"youTubeTest" controller:[YouTubeTestController class]];
  [nav addView:@"tableFieldTest" controller:[TableFieldTestController class]];
  [nav addView:@"tableTest" controller:[TableTestController class]];
  [nav addView:@"composerTest" controller:[ComposerTestController class]];
  [nav addView:@"searchTest" controller:[SearchTestController class]];
  [nav addView:@"tabBarTest" controller:[TabBarTestController class]];
  [nav addView:@"activityTest" controller:[ActivityTestController class]];
  [nav addView:@"scrollViewTest" controller:[ScrollViewTestController class]];
  
  [self validateView];
  
//  NSIndexPath* indexPath = [NSIndexPath indexPathForRow:1 inSection:2];
//  [self.tableView touchRowAtIndexPath:indexPath animated:NO];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// TTTableViewController

- (id<TTTableViewDataSource>)createDataSource {
  return [TTSectionedDataSource dataSourceWithObjects:
    @"Photos",
    [[[TTTableField alloc] initWithText:@"Photo Browser"
      href:@"tt://photoTest1"] autorelease],
    [[[TTTableField alloc] initWithText:@"Photo Thumbnails"
      href:@"tt://photoTest2"] autorelease],

    @"Tables",
    [[[TTTableField alloc] initWithText:@"Table States"
      href:@"tt://tableTest"] autorelease],
    [[[TTTableField alloc] initWithText:@"Table Cells"
      href:@"tt://tableFieldTest"] autorelease],
    [[[TTTableField alloc] initWithText:@"Web Images in Table"
      href:@"tt://imageTest2"] autorelease],

    @"Text",
    [[[TTTableField alloc] initWithText:@"Composer"
      href:@"tt://composerTest"] autorelease],
    [[[TTTableField alloc] initWithText:@"Search Bar"
      href:@"tt://searchTest"] autorelease],
    [[[TTTableField alloc] initWithText:@"Activity Labels"
      href:@"tt://activityTest"] autorelease],

    @"Views",
    [[[TTTableField alloc] initWithText:@"Tab Bars"
      href:@"tt://tabBarTest"] autorelease],
    [[[TTTableField alloc] initWithText:@"Web Image"
      href:@"tt://imageTest1"] autorelease],
    [[[TTTableField alloc] initWithText:@"YouTube Player"
      href:@"tt://youTubeTest"] autorelease],
    [[[TTTableField alloc] initWithText:@"Scroll View"
      href:@"tt://scrollViewTest"] autorelease],
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

@end
