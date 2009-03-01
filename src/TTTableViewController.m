#import "Three20/TTTableViewController.h"
#import "Three20/TTTableViewDataSource.h"
#import "Three20/TTAppearance.h"
#import "Three20/TTNavigationCenter.h"
#import "Three20/TTURLRequestQueue.h"
#import "Three20/TTTableField.h"
#import "Three20/TTTableFieldCell.h"
#import "Three20/TTTableHeaderView.h"

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation TTTableViewController

@synthesize tableView = _tableView, dataSource = _dataSource;

- (id)init {
  if (self = [super init]) {
    _tableView = nil;
    _dataSource = nil;
    _statusDataSource = nil;
  }  
  return self;
}

- (void)dealloc {
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

- (void)persistView:(NSMutableDictionary*)state {
  CGFloat scrollY = _tableView.contentOffset.y;
  [state setObject:[NSNumber numberWithFloat:scrollY] forKey:@"scrollOffsetY"];
}

- (void)restoreView:(NSDictionary*)state {
  NSNumber* scrollY = [state objectForKey:@"scrollOffsetY"];
  _tableView.contentOffset = CGPointMake(0, scrollY.floatValue);
}

- (void)updateContent {
  self.dataSource = [self createDataSource];
  
  if (_dataSource.loading) {
    self.contentState = TTContentActivity;
  } else if (!_dataSource.loaded) {
    [_dataSource load:TTURLRequestCachePolicyDefault nextPage:NO];
  } else {
    if (_dataSource.empty) {
      self.contentState = TTContentNone;
    } else {
      self.contentState = TTContentReady;
    }
  }
}

- (void)refreshContent {
  if (!_dataSource.loading && _dataSource.outdated) {
    [self reloadContent];
  }
}

- (void)reloadContent {
  [_dataSource load:TTURLRequestCachePolicyNetwork nextPage:NO];
}

- (void)updateView {
  if (self.contentState & TTContentReady) {
    [_statusDataSource release];
    _statusDataSource = nil;

    if (_dataSource) {
      _tableView.dataSource = _dataSource;
    } else if ([self conformsToProtocol:@protocol(UITableViewDataSource)]) {
      _tableView.dataSource = (id<UITableViewDataSource>)self;
    } else {
      _tableView.dataSource = nil;
    }

    [_tableView reloadData];

    [super updateView];
  } else {
    [_statusView removeFromSuperview];
    [_statusView release];
    _statusView = nil;

    _statusDataSource = [[self createDataSourceForStatus] retain];
    _tableView.dataSource = _statusDataSource;
    [_tableView reloadData];
  }
}

- (void)unloadView {
  [_dataSource.delegates removeObject:self];
  [_dataSource release];
  _dataSource = nil;
  [_statusDataSource release];
  _statusDataSource = nil;
  [_tableView release];
  _tableView = nil;
  [super unloadView];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// UITableViewDelegate

- (CGFloat)tableView:(UITableView*)tableView heightForRowAtIndexPath:(NSIndexPath*)indexPath {
  id<TTTableViewDataSource> dataSource = _statusDataSource ? _statusDataSource : _dataSource;
  id item = [dataSource tableView:tableView objectForRowAtIndexPath:indexPath];
  Class cls = [dataSource tableView:tableView cellClassForObject:item];
  return [cls tableView:_tableView rowHeightForItem:item];
}

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
  id<TTTableViewDataSource> dataSource = _statusDataSource ? _statusDataSource : _dataSource;

  id item = [dataSource tableView:tableView objectForRowAtIndexPath:indexPath];
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
      
      
      [_dataSource load:TTURLRequestCachePolicyDefault nextPage:YES];
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
// TTTableViewDataSourceDelegate

- (void)dataSourceLoading:(id<TTTableViewDataSource>)dataSource {
  self.contentState |= TTContentActivity;
}

- (void)dataSourceLoaded:(id<TTTableViewDataSource>)dataSource {
  if (!dataSource.empty) {
    self.contentState = TTContentReady;
  } else {
    self.contentState = TTContentNone;
  }
}

- (void)dataSource:(id<TTTableViewDataSource>)dataSource didFailWithError:(NSError*)error {
  self.contentState &= ~TTContentActivity;
  self.contentState |= TTContentError;
  self.contentError = error;
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

- (void)setTableView:(UITableView*)tableView {
  if (_tableView != tableView) {
    [_tableView release];
    _tableView = [tableView retain];

    if (!_tableView.delegate) {
      _tableView.delegate = self;
    }
  }
}

- (id<TTTableViewDataSource>)createDataSource {
  return nil;
}

- (id<TTTableViewDataSource>)createDataSourceForStatus {
  TTStatusTableField* statusItem = nil;
  
  if (_contentState & TTContentActivity) {
    statusItem = [[[TTActivityTableField alloc] initWithText:[self titleForActivity]] autorelease];
  } else if (_contentState & TTContentError) {
    statusItem = [[[TTErrorTableField alloc] initWithText:[self titleForError:_contentError]
      subtitle:[self subtitleForError:_contentError]
      image:[self imageForError:_contentError]] autorelease];
  } else {
    statusItem = [[[TTErrorTableField alloc] initWithText:[self titleForNoContent]
      subtitle:[self subtitleForNoContent]
      image:[self imageForNoContent]] autorelease];
  }

  statusItem.sizeToFit = YES;
  return [[[TTListDataSource alloc] initWithItems:
    [NSArray arrayWithObject:statusItem]] autorelease];
}

@end
