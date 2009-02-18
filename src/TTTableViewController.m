#import "Three20/TTTableViewController.h"
#import "Three20/TTTableViewDataSource.h"
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
      selector:@selector(keyboardWillShow:) name:@"UIKeyboardWillShowNotification" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
      selector:@selector(keyboardWillHide:) name:@"UIKeyboardWillHideNotification" object:nil];
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

- (void)resizeForKeyboard:(NSNotification*)notification {
  NSValue* v1 = [notification.userInfo objectForKey:UIKeyboardBoundsUserInfoKey];
  CGRect keyboardBounds;
  [v1 getValue:&keyboardBounds];

  NSValue* v2 = [notification.userInfo objectForKey:UIKeyboardCenterBeginUserInfoKey];
  CGPoint keyboardStart;
  [v2 getValue:&keyboardStart];

  NSValue* v3 = [notification.userInfo objectForKey:UIKeyboardCenterEndUserInfoKey];
  CGPoint keyboardEnd;
  [v3 getValue:&keyboardEnd];
  
  CGFloat keyboardTop = keyboardEnd.y - floor(keyboardBounds.size.height/2);
  CGFloat screenBottom = self.view.screenY + self.view.height;
  if (screenBottom != keyboardTop) {
    BOOL animated = keyboardStart.y != keyboardEnd.y;
    if (animated) {
      [UIView beginAnimations:nil context:nil];
      [UIView setAnimationDuration:TT_TRANSITION_DURATION];
    }
    
    CGFloat dy = screenBottom - keyboardTop;
    self.view.frame = TTRectContract(self.view.frame, 0, dy);

    if (animated) {
      [UIView commitAnimations];
    }
  }
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

- (CGFloat)tableView:(UITableView*)tableView heightForRowAtIndexPath:(NSIndexPath*)indexPath {
  id item = [_dataSource tableView:tableView objectForRowAtIndexPath:indexPath];
  Class cls = [_dataSource tableView:tableView cellClassForObject:item];
  return [cls tableView:_tableView rowHeightForItem:item];
}

- (void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath {
  id item = [_dataSource tableView:tableView objectForRowAtIndexPath:indexPath];
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

- (void)keyboardWillShow:(NSNotification*)notification {
  if (self.appearing) {
    [self resizeForKeyboard:notification];
  }
}

- (void)keyboardWillHide:(NSNotification*)notification {
  if (self.appearing) {
    [self resizeForKeyboard:notification];
  }
}

///////////////////////////////////////////////////////////////////////////////////////////////////

- (void)setDataSource:(id<TTTableViewDataSource>)dataSource {
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
