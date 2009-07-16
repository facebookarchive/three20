#import "Three20/TTGlobal.h"

@protocol TTTableViewDataSource;
@class TTTableViewController;

@interface TTSearchDisplayController : UISearchDisplayController <UISearchDisplayDelegate> {
  id<TTTableViewDataSource> _dataSource;
  id<UITableViewDelegate> _searchResultsDelegate2;
  TTTableViewController* _tableViewController;
}

@property(nonatomic,retain) id<TTTableViewDataSource> dataSource;

@end
