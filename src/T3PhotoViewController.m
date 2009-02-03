#import "Three20/T3PhotoViewController.h"
#import "Three20/T3ThumbsViewController.h"
#import "Three20/T3URLCache.h"
#import "Three20/T3UnclippedView.h"
#import "Three20/T3PhotoView.h"

///////////////////////////////////////////////////////////////////////////////////////////////////

static const NSTimeInterval kPhotoLoadLongDelay = 0.5;
static const NSTimeInterval kPhotoLoadShortDelay = 0.25;

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
    _previousBarStyle = 0;
    _scrollView = nil;
    _photoStatusView = nil;
    _statusText = nil;
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
  [_loadTimer invalidate];
  _loadTimer = nil;
  [_centerPhoto release];
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
  if (!_photoSource.numberOfPhotos) {
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
  for (T3PhotoView* photoView in _scrollView.visiblePages.objectEnumerator) {
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
  _centerPhotoIndex = photoIndex;
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

- (void)loadPhotos {
  if (!_photoSource.loading) {
    [_photoSource loadPhotosFromIndex:_photoSource.maxPhotoIndex+1 toIndex:-1
      cachePolicy:T3URLRequestCachePolicyAny delegate:self];
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

- (BOOL)isShowingChrome {
  UINavigationBar* bar = self.navigationController.navigationBar;
  return bar ? bar.alpha != 0 : 1;
}

- (void)showNavigationBar:(BOOL)show {
  self.navigationController.navigationBar.alpha = show ? 1 : 0;
}

- (void)showChrome:(BOOL)show animated:(BOOL)animated {
  [[UIApplication sharedApplication] setStatusBarHidden:!show animated:animated];
  
  if (animated) {
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3];
  }
  
  [self showNavigationBar:show];

  if (animated) {
    [UIView commitAnimations];
  }
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
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];

  UINavigationBar* bar = self.navigationController.navigationBar;
  if (bar.barStyle != UIBarStyleBlackTranslucent) {
    if (!self.nextViewController) {
      _previousBarStyle = bar.barStyle;
    }

    bar.barStyle = UIBarStyleBlackTranslucent;
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackTranslucent
      animated:YES];
  }
}

- (void)viewDidAppear:(BOOL)animated {
  [super viewDidAppear:animated];

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

  [self showNavigationBar:YES];

  UIApplication* app = [UIApplication sharedApplication];
  if (app.statusBarHidden) {
    app.statusBarStyle = UIStatusBarStyleDefault;
    [app setStatusBarHidden:NO animated:YES];
  } else {
    [app setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
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
    [self loadPhotos];
  } else {
    if (_photoSource.numberOfPhotos) {
      self.contentState = T3ContentReady;
    } else {
      self.contentState = T3ContentNone;
    }
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

- (void)photoSourceLoading:(id<T3PhotoSource>)photoSource fromIndex:(NSUInteger)fromIndex
    toIndex:(NSUInteger)toIndex {
  self.contentState |= T3ContentActivity;
}

- (void)photoSourceLoaded:(id<T3PhotoSource>)photoSource {
  if (_centerPhotoIndex >= photoSource.numberOfPhotos) {
    [self moveToPhotoAtIndex:photoSource.numberOfPhotos - 1 withDelay:NO];
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

- (void)photoSource:(id<T3PhotoSource>)photoSource loadDidFailWithError:(NSError*)error {
  self.contentState &= ~T3ContentActivity;
  self.contentState |= T3ContentError;
  self.contentError = error;
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
  [self showChrome:NO animated:NO];
}

- (void)scrollViewDidEndDecelerating:(T3ScrollView*)scrollView {
  [self startImageLoadTimer:kPhotoLoadShortDelay];
}

- (void)scrollViewWillRotate:(T3ScrollView*)scrollView {
  self.centerPhotoView.extrasHidden = YES;
  [self showChrome:NO animated:YES];
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
    [self showChrome:NO animated:YES];
  } else {
    [self showChrome:YES animated:NO];
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
    photoView = [_delegate photoViewController:self viewForPhotoAtIndex:pageIndex];
    if (!photoView) {
      photoView = [[[T3PhotoView alloc] initWithFrame:CGRectZero] autorelease];
      photoView.defaultImage = _defaultImage;
    }
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

- (void)setPhotoSource:(id<T3PhotoSource>)photoSource {
  if (_photoSource != photoSource) {
    [_photoSource release];
    _photoSource = [photoSource retain];
  
    [self moveToPhotoAtIndex:0 withDelay:NO];
    [self invalidate];
  }
}

- (void)setCenterPhoto:(id<T3Photo>)photo {
  if (_centerPhoto != photo) {
    if (photo.photoSource != _photoSource) {
      [_photoSource release];
      _photoSource = [photo.photoSource retain];
    }

    [self moveToPhotoAtIndex:photo.index withDelay:NO];
    [self invalidate];
  }
}

@end
