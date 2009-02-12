#import "Three20/T3PhotoViewController.h"
#import "Three20/T3URLCache.h"
#import "Three20/T3URLRequest.h"
#import "Three20/T3UnclippedView.h"
#import "Three20/T3PhotoView.h"

///////////////////////////////////////////////////////////////////////////////////////////////////

static const NSTimeInterval kPhotoLoadLongDelay = 0.5;
static const NSTimeInterval kPhotoLoadShortDelay = 0.25;

static const NSTimeInterval kSlideshowInterval = 2;

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation T3PhotoViewController

@synthesize delegate = _delegate, photoSource = _photoSource, centerPhoto = _centerPhoto,
  centerPhotoIndex = _centerPhotoIndex, defaultImage = _defaultImage;

- (id)init {
  if (self = [super init]) {
    _delegate = nil;
    _photoSource = nil;
    _centerPhoto = nil;
    _centerPhotoIndex = 0;
    _scrollView = nil;
    _photoStatusView = nil;
    _toolbar = nil;
    _nextButton = nil;
    _previousButton = nil;
    _statusText = nil;
    _thumbsController = nil;
    _slideshowTimer = nil;
    _loadTimer = nil;
    _delayLoad = NO;
    self.defaultImage = [UIImage imageNamed:@"t3images/photoDefault.png"];
    
    self.hidesBottomBarWhenPushed = YES;
    self.navigationItem.backBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:
      NSLocalizedString(@"Photo", @"Title for back button that returns to photo browser")
      style:UIBarButtonItemStylePlain target:nil action:nil] autorelease];
  }
  return self;
}

- (void)dealloc {
  [_thumbsController release];
  [_slideshowTimer invalidate];
  _slideshowTimer = nil;
  [_loadTimer invalidate];
  _loadTimer = nil;
  [_centerPhoto release];
  [_photoSource removeDelegate:self];
  [_photoSource release];
  [_statusText release];
  [_defaultImage release];
  [super dealloc];
}

///////////////////////////////////////////////////////////////////////////////////////////////////

- (T3PhotoView*)centerPhotoView {
  return (T3PhotoView*)_scrollView.centerPage;
}

- (void)updateTitle {
  if (!_photoSource.numberOfPhotos || _photoSource.numberOfPhotos == T3_INFINITE_PHOTO_INDEX) {
    self.title = _photoSource.title;
  } else {
    self.title = [NSString stringWithFormat:
      NSLocalizedString(@"%d of %d", @"Current page in photo browser (1 of 10)"),
      _centerPhotoIndex+1, _photoSource.numberOfPhotos];
  }
}

- (void)loadImageDelayed {
  _loadTimer = nil;
  [self.centerPhotoView loadImage];
}

- (void)startImageLoadTimer:(NSTimeInterval)delay {
  [_loadTimer invalidate];
  _loadTimer = [NSTimer scheduledTimerWithTimeInterval:delay target:self
    selector:@selector(loadImageDelayed) userInfo:nil repeats:NO];
}

- (void)cancelImageLoadTimer {
  [_loadTimer invalidate];
  _loadTimer = nil;
}

- (void)loadImages {
  T3PhotoView* centerPhotoView = self.centerPhotoView;
  for (T3PhotoView* photoView in [_scrollView.visiblePages objectEnumerator]) {
    if (photoView == centerPhotoView) {
      [photoView loadPreview:NO];
    } else {
      [photoView loadPreview:YES];
    }
  }

  if (_delayLoad) {
    _delayLoad = NO;
    [self startImageLoadTimer:kPhotoLoadLongDelay];
  } else {
    [centerPhotoView loadImage];
  }
}

- (void)moveToPhotoAtIndex:(NSInteger)photoIndex withDelay:(BOOL)withDelay {
  _centerPhotoIndex = photoIndex == T3_NULL_PHOTO_INDEX ? 0 : photoIndex;
  [_centerPhoto release];
  _centerPhoto = [[_photoSource photoAtIndex:_centerPhotoIndex] retain];
  _delayLoad = withDelay;
}

- (void)showPhoto:(id<T3Photo>)photo inView:(T3PhotoView*)photoView {
  photoView.photo = photo;
  if (!photoView.photo && _statusText) {
    [photoView showStatus:_statusText];
  }
}

- (void)loadPhotosFromIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex {
  if (!_photoSource.loading) {
    T3URLRequest* request = [T3URLRequest request];
    [_photoSource loadPhotos:request fromIndex:fromIndex toIndex:toIndex];
  }
}

- (void)refreshVisiblePhotoViews {
  NSDictionary* photoViews = _scrollView.visiblePages;
  for (NSNumber* key in photoViews.keyEnumerator) {
    T3PhotoView* photoView = [photoViews objectForKey:key];
    id<T3Photo> photo = [_photoSource photoAtIndex:key.intValue];
    [self showPhoto:photo inView:photoView];
  }
}

- (void)resetVisiblePhotoViews {
  NSDictionary* photoViews = _scrollView.visiblePages;
  for (NSNumber* key in photoViews.keyEnumerator) {
    T3PhotoView* photoView = [photoViews objectForKey:key];
    [photoView showProgress:-1];
  }
}

- (BOOL)isShowingChrome {
  UINavigationBar* bar = self.navigationController.navigationBar;
  return bar ? bar.alpha != 0 : 1;
}

- (T3PhotoView*)statusView {
  if (!_photoStatusView) {
    _photoStatusView = [[T3PhotoView alloc] initWithFrame:_scrollView.frame];
    _photoStatusView.defaultImage = _defaultImage;
    _photoStatusView.photo = nil;
    [self.view addSubview:_photoStatusView];
  }
  
  return _photoStatusView;
}

- (void)showProgress:(CGFloat)progress {
  if ((self.appeared || self.appearing) && progress >= 0 && !self.centerPhotoView) {
    [self.statusView showProgress:progress];
    self.statusView.hidden = NO;
  } else {
    _photoStatusView.hidden = YES;
  }
}

- (void)showStatus:(NSString*)status {
  [_statusText release];
  _statusText = [status retain];

  if ((self.appeared || self.appearing) && status && !self.centerPhotoView) {
    [self.statusView showStatus:status];
    self.statusView.hidden = NO;
  } else {
    _photoStatusView.hidden = YES;
  }
}

- (void)showThumbnails {
  if (!_thumbsController) {
    _thumbsController = [[self createThumbsViewController] retain];
    _thumbsController.delegate = self;
    _thumbsController.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]
    initWithCustomView:[[[UIView alloc] initWithFrame:CGRectZero] autorelease]];
    _thumbsController.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]
    initWithTitle:NSLocalizedString(@"Done", @"") style:UIBarButtonItemStyleBordered
    target:self action:@selector(hideThumbnails)];
  }
  
  _thumbsController.photoSource = _photoSource;
  [self.navigationController pushViewController:_thumbsController
    withTransition:UIViewAnimationTransitionCurlDown];
}

- (void)hideThumbnails {
  [self.navigationController popViewControllerWithTransition:UIViewAnimationTransitionCurlUp];
}

- (void)slideshowTimer {
  if (_centerPhotoIndex == _photoSource.numberOfPhotos-1) {
    _scrollView.centerPageIndex = 0;
  } else {
    _scrollView.centerPageIndex = _centerPhotoIndex+1;
  }
}

- (void)playAction {
  if (!_slideshowTimer) {
    UIBarButtonItem* pauseButton = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:
      UIBarButtonSystemItemPause target:self action:@selector(pauseAction)] autorelease];
    pauseButton.tag = 1;
    
    [_toolbar replaceItemWithTag:1 withItem:pauseButton];

    _slideshowTimer = [NSTimer scheduledTimerWithTimeInterval:kSlideshowInterval
      target:self selector:@selector(slideshowTimer) userInfo:nil repeats:YES];
  }
}

- (void)pauseAction {
  if (_slideshowTimer) {
    UIBarButtonItem* playButton = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:
      UIBarButtonSystemItemPlay target:self action:@selector(playAction)] autorelease];
    playButton.tag = 1;
    
    [_toolbar replaceItemWithTag:1 withItem:playButton];

    [_slideshowTimer invalidate];
    _slideshowTimer = nil;
  }
}

- (void)nextAction {
  [self pauseAction];
  _scrollView.centerPageIndex = _centerPhotoIndex+1;
}

- (void)previousAction {
  [self pauseAction];
  _scrollView.centerPageIndex = _centerPhotoIndex-1;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// UIViewController

- (void)loadView {
  CGRect screenFrame = [UIScreen mainScreen].bounds;
  self.view = [[[T3UnclippedView alloc] initWithFrame:screenFrame] autorelease];
  
  _scrollView = [[T3ScrollView alloc] initWithFrame:CGRectOffset(screenFrame, 0, -CHROME_HEIGHT)];
  _scrollView.delegate = self;
  _scrollView.dataSource = self;
  _scrollView.backgroundColor = [UIColor blackColor];
  [self.view addSubview:_scrollView];
  
  
  _nextButton = [[UIBarButtonItem alloc] initWithImage:
    [UIImage imageNamed:@"t3images/nextIcon.png"]
     style:UIBarButtonItemStylePlain target:self action:@selector(nextAction)];
  _previousButton = [[UIBarButtonItem alloc] initWithImage:
    [UIImage imageNamed:@"t3images/previousIcon.png"]
     style:UIBarButtonItemStylePlain target:self action:@selector(previousAction)];

  UIBarButtonItem* playButton = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:
    UIBarButtonSystemItemPlay target:self action:@selector(playAction)] autorelease];
  playButton.tag = 1;

  UIBarItem* space = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:
   UIBarButtonSystemItemFlexibleSpace target:nil action:nil] autorelease];

  CGFloat y = screenFrame.size.height - (CHROME_HEIGHT + TOOLBAR_HEIGHT);
  _toolbar = [[UIToolbar alloc] initWithFrame:
    CGRectMake(0, y, screenFrame.size.width, TOOLBAR_HEIGHT)];
  _toolbar.barStyle = UIBarStyleBlackTranslucent;
  _toolbar.items = [NSArray arrayWithObjects:
    space, _previousButton, space, playButton, space, _nextButton, space, nil];
  [self.view addSubview:_toolbar];    
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  [self changeNavigationBarStyle:UIBarStyleBlackTranslucent barColor:nil
    statusBarStyle:UIStatusBarStyleBlackTranslucent];
}

- (void)viewDidAppear:(BOOL)animated {
  [super viewDidAppear:animated];

  if (!self.nextViewController) {
    self.view.superview.frame = CGRectOffset(self.view.superview.frame, 0, TOOLBAR_HEIGHT);
  }
}

- (void)viewWillDisappear:(BOOL)animated {
  [super viewWillDisappear:animated];

  [self pauseAction];

  self.view.superview.frame = CGRectOffset(self.view.superview.frame, 0, TOOLBAR_HEIGHT);

  [self showBars:YES animated:NO];
  [self restoreNavigationBarStyle];
}


- (void)showBars:(BOOL)show animated:(BOOL)animated {
  [super showBars:show animated:animated];
  
  if (animated) {
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3];
  }

  _toolbar.alpha = show ? 1 : 0;
  
  if (animated) {
    [UIView commitAnimations];
  }
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// T3ViewController

- (id<T3Object>)viewObject {
  return _centerPhoto;
}

- (void)showObject:(id<T3Object>)object inView:(NSString*)viewType withState:(NSDictionary*)state {
  [super showObject:object inView:viewType withState:state];
  
  if ([object conformsToProtocol:@protocol(T3PhotoSource)]) {
    self.photoSource = (id<T3PhotoSource>)object;
  } else if ([object conformsToProtocol:@protocol(T3Photo)]) {
    self.centerPhoto = (id<T3Photo>)object;
  }
}

- (void)updateContent {
  if (_photoSource.loading) {
    self.contentState = T3ContentActivity;
  } else if (!_centerPhoto) {
    [self loadPhotosFromIndex:_photoSource.isInvalid ? 0 : _photoSource.maxPhotoIndex+1
      toIndex:T3_INFINITE_PHOTO_INDEX];
  } else if (_photoSource.numberOfPhotos == T3_INFINITE_PHOTO_INDEX) {
    [self loadPhotosFromIndex:0 toIndex:T3_INFINITE_PHOTO_INDEX];
  } else {
    if (_photoSource.numberOfPhotos) {
      self.contentState = T3ContentReady;
    } else {
      self.contentState = T3ContentNone;
    }
  }
}

//- (void)refreshContent {
//  if (_photoSource.isInvalid && !_photoSource.loading) {
//    [self loadPhotosFromIndex:0 toIndex:T3_INFINITE_PHOTO_INDEX];
//  }
//}

- (void)reloadContent {
    [self loadPhotosFromIndex:0 toIndex:T3_INFINITE_PHOTO_INDEX];
}

- (void)updateView {
  if (![self.previousViewController isKindOfClass:[T3ThumbsViewController class]]) {
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]
      initWithTitle:NSLocalizedString(@"See All", @"See all photo thumbnails")
      style:UIBarButtonItemStyleBordered target:self action:@selector(showThumbnails)];
  } else {
    self.navigationItem.rightBarButtonItem = nil;
  }

  _scrollView.centerPageIndex = _centerPhotoIndex;
  [self loadImages];

  if (self.contentState & T3ContentReady) {
    [self showProgress:-1];
    [self showStatus:nil];
  } else if (self.contentState & T3ContentActivity) {
    [self showProgress:0];
  } else if (self.contentState & T3ContentError) {
    [self showStatus:NSLocalizedString(@"This photo set could not be loaded.", "")];
  } else if (self.contentState & T3ContentNone) {
    [self showStatus:NSLocalizedString(@"This photo set contains no photos.", "")];
  }

  [self updateTitle];
}

- (void)unloadView {
  _scrollView.delegate = nil;
  _scrollView.dataSource = nil;
  [_scrollView release];
  _scrollView = nil;
  [_photoStatusView release];
  _photoStatusView = nil;
  [_nextButton release];
  _nextButton = nil;
  [_previousButton release];
  _previousButton = nil;
  [_toolbar release];
  _toolbar = nil;
}

- (NSString*)titleForActivity {
  return NSLocalizedString(@"Loading...", @"");
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

///////////////////////////////////////////////////////////////////////////////////////////////////
// T3PhotoSourceDelegate

- (void)photoSourceLoading:(id<T3PhotoSource>)photoSource {
  self.contentState |= T3ContentActivity;
}

- (void)photoSourceLoaded:(id<T3PhotoSource>)photoSource {
  if (_centerPhotoIndex >= _photoSource.numberOfPhotos) {
    [self moveToPhotoAtIndex:_photoSource.numberOfPhotos - 1 withDelay:NO];
    [_scrollView reloadData];
  } else {
    [self refreshVisiblePhotoViews];
  }
  
  if (_photoSource.numberOfPhotos) {
    self.contentState = T3ContentReady;
  } else {
    self.contentState = T3ContentNone;
  }
}

- (void)photoSource:(id<T3PhotoSource>)photoSource didFailWithError:(NSError*)error {
  [self resetVisiblePhotoViews];

  self.contentState &= ~T3ContentActivity;
  self.contentState |= T3ContentError;
  self.contentError = error;
}

- (void)photoSourceCancelled:(id<T3PhotoSource>)photoSource {
  [self resetVisiblePhotoViews];

  self.contentState &= ~T3ContentActivity;
  self.contentState |= T3ContentError;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// T3ScrollViewDelegate

- (void)scrollView:(T3ScrollView*)scrollView didMoveToPageAtIndex:(NSInteger)pageIndex {
  if (pageIndex != _centerPhotoIndex) {
    [self moveToPhotoAtIndex:pageIndex withDelay:YES];
    [self invalidate];
  }
}

- (void)scrollViewWillBeginDragging:(T3ScrollView *)scrollView {
  [self cancelImageLoadTimer];
  [self showBars:NO animated:YES];
}

- (void)scrollViewDidEndDecelerating:(T3ScrollView*)scrollView {
  [self startImageLoadTimer:kPhotoLoadShortDelay];
}

- (void)scrollViewWillRotate:(T3ScrollView*)scrollView {
  self.centerPhotoView.extrasHidden = YES;
}

- (void)scrollViewDidRotate:(T3ScrollView*)scrollView {
  self.centerPhotoView.extrasHidden = NO;
}

- (BOOL)scrollViewShouldZoom:(T3ScrollView*)scrollView {
  return self.centerPhotoView.image != self.centerPhotoView.defaultImage;
}

- (void)scrollViewDidBeginZooming:(T3ScrollView*)scrollView {
  self.centerPhotoView.extrasHidden = YES;
}

- (void)scrollViewDidEndZooming:(T3ScrollView*)scrollView {
  self.centerPhotoView.extrasHidden = NO;
}

- (void)scrollViewTapped:(T3ScrollView*)scrollView {
  if ([self isShowingChrome]) {
    [self showBars:NO animated:YES];
  } else {
    [self showBars:YES animated:NO];
  }
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// T3ScrollViewDataSource

- (NSInteger)numberOfPagesInScrollView:(T3ScrollView*)scrollView {
  return _photoSource.numberOfPhotos;
}

- (UIView*)scrollView:(T3ScrollView*)scrollView pageAtIndex:(NSInteger)pageIndex {
  T3PhotoView* photoView = (T3PhotoView*)[_scrollView dequeueReusablePage];
  if (!photoView) {
    photoView = [self createPhotoView];
    photoView.defaultImage = _defaultImage;
  }

  id<T3Photo> photo = [_photoSource photoAtIndex:pageIndex];
  [self showPhoto:photo inView:photoView];
  
  return photoView;
}

- (CGSize)scrollView:(T3ScrollView*)scrollView sizeOfPageAtIndex:(NSInteger)pageIndex {
  id<T3Photo> photo = [_photoSource photoAtIndex:pageIndex];
  return photo ? photo.size : CGSizeZero;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// T3ThumbsViewControllerDelegate

- (void)thumbsViewController:(T3ThumbsViewController*)controller didSelectPhoto:(id<T3Photo>)photo {
  self.centerPhoto = photo;
  [self hideThumbnails];
}

///////////////////////////////////////////////////////////////////////////////////////////////////

- (void)setPhotoSource:(id<T3PhotoSource>)photoSource {
  if (_photoSource != photoSource) {
    [_photoSource removeDelegate:self];
    [_photoSource release];
    _photoSource = [photoSource retain];
    [_photoSource addDelegate:self];
  
    [self moveToPhotoAtIndex:0 withDelay:NO];
    [self invalidate];
  }
}

- (void)setCenterPhoto:(id<T3Photo>)photo {
  if (_centerPhoto != photo) {
    if (photo.photoSource != _photoSource) {
      [_photoSource removeDelegate:self];
      [_photoSource release];
      _photoSource = [photo.photoSource retain];
      [_photoSource addDelegate:self];
    }

    [self moveToPhotoAtIndex:photo.index withDelay:NO];
    [self invalidate];
  }
}

- (T3PhotoView*)createPhotoView {
  return [[[T3PhotoView alloc] initWithFrame:CGRectZero] autorelease];
}

- (T3ThumbsViewController*)createThumbsViewController {
  return [[[T3ThumbsViewController alloc] init] autorelease];
}

@end
