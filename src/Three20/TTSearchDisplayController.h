#import "Three20/TTGlobal.h"

@protocol TTTableViewDataSource;
@class TTTableViewController;

@interface TTSearchDisplayController : UISearchDisplayController <UISearchDisplayDelegate> {
  id<TTTableViewDataSource> _dataSource;
  id<UITableViewDelegate> _searchResultsDelegate2;
  TTTableViewController* _tableViewController;
  NSTimer* _pauseTimer;
  BOOL _pausesBeforeSearching;
}

@property(nonatomic,retain) id<TTTableViewDataSource> dataSource;
@property(nonatomic) BOOL pausesBeforeSearching;

@end
