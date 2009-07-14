#import "Three20/TTTableViewController.h"
#import "Three20/TTTableViewDataSources.h"
#import "Three20/TTTableView.h"
#import "Three20/TTTableItem.h"
#import "Three20/TTTableItemCell.h"
#import "Three20/TTActivityLabel.h"
#import "Three20/TTTableViewDelegate.h"

///////////////////////////////////////////////////////////////////////////////////////////////////
// global

static const CGFloat kRefreshingViewHeight = 22;

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation TTTableViewController

@synthesize tableView = _tableView, dataSource = _dataSource, tableViewStyle = _tableViewStyle,
            variableHeightRows = _variableHeightRows;

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
  //NSDate* date = [NSDate date];
  [_tableView reloadData];
  //NSLog(@"TABLE LAYOUT %fs", [date timeIntervalSinceNow]);
}

- (void)refreshingHideAnimationStopped {
  [_refreshingView removeFromSuperview];
  TT_RELEASE_MEMBER(_refreshingView);
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
    _refreshingView = nil;
    _dataSource = nil;
    _statusDataSource = nil;
    _tableDelegate = nil;
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
  
  self.tableView = [[[TTTableView alloc] initWithFrame:self.view.bounds
                                         style:_tableViewStyle] autorelease];
	self.tableView.autoresizingMask =  UIViewAutoresizingFlexibleWidth
                                     | UIViewAutoresizingFlexibleHeight;
  [self.view addSubview:self.tableView];
}

- (void)viewDidUnload {
  [super viewDidUnload];
  [_dataSource.delegates removeObject:self];
  TT_RELEASE_MEMBER(_dataSource);
  TT_RELEASE_MEMBER(_statusDataSource);
  TT_RELEASE_MEMBER(_tableView);
  TT_RELEASE_MEMBER(_refreshingView);
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

- (void)reload {
  [_dataSource load:TTURLRequestCachePolicyNetwork nextPage:NO];
}

- (void)reloadIfNeeded {
  if (!_dataSource.isLoading && _dataSource.isOutdated) {
    [self reload];
  }
}

- (void)updateModel {
  self.dataSource = [self createDataSource];
}

- (void)modelDidChangeLoadingState {
  if (self.modelState & TTModelStateLoading) {
    NSString* title = [_dataSource titleForLoading:NO];
    TTTableStatusItem* statusItem = [TTTableActivityItem itemWithText:title];
    statusItem.sizeToFit = YES;

    _statusDataSource = [[TTListDataSource alloc] initWithItems:
      [NSArray arrayWithObject:statusItem]];
    _tableView.dataSource = _statusDataSource;
    [self reloadTableData];
  } else if (self.modelState & TTModelStateRefreshing) {
    if (!_refreshingView) {
      _refreshingView = [[TTActivityLabel alloc] initWithFrame:
        CGRectMake(0, _tableView.height + _tableView.top, self.view.width, kRefreshingViewHeight)
        style:TTActivityLabelStyleBlackBox text:[_dataSource titleForLoading:YES]];
      _refreshingView.centeredToScreen = NO;
      _refreshingView.userInteractionEnabled = NO;
      _refreshingView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
      _refreshingView.font = [UIFont boldSystemFontOfSize:12];
      
      NSInteger tableIndex = [self.view.subviews indexOfObject:_tableView];
      [self.view insertSubview:_refreshingView atIndex:tableIndex+1];
      
      [UIView beginAnimations:nil context:nil];
      [UIView setAnimationDuration:TT_TRANSITION_DURATION];
      [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
      _refreshingView.frame = CGRectOffset(_refreshingView.frame, 0, -kRefreshingViewHeight);
      [UIView commitAnimations];
    }
  } else if (_refreshingView) {
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:TT_TRANSITION_DURATION*2];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(refreshingHideAnimationStopped)];
    _refreshingView.alpha = 0;
    [UIView commitAnimations];
  }
}

- (void)modelDidChangeLoadedState {
  if (self.modelState & TTModelStateLoaded) {
    TT_RELEASE_MEMBER(_statusDataSource);

    if (_dataSource) {
      _tableView.dataSource = _dataSource;
    } else if ([self conformsToProtocol:@protocol(UITableViewDataSource)]) {
      _tableView.dataSource = (id<UITableViewDataSource>)self;
    } else {
      _tableView.dataSource = nil;
    }
  } else if (self.modelState & TTModelStateLoadedError) {
    NSString* title = [_dataSource titleForError:_modelError];
    NSString* subtitle = [_dataSource subtitleForError:_modelError];
    UIImage* image = [_dataSource imageForError:_modelError];
    
    TTTableErrorItem* statusItem = [TTTableErrorItem itemWithTitle:title subtitle:subtitle
                                                     image:image];
    statusItem.sizeToFit = YES;

    _statusDataSource = [[TTListDataSource alloc] initWithItems:
      [NSArray arrayWithObject:statusItem]];
    _tableView.dataSource = _statusDataSource;
  } else if (!(self.modelState & TTModelLoadingStates)) {
    NSString* title = [_dataSource titleForNoData];
    NSString* subtitle = [_dataSource subtitleForNoData];
    UIImage* image = [_dataSource imageForNoData];
    
    TTTableStatusItem* statusItem = [TTTableErrorItem itemWithTitle:title subtitle:subtitle
                                                      image:image];
    statusItem.sizeToFit = YES;

    _statusDataSource = [[TTListDataSource alloc] initWithItems:
      [NSArray arrayWithObject:statusItem]];
    _tableView.dataSource = _statusDataSource;
  }

  [self reloadTableData];
}

- (void)keyboardWillAppear:(BOOL)animated {
  [self.tableView scrollFirstResponderIntoView];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// TTTableViewDataSourceDelegate

- (void)dataSourceDidStartLoad:(id<TTTableViewDataSource>)dataSource {
  if (dataSource.isLoadingMore) {
    self.modelState = (_modelState & TTModelLoadedStates) | TTModelStateLoadingMore;
  } else if (_modelState & TTModelLoadedStates) {
    self.modelState = (_modelState & TTModelLoadedStates) | TTModelStateRefreshing;
  } else {
    self.modelState = TTModelStateLoading;
  }
}

- (void)dataSourceDidFinishLoad:(id<TTTableViewDataSource>)dataSource {
  if (dataSource.isEmpty) {
    self.modelState = TTModelStateEmpty;
  } else {
    self.modelState = TTModelStateLoaded;
  }
}

- (void)dataSource:(id<TTTableViewDataSource>)dataSource didFailLoadWithError:(NSError*)error {
  self.modelError = error;
  self.modelState = TTModelStateLoadedError;
}

- (void)dataSourceDidCancelLoad:(id<TTTableViewDataSource>)dataSource {
  self.modelError = nil;
  self.modelState = TTModelStateLoadedError;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// public

- (void)setDataSource:(id<TTTableViewDataSource>)dataSource {
  if (dataSource != _dataSource) {
    [_dataSource.delegates removeObject:self];
    [_dataSource release];
    _dataSource = [dataSource retain];
    [_dataSource.delegates addObject:self];
    
    [self invalidateView];
    
    if (!_dataSource.isLoaded) {
      [_dataSource load:TTURLRequestCachePolicyDefault nextPage:NO];
    } else {
      [_dataSource update];
      
      if (_dataSource.isLoading) {
        if (_dataSource.isLoadingMore) {
          self.modelState = (_modelState & TTModelLoadedStates) | TTModelStateLoadingMore;
        } else if (_dataSource.isLoaded) {
          self.modelState = (_modelState & TTModelLoadedStates) | TTModelStateRefreshing;
        } else {
          self.modelState = TTModelStateLoading;
        }
      } else {
        if (_modelError) {
          self.modelState = TTModelStateLoadedError;
        } else if (_dataSource.isEmpty) {
          self.modelState = TTModelStateEmpty;
        } else {
          self.modelState = TTModelStateLoaded;
        }
      }
    }
  }
}

- (id<TTTableViewDataSource>)createDataSource {
  return nil;
}

- (id<UITableViewDelegate>)createDelegate {
  if (_variableHeightRows || _statusDataSource) {
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

