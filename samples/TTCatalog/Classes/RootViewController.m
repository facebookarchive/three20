#import "RootViewController.h"
#import "PhotoTest1Controller.h"
#import "PhotoTest2Controller.h"
#import "ImageTest1Controller.h"
#import "ImageTest2Controller.h"
#import "YouTubeTestController.h"
#import "TableFieldTestController.h"
#import "SearchTestController.h"
#import "TextEditTestController.h"
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
  
  [nav addController:[PhotoTest1Controller class] forView:@"photoTest1"];
  [nav addController:[PhotoTest2Controller class] forView:@"photoTest2"];
  [nav addController:[ImageTest1Controller class] forView:@"imageTest1"];
  [nav addController:[ImageTest2Controller class] forView:@"imageTest2"];
  [nav addController:[YouTubeTestController class] forView:@"youTubeTest"];
  [nav addController:[TableFieldTestController class] forView:@"tableFieldTest"];
  [nav addController:[TextEditTestController class] forView:@"textEditTest"];
  [nav addController:[SearchTestController class] forView:@"searchTest"];
  [nav addController:[TabBarTestController class] forView:@"tabBarTest"];
  [nav addController:[ActivityTestController class] forView:@"activityTest"];
  [nav addController:[ScrollViewTestController class] forView:@"scrollViewTest"];
  
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
    [[[TTTableField alloc] initWithText:@"Text Editing"
      href:@"tt://textEditTest"] autorelease],
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
