
#import "SearchTestController.h"
#import "MockDataSource.h"

@implementation SearchTestController

@synthesize delegate = _delegate;

///////////////////////////////////////////////////////////////////////////////////////////////////
// NSObject

- (id)init {
  if (self = [super init]) {
    _delegate = nil;
    
    self.title = @"Search Test";
    self.dataSource = [[[MockDataSource alloc] init] autorelease];
    self.searchDataSource = [[[MockSearchDataSource alloc] init] autorelease];
  }
  return self;
}

- (void)dealloc {
	[super dealloc];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// UIViewController

- (void)loadView {
  [super loadView];

//  _searchController.searchBar.showsScopeBar = YES;
//  _searchController.searchBar.scopeButtonTitles = [NSArray arrayWithObjects:
//    @"First", @"Last", @"City", nil];
  self.tableView.tableHeaderView = _searchController.searchBar;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// TTTableViewController

- (void)didSelectObject:(id)object atIndexPath:(NSIndexPath*)indexPath {
  [_delegate searchTestController:self didSelectObject:object];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// TTSearchTextFieldDelegate

- (void)textField:(TTSearchTextField*)textField didSelectObject:(id)object {
  [_delegate searchTestController:self didSelectObject:object];
}

@end
