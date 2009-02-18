
#import "SearchTestController.h"
#import "MockDataSource.h"

@implementation SearchTestController

@synthesize delegate = _delegate;

- (id)init {
  if (self = [super init]) {
    _delegate = nil;
  }
  return self;
}

- (void)dealloc {
	[super dealloc];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// UIViewController
//
- (void)loadView {
  CGRect appFrame = [UIScreen mainScreen].applicationFrame;
  self.view = [[[UIView alloc] initWithFrame:appFrame] autorelease];
    
  self.dataSource = [MockDataSource mockDataSource:NO];
  
  self.tableView = [[[UITableView alloc] initWithFrame:self.view.bounds
    style:UITableViewStylePlain] autorelease];
	self.tableView.autoresizingMask = 
    UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
  self.tableView.sectionIndexMinimumDisplayRowCount = 2;
  [self.view addSubview:self.tableView];

  TTSearchBar* searchBar = [[[TTSearchBar alloc] initWithFrame:
    CGRectMake(0, 0, appFrame.size.width, 0)] autorelease];
  searchBar.delegate = self;
  searchBar.dataSource = [MockDataSource mockDataSource:YES];
  searchBar.showsDoneButton = YES;
  searchBar.showsDarkScreen = YES;
  [searchBar sizeToFit];
  self.tableView.tableHeaderView = searchBar;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// UITableViewDelegate

- (void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath {
  [super tableView:tableView didSelectRowAtIndexPath:indexPath];
  
  id object = [self.dataSource tableView:tableView objectForRowAtIndexPath:indexPath];
  [_delegate searchTestController:self didSelectObject:object];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// TTSearchTextFieldDelegate

- (void)textField:(TTSearchTextField*)textField didSelectObject:(id)object {
  [_delegate searchTestController:self didSelectObject:object];
}

@end
