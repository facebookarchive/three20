#import "Three20/T3ViewController.h"

@class T3DataSource;

@interface T3TableViewController : T3ViewController
    <UITableViewDelegate, UITableViewDataSource> {
  UITableView* _tableView;
  T3DataSource* _dataSource;
}

@property(nonatomic,retain) UITableView* tableView;
@property(nonatomic,retain) T3DataSource* dataSource;

@end
