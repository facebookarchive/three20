#import "Three20/T3ViewController.h"

@interface T3TableViewController : T3ViewController
    <UITableViewDelegate, UITableViewDataSource> {
  UITableView* _tableView;
}

@property(nonatomic,retain) UITableView* tableView;

@end
