
#import "SearchTestController.h"
#import "TestSearchSource.h"

@implementation SearchTestController

- (void)dealloc {
	[super dealloc];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// UIViewController
//
- (void)loadView {
  self.view = [[[UIView alloc] init] autorelease];
  
  self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
	self.tableView.autoresizingMask = 
    UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
  [self.view addSubview:self.tableView];

  _searchSource = [[TestSearchSource alloc] init];
  
  TTSearchTextField* textField = [[[TTSearchTextField alloc] initWithFrame:
    CGRectMake(0, 0, 320, 0)] autorelease];
  textField.searchSource = _searchSource;

  self.tableView.tableHeaderView = textField;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// TTSearchSource

@end
