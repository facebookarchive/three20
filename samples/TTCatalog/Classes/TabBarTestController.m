#import "TabBarTestController.h"
#import <Three20UI/UIViewAdditions.h>

@implementation TabBarTestController

- (void)dealloc {
  TT_RELEASE_SAFELY(_tabBar1);
  TT_RELEASE_SAFELY(_tabBar2);
  TT_RELEASE_SAFELY(_tabBar3);
  [super dealloc];
}

- (void)loadView {
	CGRect applicationFrame = [UIScreen mainScreen].applicationFrame;
	
  self.view = [[[UIView alloc] initWithFrame:applicationFrame] autorelease];
  self.view.backgroundColor = TTSTYLEVAR(tabTintColor);

  _tabBar1 = [[TTTabStrip alloc] initWithFrame:CGRectMake(0, 0, applicationFrame.size.width, 41)];
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
  [self.view addSubview:_tabBar1];

  _tabBar2 = [[TTTabBar alloc] initWithFrame:CGRectMake(0, _tabBar1.bottom, applicationFrame.size.width, 40)];
  _tabBar2.tabItems = [NSArray arrayWithObjects:
    [[[TTTabItem alloc] initWithTitle:@"Banana"] autorelease],
    [[[TTTabItem alloc] initWithTitle:@"Cherry"] autorelease],
    [[[TTTabItem alloc] initWithTitle:@"Orange"] autorelease],
    [[[TTTabItem alloc] initWithTitle:@"Grape"] autorelease],
    nil];
  _tabBar2.selectedTabIndex = 2;
  [self.view addSubview:_tabBar2];

  TTTabItem* item = [_tabBar2.tabItems objectAtIndex:1];
  item.badgeNumber = 2;

  _tabBar3 = [[TTTabGrid alloc] initWithFrame:CGRectMake(10, _tabBar2.bottom+10, applicationFrame.size.width - 20, 0)];
  _tabBar3.backgroundColor = [UIColor clearColor];
  _tabBar3.tabItems = [NSArray arrayWithObjects:
    [[[TTTabItem alloc] initWithTitle:@"Banana"] autorelease],
    [[[TTTabItem alloc] initWithTitle:@"Cherry"] autorelease],
    [[[TTTabItem alloc] initWithTitle:@"Orange"] autorelease],
    [[[TTTabItem alloc] initWithTitle:@"Pineapple"] autorelease],
    [[[TTTabItem alloc] initWithTitle:@"Grape"] autorelease],
    [[[TTTabItem alloc] initWithTitle:@"Mango"] autorelease],
    [[[TTTabItem alloc] initWithTitle:@"Blueberry"] autorelease],
    [[[TTTabItem alloc] initWithTitle:@"Apple"] autorelease],
    [[[TTTabItem alloc] initWithTitle:@"Peach"] autorelease],
    nil];
  [_tabBar3 sizeToFit];
  [self.view addSubview:_tabBar3];
}

///////////////////////////////////////////////////////////////////////////////////////////////////

@end
