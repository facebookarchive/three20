#import "Three20/T3ThumbsViewController.h"
#import "Three20/T3PhotoViewController.h"
#import "Three20/T3ThumbsTableViewCell.h"
#import "Three20/T3PhotoSource.h"
#import "Three20/T3UnclippedView.h"
#import "Three20/T3ErrorView.h"

///////////////////////////////////////////////////////////////////////////////////////////////////

static NSInteger kColumnCount = 4;

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation T3ThumbsViewController

@synthesize photoSource = _photoSource;

- (id)init {
  if (self = [super init]) {
    _photoSource = nil;
    _previousBarStyle = 0;
  }
  
  return self;
}

- (void)dealloc {
  [_photoSource release];
  [super dealloc];
}

///////////////////////////////////////////////////////////////////////////////////////////////////

- (void)pauseLoadingThumbnails:(BOOL)suspended {
  if (_photoSource.maxPhotoIndex >= 0) {
    NSArray* cells = _tableView.visibleCells;
    for (int i = 0; i < cells.count; ++i) {
      T3ThumbsTableViewCell* cell = [cells objectAtIndex:i];
      if ([cell isKindOfClass:[T3ThumbsTableViewCell class]]) {
        [cell pauseLoading:suspended];
      }
    }
  }
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// UIViewController

- (void)loadView {
  CGRect appFrame = [UIScreen mainScreen].applicationFrame;
  CGRect frame = CGRectMake(0, 0, appFrame.size.width, appFrame.size.height - TOOLBAR_HEIGHT);

  UIView* contentView = [[[T3UnclippedView alloc] initWithFrame:appFrame] autorelease];
  contentView.backgroundColor = [UIColor whiteColor];
//	contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
//  contentView.autoresizesSubviews = YES;
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

  UINavigationBar* bar = self.navigationController.navigationBar;
  if (bar.barStyle != UIBarStyleBlackTranslucent) {
    if (![self nextViewController]) {
      _previousBarStyle = bar.barStyle;
    }

    bar.barStyle = UIBarStyleBlackTranslucent;
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackTranslucent
      animated:YES];
  }
}

- (void)viewDidAppear:(BOOL)animated {
  [super viewDidAppear:animated];
  [self pauseLoadingThumbnails:NO];

  if (!self.nextViewController) {
    self.view.superview.frame = CGRectOffset(self.view.superview.frame, 0, TOOLBAR_HEIGHT);
  }
}

- (void)viewWillDisappear:(BOOL)animated {
  [super viewWillDisappear:animated];

  self.view.superview.frame = CGRectOffset(self.view.superview.frame, 0, TOOLBAR_HEIGHT);

  // If we're going backwards...
  if (!self.nextViewController) {
    UINavigationBar* bar = self.navigationController.navigationBar;
    if (_previousBarStyle != UIBarStyleBlackTranslucent) {
      bar.barStyle = _previousBarStyle;
      [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
    }
  }
}  

- (void)viewDidDisappear:(BOOL)animated {
  [self pauseLoadingThumbnails:YES];
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
    [_photoSource loadPhotosFromIndex:0 toIndex:NSUIntegerMax
      cachePolicy:T3URLRequestCachePolicyMemory|T3URLRequestCachePolicyDisk delegate:self];
  } else if (_photoSource.numberOfPhotos) {
    self.contentState = T3ContentReady;
  } else {
    self.contentState = T3ContentNone;
  }
}

- (void)refreshContent {
  if (_photoSource.isInvalid && !_photoSource.loading) {
    [_photoSource loadPhotosFromIndex:0 toIndex:NSUIntegerMax
      cachePolicy:T3URLRequestCachePolicyNetwork delegate:self];
  }
}

- (void)reloadContent {
  [_photoSource loadPhotosFromIndex:0 toIndex:NSUIntegerMax
    cachePolicy:T3URLRequestCachePolicyNetwork delegate:self];
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
    return (maxIndex / kColumnCount) + (maxIndex % kColumnCount ? 1 : 0);
  } else {
    return 0;
  }
}

- (UITableViewCell *)tableView:(UITableView*)tableView
    cellForRowAtIndexPath:(NSIndexPath*)indexPath {
  static NSString* cellId = @"Thumbs";
	
	T3ThumbsTableViewCell* cell =
    (T3ThumbsTableViewCell*)[_tableView dequeueReusableCellWithIdentifier:cellId];
	if (cell == nil) {
		cell = [[[T3ThumbsTableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:cellId]
      autorelease];
	}
	
  cell.photo = [_photoSource photoAtIndex:indexPath.row * kColumnCount];
 
	return cell;
}

- (void)tableView:(UITableView*)tableView didSelectPhoto:(id<T3Photo>)photo {
  T3PhotoViewController* controller = [[[T3PhotoViewController alloc] init] autorelease];
  controller.centerPhoto = photo;
  [self.navigationController pushViewController:controller animated:YES];  
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// T3PhotoSourceDelegate

- (void)photoSourceLoading:(id<T3PhotoSource>)photoSource fromIndex:(NSUInteger)fromIndex
   toIndex:(NSUInteger)toIndex {
  self.contentState |= T3ContentActivity;
}

- (void)photoSourceLoaded:(id<T3PhotoSource>)photoSource {
  if (_photoSource.numberOfPhotos) {
    self.contentState = T3ContentReady;
  } else {
    self.contentState = T3ContentNone;
  }
}

- (void)photoSource:(id<T3PhotoSource>)photoSource loadDidFailWithError:(NSError*)error {
  self.contentState &= ~T3ContentActivity;
  self.contentState |= T3ContentError;
  self.contentError = error;
}

///////////////////////////////////////////////////////////////////////////////////////////////////

- (void)setPhotoSource:(id<T3PhotoSource>)photoSource {
  if (photoSource != _photoSource) {
    [_photoSource release];
    _photoSource = [photoSource retain];

    [self invalidate];
  }
}

@end
