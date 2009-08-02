#import "Three20/TTGlobal.h"

@protocol TTTableViewDataSource;
@class TTTableViewController;

#define TT_SEARCH_BAR_BACKGROUND_TAG 18942

/**
 * Shows search results using a TTTableViewController.
 *
 * This extends the standard search display controller so that you can search a Three20 model.
 * Searches that hit the internet and return asynchronously can provide feedback to the
 * about the status of the remote search using TTModel's loading interface, and
 * TTTableViewController's status views.
 */
@interface TTSearchDisplayController : UISearchDisplayController <UISearchDisplayDelegate> {
  id<UITableViewDelegate> _searchResultsDelegate2;
  TTTableViewController* _searchResultsViewController;
  NSTimer* _pauseTimer;
  BOOL _pausesBeforeSearching;
}

@property(nonatomic,retain) TTTableViewController* searchResultsViewController;
@property(nonatomic) BOOL pausesBeforeSearching;

@end
