#import "Three20/TTGlobal.h"

@protocol TTTableViewDataSource;
@class TTTableViewController;

@interface TTSearchDisplayController : UISearchDisplayController <UISearchDisplayDelegate> {
  id<UITableViewDelegate> _searchResultsDelegate2;
  TTTableViewController* _searchResultsViewController;
  NSTimer* _pauseTimer;
  BOOL _pausesBeforeSearching;
}

@property(nonatomic,retain) TTTableViewController* searchResultsViewController;
@property(nonatomic) BOOL pausesBeforeSearching;

@end
