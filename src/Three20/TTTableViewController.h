#import "Three20/TTViewController.h"
#import "Three20/TTTableViewDataSource.h"

@class TTActivityLabel;

@interface TTTableViewController : TTViewController <TTTableViewDataSourceDelegate> {
  UITableView* _tableView;
  TTActivityLabel* _refreshingView;
  id<TTTableViewDataSource> _dataSource;
  id<TTTableViewDataSource> _statusDataSource;
  id<UITableViewDelegate> _tableDelegate;
  UITableViewStyle _tableViewStyle;
  BOOL _variableHeightRows;
}

@property(nonatomic,retain) UITableView* tableView;
@property(nonatomic,retain) id<TTTableViewDataSource> dataSource;
@property(nonatomic) UITableViewStyle tableViewStyle;
@property(nonatomic) BOOL variableHeightRows;

- (id)initWithStyle:(UITableViewStyle)style;

- (id<TTTableViewDataSource>)createDataSource;
- (id<UITableViewDelegate>)createDelegate;

- (void)didSelectObject:(id)object atIndexPath:(NSIndexPath*)indexPath;

- (BOOL)shouldOpenURL:(NSString*)URL;

- (void)didBeginDragging;
- (void)didEndDragging;

@end
