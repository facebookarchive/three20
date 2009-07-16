#import "Three20/TTTableViewController.h"
#import "Three20/TTTableViewDataSources.h"
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
  if (!_tableView.delegate || [_tableView.delegate isKindOfClass:[TTTableViewDelegate class]]) {
    [_tableDelegate release];
    _tableDelegate = [[self createDelegate] retain];
    
    _tableView.delegate = nil;
    _tableView.delegate = _tableDelegate;
  }
}

- (void)reloadTableData {
  [self updateTableDelegate];
  [_tableView reloadData];
}

- (void)addSubviewOverTableView:(UIView*)view {
  NSInteger tableIndex = [_tableView.superview.subviews indexOfObject:_tableView];
  if (tableIndex != NSNotFound) {
    view.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    view.userInteractionEnabled = NO;
    [_tableView.superview insertSubview:view atIndex:tableIndex+1];
  }
}

- (CGRect)rectForOverlayView {
  CGRect frame = [_tableView frameWithKeyboardSubtracted];
  
  if (_tableView.tableHeaderView) {
    CGRect headerRect = _tableView.tableHeaderView.frame;
    if (headerRect.origin.y == 0) {
      frame.origin.y += headerRect.size.height;
      frame.size.height -= headerRect.size.height;
    }
  }
  
  NSArray* indexPaths = [_tableView indexPathsForVisibleRows];
  for (NSIndexPath* indexPath in indexPaths) {
    CGRect headerRect = [_tableView rectForHeaderInSection:indexPath.section];
    if (headerRect.origin.y == 0) {
      frame.origin.y += headerRect.size.height;
      frame.size.height -= headerRect.size.height;
    }
    break;
  }
  return frame;
}

- (CGRect)rectForBannerView {
  CGRect tableFrame = [_tableView frameWithKeyboardSubtracted];
  return CGRectMake(tableFrame.origin.x,
                    (tableFrame.origin.y + tableFrame.size.height) - kBannerViewHeight,
                    tableFrame.size.width, kBannerViewHeight);
}

- (void)showLoadingView {
  TTActivityLabel* label = [[[TTActivityLabel alloc] initWithStyle:TTActivityLabelStyleWhiteBox]
                              autorelease];
  label.text = [_dataSource titleForLoading:NO];
  label.backgroundColor = _tableView.backgroundColor;
  label.centeredToScreen = NO;
  self.tableOverlayView = label;
}

- (void)showReloadingView {
  TTActivityLabel* label = [[[TTActivityLabel alloc] initWithStyle:TTActivityLabelStyleBlackBox]
                              autorelease];
  label.text = [_dataSource titleForLoading:YES];
  label.font = [UIFont boldSystemFontOfSize:12];
  label.centeredToScreen = NO;
  self.tableBannerView = label;
}

- (void)showReloadingViewWithDelay {
  [_bannerTimer invalidate];
  _bannerTimer = [NSTimer scheduledTimerWithTimeInterval:0.3 target:self
                          selector:@selector(showReloadingView) userInfo:nil repeats:NO];
}

- (void)layoutOverlayView {
  if (_tableOverlayView) {
    _tableOverlayView.frame = [self rectForOverlayView];
  }
}

- (void)animateBannerViewToBottom {
  if (_tableBannerView) {
    CGRect frame = [self rectForBannerView];
    if (_tableBannerView.top != frame.origin.y) {
      [UIView beginAnimations:nil context:nil];
      [UIView setAnimationDuration:TT_TRANSITION_DURATION];
      [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
      _tableBannerView.frame = frame;
      [UIView commitAnimations];
    }
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

///////////////////////////////////////////////////////////////////////////////////////////////////
// NSObject

- (id)initWithStyle:(UITableViewStyle)style {
  if (self = [super init]) {
    _tableViewStyle = style;
  }
  return self;
}

- (id)init {
  if (self = [super init]) {
    _tableView = nil;
    _tableBannerView = nil;
    _tableOverlayView = nil;
    _dataSource = nil;
    _tableDelegate = nil;
    _bannerTimer = nil;
    _variableHeightRows = NO;
    _tableViewStyle = UITableViewStylePlain;
  }  
  return self;
}

- (void)dealloc {
  TT_RELEASE_MEMBER(_tableDelegate);
  TT_RELEASE_MEMBER(_dataSource);
  TT_RELEASE_MEMBER(_tableView);
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
  TT_RELEASE_MEMBER(_dataSource);
  TT_RELEASE_MEMBER(_tableView);
  [_tableBannerView removeFromSuperview];
  TT_RELEASE_MEMBER(_tableBannerView);
  [_tableOverlayView removeFromSuperview];
  TT_RELEASE_MEMBER(_tableOverlayView);
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

- (void)setSearchDataSource:(id<TTTableViewDataSource>)searchDataSource {
  [super setSearchDataSource:searchDataSource];
  if (!_searchController.searchResultsDelegate) {
    _searchController.searchResultsDelegate = [self createDelegate];
  }
}

- (void)keyboardWillAppear:(BOOL)animated {
  [self.tableView scrollFirstResponderIntoView];
  [self layoutOverlayView];
  [self animateBannerViewToBottom];
}

- (void)keyboardWillDisappear:(BOOL)animated {
  [self layoutOverlayView];
  [self animateBannerViewToBottom];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// TTModelViewController

- (void)modelDidChangeLoadingState {
  if (self.modelState & TTModelStateLoading) {
    [self showLoadingView];
  } else {
    self.tableOverlayView = nil;
  }
  if (self.modelState & TTModelStateReloading) {
    [self showReloadingViewWithDelay];
  } else {
    self.tableBannerView = nil;
  }
}

- (void)modelDidChangeLoadedState {
  if (self.modelState & TTModelStateLoaded) {
    if (_dataSource) {
      [_dataSource willAppearInTableView:_tableView];
      _tableView.dataSource = _dataSource;
    } else if ([self conformsToProtocol:@protocol(UITableViewDataSource)]) {
      _tableView.dataSource = (id<UITableViewDataSource>)self;
    } else {
      _tableView.dataSource = nil;
    }
    [self reloadTableData];
    
    self.tableOverlayView = nil;
  } else if (self.modelState & TTModelStateLoadedError) {
    NSString* title = [_dataSource titleForError:_modelError];
    NSString* subtitle = [_dataSource subtitleForError:_modelError];
    UIImage* image = [_dataSource imageForError:_modelError];
    self.tableOverlayView = [[[TTErrorView alloc] initWithTitle:title
                                                  subtitle:subtitle
                                                  image:image] autorelease];
    self.tableOverlayView.backgroundColor = _tableView.backgroundColor;
  } else if (!(self.modelState & TTModelLoadingStates)) {
    NSString* title = [_dataSource titleForNoData];
    NSString* subtitle = [_dataSource subtitleForNoData];
    UIImage* image = [_dataSource imageForNoData];
    self.tableOverlayView = [[[TTErrorView alloc] initWithTitle:title
                                                  subtitle:subtitle
                                                  image:image] autorelease];
    self.tableOverlayView.backgroundColor = _tableView.backgroundColor;
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

- (id<UITableViewDelegate>)createDelegate {
  if (_variableHeightRows) {
    return [[[TTTableViewVarHeightDelegate alloc] initWithController:self] autorelease];
  } else {
    return [[[TTTableViewDelegate alloc] initWithController:self] autorelease];
  }
}

- (void)didSelectObject:(id)object atIndexPath:(NSIndexPath*)indexPath {
}

- (BOOL)shouldOpenURL:(NSString*)URL {
  return YES;
}

- (void)didBeginDragging {
}

- (void)didEndDragging {
}

@end
