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
static NSInteger kPageSize = 60;
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

- (void)loadNextPage:(BOOL)forceReload {
  NSInteger maxIndex = _photoSource.maxPhotoIndex;
  [self loadPhotosFromIndex:maxIndex+1 toIndex:maxIndex+1+kPageSize forceReload:forceReload];
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
  CGRect appFrame = [UIScreen mainScreen].applicationFrame;
  CGRect frame = CGRectMake(0, 0, appFrame.size.width, appFrame.size.height - TOOLBAR_HEIGHT);

  UIView* contentView = [[[TTUnclippedView alloc] initWithFrame:appFrame] autorelease];
  contentView.backgroundColor = [UIColor whiteColor];
  contentView.autoresizesSubviews = YES;
	contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
  self.view = contentView;
    
  UITableView* tableView = [[UITableView alloc] initWithFrame:frame
    style:UITableViewStylePlain];
  tableView.rowHeight = 79;
//  tableView.autoresizesSubviews = YES;
//	tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
  tableView.backgroundColor = [UIColor whiteColor];
  tableView.separatorColor = [UIColor whiteColor];
  tableView.contentInset = UIEdgeInsetsMake(4, 0, 0, 0);
  tableView.clipsToBounds = NO;
  tableView.delegate = self;
  tableView.dataSource = self;
  [self.view addSubview:tableView];
  self.tableView = tableView;
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

- (void)updateContent {
  if (_photoSource.loading) {
    self.contentState = TTContentActivity;
  } else if (!_photoSource.loaded) {
    [self loadPhotosFromIndex:0 toIndex:TT_INFINITE_PHOTO_INDEX forceReload:NO];
  } else if (_photoSource.numberOfPhotos) {
    self.contentState = TTContentReady;
  } else {
    self.contentState = TTContentNone;
  }
}

- (void)refreshContent {
  if (!_photoSource.loading && self.outdated) {
    [self reloadContent];
  }
}

- (void)reloadContent {
  [self loadPhotosFromIndex:0 toIndex:TT_INFINITE_PHOTO_INDEX forceReload:YES];
}

- (UIImage*)imageForNoContent {
  return [UIImage imageNamed:@"Three20.bundle/images/photoDefault.png"];
}

- (NSString*)titleForNoContent {
  return TTLocalizedString(@"No Photos", @"");
}

- (NSString*)subtitleForNoContent {
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
  NSInteger maxIndex = _photoSource.maxPhotoIndex;
  if (!_photoSource.loading && maxIndex > 0) {
    NSInteger count =  (maxIndex / kColumnCount) + (maxIndex % kColumnCount ? 1 : 0);
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
// UITableViewDelegate

- (CGFloat)tableView:(UITableView*)tableView heightForRowAtIndexPath:(NSIndexPath*)indexPath {
  return kThumbnailRowHeight;
}

- (void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath {
  if (indexPath.row == [_tableView numberOfRowsInSection:0]-1) {
    [self loadNextPage:NO];

    TTMoreButtonTableFieldCell* cell
      = (TTMoreButtonTableFieldCell*)[tableView cellForRowAtIndexPath:indexPath];
    cell.animating = YES;
    [_tableView deselectRowAtIndexPath:indexPath animated:YES];
  }
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// TTURLRequestDelegate

- (void)photoSourceLoading:(id<TTPhotoSource>)photoSource {
  self.contentState |= TTContentActivity;
}

- (void)photoSourceLoaded:(id<TTPhotoSource>)photoSource {
  if (_photoSource.numberOfPhotos) {
    self.contentState = TTContentReady;
  } else {
    self.contentState = TTContentNone;
  }
}

- (void)photoSource:(id<TTPhotoSource>)photoSource didFailWithError:(NSError*)error {
  self.contentState &= ~TTContentActivity;
  self.contentState |= TTContentError;
  self.contentError = error;
}

- (void)photoSourceCancelled:(id<TTPhotoSource>)photoSource {
  self.contentState &= ~TTContentActivity;
  self.contentState |= TTContentError;
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
    [self invalidate];
  }
}

- (TTPhotoViewController*)createPhotoViewController {
  return [[[TTPhotoViewController alloc] init] autorelease];
}

@end
