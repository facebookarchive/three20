#import "Three20/TTThumbsViewController.h"
#import "Three20/TTPhotoViewController.h"
#import "Three20/TTURLRequest.h"
#import "Three20/TTNavigator.h"
#import "Three20/TTTableItem.h"
#import "Three20/TTURLCache.h"
#import "Three20/TTStyleSheet.h"

///////////////////////////////////////////////////////////////////////////////////////////////////
// global

static NSInteger kColumnCount = 4;
static CGFloat kThumbnailRowHeight = 79;

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation TTThumbsDataSource

@synthesize photoSource = _photoSource, delegate = _delegate;

///////////////////////////////////////////////////////////////////////////////////////////////////
// private

- (BOOL)hasMoreToLoad {
  return _photoSource.maxPhotoIndex+1 < _photoSource.numberOfPhotos;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// NSObject

- (id)initWithPhotoSource:(id<TTPhotoSource>)photoSource
      delegate:(id<TTThumbsTableViewCellDelegate>)delegate {
  if (self = [super init]) {
    _photoSource = [photoSource retain];
    _delegate = delegate;
  }
  return self;
}

- (void)dealloc {
  TT_RELEASE_SAFELY(_photoSource);
  [super dealloc];
}

//////////////////////////////////////////////////////////////////////////////////////////////////
// UITableViewDataSource

- (NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section {
  NSInteger maxIndex = _photoSource.maxPhotoIndex;
  if (!_photoSource.isLoading && maxIndex > 0) {
    maxIndex += 1;
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

- (id<TTModel>)model {
  return _photoSource;
}

- (id)tableView:(UITableView*)tableView objectForRowAtIndexPath:(NSIndexPath*)indexPath {
  if (indexPath.row == [tableView numberOfRowsInSection:0]-1 && self.hasMoreToLoad) {
    NSString* text = TTLocalizedString(@"Load More Photos...", @"");
    NSString* caption = [NSString stringWithFormat:
      TTLocalizedString(@"Showing %d of %d Photos", @""), _photoSource.maxPhotoIndex+1,
      _photoSource.numberOfPhotos];

    return [TTTableMoreButton itemWithText:text caption:caption];
  } else {
    return [_photoSource photoAtIndex:indexPath.row * kColumnCount];
  }
}

- (Class)tableView:(UITableView*)tableView cellClassForObject:(id)object {
  if ([object conformsToProtocol:@protocol(TTPhoto)]) {
    return [TTThumbsTableViewCell class];
  } else {
    return [super tableView:tableView cellClassForObject:object];
  }
}

- (void)tableView:(UITableView*)tableView cell:(UITableViewCell*)cell
        willAppearAtIndexPath:(NSIndexPath*)indexPath {
  if ([cell isKindOfClass:[TTThumbsTableViewCell class]]) {
    TTThumbsTableViewCell* thumbsCell = (TTThumbsTableViewCell*)cell;
    thumbsCell.delegate = _delegate;
  }
}

- (UIImage*)imageForEmpty {
  return TTIMAGE(@"bundle://Three20.bundle/images/photoDefault.png");
}

- (NSString*)titleForEmpty {
  return TTLocalizedString(@"No Photos", @"");
}

- (NSString*)subtitleForEmpty {
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

- (NSString*)URLForPhoto:(id<TTPhoto>)photo {
  if ([photo respondsToSelector:@selector(URLValueWithName:)]) {
    return [photo URLValueWithName:@"TTPhotoViewController"];
  } else {
    return nil;
  }
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// NSObject

- (id)initWithDelegate:(id<TTThumbsViewControllerDelegate>)delegate {
  if (self = [self init]) {
    self.delegate = delegate;
  }
  return self;
}

- (id)initWithQuery:(NSDictionary*)query {
  id<TTThumbsViewControllerDelegate> delegate = [query objectForKey:@"delegate"];
  if (delegate) {
    return [self initWithDelegate:delegate];
  } else {
    return [self init];
  }
}

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
  TT_RELEASE_SAFELY(_photoSource);
  [super dealloc];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// UIViewController

- (void)loadView {
  CGRect screenFrame = [UIScreen mainScreen].bounds;
  self.view = [[[UIView alloc] initWithFrame:screenFrame] autorelease];
  self.view.autoresizesSubviews = YES;
	self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;

  CGRect innerFrame = CGRectMake(0, 0,
                                 screenFrame.size.width, screenFrame.size.height + TT_CHROME_HEIGHT);
  UIView* innerView = [[[UIView alloc] initWithFrame:innerFrame] autorelease];
  innerView.backgroundColor = TTSTYLEVAR(backgroundColor);
  [self.view addSubview:innerView];
  
  CGRect tableFrame = CGRectMake(0, TT_CHROME_HEIGHT,
                                 screenFrame.size.width, screenFrame.size.height - TT_CHROME_HEIGHT);
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

- (void)modelDidChangeLoadedState {
  [super modelDidChangeLoadedState];
  if (self.modelState & TTModelStateLoaded) {
    self.title = _photoSource.title;
  }
}

//////////////////////////////////////////////////////////////////////////////////////////////////
// UIViewController (TTCategory)

- (void)persistView:(NSMutableDictionary*)state {
  [super persistView:state];
  NSString* delegate = [[TTNavigator navigator] pathForObject:_delegate];
  if (delegate) {
    [state setObject:delegate forKey:@"delegate"];
  }
}

- (void)restoreView:(NSDictionary*)state {
  [super restoreView:state];
  NSString* delegate = [state objectForKey:@"delegate"];
  if (delegate) {
    self.delegate = [[TTNavigator navigator] objectForPath:delegate];
  }
}

- (void)setDelegate:(id<TTThumbsViewControllerDelegate>)delegate {
  _delegate = delegate;

  if (_delegate) {
    self.navigationItem.leftBarButtonItem =
      [[[UIBarButtonItem alloc] initWithCustomView:[[[UIView alloc] init] autorelease]] autorelease];
    self.navigationItem.rightBarButtonItem =
      [[[UIBarButtonItem alloc] initWithTitle:TTLocalizedString(@"Done", @"")
                                style:UIBarButtonItemStyleBordered
                                target:self
                                action:@selector(removeFromSupercontroller)] autorelease];
  }
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
    NSString* URL = [self URLForPhoto:photo];
    if (URL) {
      TTOpenURL(URL);
    } else {
      TTPhotoViewController* controller = [self createPhotoViewController];
      controller.centerPhoto = photo;
      [self.navigationController pushViewController:controller animated:YES];  
    }
  }
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// public

- (void)setPhotoSource:(id<TTPhotoSource>)photoSource {
  if (photoSource != _photoSource) {
    [_photoSource release];
    _photoSource = [photoSource retain];

    self.title = _photoSource.title;
    self.dataSource = [self createDataSource];
  }
}

- (TTPhotoViewController*)createPhotoViewController {
  return [[[TTPhotoViewController alloc] init] autorelease];
}

- (id<TTTableViewDataSource>)createDataSource {
  return [[[TTThumbsDataSource alloc] initWithPhotoSource:_photoSource delegate:self] autorelease];
}

@end
