
#import "SearchTestController.h"
#import "MockDataSource.h"
#import "MockSearchSource.h"

@implementation SearchTestController

- (void)dealloc {
  [_searchSource release];
	[super dealloc];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// UIViewController
//
- (void)loadView {
  self.view = [[[UIView alloc] init] autorelease];
    
  self.dataSource = [MockDataSource mockDataSource];
  
  self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
	self.tableView.autoresizingMask = 
    UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
  self.tableView.sectionIndexMinimumDisplayRowCount = 2;
  [self.view addSubview:self.tableView];

  _searchSource = [[MockSearchSource alloc] init];
  
  TTSearchBar* searchBar = [[[TTSearchBar alloc] initWithFrame:
    CGRectMake(0, 0, 320, 0)] autorelease];
  searchBar.searchSource = _searchSource;
  searchBar.showsDoneButton = YES;
  searchBar.showsDarkScreen = YES;
  [searchBar sizeToFit];
  self.tableView.tableHeaderView = searchBar;
}

@end
