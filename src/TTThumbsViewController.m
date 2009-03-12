#import "Three20/TTThumbsViewController.h"
#import "Three20/TTPhotoViewController.h"
#import "Three20/TTURLRequest.h"
#import "Three20/TTUnclippedView.h"
#import "Three20/TTErrorView.h"
#import "Three20/TTTableFieldCell.h"
#import "Three20/TTTableField.h"
#import "Three20/TTURLCache.h"

///////////////////////////////////////////////////////////////////////////////////////////////////

static NSInteger kColumnCount = 4;
static CGFloat kThumbnailRowHeight = 79;

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation TTThumbsViewController

@synthesize delegate = _delegate, photoSource = _photoSource;

- (id)init {
  if (self = [super init]) {
    _delegate = nil;
    _photoSource = nil;
    
    self.hidesBottomBarWhenPushed = YES;
  }
  
  return self;
}

- (void)dealloc {
  [_photoSource.delegates removeObject:self];
  [_photoSource release];
  [super dealloc];
}

///////////////////////////////////////////////////////////////////////////////////////////////////

- (void)loadPhotosFromIndex:(NSUInteger)fromIndex toIndex:(NSUInteger)toIndex
    forceReload:(BOOL)forceReload {
  [_photoSource loadPhotosFromIndex:fromIndex toIndex:toIndex
    cachePolicy:forceReload ? TTURLRequestCachePolicyNetwork : TTURLRequestCachePolicyDefault];
}

- (void)suspendLoadingThumbnails:(BOOL)suspended {
  if (_photoSource.maxPhotoIndex >= 0) {
    NSArray* cells = _tableView.visibleCells;
    for (int i = 0; i < cells.count; ++i) {
      TTThumbsTableViewCell* cell = [cells objectAtIndex:i];
      if ([cell isKindOfClass:[TTThumbsTableViewCell class]]) {
        [cell suspendLoading:suspended];
      }
    }
  }
}

- (BOOL)outdated {
  NSDate* loadedTime = _photoSource.loadedTime;
  if (loadedTime) {
    return -[loadedTime timeIntervalSinceNow] > [TTURLCache sharedCache].invalidationAge;
  } else {
    return NO;
  }
}

- (BOOL)hasMoreToLoad {
  return _photoSource.maxPhotoIndex+1 < _photoSource.numberOfPhotos;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// UIViewController

- (void)loadView {
  self.view = [[[TTUnclippedView alloc] initWithFrame:TTApplicationFrame()] autorelease];
  self.view.backgroundColor = [UIColor whiteColor];
  self.view.autoresizesSubviews = YES;
	self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
  
  self.tableView = [[[UITableView alloc] initWithFrame:TTNavigationFrame()
                                         style:UITableViewStylePlain] autorelease];
  self.tableView.dataSource = self;
  self.tableView.rowHeight = kThumbnailRowHeight;
	self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth
    | UIViewAutoresizingFlexibleHeight;
  self.tableView.backgroundColor = [UIColor whiteColor];
  self.tableView.separatorColor = [UIColor whiteColor];
  self.tableView.contentInset = UIEdgeInsetsMake(4, 0, 0, 0);
  self.tableView.clipsToBounds = NO;
  [self.view addSubview:self.tableView];
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  [self changeNavigationBarStyle:UIBarStyleBlackTranslucent barColor:nil
    statusBarStyle:UIStatusBarStyleBlackTranslucent];
}

- (void)viewDidAppear:(BOOL)animated {
  [super viewDidAppear:animated];
  [self suspendLoadingThumbnails:NO];

  if (!self.nextViewController) {
    self.view.superview.frame = CGRectOffset(self.view.superview.frame, 0, TOOLBAR_HEIGHT);
  }
}

- (void)viewWillDisappear:(BOOL)animated {
  [super viewWillDisappear:animated];

  self.view.superview.frame = CGRectOffset(self.view.superview.frame, 0, TOOLBAR_HEIGHT);
  
  [self restoreNavigationBarStyle];
}  

- (void)viewDidDisappear:(BOOL)animated {
  [self suspendLoadingThumbnails:YES];
  [super viewDidDisappear:animated];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// TTViewController

- (id<TTPersistable>)viewObject {
  return _photoSource;
}

- (void)showObject:(id)object inView:(NSString*)viewType withState:(NSDictionary*)state {
  [super showObject:object inView:viewType withState:state];

  self.photoSource = (id<TTPhotoSource>)object;
}

- (void)reloadContent {
  [self loadPhotosFromIndex:0 toIndex:TT_INFINITE_PHOTO_INDEX forceReload:YES];
}

- (void)refreshContent {
  if (!_photoSource.loading && self.outdated) {
    [self reloadContent];
  }
}

- (void)updateView {
  if (_photoSource.loading) {
    if (_photoSource.loadingMore) {
      [self invalidateViewState:(_viewState & TTViewDataStates) | TTViewLoadingMore];
    } else if (_photoSource.loaded) {
      [self invalidateViewState:(_viewState & TTViewDataStates) | TTViewRefreshing];
    } else {
      [self invalidateViewState:TTViewLoading];
    }
  } else if (!_photoSource.loaded) {
    [self loadPhotosFromIndex:0 toIndex:TT_INFINITE_PHOTO_INDEX forceReload:NO];
  } else {
    if (_contentError) {
      [self invalidateViewState:TTViewDataLoadedError];
    } else if (!_photoSource.numberOfPhotos) {
      [self invalidateViewState:TTViewDataLoadedNothing];
    } else {
      [self invalidateViewState:TTViewDataLoaded];
    }
  }
}

- (UIImage*)imageForNoData {
  return [UIImage imageNamed:@"Three20.bundle/images/photoDefault.png"];
}

- (NSString*)titleForNoData {
  return TTLocalizedString(@"No Photos", @"");
}

- (NSString*)subtitleForNoData {
  return TTLocalizedString(@"This photo set contains no photos.", @"");
}

- (UIImage*)imageForError:(NSError*)error {
  return [UIImage imageNamed:@"Three20.bundle/images/photoDefault.png"];
}

- (NSString*)titleForError:(NSError*)error {
  return TTLocalizedString(@"Error", @"");
}

- (NSString*)subtitleForError:(NSError*)error {
  return TTLocalizedString(@"This photo set could not be loaded.", @"");
}

//////////////////////////////////////////////////////////////////////////////////////////////////
// UITableViewDataSource

- (NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section {
  NSInteger maxIndex = _photoSource.maxPhotoIndex+1;
  if (!_photoSource.loading && maxIndex > 0) {
    NSInteger count =  ceil((maxIndex / kColumnCount) + (maxIndex % kColumnCount ? 1 : 0));
    if (self.hasMoreToLoad) {
      return count + 1;
    } else {
      return count;
    }
  } else {
    return 0;
  }
}

- (UITableViewCell *)tableView:(UITableView*)tableView
    cellForRowAtIndexPath:(NSIndexPath*)indexPath {
  static NSString* thumbCellId = @"Thumbs";
  static NSString* moreCellId = @"More";

  if (indexPath.row == [_tableView numberOfRowsInSection:0]-1 && self.hasMoreToLoad) {
    TTMoreButtonTableFieldCell* cell =
      (TTMoreButtonTableFieldCell*)[_tableView dequeueReusableCellWithIdentifier:moreCellId];
    if (cell == nil) {
      cell = [[[TTMoreButtonTableFieldCell alloc] initWithFrame:CGRectZero
        reuseIdentifier:moreCellId] autorelease];
    }
    
    NSString* title = TTLocalizedString(@"Load More Photos...", @"");
    NSString* subtitle = [NSString stringWithFormat:
      TTLocalizedString(@"Showing %d of %d Photos", @""), _photoSource.maxPhotoIndex+1,
      _photoSource.numberOfPhotos];

    cell.object = [[[TTMoreButtonTableField alloc] initWithText:title subtitle:subtitle]
      autorelease];
   
    return cell;
	} else {
    TTThumbsTableViewCell* cell =
      (TTThumbsTableViewCell*)[_tableView dequeueReusableCellWithIdentifier:thumbCellId];
    if (cell == nil) {
      cell = [[[TTThumbsTableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:thumbCellId]
        autorelease];
      cell.delegate = self;
    }
    
    cell.photo = [_photoSource photoAtIndex:indexPath.row * kColumnCount];
   
    return cell;
  }
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// TTURLRequestDelegate

- (void)photoSourceLoading:(id<TTPhotoSource>)photoSource {
  if (photoSource.loadingMore) {
    [self invalidateViewState:(_viewState & TTViewDataStates) | TTViewLoadingMore];
  } else if (_viewState & TTViewDataStates) {
    [self invalidateViewState:(_viewState & TTViewDataStates) | TTViewRefreshing];
  } else {
    [self invalidateViewState:TTViewLoading];
  }
}

- (void)photoSourceLoaded:(id<TTPhotoSource>)photoSource {
  if (!_photoSource.numberOfPhotos) {
    [self invalidateViewState:TTViewDataLoadedNothing];
  } else {
    [self invalidateViewState:TTViewDataLoaded];
  }
}

- (void)photoSource:(id<TTPhotoSource>)photoSource didFailWithError:(NSError*)error {
  self.contentError = error;
  [self invalidateViewState:TTViewDataLoadedError];
}

- (void)photoSourceCancelled:(id<TTPhotoSource>)photoSource {
  [self invalidateViewState:TTViewDataLoadedError];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// TTThumbsTableViewCellDelegate

- (void)thumbsTableViewCell:(TTThumbsTableViewCell*)cell didSelectPhoto:(id<TTPhoto>)photo {
  [_delegate thumbsViewController:self didSelectPhoto:photo];
    
  BOOL shouldNavigate = YES;
  if ([_delegate respondsToSelector:@selector(thumbsViewController:shouldNavigateToPhoto:)]) {
    shouldNavigate = [_delegate thumbsViewController:self shouldNavigateToPhoto:photo];
  }

  if (shouldNavigate) {
    TTPhotoViewController* controller = [self createPhotoViewController];
    controller.centerPhoto = photo;
    [self.navigationController pushViewController:controller animated:YES];  
  }
}

///////////////////////////////////////////////////////////////////////////////////////////////////

- (void)setPhotoSource:(id<TTPhotoSource>)photoSource {
  if (photoSource != _photoSource) {
    [_photoSource.delegates removeObject:self];
    [_photoSource release];
    _photoSource = [photoSource retain];
    [_photoSource.delegates addObject:self];

    self.navigationItem.title = _photoSource.title;
    [self invalidateView];
  }
}

- (TTPhotoViewController*)createPhotoViewController {
  return [[[TTPhotoViewController alloc] init] autorelease];
}

@end
