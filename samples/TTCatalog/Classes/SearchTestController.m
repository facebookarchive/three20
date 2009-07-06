
#import "SearchTestController.h"
#import "MockDataSource.h"

@implementation SearchTestController

@synthesize delegate = _delegate;

///////////////////////////////////////////////////////////////////////////////////////////////////
// NSObject

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
  [super loadView];
  
  self.tableView.sectionIndexMinimumDisplayRowCount = 2;

  TTSearchBar* searchBar = [[[TTSearchBar alloc] initWithFrame:
    CGRectMake(0, 0, self.tableView.width, 0)] autorelease];
  searchBar.delegate = self;
  searchBar.dataSource = [MockDataSource mockDataSource:YES];
  searchBar.showsDoneButton = YES;
  searchBar.showsDarkScreen = YES;
  [searchBar sizeToFit];
  self.tableView.tableHeaderView = searchBar;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// TTTableViewController

- (id<TTTableViewDataSource>)createDataSource {
  return [MockDataSource mockDataSource:NO];
}

- (void)didSelectObject:(id)object atIndexPath:(NSIndexPath*)indexPath {
  [_delegate searchTestController:self didSelectObject:object];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// TTSearchTextFieldDelegate

- (void)textField:(TTSearchTextField*)textField didSelectObject:(id)object {
  [_delegate searchTestController:self didSelectObject:object];
}

@end
