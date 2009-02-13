#import "TabBarTestController.h"

@implementation TabBarTestController

- (void)dealloc {
  [_tabBar1 release];
  [_tabBar2 release];
  [_tabBar3 release];
  [super dealloc];
}

- (void)loadView {
  self.view = [[[UIView alloc] initWithFrame:[UIScreen mainScreen].applicationFrame] autorelease];
  self.view.backgroundColor = RGBCOLOR(240, 242, 245);
    
  _tabBar1 = [[T3TabBar alloc] initWithFrame:CGRectMake(0, -1, 320, 43)
    style:T3TabBarStyleButtons];
  _tabBar1.delegate = self;
  [self.view addSubview:_tabBar1];

  _tabBar1.tabItems = [NSArray arrayWithObjects:
    [[[T3TabItem alloc] initWithTitle:@"Item 1"] autorelease],
    [[[T3TabItem alloc] initWithTitle:@"Item 2"] autorelease],
    [[[T3TabItem alloc] initWithTitle:@"Item 3"] autorelease],
    [[[T3TabItem alloc] initWithTitle:@"Item 4"] autorelease],
    [[[T3TabItem alloc] initWithTitle:@"Item 5"] autorelease],
    [[[T3TabItem alloc] initWithTitle:@"Item 6"] autorelease],
    [[[T3TabItem alloc] initWithTitle:@"Item 7"] autorelease],
    [[[T3TabItem alloc] initWithTitle:@"Item 8"] autorelease],
    [[[T3TabItem alloc] initWithTitle:@"Item 9"] autorelease],
    [[[T3TabItem alloc] initWithTitle:@"Item 10"] autorelease],
    nil];

  _tabBar2 = [[T3TabBar alloc] initWithFrame:CGRectMake(0, 42, 320, 41)
    style:T3TabBarStyleDark];
  _tabBar2.delegate = self;
  _tabBar2.contentMode = UIViewContentModeScaleToFill;
  [self.view addSubview:_tabBar2];

  _tabBar2.tabItems = [NSArray arrayWithObjects:
    [[[T3TabItem alloc] initWithTitle:@"Banana"] autorelease],
    [[[T3TabItem alloc] initWithTitle:@"Cherry"] autorelease],
    [[[T3TabItem alloc] initWithTitle:@"Orange"] autorelease],
    [[[T3TabItem alloc] initWithTitle:@"Grape"] autorelease],
    nil];
  
  _tabBar2.selectedTabIndex = 2;
  
  T3TabItem* item = [_tabBar2.tabItems objectAtIndex:1];
  item.badgeNumber = 2;

  _tabBar3 = [[T3TabBar alloc] initWithFrame:CGRectMake(0, 100, 320, 41)
    style:T3TabBarStyleLight];
  _tabBar3.delegate = self;
  _tabBar3.contentMode = UIViewContentModeScaleToFill;
  [self.view addSubview:_tabBar3];

  _tabBar3.tabItems = [NSArray arrayWithObjects:
    [[[T3TabItem alloc] initWithTitle:@"Red"] autorelease],
    [[[T3TabItem alloc] initWithTitle:@"Green"] autorelease],
    [[[T3TabItem alloc] initWithTitle:@"Blue"] autorelease],
    nil];
}

///////////////////////////////////////////////////////////////////////////////////////////////////

@end
