#import "Three20/TTTableViewController.h"
#import "Three20/TTListDataSource.h"
#import "Three20/TTTableView.h"
#import "Three20/TTTableItem.h"
#import "Three20/TTTableItemCell.h"
#import "Three20/TTActivityLabel.h"
#import "Three20/TTErrorView.h"
#import "Three20/TTTableViewDelegate.h"
#import "Three20/TTSearchDisplayController.h"
#import "Three20/TTDefaultStyleSheet.h"

///////////////////////////////////////////////////////////////////////////////////////////////////
// global

static const CGFloat kBannerViewHeight = 22;

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation TTTableViewController

@synthesize tableView = _tableView, tableBannerView = _tableBannerView,
            tableOverlayView = _tableOverlayView, dataSource = _dataSource,
            tableViewStyle = _tableViewStyle, variableHeightRows = _variableHeightRows;

///////////////////////////////////////////////////////////////////////////////////////////////////
// private

- (void)updateTableDelegate {
  if (!_tableView.delegate) {
    [_tableDelegate release];
    _tableDelegate = [[self createDelegate] retain];
    
    // You need to set it to nil before changing it or it won't have any effect
    _tableView.delegate = nil;
    _tableView.delegate = _tableDelegate;
  }
}

- (void)addSubviewOverTableView:(UIView*)view {
  NSInteger tableIndex = [_tableView.superview.subviews indexOfObject:_tableView];
  if (tableIndex != NSNotFound) {
    view.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [_tableView.superview insertSubview:view atIndex:tableIndex+1];
  }
}

- (void)showReloadingViewWithDelay {
  [_bannerTimer invalidate];
  _bannerTimer = [NSTimer scheduledTimerWithTimeInterval:0.3 target:self
                          selector:@selector(showBanner) userInfo:nil repeats:NO];
}

- (void)showBanner {
  _bannerTimer = nil;
  [self showReloadingView];
}

- (void)layoutOverlayView {
  if (_tableOverlayView) {
    _tableOverlayView.frame = [self rectForOverlayView];
  }
}

- (void)layoutBannerView {
  if (_tableBannerView) {
    _tableBannerView.frame = [self rectForBannerView];
  }
}

- (void)fadeOutView:(UIView*)view {
  [view retain];
  [UIView beginAnimations:nil context:view];
  [UIView setAnimationDuration:TT_TRANSITION_DURATION];
  [UIView setAnimationDelegate:self];
  [UIView setAnimationDidStopSelector:@selector(fadingOutViewDidStop:finished:context:)];
  view.alpha = 0;
  [UIView commitAnimations];
}

- (void)fadingOutViewDidStop:(NSString*)animationID finished:(NSNumber*)finished
        context:(void*)context {
  UIView* view = (UIView*)context;
  [view removeFromSuperview];
  [view release];
}

- (void)hideMenuAnimationDidStop:(NSString*)animationID finished:(NSNumber*)finished
        context:(void*)context {
  UIView* menuView = (UIView*)context;
  [menuView removeFromSuperview];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// NSObject

- (id)initWithStyle:(UITableViewStyle)style {
  if (self = [super init]) {
    _tableView = nil;
    _tableBannerView = nil;
    _tableOverlayView = nil;
    _menuView = nil;
    _menuCell = nil;
    _dataSource = nil;
    _tableDelegate = nil;
    _bannerTimer = nil;
    _variableHeightRows = NO;
    _tableViewStyle = style;
  }
  return self;
}

- (id)init {
  return [self initWithStyle:UITableViewStylePlain];
}

- (void)dealloc {
  TT_RELEASE_SAFELY(_tableDelegate);
  TT_RELEASE_SAFELY(_dataSource);
  TT_RELEASE_SAFELY(_tableView);
  [super dealloc];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// UIViewController

- (void)loadView {
  [super loadView];
  self.tableView;
}

- (void)viewDidUnload {
  [super viewDidUnload];
  TT_RELEASE_SAFELY(_dataSource);
  TT_RELEASE_SAFELY(_tableView);
  [_tableBannerView removeFromSuperview];
  TT_RELEASE_SAFELY(_tableBannerView);
  [_tableOverlayView removeFromSuperview];
  TT_RELEASE_SAFELY(_tableOverlayView);
  [_menuView removeFromSuperview];
  TT_RELEASE_SAFELY(_menuView);
  [_menuCell removeFromSuperview];
  TT_RELEASE_SAFELY(_menuCell);
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];

  [_tableView deselectRowAtIndexPath:[_tableView indexPathForSelectedRow] animated:NO];

  if ([_tableView isKindOfClass:[TTTableView class]]) {
    TTTableView* tableView = (TTTableView*)_tableView;
    tableView.highlightedLabel = nil;    
  }
}  

///////////////////////////////////////////////////////////////////////////////////////////////////
// UTViewController (TTCategory)

- (void)persistView:(NSMutableDictionary*)state {
  CGFloat scrollY = _tableView.contentOffset.y;
  [state setObject:[NSNumber numberWithFloat:scrollY] forKey:@"scrollOffsetY"];
}

- (void)restoreView:(NSDictionary*)state {
  NSNumber* scrollY = [state objectForKey:@"scrollOffsetY"];
  _tableView.contentOffset = CGPointMake(0, scrollY.floatValue);
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// TTViewController

- (void)keyboardDidAppear:(BOOL)animated withBounds:(CGRect)bounds {
  [super keyboardDidAppear:animated withBounds:bounds];
  self.tableView.frame = TTRectContract(self.tableView.frame, 0, bounds.size.height);
  [self.tableView scrollFirstResponderIntoView];
  [self layoutOverlayView];
  [self layoutBannerView];
}

- (void)keyboardWillDisappear:(BOOL)animated withBounds:(CGRect)bounds {
  [super keyboardWillDisappear:animated withBounds:bounds];
  self.tableView.frame = TTRectContract(self.tableView.frame, 0, -bounds.size.height);
  [self layoutOverlayView];
  [self layoutBannerView];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// TTModelViewController

- (BOOL)canShowModel {
  if ([_dataSource respondsToSelector:@selector(numberOfSectionsInTableView:)]) {
    NSInteger numberOfSections = [_dataSource numberOfSectionsInTableView:_tableView];
    if (!numberOfSections) {
      return NO;
    } else if (numberOfSections == 1) {
      return [_dataSource tableView:_tableView numberOfRowsInSection:0] > 0;
    } else {
      return YES;
    }
  } else {
    return [_dataSource tableView:_tableView numberOfRowsInSection:0] > 0;
  }
}

- (void)didLoadModel {
  [_dataSource tableViewDidLoadModel:_tableView];
}

- (void)beginUpdates {
  [super beginUpdates];
  [_tableView beginUpdates];
}

- (void)endUpdates {
  [super endUpdates];
  [_tableView beginUpdates];
}

- (void)showLoading:(BOOL)show {
  if (show) {
    if (!self.model.isLoaded) {
      [self showLoadingView];
    }
  } else {
    self.tableOverlayView = nil;
  }
//  if (self.modelState & TTModelStateReloading) {
//    [self showReloadingViewWithDelay];
//  } else {
//    self.tableBannerView = nil;
//  }
}

- (void)showModel:(BOOL)show {
  [self hideMenu:YES];
  if (show) {
    [self updateTableDelegate];
    _tableView.dataSource = _dataSource;
  } else {
    _tableView.dataSource = nil;
  }
  [_tableView reloadData];
}

- (void)showError:(BOOL)show {
  if (show) {
    [self showErrorView];
  } else {
    self.tableOverlayView = nil;
  }
}

- (void)showEmpty:(BOOL)show {
  if (show) {
    [self showEmptyView];
  } else {
    self.tableOverlayView = nil;
  }
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// TTModelDelegate

- (void)model:(id<TTModel>)model didInsertObject:(id)object atIndexPath:(NSIndexPath*)indexPath {
  if (model == _model) {
    if (_isViewAppearing) {
      if ([_dataSource respondsToSelector:@selector(tableView:willInsertObject:atIndexPath:)]) {
        NSIndexPath* newIndexPath = [_dataSource tableView:_tableView willInsertObject:object
                                                 atIndexPath:indexPath];
        TTLOG(@"FROM %@ TO %@", indexPath, newIndexPath);
        if (newIndexPath) {
          [_tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]
                      withRowAnimation:UITableViewRowAnimationTop];
        }
      }
    } else {
      [self invalidateView];
    }
  }
}

- (void)model:(id<TTModel>)model didDeleteObject:(id)object atIndexPath:(NSIndexPath*)indexPath {
  if (model == _model) {
    if (_isViewAppearing) {
      if ([_dataSource respondsToSelector:@selector(tableView:willRemoveObject:atIndexPath:)]) {
        NSIndexPath* newIndexPath = [_dataSource tableView:_tableView willRemoveObject:object
                                                 atIndexPath:indexPath];
        if (newIndexPath) {
          [_tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]
                      withRowAnimation:UITableViewRowAnimationTop];
        }
      }
    } else {
      [self invalidateView];
    }
  }
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// public

- (UITableView*)tableView {
  if (!_tableView) {
    _tableView = [[TTTableView alloc] initWithFrame:self.view.bounds style:_tableViewStyle];
    _tableView.autoresizingMask =  UIViewAutoresizingFlexibleWidth
                                   | UIViewAutoresizingFlexibleHeight;

    UIColor* backgroundColor = _tableViewStyle == UITableViewStyleGrouped
      ? TTSTYLEVAR(tableGroupedBackgroundColor)
      : TTSTYLEVAR(tablePlainBackgroundColor);
    if (backgroundColor) {
      _tableView.backgroundColor = backgroundColor;
    }
    [self.view addSubview:_tableView];
  }
  return _tableView;
}

- (void)setTableView:(UITableView*)tableView {
  if (tableView != _tableView) {
    [_tableView release];
    _tableView = [tableView retain];
    if (!_tableView) {
      self.tableBannerView = nil;
      self.tableOverlayView = nil;
    }
  }
}

- (void)setTableBannerView:(UIView*)tableBannerView {
  [self setTableBannerView:tableBannerView animated:YES];
}

- (void)setTableBannerView:(UIView*)tableBannerView animated:(BOOL)animated {
  TT_RELEASE_TIMER(_bannerTimer);
  if (tableBannerView != _tableBannerView) {
    if (_tableBannerView) {
      if (animated) {
        [self fadeOutView:_tableBannerView];
      } else {
        [_tableBannerView removeFromSuperview];
      }
    }
    
    [_tableBannerView release];
    _tableBannerView = [tableBannerView retain];
    
    if (_tableBannerView) {
      _tableBannerView.frame = [self rectForBannerView];
      _tableBannerView.userInteractionEnabled = NO;
      [self addSubviewOverTableView:_tableBannerView];

      if (animated) {
        _tableBannerView.top += kBannerViewHeight;
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:TT_TRANSITION_DURATION];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
        _tableBannerView.top -= kBannerViewHeight;
        [UIView commitAnimations];
      }
    }
  }
}

- (void)setTableOverlayView:(UIView*)tableOverlayView {
  [self setTableOverlayView:tableOverlayView animated:YES];
}

- (void)setTableOverlayView:(UIView*)tableOverlayView animated:(BOOL)animated {
  if (tableOverlayView != _tableOverlayView) {
    if (_tableOverlayView) {
      if (animated) {
        [self fadeOutView:_tableOverlayView];
      } else {
        [_tableOverlayView removeFromSuperview];
      }
    }

    [_tableOverlayView release];
    _tableOverlayView = [tableOverlayView retain];

    if (_tableOverlayView) {
      _tableOverlayView.frame = [self rectForOverlayView];
      [self addSubviewOverTableView:_tableOverlayView];
    }

    _tableView.scrollEnabled = !_tableOverlayView;
  }
}

- (void)setDataSource:(id<TTTableViewDataSource>)dataSource {
  if (dataSource != _dataSource) {
    [_dataSource release];
    _dataSource = [dataSource retain];
    _tableView.dataSource = nil;

    self.model = dataSource.model;
  }
}

- (void)setVariableHeightRows:(BOOL)variableHeightRows {
  if (variableHeightRows != _variableHeightRows) {
    _variableHeightRows = variableHeightRows;
    
    // Force the delegate to be re-created so that it supports the right kind of row measurement
    _tableView.delegate = nil;
  }
}

- (id<UITableViewDelegate>)createDelegate {
  if (_variableHeightRows) {
    return [[[TTTableViewVarHeightDelegate alloc] initWithController:self] autorelease];
  } else {
    return [[[TTTableViewDelegate alloc] initWithController:self] autorelease];
  }
}

- (void)showLoadingView {
  NSString* title = [_dataSource titleForLoading:NO];
  if (title.length) {
    TTActivityLabel* label = [[[TTActivityLabel alloc] initWithStyle:TTActivityLabelStyleWhiteBox]
                                autorelease];
    label.text = title;
    label.backgroundColor = _tableView.backgroundColor;
    label.centeredToScreen = NO;
    self.tableOverlayView = label;
  }
}

- (void)showReloadingView {
  NSString* title = [_dataSource titleForLoading:YES];
  if (title.length) {
    TTActivityLabel* label = [[[TTActivityLabel alloc] initWithStyle:TTActivityLabelStyleBlackBox]
                                autorelease];
    label.text = title;
    label.font = TTSTYLEVAR(tableBannerFont);
    label.centeredToScreen = NO;
    self.tableBannerView = label;
  }
}

- (void)showEmptyView {
  NSString* title = [_dataSource titleForEmpty];
  NSString* subtitle = [_dataSource subtitleForEmpty];
  UIImage* image = [_dataSource imageForEmpty];
  self.tableOverlayView = [[[TTErrorView alloc] initWithTitle:title
                                                subtitle:subtitle
                                                image:image] autorelease];
  self.tableOverlayView.backgroundColor = _tableView.backgroundColor;
}

- (void)showErrorView {
  NSString* title = [_dataSource titleForError:_modelError];
  NSString* subtitle = [_dataSource subtitleForError:_modelError];
  UIImage* image = [_dataSource imageForError:_modelError];
  self.tableOverlayView = [[[TTErrorView alloc] initWithTitle:title
                                                subtitle:subtitle
                                                image:image] autorelease];
  self.tableOverlayView.backgroundColor = _tableView.backgroundColor;
}

- (void)showMenu:(UIView*)view forCell:(UITableViewCell*)cell animated:(BOOL)animated {
  [self hideMenu:YES];

  _menuView = [view retain];
  _menuCell = [cell retain];
  
  // Insert the cell below all content subviews
  [_menuCell.contentView insertSubview:_menuView atIndex:0];

  if (animated) {
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:TT_FAST_TRANSITION_DURATION];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
  }

  // Move each content subview down, revealing the menu
  for (UIView* view in _menuCell.contentView.subviews) {
    if (view != _menuView) {
      view.left -= _menuCell.contentView.width;
    }
  }
  
  if (animated) {
    [UIView commitAnimations];
  }
}

- (void)hideMenu:(BOOL)animated {
  if (_menuView) {
    if (animated) {
      [UIView beginAnimations:nil context:_menuView];
      [UIView setAnimationDuration:TT_FAST_TRANSITION_DURATION];
      [UIView setAnimationDelegate:self];
      [UIView setAnimationDidStopSelector:@selector(hideMenuAnimationDidStop:finished:context:)];
    }

    for (UIView* view in _menuCell.contentView.subviews) {
      if (view != _menuView) {
        view.left += _menuCell.contentView.width;
      }
    }

    if (animated) {
      [UIView commitAnimations];
    } else {
      [_menuView removeFromSuperview];
    }

    TT_RELEASE_SAFELY(_menuView);
    TT_RELEASE_SAFELY(_menuCell);
  }
}

- (void)didSelectObject:(id)object atIndexPath:(NSIndexPath*)indexPath {
}

- (BOOL)shouldOpenURL:(NSString*)URL {
  return YES;
}

- (void)didBeginDragging {
  [self hideMenu:YES];
}

- (void)didEndDragging {
}

- (CGRect)rectForOverlayView {
  CGRect frame = [_tableView frameWithKeyboardSubtracted];
  
  if (_tableView.tableHeaderView) {
    CGRect headerRect = _tableView.tableHeaderView.frame;
    CGFloat diff = (headerRect.origin.y + headerRect.size.height) - _tableView.contentOffset.y;
    if (diff >= 0) {
      frame.origin.y += diff;
      frame.size.height -= diff;
    }
  }
  return frame;
}

- (CGRect)rectForBannerView {
  CGRect tableFrame = [_tableView frameWithKeyboardSubtracted];
  return CGRectMake(tableFrame.origin.x,
                    (tableFrame.origin.y + tableFrame.size.height) - kBannerViewHeight,
                    tableFrame.size.width, kBannerViewHeight);
}

@end
