#import "Three20/TTViewController.h"
#import "Three20/TTTableViewDataSource.h"

@interface TTTableViewController : TTViewController
    <UITableViewDelegate, TTTableViewDataSourceDelegate> {
  UITableView* _tableView;
  id<TTTableViewDataSource> _dataSource;
  id<TTTableViewDataSource> _statusDataSource;
}

@property(nonatomic,retain) UITableView* tableView;
@property(nonatomic,retain) id<TTTableViewDataSource> dataSource;

- (id<TTTableViewDataSource>)createDataSource;

- (id<TTTableViewDataSource>)createDataSourceForStatus;

@end
