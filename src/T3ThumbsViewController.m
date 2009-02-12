#import "Three20/T3ThumbsViewController.h"
#import "Three20/T3PhotoViewController.h"
#import "Three20/T3URLRequest.h"
#import "Three20/T3UnclippedView.h"
#import "Three20/T3ErrorView.h"
#import "Three20/T3TableViewCells.h"
#import "Three20/T3TableItems.h"

///////////////////////////////////////////////////////////////////////////////////////////////////

static NSInteger kColumnCount = 4;
static NSInteger kPageSize = 60;

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation T3ThumbsViewController

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
  [_photoSource removeDelegate:self];
  [_photoSource release];
  [super dealloc];
}

///////////////////////////////////////////////////////////////////////////////////////////////////

- (void)loadPhotosFromIndex:(NSUInteger)fromIndex toIndex:(NSUInteger)toIndex
    fromCache:(BOOL)fromCache {
  T3URLRequest* request = [T3URLRequest request];
  request.cachePolicy = fromCache ? T3URLRequestCachePolicyAny : T3URLRequestCachePolicyNetwork;
  [_photoSource loadPhotos:request fromIndex:fromIndex toIndex:toIndex];
}

- (void)loadNextPage:(BOOL)fromCache {
  NSInteger maxIndex = _photoSource.maxPhotoIndex;
  [self loadPhotosFromIndex:maxIndex+1 toIndex:maxIndex+1+kPageSize fromCache:fromCache];
}

- (void)suspendLoadingThumbnails:(BOOL)suspended {
  if (_photoSource.maxPhotoIndex >= 0) {
    NSArray* cells = _tableView.visibleCells;
    for (int i = 0; i < cells.count; ++i) {
      T3ThumbsTableViewCell* cell = [cells objectAtIndex:i];
      if ([cell isKindOfClass:[T3ThumbsTableViewCell class]]) {
        [cell suspendLoading:suspended];
      }
    }
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

  UIView* contentView = [[[T3UnclippedView alloc] initWithFrame:appFrame] autorelease];
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
// T3ViewController

- (id<T3Object>)viewObject {
  return _photoSource;
}

- (void)showObject:(id<T3Object>)object inView:(NSString*)viewType withState:(NSDictionary*)state {
  [super showObject:object inView:viewType withState:state];

  self.photoSource = (id<T3PhotoSource>)object;
}

- (void)updateContent {
  if (_photoSource.loading) {
    self.contentState = T3ContentActivity;
  } else if (_photoSource.isInvalid) {
    [self loadPhotosFromIndex:0 toIndex:T3_INFINITE_PHOTO_INDEX fromCache:YES];
  } else if (_photoSource.numberOfPhotos) {
    self.contentState = T3ContentReady;
  } else {
    self.contentState = T3ContentNone;
  }
}

- (void)refreshContent {
  if (_photoSource.isInvalid && !_photoSource.loading) {
    [self loadPhotosFromIndex:0 toIndex:T3_INFINITE_PHOTO_INDEX fromCache:NO];
  }
}

- (void)reloadContent {
  [self loadPhotosFromIndex:0 toIndex:T3_INFINITE_PHOTO_INDEX fromCache:NO];
}

- (void)updateView {
  self.navigationItem.title = _photoSource.title;
  [super updateView];
}

- (UIImage*)imageForNoContent {
  return [UIImage imageNamed:@"t3images/photoDefault.png"];
}

- (NSString*)titleForNoContent {
  return  NSLocalizedString(@"No Photos", @"");
}

- (NSString*)subtitleForNoContent {
  return NSLocalizedString(@"This photo set contains no photos.", @"");
}

- (UIImage*)imageForError:(NSError*)error {
  return [UIImage imageNamed:@"t3images/photoDefault.png"];
}

- (NSString*)titleForError:(NSError*)error {
  return NSLocalizedString(@"Error", @"");
}

- (NSString*)subtitleForError:(NSError*)error {
  return NSLocalizedString(@"This photo set could not be loaded.", @"");
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
    T3ActivityTableViewCell* cell =
      (T3ActivityTableViewCell*)[_tableView dequeueReusableCellWithIdentifier:moreCellId];
    if (cell == nil) {
      cell = [[[T3ActivityTableViewCell alloc] initWithFrame:CGRectZero style:0
        reuseIdentifier:moreCellId] autorelease];
    }
    
    NSString* title = NSLocalizedString(@"Load More Photos...", @"");
    NSString* subtitle = [NSString stringWithFormat:
      NSLocalizedString(@"Showing %d of %d Photos", @""), _photoSource.maxPhotoIndex+1,
      _photoSource.numberOfPhotos];

    cell.object = [[[T3MoreLinkTableItem alloc] initWithTitle:title subtitle:subtitle] autorelease];
   
    return cell;
	} else {
    T3ThumbsTableViewCell* cell =
      (T3ThumbsTableViewCell*)[_tableView dequeueReusableCellWithIdentifier:thumbCellId];
    if (cell == nil) {
      cell = [[[T3ThumbsTableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:thumbCellId]
        autorelease];
      cell.delegate = self;
    }
    
    cell.photo = [_photoSource photoAtIndex:indexPath.row * kColumnCount];
   
    return cell;
  }
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// UITableViewDelegate

- (void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath {
  if (indexPath.row == [_tableView numberOfRowsInSection:0]-1) {
    [self loadNextPage:NO];

    T3ActivityTableViewCell* cell
      = (T3ActivityTableViewCell*)[tableView cellForRowAtIndexPath:indexPath];
    cell.animating = YES;
    [_tableView deselectRowAtIndexPath:indexPath animated:YES];
  }
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// T3URLRequestDelegate

- (void)photoSourceLoading:(id<T3PhotoSource>)photoSource {
  self.contentState |= T3ContentActivity;
}

- (void)photoSourceLoaded:(id<T3PhotoSource>)photoSource {
  if (_photoSource.numberOfPhotos) {
    self.contentState = T3ContentReady;
  } else {
    self.contentState = T3ContentNone;
  }
}

- (void)photoSource:(id<T3PhotoSource>)photoSource didFailWithError:(NSError*)error {
  self.contentState &= ~T3ContentActivity;
  self.contentState |= T3ContentError;
  self.contentError = error;
}

- (void)photoSourceCancelled:(id<T3PhotoSource>)photoSource {
  self.contentState &= ~T3ContentActivity;
  self.contentState |= T3ContentError;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// T3ThumbsTableViewCellDelegate

- (void)thumbsTableViewCell:(T3ThumbsTableViewCell*)cell didSelectPhoto:(id<T3Photo>)photo {
  [_delegate thumbsViewController:self didSelectPhoto:photo];
    
  BOOL shouldNavigate = YES;
  if ([_delegate respondsToSelector:@selector(thumbsViewController:shouldNavigateToPhoto:)]) {
    shouldNavigate = [_delegate thumbsViewController:self shouldNavigateToPhoto:photo];
  }

  if (shouldNavigate) {
    T3PhotoViewController* controller = [self createPhotoViewController];
    controller.centerPhoto = photo;
    [self.navigationController pushViewController:controller animated:YES];  
  }
}

///////////////////////////////////////////////////////////////////////////////////////////////////

- (void)setPhotoSource:(id<T3PhotoSource>)photoSource {
  if (photoSource != _photoSource) {
    [_photoSource removeDelegate:self];
    [_photoSource release];
    _photoSource = [photoSource retain];
    [_photoSource addDelegate:self];

    [self invalidate];
  }
}

- (T3PhotoViewController*)createPhotoViewController {
  return [[[T3PhotoViewController alloc] init] autorelease];
}

@end
