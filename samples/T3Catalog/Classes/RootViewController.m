#import "RootViewController.h"
#import "PhotoTest1Controller.h"
#import "PhotoTest2Controller.h"
#import "ImageTest1Controller.h"
#import "ImageTest2Controller.h"
#import "YouTubeTestController.h"
#import "TableFieldTestController.h"
#import "TabBarTestController.h"
#import "TextTest1Controller.h"
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
  T3NavigationCenter* nav = [T3NavigationCenter defaultCenter];
  nav.mainViewController = self.navigationController;
  nav.delegate = self;
  nav.urlSchemes = [NSArray arrayWithObject:@"t3"];
  nav.supportsShakeToReload = YES;
  
  [nav addController:[PhotoTest1Controller class] forView:@"photoTest1"];
  [nav addController:[PhotoTest2Controller class] forView:@"photoTest2"];
  [nav addController:[ImageTest1Controller class] forView:@"imageTest1"];
  [nav addController:[ImageTest2Controller class] forView:@"imageTest2"];
  [nav addController:[YouTubeTestController class] forView:@"youTubeTest"];
  [nav addController:[TableFieldTestController class] forView:@"tableFieldTest"];
  [nav addController:[TabBarTestController class] forView:@"tabBarTest"];
  [nav addController:[TextTest1Controller class] forView:@"textTest1"];
  [nav addController:[ScrollViewTestController class] forView:@"scrollViewTest"];
  
  self.dataSource = [T3SectionedDataSource dataSourceWithObjects:
    @"Photos",
    [[[T3TableField alloc] initWithText:@"Photo Browser"
      href:@"t3://photoTest1"] autorelease],
    [[[T3TableField alloc] initWithText:@"Photo Thumbnails"
      href:@"t3://photoTest2"] autorelease],

    @"Web Media",
    [[[T3TableField alloc] initWithText:@"Web Image"
      href:@"t3://imageTest1"] autorelease],
    [[[T3TableField alloc] initWithText:@"Web Images in Table"
      href:@"t3://imageTest2"] autorelease],
    [[[T3TableField alloc] initWithText:@"YouTube Player"
      href:@"t3://youTubeTest"] autorelease],

    @"Controls",
    [[[T3TableField alloc] initWithText:@"Table Fields"
      href:@"t3://tableFieldTest"] autorelease],
    [[[T3TableField alloc] initWithText:@"Tab Bars"
      href:@"t3://tabBarTest"] autorelease],
    [[[T3TableField alloc] initWithText:@"Shiny Label"
      href:@"t3://textTest1"] autorelease],
    [[[T3TableField alloc] initWithText:@"Scroll View"
      href:@"t3://scrollViewTest"] autorelease],
    nil];

  NSIndexPath* indexPath = [NSIndexPath indexPathForRow:0 inSection:2];
  [self.tableView touchRowAtIndexPath:indexPath animated:NO];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// T3NavigationDelegate

- (void)willNavigateToObject:(id<T3Object>)object inView:(NSString*)viewType
    withController:(UIViewController*)viewController {
  NSIndexPath* indexPath = self.tableView.indexPathForSelectedRow;
  T3LinkTableField* field = [self.dataSource objectForRowAtIndexPath:indexPath];
  viewController.title = field.text;
}

@end
