#import "Three20/T3ViewController.h"

@protocol T3DataSource;

@interface T3TableViewController : T3ViewController <UITableViewDelegate> {
  UITableView* _tableView;
  id<T3DataSource> _dataSource;
}

@property(nonatomic,retain) UITableView* tableView;
@property(nonatomic,retain) id<T3DataSource> dataSource;

@end
