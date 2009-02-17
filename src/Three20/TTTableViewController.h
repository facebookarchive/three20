#import "Three20/TTViewController.h"

@protocol TTTableViewDataSource;

@interface TTTableViewController : TTViewController <UITableViewDelegate> {
  UITableView* _tableView;
  id<TTTableViewDataSource> _dataSource;
}

@property(nonatomic,retain) UITableView* tableView;
@property(nonatomic,retain) id<TTTableViewDataSource> dataSource;

@end
