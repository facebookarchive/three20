#import "Three20/TTTableViewController.h"
#import "Three20/TTDataSource.h"
#import "Three20/TTNavigationCenter.h"
#import "Three20/TTURLRequestQueue.h"
#import "Three20/TTTableField.h"
#import "Three20/TTTableFieldCell.h"
#import "Three20/TTErrorView.h"

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation TTTableViewController

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
// TTViewController

- (void)updateView {
  if (self.contentState == TTContentReady) {
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
  if ([item isKindOfClass:[TTTableField class]]) {
    TTTableField* field = item;
    if (field.href) {
      [[TTNavigationCenter defaultCenter] displayURL:field.href];
    }
    if ([field isKindOfClass:[TTButtonTableField class]]) {
      [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    } else if ([item isKindOfClass:[TTMoreButtonTableField class]]) {
      TTMoreButtonTableField* moreLink = (TTMoreButtonTableField*)item;
      moreLink.loading = YES;
      TTActivityTableFieldCell* cell
        = (TTActivityTableFieldCell*)[self.tableView cellForRowAtIndexPath:indexPath];
      cell.animating = YES;
      [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
      //[_dataSource loadMore];
    }
  }
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// UIScrollViewDelegate

- (BOOL)scrollViewWillScrollToTop:(UIScrollView *)scrollView {
  [TTURLRequestQueue mainQueue].suspended = YES;
  return YES;
}

- (void)scrollViewDidScrollToTop:(UIScrollView *)scrollView {
  [TTURLRequestQueue mainQueue].suspended = NO;
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
  [TTURLRequestQueue mainQueue].suspended = YES;
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
  if (!decelerate) {
    [TTURLRequestQueue mainQueue].suspended = NO;
  }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
  [TTURLRequestQueue mainQueue].suspended = NO;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// UIKeyboardNotifications

- (void)keyboardWillShow {
//  if (self.appearing) {
//    [self.view sizeToFitKeyboard:YES animated:YES];
//  }
}

- (void)keyboardWillHide {
//  if (self.appearing) {
//    [self.view sizeToFitKeyboard:NO animated:YES];
//  }
}

///////////////////////////////////////////////////////////////////////////////////////////////////

- (void)setDataSource:(id<TTDataSource>)dataSource {
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
