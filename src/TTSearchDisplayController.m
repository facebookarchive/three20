#import "Three20/TTSearchDisplayController.h"
#import "Three20/TTTableViewController.h"
#import "Three20/TTTableViewDataSource.h"

///////////////////////////////////////////////////////////////////////////////////////////////////
// global

static const NSTimeInterval kPauseInterval = 0.4;

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation TTSearchDisplayController

@synthesize searchResultsViewController = _searchResultsViewController,
            pausesBeforeSearching = _pausesBeforeSearching;

///////////////////////////////////////////////////////////////////////////////////////////////////
// private

- (void)resetResults {
  if (_searchResultsViewController.model.isLoading) {
    [_searchResultsViewController.model cancel];
  }
  [_searchResultsViewController.dataSource search:nil];
  [_searchResultsViewController viewWillDisappear:NO];
  [_searchResultsViewController viewDidDisappear:NO];
  _searchResultsViewController.tableView = nil;
}

- (void)restartPauseTimer {
  TT_INVALIDATE_TIMER(_pauseTimer);
  _pauseTimer = [NSTimer scheduledTimerWithTimeInterval:kPauseInterval target:self
                         selector:@selector(searchAfterPause) userInfo:nil repeats:NO];
}

- (void)searchAfterPause {
  _pauseTimer = nil;
  [_searchResultsViewController.dataSource search:self.searchBar.text];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// NSObject

- (id)initWithSearchBar:(UISearchBar*)searchBar contentsController:(UIViewController*)controller {
  if (self = [super initWithSearchBar:searchBar contentsController:controller]) {
    _searchResultsDelegate2 = nil;
    _searchResultsViewController = nil;
    _pauseTimer = nil;
    _pausesBeforeSearching = NO;
    
    self.delegate = self;
  }
  return self;
}

- (void)dealloc {
  TT_INVALIDATE_TIMER(_pauseTimer);
  TT_RELEASE_SAFELY(_searchResultsDelegate2);
  TT_RELEASE_SAFELY(_searchResultsViewController);
  [super dealloc];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// UISearchDisplayDelegate

- (void)searchDisplayControllerWillBeginSearch:(UISearchDisplayController*)controller {
  UIView* backgroundView = [self.searchBar viewWithTag:TT_SEARCH_BAR_BACKGROUND_TAG];
  if (backgroundView) {
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:TT_FAST_TRANSITION_DURATION];
    backgroundView.alpha = 0;
    [UIView commitAnimations];
  }
  if (!self.searchContentsController.navigationController) {
    [UIView beginAnimations:nil context:nil];
    self.searchBar.superview.top -= self.searchBar.screenY - TTStatusHeight();
    [UIView commitAnimations];
  }
}

- (void)searchDisplayControllerDidBeginSearch:(UISearchDisplayController*)controller {
  [_searchResultsViewController updateView];
}

- (void)searchDisplayControllerWillEndSearch:(UISearchDisplayController*)controller {
  UIView* backgroundView = [self.searchBar viewWithTag:TT_SEARCH_BAR_BACKGROUND_TAG];
  if (backgroundView) {
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:TT_FAST_TRANSITION_DURATION];
    backgroundView.alpha = 1;
    [UIView commitAnimations];
  }

  if (!self.searchContentsController.navigationController) {
    [UIView beginAnimations:nil context:nil];
    self.searchBar.superview.top += self.searchBar.top - TTStatusHeight();
    [UIView commitAnimations];
  }
}
 
- (void)searchDisplayControllerDidEndSearch:(UISearchDisplayController*)controller {
  [self resetResults];
}

- (void)searchDisplayController:(UISearchDisplayController *)controller
        didLoadSearchResultsTableView:(UITableView *)tableView {
}
 
- (void)searchDisplayController:(UISearchDisplayController *)controller
        willUnloadSearchResultsTableView:(UITableView *)tableView {
}

- (void)searchDisplayController:(UISearchDisplayController *)controller
        didShowSearchResultsTableView:(UITableView *)tableView {
  _searchResultsViewController.tableView = tableView;
  [_searchResultsViewController viewWillAppear:NO];
  [_searchResultsViewController viewDidAppear:NO];
}

- (void)searchDisplayController:(UISearchDisplayController*)controller
        willHideSearchResultsTableView:(UITableView*)tableView {
  [self resetResults];
}

- (BOOL)searchDisplayController:(UISearchDisplayController*)controller
        shouldReloadTableForSearchString:(NSString*)searchString {
  if (_pausesBeforeSearching) {
    [self restartPauseTimer];
  } else {
    [_searchResultsViewController.dataSource search:searchString];
  }
  return NO;
}

- (BOOL)searchDisplayController:(UISearchDisplayController*)controller
        shouldReloadTableForSearchScope:(NSInteger)searchOption {
  [_searchResultsViewController invalidateModel];
  [_searchResultsViewController.dataSource search:self.searchBar.text];
  return NO;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// public

- (void)setSearchResultsDelegate:(id<UITableViewDelegate>)searchResultsDelegate {
  [super setSearchResultsDelegate:searchResultsDelegate];
  if (_searchResultsDelegate2 != searchResultsDelegate) {
    [_searchResultsDelegate2 release];
    _searchResultsDelegate2 = [searchResultsDelegate retain];
  }
}

@end
