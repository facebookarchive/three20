#import "Three20/TTThumbsViewController.h"
#import "Three20/TTPhotoViewController.h"
#import "Three20/TTURLRequest.h"
#import "Three20/TTUnclippedView.h"
#import "Three20/TTTableItem.h"
#import "Three20/TTURLCache.h"
#import "Three20/TTStyleSheet.h"

///////////////////////////////////////////////////////////////////////////////////////////////////
// global

static NSInteger kColumnCount = 4;
static CGFloat kThumbnailRowHeight = 79;

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation TTThumbsDataSource

///////////////////////////////////////////////////////////////////////////////////////////////////
// private

- (BOOL)hasMoreToLoad {
  return _controller.photoSource.maxPhotoIndex+1 < _controller.photoSource.numberOfPhotos;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// NSObject

- (id)initWithController:(TTThumbsViewController*)controller {
  if (self = [super init]) {
    _controller = controller;
    _photoSource = [_controller.photoSource retain];
    [_photoSource.delegates addObject:self];
  }
  return self;
}

- (void)dealloc {
  [_photoSource.delegates removeObject:self];
  TT_RELEASE_MEMBER(_photoSource);
  [super dealloc];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// TTURLRequestDelegate

- (void)photoSourceDidStartLoad:(id<TTPhotoSource>)photoSource {
  [self dataSourceDidStartLoad];
}

- (void)photoSourceDidFinishLoad:(id<TTPhotoSource>)photoSource {
  [self dataSourceDidFinishLoad];
}

- (void)photoSource:(id<TTPhotoSource>)photoSource didFailLoadWithError:(NSError*)error {
  [self dataSourceDidFailLoadWithError:error];
}

- (void)photoSourceDidCancelLoad:(id<TTPhotoSource>)photoSource {
  [self dataSourceDidCancelLoad];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// TTThumbsTableViewCellDelegate

- (void)thumbsTableViewCell:(TTThumbsTableViewCell*)cell didSelectPhoto:(id<TTPhoto>)photo {
  [_controller.delegate thumbsViewController:_controller didSelectPhoto:photo];
    
  BOOL shouldNavigate = YES;
  if ([_controller.delegate
       respondsToSelector:@selector(thumbsViewController:shouldNavigateToPhoto:)]) {
    shouldNavigate = [_controller.delegate thumbsViewController:_controller
                                           shouldNavigateToPhoto:photo];
  }

  if (shouldNavigate) {
    TTPhotoViewController* controller = [_controller createPhotoViewController];
    controller.centerPhoto = photo;
    [_controller.navigationController pushViewController:controller animated:YES];  
  }
}

//////////////////////////////////////////////////////////////////////////////////////////////////
// UITableViewDataSource

- (NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section {
  NSInteger maxIndex = _controller.photoSource.maxPhotoIndex+1;
  if (!_controller.photoSource.isLoading && maxIndex > 0) {
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

//////////////////////////////////////////////////////////////////////////////////////////////////
// TTTableViewDataSource

- (NSDate*)loadedTime {
  return _controller.photoSource.loadedTime;
}

- (BOOL)isLoading {
  return _controller.photoSource.isLoading;
}

- (BOOL)isLoadingMore {
  return _controller.photoSource.isLoadingMore;
}

- (BOOL)isLoaded {
  return _controller.photoSource.isLoaded;
}

- (BOOL)isOutdated {
  return _controller.photoSource.isOutdated;
}

- (BOOL)isEmpty {
  return _controller.photoSource.isEmpty;
}

- (id)tableView:(UITableView*)tableView objectForRowAtIndexPath:(NSIndexPath*)indexPath {
  if (indexPath.row == [tableView numberOfRowsInSection:0]-1 && self.hasMoreToLoad) {
    NSString* text = TTLocalizedString(@"Load More Photos...", @"");
    NSString* caption = [NSString stringWithFormat:
      TTLocalizedString(@"Showing %d of %d Photos", @""), _controller.photoSource.maxPhotoIndex+1,
      _controller.photoSource.numberOfPhotos];

    return [TTTableMoreButton itemWithText:text caption:caption];
  } else {
    return [_controller.photoSource photoAtIndex:indexPath.row * kColumnCount];
  }
}

- (Class)tableView:(UITableView*)tableView cellClassForObject:(id)object {
  if ([object conformsToProtocol:@protocol(TTPhoto)]) {
    return [TTThumbsTableViewCell class];
  } else {
    return [super tableView:tableView cellClassForObject:object];
  }
}

- (void)tableView:(UITableView*)tableView prepareCell:(UITableViewCell*)cell
        forRowAtIndexPath:(NSIndexPath*)indexPath {
  if ([cell isKindOfClass:[TTThumbsTableViewCell class]]) {
    TTThumbsTableViewCell* thumbsCell = (TTThumbsTableViewCell*)cell;
    thumbsCell.delegate = self;
  }
}

- (void)load:(TTURLRequestCachePolicy)cachePolicy nextPage:(BOOL)nextPage {
  NSInteger index = nextPage ? _controller.photoSource.maxPhotoIndex : 0;
  [_controller.photoSource loadPhotosFromIndex:index toIndex:TT_INFINITE_PHOTO_INDEX
                           cachePolicy:cachePolicy];
}

@end

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation TTThumbsViewController

@synthesize delegate = _delegate, photoSource = _photoSource;

///////////////////////////////////////////////////////////////////////////////////////////////////
// private

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

///////////////////////////////////////////////////////////////////////////////////////////////////
// NSObject

- (id)init {
  if (self = [super init]) {
    _delegate = nil;
    _photoSource = nil;
    
    self.hidesBottomBarWhenPushed = YES;
    self.navigationBarStyle = UIBarStyleBlackTranslucent;
    self.navigationBarTintColor = nil;
    self.statusBarStyle = UIStatusBarStyleBlackTranslucent;
    self.wantsFullScreenLayout = YES;
  }
  
  return self;
}

- (void)dealloc {
  [_photoSource.delegates removeObject:self];
  TT_RELEASE_MEMBER(_photoSource);
  [super dealloc];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// UIViewController

- (void)loadView {
  CGRect screenFrame = [UIScreen mainScreen].bounds;
  self.view = [[[TTUnclippedView alloc] initWithFrame:screenFrame] autorelease];
  self.view.autoresizesSubviews = YES;
	self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;

  CGRect innerFrame = CGRectMake(0, 0,
                                 screenFrame.size.width, screenFrame.size.height + CHROME_HEIGHT);
  UIView* innerView = [[[UIView alloc] initWithFrame:innerFrame] autorelease];
  innerView.backgroundColor = TTSTYLEVAR(backgroundColor);
  [self.view addSubview:innerView];
  
  CGRect tableFrame = CGRectMake(0, CHROME_HEIGHT,
                                 screenFrame.size.width, screenFrame.size.height - CHROME_HEIGHT);
  self.tableView = [[[UITableView alloc] initWithFrame:tableFrame
                                         style:UITableViewStylePlain] autorelease];
  self.tableView.rowHeight = kThumbnailRowHeight;
	self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth
    | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
  self.tableView.backgroundColor = TTSTYLEVAR(backgroundColor);
  self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
  self.tableView.contentInset = UIEdgeInsetsMake(4, 0, 0, 0);
  self.tableView.clipsToBounds = NO;
  [innerView addSubview:self.tableView];
}

- (void)viewDidAppear:(BOOL)animated {
  [super viewDidAppear:animated];
  [self suspendLoadingThumbnails:NO];
}

- (void)viewDidDisappear:(BOOL)animated {
  [self suspendLoadingThumbnails:YES];
  [super viewDidDisappear:animated];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// TTViewController

- (UIImage*)imageForNoData {
  return TTIMAGE(@"bundle://Three20.bundle/images/photoDefault.png");
}

- (NSString*)titleForNoData {
  return TTLocalizedString(@"No Photos", @"");
}

- (NSString*)subtitleForNoData {
  return TTLocalizedString(@"This photo set contains no photos.", @"");
}

- (UIImage*)imageForError:(NSError*)error {
  return TTIMAGE(@"bundle://Three20.bundle/images/photoDefault.png");
}

- (NSString*)titleForError:(NSError*)error {
  return TTLocalizedString(@"Error", @"");
}

- (NSString*)subtitleForError:(NSError*)error {
  return TTLocalizedString(@"This photo set could not be loaded.", @"");
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// TTTableViewController

- (id<TTTableViewDataSource>)createDataSource {
  return [[[TTThumbsDataSource alloc] initWithController:self] autorelease];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// public

- (void)setPhotoSource:(id<TTPhotoSource>)photoSource {
  if (photoSource != _photoSource) {
    [_photoSource release];
    _photoSource = [photoSource retain];

    self.title = _photoSource.title;
    [self invalidateView];
  }
}

- (TTPhotoViewController*)createPhotoViewController {
  return [[[TTPhotoViewController alloc] init] autorelease];
}

@end
