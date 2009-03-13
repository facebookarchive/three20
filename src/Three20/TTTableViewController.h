#import "Three20/TTViewController.h"
#import "Three20/TTTableViewDataSource.h"

@class TTActivityLabel;

@interface TTTableViewController : TTViewController <TTTableViewDataSourceDelegate> {
  UITableView* _tableView;
  TTActivityLabel* _refreshingView;
  id<TTTableViewDataSource> _dataSource;
  id<TTTableViewDataSource> _statusDataSource;
  id<UITableViewDelegate> _tableDelegate;
  BOOL _variableHeightRows;
}

@property(nonatomic,retain) UITableView* tableView;
@property(nonatomic,retain) id<TTTableViewDataSource> dataSource;
@property(nonatomic) BOOL variableHeightRows;

- (id<TTTableViewDataSource>)createDataSource;

- (void)didSelectObject:(id)object atIndexPath:(NSIndexPath*)indexPath;

@end
