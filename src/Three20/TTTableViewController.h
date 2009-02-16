#import "Three20/TTViewController.h"

@protocol TTDataSource;

@interface TTTableViewController : TTViewController <UITableViewDelegate> {
  UITableView* _tableView;
  id<TTDataSource> _dataSource;
}

@property(nonatomic,retain) UITableView* tableView;
@property(nonatomic,retain) id<TTDataSource> dataSource;

@end
