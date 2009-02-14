#import "Three20/T3TableViewController.h"
#import "Three20/T3DataSource.h"
#import "Three20/T3NavigationCenter.h"
#import "Three20/T3URLRequestQueue.h"
#import "Three20/T3TableField.h"
#import "Three20/T3TableFieldCell.h"
#import "Three20/T3ErrorView.h"

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation T3TableViewController

@synthesize tableView = _tableView, dataSource = _dataSource;

- (id)init {
  if (self = [super init]) {
    _tableView = nil;
    _dataSource = nil;

    [[NSNotificationCenter defaultCenter] addObserver:self
      selector:@selector(keyboardWillShow) name:@"UIKeyboardWillShowNotification" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
      selector:@selector(keyboardWillHide) name:@"UIKeyboardWillHideNotification" object:nil];
  }  
  return self;
}

- (void)dealloc {
  [[NSNotificationCenter defaultCenter] removeObserver:self
    name:@"UIKeyboardWillShowNotification" object:nil];
  [[NSNotificationCenter defaultCenter] removeObserver:self
    name:@"UIKeyboardWillHideNotification" object:nil];
    
  [_dataSource release];
  [super dealloc];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// UIViewController

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];

  [_tableView deselectRowAtIndexPath:[_tableView indexPathForSelectedRow] animated:YES];
}  

///////////////////////////////////////////////////////////////////////////////////////////////////
// T3ViewController

- (void)updateView {
  if (self.contentState == T3ContentReady) {
    [_tableView reloadData];
  }
  
  [super updateView];
}

- (void)unloadView {
  [_tableView release];
  _tableView = nil;
  [super unloadView];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// UITableViewDelegate

- (CGFloat)tableView:(UITableView*)aTableView heightForRowAtIndexPath:(NSIndexPath*)indexPath {
  id item = [_dataSource objectForRowAtIndexPath:indexPath];
  Class cls = [_dataSource cellClassForObject:item];
  return [cls rowHeightForItem:item tableView:_tableView];
}

- (void)tableView:(UITableView*)aTableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath {
  id item = [_dataSource objectForRowAtIndexPath:indexPath];
  if ([item isKindOfClass:[T3TableField class]]) {
    T3TableField* field = item;
    if (field.href) {
      [[T3NavigationCenter defaultCenter] displayURL:field.href];
    }
    if ([field isKindOfClass:[T3ButtonTableField class]]) {
      [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    } else if ([item isKindOfClass:[T3MoreButtonTableField class]]) {
      T3MoreButtonTableField* moreLink = (T3MoreButtonTableField*)item;
      moreLink.loading = YES;
      T3ActivityTableFieldCell* cell
        = (T3ActivityTableFieldCell*)[self.tableView cellForRowAtIndexPath:indexPath];
      cell.animating = YES;
      [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
      //[_dataSource loadMore];
    }
  }
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// UIScrollViewDelegate

- (BOOL)scrollViewWillScrollToTop:(UIScrollView *)scrollView {
  [T3URLRequestQueue mainQueue].suspended = YES;
  return YES;
}

- (void)scrollViewDidScrollToTop:(UIScrollView *)scrollView {
  [T3URLRequestQueue mainQueue].suspended = NO;
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
  [T3URLRequestQueue mainQueue].suspended = YES;
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
  if (!decelerate) {
    [T3URLRequestQueue mainQueue].suspended = NO;
  }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
  [T3URLRequestQueue mainQueue].suspended = NO;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// UIKeyboardNotifications

- (void)keyboardWillShow {
  if (self.appearing) {
    [self.view sizeToFitKeyboard:YES animated:YES];
  }
}

- (void)keyboardWillHide {
  if (self.appearing) {
    [self.view sizeToFitKeyboard:NO animated:YES];
  }
}

///////////////////////////////////////////////////////////////////////////////////////////////////

- (void)setDataSource:(T3DataSource*)dataSource {
  if (dataSource != _dataSource) {
    [_dataSource release];
    _dataSource = [dataSource retain];
    
    _tableView.dataSource = dataSource;
  }  
}

- (void)setTableView:(UITableView*)tableView {
  if (_tableView != tableView) {
    [_tableView release];
    _tableView = [tableView retain];

    if (_dataSource) {
      _tableView.dataSource = _dataSource;
    }
    
    if (!_tableView.delegate) {
      _tableView.delegate = self;
    }
  }
}

@end
