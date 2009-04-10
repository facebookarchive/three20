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
  self.view.backgroundColor = TTSTYLEVAR(tabTintColor);
    
  _tabBar1 = [[TTTabBar alloc] initWithFrame:CGRectMake(0, 0, 320, 41)];
  _tabBar1.tabStyle = @"tabRound:";
  _tabBar1.style = TTSTYLE(tabBarSmall);
  [self.view addSubview:_tabBar1];

  _tabBar1.tabItems = [NSArray arrayWithObjects:
    [[[TTTabItem alloc] initWithTitle:@"Item 1"] autorelease],
    [[[TTTabItem alloc] initWithTitle:@"Item 2"] autorelease],
    [[[TTTabItem alloc] initWithTitle:@"Item 3"] autorelease],
    [[[TTTabItem alloc] initWithTitle:@"Item 4"] autorelease],
    [[[TTTabItem alloc] initWithTitle:@"Item 5"] autorelease],
    [[[TTTabItem alloc] initWithTitle:@"Item 6"] autorelease],
    [[[TTTabItem alloc] initWithTitle:@"Item 7"] autorelease],
    [[[TTTabItem alloc] initWithTitle:@"Item 8"] autorelease],
    [[[TTTabItem alloc] initWithTitle:@"Item 9"] autorelease],
    [[[TTTabItem alloc] initWithTitle:@"Item 10"] autorelease],
    nil];

  _tabBar2 = [[TTTabBar alloc] initWithFrame:CGRectMake(0, _tabBar1.bottom, 320, 40)];
  _tabBar2.contentMode = UIViewContentModeScaleToFill;
  [self.view addSubview:_tabBar2];

  _tabBar2.tabItems = [NSArray arrayWithObjects:
    [[[TTTabItem alloc] initWithTitle:@"Banana"] autorelease],
    [[[TTTabItem alloc] initWithTitle:@"Cherry"] autorelease],
    [[[TTTabItem alloc] initWithTitle:@"Orange"] autorelease],
    [[[TTTabItem alloc] initWithTitle:@"Grape"] autorelease],
    nil];
  
  _tabBar2.selectedTabIndex = 2;
  
  TTTabItem* item = [_tabBar2.tabItems objectAtIndex:1];
  item.badgeNumber = 2;
}

///////////////////////////////////////////////////////////////////////////////////////////////////

@end
