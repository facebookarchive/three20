#import "RootViewController.h"
#import "PhotoTest1Controller.h"
#import "PhotoTest2Controller.h"
#import "ImageTest1Controller.h"
#import "ImageTest2Controller.h"
#import "YouTubeTestController.h"
#import "TableFieldTestController.h"
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
  
//  self.navigationController.navigationBar.tintColor = RGBCOLOR(236, 106, 45);
//  
//  TTAppearance* appearance = [TTAppearance appearance];
//  appearance.barTintColor = RGBCOLOR(236, 106, 45);
  
  [nav addView:@"photoTest1" controller:[PhotoTest1Controller class]];
  [nav addView:@"photoTest2" controller:[PhotoTest2Controller class]];
  [nav addView:@"imageTest1" controller:[ImageTest1Controller class]];
  [nav addView:@"imageTest2" controller:[ImageTest2Controller class]];
  [nav addView:@"youTubeTest" controller:[YouTubeTestController class]];
  [nav addView:@"tableFieldTest" controller:[TableFieldTestController class]];
  [nav addView:@"composerTest" controller:[ComposerTestController class]];
  [nav addView:@"searchTest" controller:[SearchTestController class]];
  [nav addView:@"tabBarTest" controller:[TabBarTestController class]];
  [nav addView:@"activityTest" controller:[ActivityTestController class]];
  [nav addView:@"scrollViewTest" controller:[ScrollViewTestController class]];
  
  self.dataSource = [TTSectionedDataSource dataSourceWithObjects:
    @"Photos",
    [[[TTTableField alloc] initWithText:@"Photo Browser"
      href:@"tt://photoTest1"] autorelease],
    [[[TTTableField alloc] initWithText:@"Photo Thumbnails"
      href:@"tt://photoTest2"] autorelease],

    @"Web Media",
    [[[TTTableField alloc] initWithText:@"Web Image"
      href:@"tt://imageTest1"] autorelease],
    [[[TTTableField alloc] initWithText:@"Web Images in Table"
      href:@"tt://imageTest2"] autorelease],
    [[[TTTableField alloc] initWithText:@"YouTube Player"
      href:@"tt://youTubeTest"] autorelease],

    @"Controls",
    [[[TTTableField alloc] initWithText:@"Table Fields"
      href:@"tt://tableFieldTest"] autorelease],
    [[[TTTableField alloc] initWithText:@"Search Bar"
      href:@"tt://searchTest"] autorelease],
    [[[TTTableField alloc] initWithText:@"Message Composer"
      href:@"tt://composerTest"] autorelease],
    [[[TTTableField alloc] initWithText:@"Tab Bars"
      href:@"tt://tabBarTest"] autorelease],
    [[[TTTableField alloc] initWithText:@"Shiny Label"
      href:@"tt://activityTest"] autorelease],
    [[[TTTableField alloc] initWithText:@"Scroll View"
      href:@"tt://scrollViewTest"] autorelease],
    nil];

  NSIndexPath* indexPath = [NSIndexPath indexPathForRow:2 inSection:2];
  [self.tableView touchRowAtIndexPath:indexPath animated:NO];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// TTNavigationDelegate

- (void)willNavigateToObject:(id<TTObject>)object inView:(NSString*)viewType
    withController:(UIViewController*)viewController {
  NSIndexPath* indexPath = self.tableView.indexPathForSelectedRow;
  TTLinkTableField* field = [self.dataSource objectForRowAtIndexPath:indexPath];
  viewController.title = field.text;
}

@end
