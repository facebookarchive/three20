#import "Three20/TTTableViewController.h"
#import "Three20/TTTableViewDataSource.h"
#import "Three20/TTAppearance.h"
#import "Three20/TTNavigationCenter.h"
#import "Three20/TTURLRequestQueue.h"
#import "Three20/TTTableField.h"
#import "Three20/TTTableFieldCell.h"
#import "Three20/TTTableHeaderView.h"
#import "Three20/TTActivityLabel.h"

///////////////////////////////////////////////////////////////////////////////////////////////////
// global

static const CGFloat kEmptyHeaderHeight = 1;
static const CGFloat kSectionHeaderHeight = 35;
static const CGFloat kRefreshingViewHeight = 22;

///////////////////////////////////////////////////////////////////////////////////////////////////

@interface TTTableViewDelegate : NSObject <UITableViewDelegate> {
  TTTableViewController* _controller;
}

- (id)initWithController:(TTTableViewController*)controller;

@end

@implementation TTTableViewDelegate

///////////////////////////////////////////////////////////////////////////////////////////////////
// NSObject

- (id)initWithController:(TTTableViewController*)controller {
  if (self = [super init]) {
    _controller = controller;
  }
  return self;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// UITableViewDelegate

- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
  if (tableView.style == UITableViewStylePlain && [TTAppearance appearance].tableHeaderTintColor) {
    if ([tableView.dataSource respondsToSelector:@selector(tableView:titleForHeaderInSection:)]) {
      NSString* title = [tableView.dataSource tableView:tableView titleForHeaderInSection:section];
      if (title.length) {
        return [[[TTTableHeaderView alloc] initWithTitle:title] autorelease];
      }
    }
  }
  return nil;
}

- (void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath {
  id<TTTableViewDataSource> dataSource = (id<TTTableViewDataSource>)tableView.dataSource;

  id object = [dataSource tableView:tableView objectForRowAtIndexPath:indexPath];
  if ([object isKindOfClass:[TTTableField class]]) {
    TTTableField* field = object;
    if (field.url) {
      [[TTNavigationCenter defaultCenter] displayURL:field.url];
    }

    if ([field isKindOfClass:[TTButtonTableField class]]) {
      [tableView deselectRowAtIndexPath:indexPath animated:YES];
    } else if ([object isKindOfClass:[TTMoreButtonTableField class]]) {
      TTMoreButtonTableField* moreLink = (TTMoreButtonTableField*)object;
      moreLink.isLoading = YES;
      TTMoreButtonTableFieldCell* cell
        = (TTMoreButtonTableFieldCell*)[tableView cellForRowAtIndexPath:indexPath];
      cell.animating = YES;
      [tableView deselectRowAtIndexPath:indexPath animated:YES];
      
      [dataSource load:TTURLRequestCachePolicyDefault nextPage:YES];
    }
  }

  [_controller didSelectObject:object atIndexPath:indexPath];
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

@end

///////////////////////////////////////////////////////////////////////////////////////////////////

@interface TTTableViewVarHeightDelegate : TTTableViewDelegate
@end

@implementation TTTableViewVarHeightDelegate

///////////////////////////////////////////////////////////////////////////////////////////////////
// UITableViewDelegate

- (CGFloat)tableView:(UITableView*)tableView heightForRowAtIndexPath:(NSIndexPath*)indexPath {
  id<TTTableViewDataSource> dataSource = (id<TTTableViewDataSource>)tableView.dataSource;

  id object = [dataSource tableView:tableView objectForRowAtIndexPath:indexPath];
  Class cls = [dataSource tableView:tableView cellClassForObject:object];
  return [cls tableView:tableView rowHeightForItem:object];
}

@end

///////////////////////////////////////////////////////////////////////////////////////////////////

@interface TTTableViewPlainDelegate : TTTableViewDelegate
@end

@implementation TTTableViewPlainDelegate

///////////////////////////////////////////////////////////////////////////////////////////////////
// UITableViewDelegate

- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
  NSString* title = [tableView.dataSource tableView:tableView titleForHeaderInSection:section];
  if (!title.length)
    return nil;

  return [[[TTTableHeaderView alloc] initWithTitle:title] autorelease];
}

@end

///////////////////////////////////////////////////////////////////////////////////////////////////

@interface TTTableViewPlainVarHeightDelegate : TTTableViewVarHeightDelegate
@end

@implementation TTTableViewPlainVarHeightDelegate

///////////////////////////////////////////////////////////////////////////////////////////////////
// UITableViewDelegate

- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
  NSString* title = [tableView.dataSource tableView:tableView titleForHeaderInSection:section];
  if (!title.length)
    return nil;

  return [[[TTTableHeaderView alloc] initWithTitle:title] autorelease];
}

@end

///////////////////////////////////////////////////////////////////////////////////////////////////

@interface TTTableViewGroupedVarHeightDelegate : TTTableViewVarHeightDelegate
@end

@implementation TTTableViewGroupedVarHeightDelegate

///////////////////////////////////////////////////////////////////////////////////////////////////
// UITableViewDelegate

- (CGFloat)tableView:(UITableView*)tableView heightForHeaderInSection:(NSInteger)section {
  NSString* title = [tableView.dataSource tableView:tableView titleForHeaderInSection:section];
  if (!title.length) {
    return kEmptyHeaderHeight;
  } else {
    return kSectionHeaderHeight;
  }
}

@end

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation TTTableViewController

@synthesize tableView = _tableView, dataSource = _dataSource,
            variableHeightRows = _variableHeightRows;

///////////////////////////////////////////////////////////////////////////////////////////////////
// private

- (void)updateTableDelegate {
  if (!_tableView.delegate || [_tableView.delegate isKindOfClass:[TTTableViewDelegate class]]) {
    [_tableDelegate release];
    if (_variableHeightRows || _statusDataSource) {
      _tableDelegate = [[TTTableViewVarHeightDelegate alloc] initWithController:self];
    } else {
      _tableDelegate = [[TTTableViewDelegate alloc] initWithController:self];
    }
    _tableView.delegate = nil;
    _tableView.delegate = _tableDelegate;
  }
}

- (void)reloadTableData {
  [self updateTableDelegate];
  [_tableView reloadData];
}

- (void)refreshingHideAnimationStopped {
  [_refreshingView removeFromSuperview];
  [_refreshingView release];
  _refreshingView = nil;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// NSObject

- (id)init {
  if (self = [super init]) {
    _tableView = nil;
    _refreshingView = nil;
    _dataSource = nil;
    _statusDataSource = nil;
    _tableDelegate = nil;
    _variableHeightRows = NO;
  }  
  return self;
}

- (void)dealloc {
  [_tableDelegate release];
  [super dealloc];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// UIViewController

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];

  [_tableView deselectRowAtIndexPath:[_tableView indexPathForSelectedRow] animated:NO];
}  

///////////////////////////////////////////////////////////////////////////////////////////////////
// TTViewController

- (void)persistView:(NSMutableDictionary*)state {
  CGFloat scrollY = _tableView.contentOffset.y;
  [state setObject:[NSNumber numberWithFloat:scrollY] forKey:@"scrollOffsetY"];
}

- (void)restoreView:(NSDictionary*)state {
  NSNumber* scrollY = [state objectForKey:@"scrollOffsetY"];
  _tableView.contentOffset = CGPointMake(0, scrollY.floatValue);
}

- (void)reloadContent {
  [_dataSource load:TTURLRequestCachePolicyNetwork nextPage:NO];
}

- (void)refreshContent {
  if (!_dataSource.isLoading && _dataSource.isOutdated) {
    [self reloadContent];
  }
}

- (void)updateView {
  self.dataSource = [self createDataSource];
  
  if (_dataSource.isLoading) {
    if (_dataSource.isLoadingMore) {
      [self invalidateViewState:(_viewState & TTViewDataStates) | TTViewLoadingMore];
    } else if (_dataSource.isLoaded) {
      [self invalidateViewState:(_viewState & TTViewDataStates) | TTViewRefreshing];
    } else {
      [self invalidateViewState:TTViewLoading];
    }
  } else if (!_dataSource.isLoaded) {
    [_dataSource load:TTURLRequestCachePolicyDefault nextPage:NO];
  } else {
    if (_contentError) {
      [self invalidateViewState:TTViewDataLoadedError];
    } else if (_dataSource.isEmpty) {
      [self invalidateViewState:TTViewEmpty];
    } else {
      [self invalidateViewState:TTViewDataLoaded];
    }
  }
}

- (void)updateLoadingView {
  if (self.viewState & TTViewLoading) {
    NSString* title = [self titleForActivity];
    TTStatusTableField* statusItem = [[[TTActivityTableField alloc] initWithText:title]
      autorelease];
    statusItem.sizeToFit = YES;

    _statusDataSource = [[TTListDataSource alloc] initWithItems:
      [NSArray arrayWithObject:statusItem]];
    _tableView.dataSource = _statusDataSource;
    [self reloadTableData];
  }
  
  if (self.viewState & TTViewRefreshing) {
    [_refreshingView removeFromSuperview];
    [_refreshingView release];

    _refreshingView = [[TTActivityLabel alloc] initWithFrame:
      CGRectMake(0, _tableView.height, self.view.width, kRefreshingViewHeight)
      style:TTActivityLabelStyleBlackBox text:[self titleForActivity]];
    _refreshingView.centeredToScreen = NO;
    _refreshingView.userInteractionEnabled = NO;
    _refreshingView.font = [UIFont boldSystemFontOfSize:12];
    
    NSInteger tableIndex = [self.view.subviews indexOfObject:_tableView];
    [self.view insertSubview:_refreshingView atIndex:tableIndex+1];
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:TT_TRANSITION_DURATION];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
    _refreshingView.frame = CGRectOffset(_refreshingView.frame, 0, -kRefreshingViewHeight);
    [UIView commitAnimations];
  } else if (_refreshingView) {
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:TT_TRANSITION_DURATION*2];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(refreshingHideAnimationStopped)];
    _refreshingView.alpha = 0;
    [UIView commitAnimations];
  }
}

- (void)updateDataView {
  if (self.viewState & TTViewDataLoaded) {
    [_statusDataSource release];
    _statusDataSource = nil;

    if (_dataSource) {
      _tableView.dataSource = _dataSource;
    } else if ([self conformsToProtocol:@protocol(UITableViewDataSource)]) {
      _tableView.dataSource = (id<UITableViewDataSource>)self;
    } else {
      _tableView.dataSource = nil;
    }
  } else if (self.viewState & TTViewDataLoadedError) {
    NSString* title = [self titleForError:_contentError];
    NSString* subtitle = [self subtitleForError:_contentError];
    UIImage* image = [self imageForError:_contentError];
    
    TTStatusTableField* statusItem = [[[TTErrorTableField alloc] initWithText:title
      subtitle:subtitle image:image] autorelease];
    statusItem.sizeToFit = YES;

    _statusDataSource = [[TTListDataSource alloc] initWithItems:
      [NSArray arrayWithObject:statusItem]];
    _tableView.dataSource = _statusDataSource;
  } else if (!(self.viewState & TTViewLoadingStates)) {
    NSString* title = [self titleForNoData];
    NSString* subtitle = [self subtitleForNoData];
    UIImage* image = [self imageForNoData];
    
    TTStatusTableField* statusItem = [[[TTErrorTableField alloc] initWithText:title
      subtitle:subtitle image:image] autorelease];
    statusItem.sizeToFit = YES;

    _statusDataSource = [[TTListDataSource alloc] initWithItems:
      [NSArray arrayWithObject:statusItem]];
    _tableView.dataSource = _statusDataSource;
  }

  [self reloadTableData];
}

- (void)unloadView {
  [_dataSource.delegates removeObject:self];
  [_dataSource release];
  _dataSource = nil;
  [_statusDataSource release];
  _statusDataSource = nil;
  [_tableView release];
  _tableView = nil;
  [_refreshingView release];
  _refreshingView = nil;
  [super unloadView];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// TTTableViewDataSourceDelegate

- (void)dataSourceDidStartLoad:(id<TTTableViewDataSource>)dataSource {
  if (dataSource.isLoadingMore) {
    [self invalidateViewState:(_viewState & TTViewDataStates) | TTViewLoadingMore];
  } else if (_viewState & TTViewDataStates) {
    [self invalidateViewState:(_viewState & TTViewDataStates) | TTViewRefreshing];
  } else {
    [self invalidateViewState:TTViewLoading];
  }
}

- (void)dataSourceDidFinishLoad:(id<TTTableViewDataSource>)dataSource {
  if (dataSource.isEmpty) {
    [self invalidateViewState:TTViewEmpty];
  } else {
    [self invalidateViewState:TTViewDataLoaded];
  }
}

- (void)dataSource:(id<TTTableViewDataSource>)dataSource didFailLoadWithError:(NSError*)error {
  self.contentError = error;
  [self invalidateViewState:TTViewDataLoadedError];
}

- (void)dataSourceDidCancelLoad:(id<TTTableViewDataSource>)dataSource {
  [self invalidateViewState:TTViewDataLoadedError];
}

///////////////////////////////////////////////////////////////////////////////////////////////////

- (void)setDataSource:(id<TTTableViewDataSource>)dataSource {
  if (dataSource != _dataSource) {
    [_dataSource.delegates removeObject:self];
    [_dataSource release];
    _dataSource = [dataSource retain];
    [_dataSource.delegates addObject:self];
  }
}

- (id<TTTableViewDataSource>)createDataSource {
  return nil;
}

- (void)didSelectObject:(id)object atIndexPath:(NSIndexPath*)indexPath {
}

@end
