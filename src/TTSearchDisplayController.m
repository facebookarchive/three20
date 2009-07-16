#import "Three20/TTSearchDisplayController.h"
#import "Three20/TTTableViewController.h"
#import "Three20/TTTableViewDataSource.h"

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation TTSearchDisplayController

@synthesize dataSource = _dataSource;

///////////////////////////////////////////////////////////////////////////////////////////////////
// NSObject

- (id)initWithSearchBar:(UISearchBar*)searchBar contentsController:(UIViewController*)controller {
  if (self = [super initWithSearchBar:searchBar contentsController:controller]) {
    _dataSource = nil;
    _searchResultsDelegate2 = nil;
    _tableViewController = nil;
    
    self.delegate = self;
  }
  return self;
}

- (void)dealloc {
  TT_RELEASE_MEMBER(_dataSource);
  TT_RELEASE_MEMBER(_searchResultsDelegate2);
  TT_RELEASE_MEMBER(_tableViewController);
  [super dealloc];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// UISearchDisplayDelegate

- (void)searchDisplayControllerWillEndSearch:(UISearchDisplayController*)controller {
  if (_dataSource.model.isLoading) {
    [_dataSource.model cancel];
  }
}
 
- (void)searchDisplayController:(UISearchDisplayController *)controller
        didLoadSearchResultsTableView:(UITableView *)tableView {
  TT_RELEASE_MEMBER(_tableViewController);
  _tableViewController = [[TTTableViewController alloc] init];
  _tableViewController.autoresizesForKeyboard = YES;
  _tableViewController.dataSource = _dataSource;
  _tableViewController.tableView = tableView;
}

- (void)searchDisplayController:(UISearchDisplayController *)controller
        willUnloadSearchResultsTableView:(UITableView *)tableView {
  TT_RELEASE_MEMBER(_tableViewController);
}

- (void)searchDisplayController:(UISearchDisplayController *)controller
        didShowSearchResultsTableView:(UITableView *)tableView {
  [_tableViewController viewWillAppear:NO];
  [_tableViewController viewDidAppear:NO];
}

- (void)searchDisplayController:(UISearchDisplayController*)controller
        willHideSearchResultsTableView:(UITableView*)tableView {
  if (_dataSource.model.isLoading) {
    [_dataSource.model cancel];
  }
}

- (void)searchDisplayController:(UISearchDisplayController*)controller
        didHideSearchResultsTableView:(UITableView*)tableView {
  [_tableViewController viewWillDisappear:NO];
  [_tableViewController viewDidDisappear:NO];
}

- (BOOL)searchDisplayController:(UISearchDisplayController*)controller
        shouldReloadTableForSearchString:(NSString*)searchString {
  [_dataSource search:searchString];
  return YES;
}

- (BOOL)searchDisplayController:(UISearchDisplayController*)controller
        shouldReloadTableForSearchScope:(NSInteger)searchOption {
  // XXXjoe Need a way to communicate scope change to the data source
  [_dataSource search:self.searchBar.text];
  return YES;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// public

- (void)setDataSource:(id<TTTableViewDataSource>)dataSource {
  self.searchResultsDataSource = dataSource;
  if (_dataSource != dataSource) {
    [_dataSource release];
    _dataSource = [dataSource retain];
  }
}

- (void)setSearchResultsDelegate:(id<UITableViewDelegate>)searchResultsDelegate {
  [super setSearchResultsDelegate:searchResultsDelegate];
  if (_searchResultsDelegate2 != searchResultsDelegate) {
    [_searchResultsDelegate2 release];
    _searchResultsDelegate2 = [searchResultsDelegate retain];
  }
}

@end
