#import "Three20/TTSearchDisplayController.h"
#import "Three20/TTTableViewController.h"
#import "Three20/TTTableViewDataSource.h"

///////////////////////////////////////////////////////////////////////////////////////////////////
// global

static const NSTimeInterval kPauseInterval = 0.4;

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation TTSearchDisplayController

@synthesize dataSource = _dataSource, pausesBeforeSearching = _pausesBeforeSearching;

///////////////////////////////////////////////////////////////////////////////////////////////////
// private

- (void)restartPauseTimer {
  TT_RELEASE_TIMER(_pauseTimer);
  _pauseTimer = [NSTimer scheduledTimerWithTimeInterval:kPauseInterval target:self
                         selector:@selector(searchAfterPause) userInfo:nil repeats:NO];
}

- (void)searchAfterPause {
  _pauseTimer = nil;
  [_dataSource search:self.searchBar.text];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// NSObject

- (id)initWithSearchBar:(UISearchBar*)searchBar contentsController:(UIViewController*)controller {
  if (self = [super initWithSearchBar:searchBar contentsController:controller]) {
    _dataSource = nil;
    _searchResultsDelegate2 = nil;
    _tableViewController = nil;
    _pauseTimer = nil;
    _pausesBeforeSearching = NO;
    
    self.delegate = self;
  }
  return self;
}

- (void)dealloc {
  TT_RELEASE_TIMER(_pauseTimer);
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
  [_tableViewController viewWillDisappear:NO];
  [_tableViewController viewDidDisappear:NO];
  _tableViewController.tableView = nil;
}
 
- (void)searchDisplayController:(UISearchDisplayController *)controller
        didLoadSearchResultsTableView:(UITableView *)tableView {
  TT_RELEASE_MEMBER(_tableViewController);
  _tableViewController = [[TTTableViewController alloc] init];
  _tableViewController.autoresizesForKeyboard = YES;
  _tableViewController.dataSource = _dataSource;
}

- (void)searchDisplayController:(UISearchDisplayController *)controller
        willUnloadSearchResultsTableView:(UITableView *)tableView {
  TT_RELEASE_MEMBER(_tableViewController);
}

- (void)searchDisplayController:(UISearchDisplayController *)controller
        didShowSearchResultsTableView:(UITableView *)tableView {
  _tableViewController.tableView = tableView;
  [_tableViewController viewWillAppear:NO];
  [_tableViewController viewDidAppear:NO];
}

- (void)searchDisplayController:(UISearchDisplayController*)controller
        willHideSearchResultsTableView:(UITableView*)tableView {
  [self searchDisplayControllerWillEndSearch:controller];
}

- (BOOL)searchDisplayController:(UISearchDisplayController*)controller
        shouldReloadTableForSearchString:(NSString*)searchString {
  if (_pausesBeforeSearching) {
    [self restartPauseTimer];
    if (_tableViewController.modelState & TTModelStateLoaded) {
      _tableViewController.modelState = TTModelStateLoaded | TTModelStateReloading;
    } else {
      _tableViewController.modelState = TTModelStateLoading;
    }
  } else {
    [_dataSource search:searchString];
  }
  return NO;
}

- (BOOL)searchDisplayController:(UISearchDisplayController*)controller
        shouldReloadTableForSearchScope:(NSInteger)searchOption {
  // XXXjoe Need a way to communicate scope change to the data source
  [_dataSource search:self.searchBar.text];
  return NO;
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
