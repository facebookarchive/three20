#import "Three20/TTPhotoViewController.h"
#import "Three20/TTURLCache.h"
#import "Three20/TTURLRequest.h"
#import "Three20/TTUnclippedView.h"
#import "Three20/TTPhotoView.h"
#import "Three20/TTURLRequestQueue.h"

///////////////////////////////////////////////////////////////////////////////////////////////////

static const NSTimeInterval kPhotoLoadLongDelay = 0.5;
static const NSTimeInterval kPhotoLoadShortDelay = 0.25;

static const NSTimeInterval kSlideshowInterval = 2;

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation TTPhotoViewController

@synthesize photoSource = _photoSource, centerPhoto = _centerPhoto,
  centerPhotoIndex = _centerPhotoIndex, defaultImage = _defaultImage;

- (id)init {
  if (self = [super init]) {
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
    self.defaultImage = TTIMAGE(@"bundle://Three20.bundle/images/photoDefault.png");
    
    self.hidesBottomBarWhenPushed = YES;
    self.navigationItem.backBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:
      TTLocalizedString(@"Photo", @"Title for back button that returns to photo browser")
      style:UIBarButtonItemStylePlain target:nil action:nil] autorelease];
    self.navigationBarStyle = UIBarStyleBlackTranslucent;
    self.navigationBarTintColor = nil;
    self.statusBarStyle = UIStatusBarStyleBlackTranslucent;
    
    if ([self respondsToSelector:@selector(setWantsFullScreenLayout:)]) {
      [self setWantsFullScreenLayout:YES];
    }
  }
  return self;
}

- (void)dealloc {
  [[TTURLRequestQueue mainQueue] cancelRequestsWithDelegate:self];
  [_thumbsController release];
  [_slideshowTimer invalidate];
  _slideshowTimer = nil;
  [_loadTimer invalidate];
  _loadTimer = nil;
  [_centerPhoto release];
  [_photoSource.delegates removeObject:self];
  [_photoSource release];
  [_statusText release];
  [_defaultImage release];
  [super dealloc];
}

///////////////////////////////////////////////////////////////////////////////////////////////////

- (TTPhotoView*)centerPhotoView {
  return (TTPhotoView*)_scrollView.centerPage;
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
  TTPhotoView* centerPhotoView = self.centerPhotoView;
  for (TTPhotoView* photoView in [_scrollView.visiblePages objectEnumerator]) {
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

- (void)updateTitle {
  if (!_photoSource.numberOfPhotos || _photoSource.numberOfPhotos == TT_INFINITE_PHOTO_INDEX) {
    self.title = _photoSource.title;
  } else {
    self.title = [NSString stringWithFormat:
      TTLocalizedString(@"%d of %d", @"Current page in photo browser (1 of 10)"),
      _centerPhotoIndex+1, _photoSource.numberOfPhotos];
  }
}

- (void)updateChrome {
  [self updateTitle];

  if (![self.previousViewController isKindOfClass:[TTThumbsViewController class]]) {
    if (_photoSource.numberOfPhotos > 1) {
      self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]
        initWithTitle:TTLocalizedString(@"See All", @"See all photo thumbnails")
        style:UIBarButtonItemStyleBordered target:self action:@selector(showThumbnails)];
    } else {
      self.navigationItem.rightBarButtonItem = nil;
    }
  } else {
    self.navigationItem.rightBarButtonItem = nil;
  }

  UIBarButtonItem* playButton = [_toolbar itemWithTag:1];
  playButton.enabled = _photoSource.numberOfPhotos > 1;
  _previousButton.enabled = _centerPhotoIndex > 0;
  _nextButton.enabled = _centerPhotoIndex < _photoSource.numberOfPhotos-1;
}

- (void)updatePhotoView {
  _scrollView.centerPageIndex = _centerPhotoIndex;
  [self loadImages];
}

- (void)moveToPhotoAtIndex:(NSInteger)photoIndex withDelay:(BOOL)withDelay {
  _centerPhotoIndex = photoIndex == TT_NULL_PHOTO_INDEX ? 0 : photoIndex;
  [_centerPhoto release];
  _centerPhoto = [[_photoSource photoAtIndex:_centerPhotoIndex] retain];
  _delayLoad = withDelay;
}

- (void)showPhoto:(id<TTPhoto>)photo inView:(TTPhotoView*)photoView {
  photoView.photo = photo;
  if (!photoView.photo && _statusText) {
    [photoView showStatus:_statusText];
  }
}

- (void)loadPhotosFromIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex {
  if (!_photoSource.isLoading) {
    [_photoSource loadPhotosFromIndex:fromIndex toIndex:toIndex
      cachePolicy:TTURLRequestCachePolicyDefault];
  }
}

- (void)refreshVisiblePhotoViews {
  [_centerPhoto release];
  _centerPhoto = [[_photoSource photoAtIndex:_centerPhotoIndex] retain];

  NSDictionary* photoViews = _scrollView.visiblePages;
  for (NSNumber* key in photoViews.keyEnumerator) {
    TTPhotoView* photoView = [photoViews objectForKey:key];
    [photoView showProgress:-1];

    id<TTPhoto> photo = [_photoSource photoAtIndex:key.intValue];
    [self showPhoto:photo inView:photoView];
  }
}

- (void)resetVisiblePhotoViews {
  NSDictionary* photoViews = _scrollView.visiblePages;
  for (NSNumber* key in photoViews.keyEnumerator) {
    TTPhotoView* photoView = [photoViews objectForKey:key];
    if (!photoView.isLoading) {
      [photoView showProgress:-1];
    }
  }
}

- (BOOL)isShowingChrome {
  UINavigationBar* bar = self.navigationController.navigationBar;
  return bar ? bar.alpha != 0 : 1;
}

- (TTPhotoView*)statusView {
  if (!_photoStatusView) {
    _photoStatusView = [[TTPhotoView alloc] initWithFrame:_scrollView.frame];
    _photoStatusView.defaultImage = _defaultImage;
    _photoStatusView.photo = nil;
    [_innerView addSubview:_photoStatusView];
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

- (void)showCaptions:(BOOL)show {
  for (TTPhotoView* photoView in [_scrollView.visiblePages objectEnumerator]) {
    photoView.captionHidden = !show;
  }
}

- (void)showThumbnails {
  if (!_thumbsController) {
    _thumbsController = [[self createThumbsViewController] retain];
    _thumbsController.delegate = self;
    _thumbsController.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]
    initWithCustomView:[[[UIView alloc] initWithFrame:CGRectZero] autorelease]];
    _thumbsController.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]
    initWithTitle:TTLocalizedString(@"Done", @"") style:UIBarButtonItemStyleBordered
    target:self action:@selector(hideThumbnails)];
  }
  
  _thumbsController.photoSource = _photoSource;
  [self.navigationController pushViewController:_thumbsController
    animatedWithTransition:UIViewAnimationTransitionCurlDown];
}

- (void)hideThumbnails {
  [self.navigationController popViewControllerAnimatedWithTransition:
                             UIViewAnimationTransitionCurlUp];
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
  if (_centerPhotoIndex < _photoSource.numberOfPhotos-1) {
    _scrollView.centerPageIndex = _centerPhotoIndex+1;
  }
}

- (void)previousAction {
  [self pauseAction];
  if (_centerPhotoIndex > 0) {
    _scrollView.centerPageIndex = _centerPhotoIndex-1;
  }
}

- (void)showBarsAnimationDidStop {
  if (![self respondsToSelector:@selector(setWantsFullScreenLayout:)]) {
    _innerView.top = -CHROME_HEIGHT;
    self.view.top = TOOLBAR_HEIGHT;
    self.view.height -= TOOLBAR_HEIGHT;
  }
  self.navigationController.navigationBarHidden = NO;
}

- (void)hideBarsAnimationDidStop {
  if (![self respondsToSelector:@selector(setWantsFullScreenLayout:)]) {
    _innerView.top = -STATUS_HEIGHT;
    self.view.top = 0;
    self.view.height += TOOLBAR_HEIGHT;
  }
  self.navigationController.navigationBarHidden = YES;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// UIViewController

- (void)loadView {
  CGRect screenFrame = [UIScreen mainScreen].bounds;
  self.view = [[[TTUnclippedView alloc] initWithFrame:screenFrame] autorelease];
    
  CGFloat y = [self respondsToSelector:@selector(setWantsFullScreenLayout:)] ? 0 : -CHROME_HEIGHT;
  CGRect innerFrame = CGRectMake(0, y,
                                 screenFrame.size.width, screenFrame.size.height + CHROME_HEIGHT);
  _innerView = [[UIView alloc] initWithFrame:innerFrame];
  [self.view addSubview:_innerView];
  
  _scrollView = [[TTScrollView alloc] initWithFrame:screenFrame];
  _scrollView.delegate = self;
  _scrollView.dataSource = self;
  _scrollView.backgroundColor = [UIColor blackColor];
  [_innerView addSubview:_scrollView];
  
  _nextButton = [[UIBarButtonItem alloc] initWithImage:
    TTIMAGE(@"bundle://Three20.bundle/images/nextIcon.png")
     style:UIBarButtonItemStylePlain target:self action:@selector(nextAction)];
  _previousButton = [[UIBarButtonItem alloc] initWithImage:
    TTIMAGE(@"bundle://Three20.bundle/images/previousIcon.png")
     style:UIBarButtonItemStylePlain target:self action:@selector(previousAction)];

  UIBarButtonItem* playButton = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:
    UIBarButtonSystemItemPlay target:self action:@selector(playAction)] autorelease];
  playButton.tag = 1;

  UIBarItem* space = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:
   UIBarButtonSystemItemFlexibleSpace target:nil action:nil] autorelease];

  _toolbar = [[UIToolbar alloc] initWithFrame:
    CGRectMake(0, screenFrame.size.height - TOOLBAR_HEIGHT, screenFrame.size.width, TOOLBAR_HEIGHT)];
  _toolbar.barStyle = self.navigationBarStyle;
  _toolbar.items = [NSArray arrayWithObjects:
    space, _previousButton, space, _nextButton, space, nil];
  [_innerView addSubview:_toolbar];    
}

- (void)viewDidAppear:(BOOL)animated {
  [super viewDidAppear:animated];

  if (![self respondsToSelector:@selector(setWantsFullScreenLayout:)]) {
    if (!self.nextViewController) {
      self.view.superview.frame = CGRectOffset(self.view.superview.frame, 0, TOOLBAR_HEIGHT);
    }
  
    [self hideBarsAnimationDidStop];
    [self showBarsAnimationDidStop];
    if (!_toolbar.alpha) {
      [self hideBarsAnimationDidStop];
    }
  }
}

- (void)viewWillDisappear:(BOOL)animated {
  [super viewWillDisappear:animated];

  [self pauseAction];

  if (![self respondsToSelector:@selector(setWantsFullScreenLayout:)]) {
    self.view.superview.frame = CGRectOffset(self.view.superview.frame, 0, TOOLBAR_HEIGHT);
    self.view.frame = CGRectOffset(self.view.frame, 0, -TOOLBAR_HEIGHT);
  }
  if (self.nextViewController) {
    [self showBars:YES animated:NO];
  }
}

- (void)showBars:(BOOL)show animated:(BOOL)animated {
  [super showBars:show animated:animated];

  CGFloat alpha = show ? 1 : 0;
  if (alpha == _toolbar.alpha)
    return;
  
  if (animated) {
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:TT_TRANSITION_DURATION];
    [UIView setAnimationDelegate:self];
    if (show) {
      [UIView setAnimationDidStopSelector:@selector(showBarsAnimationDidStop)];
    } else {
      [UIView setAnimationDidStopSelector:@selector(hideBarsAnimationDidStop)];
    }
  } else {
    if (show) {
      [self showBarsAnimationDidStop];
    } else {
      [self hideBarsAnimationDidStop];
    }
  }

  [self showCaptions:show];
  
  _toolbar.alpha = alpha;
  
  if (animated) {
    [UIView commitAnimations];
  }
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// TTViewController

- (id<TTPersistable>)viewObject {
  return _centerPhoto;
}

- (void)showObject:(id)object inView:(NSString*)viewType withState:(NSDictionary*)state {
  [super showObject:object inView:viewType withState:state];
  
  if ([object conformsToProtocol:@protocol(TTPhotoSource)]) {
    self.photoSource = (id<TTPhotoSource>)object;
  } else if ([object conformsToProtocol:@protocol(TTPhoto)]) {
    self.centerPhoto = (id<TTPhoto>)object;
  }
}

- (void)reloadContent {
  [self loadPhotosFromIndex:0 toIndex:TT_INFINITE_PHOTO_INDEX];
}

- (void)updateView {
  if (_photoSource.isLoading) {
    [self invalidateViewState:TTViewLoading];
  } else if (!_centerPhoto) {
    [self loadPhotosFromIndex:!_photoSource.isLoaded ? 0 : _photoSource.maxPhotoIndex+1
      toIndex:TT_INFINITE_PHOTO_INDEX];
  } else if (_photoSource.numberOfPhotos == TT_INFINITE_PHOTO_INDEX) {
    [self loadPhotosFromIndex:0 toIndex:TT_INFINITE_PHOTO_INDEX];
  } else {
    if (_contentError) {
      [self invalidateViewState:TTViewDataLoadedError];
    } else if (!_photoSource.numberOfPhotos) {
      [self invalidateViewState:TTViewEmpty];
    } else {
      [self invalidateViewState:TTViewDataLoaded];
    }
  }

  [self updateChrome];
}

- (void)updateLoadingView {
  if (self.viewState & TTViewLoading) {
    [self showProgress:0];
  } else {
    [self showProgress:-1];
  }
}

- (void)updateDataView {
  if (self.viewState & TTViewDataLoaded) {
    [self showStatus:nil];
  } else if (self.viewState & TTViewDataLoadedError) {
    [self showStatus:TTLocalizedString(@"This photo set could not be loaded.", @"")];
  } else {
    [self showStatus:TTLocalizedString(@"This photo set contains no photos.", @"")];
  }
  
  [self updatePhotoView];
}

- (void)unloadView {
  [_innerView release];
  _innerView = nil;
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
  return TTLocalizedString(@"Loading...", @"");
}

- (UIImage*)imageForNoData {
  return TTIMAGE(@"bundle://Three20.bundle/images/photoDefault.png");
}

- (NSString*)titleForNoData {
  return  TTLocalizedString(@"No Photos", @"");
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
// TTPhotoSourceDelegate

- (void)photoSourceDidStartLoad:(id<TTPhotoSource>)photoSource {
  [self invalidateViewState:TTViewLoading];
}

- (void)photoSourceDidFinishLoad:(id<TTPhotoSource>)photoSource {
  if (_centerPhotoIndex >= _photoSource.numberOfPhotos) {
    [self moveToPhotoAtIndex:_photoSource.numberOfPhotos - 1 withDelay:NO];
    [_scrollView reloadData];
    [self resetVisiblePhotoViews];
  } else {
    [self refreshVisiblePhotoViews];
  }
  
  if (!_photoSource.numberOfPhotos) {
    [self invalidateViewState:TTViewEmpty];
  } else {
    [self invalidateViewState:TTViewDataLoaded];
  }
}

- (void)photoSource:(id<TTPhotoSource>)photoSource didFailLoadWithError:(NSError*)error {
  [self resetVisiblePhotoViews];

  self.contentError = error;
  [self invalidateViewState:TTViewDataLoadedError];
}

- (void)photoSourceDidCancelLoad:(id<TTPhotoSource>)photoSource {
  [self resetVisiblePhotoViews];

  self.contentError = nil;
  [self invalidateViewState:TTViewDataLoadedError];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// TTScrollViewDelegate

- (void)scrollView:(TTScrollView*)scrollView didMoveToPageAtIndex:(NSInteger)pageIndex {
  if (pageIndex != _centerPhotoIndex) {
    [self moveToPhotoAtIndex:pageIndex withDelay:YES];
    [self invalidateView];
  }
}

- (void)scrollViewWillBeginDragging:(TTScrollView *)scrollView {
  [self cancelImageLoadTimer];
  [self showCaptions:NO];
  [self showBars:NO animated:YES];
}

- (void)scrollViewDidEndDecelerating:(TTScrollView*)scrollView {
  [self startImageLoadTimer:kPhotoLoadShortDelay];
}

- (void)scrollViewWillRotate:(TTScrollView*)scrollView toOrientation:(UIInterfaceOrientation)orientation {
  self.centerPhotoView.extrasHidden = YES;
}

- (void)scrollViewDidRotate:(TTScrollView*)scrollView {
  self.centerPhotoView.extrasHidden = NO;
}

- (BOOL)scrollViewShouldZoom:(TTScrollView*)scrollView {
  return self.centerPhotoView.image != self.centerPhotoView.defaultImage;
}

- (void)scrollViewDidBeginZooming:(TTScrollView*)scrollView {
  self.centerPhotoView.extrasHidden = YES;
}

- (void)scrollViewDidEndZooming:(TTScrollView*)scrollView {
  self.centerPhotoView.extrasHidden = NO;
}

- (void)scrollView:(TTScrollView*)scrollView tapped:(UITouch*)touch {
  if ([self isShowingChrome]) {
    [self showBars:NO animated:YES];
  } else {
    [self showBars:YES animated:NO];
  }
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// TTScrollViewDataSource

- (NSInteger)numberOfPagesInScrollView:(TTScrollView*)scrollView {
  return _photoSource.numberOfPhotos;
}

- (UIView*)scrollView:(TTScrollView*)scrollView pageAtIndex:(NSInteger)pageIndex {
  TTPhotoView* photoView = (TTPhotoView*)[_scrollView dequeueReusablePage];
  if (!photoView) {
    photoView = [self createPhotoView];
    photoView.defaultImage = _defaultImage;
    photoView.captionHidden = _toolbar.alpha == 0;
  }

  id<TTPhoto> photo = [_photoSource photoAtIndex:pageIndex];
  [self showPhoto:photo inView:photoView];
  
  return photoView;
}

- (CGSize)scrollView:(TTScrollView*)scrollView sizeOfPageAtIndex:(NSInteger)pageIndex {
  id<TTPhoto> photo = [_photoSource photoAtIndex:pageIndex];
  return photo ? photo.size : CGSizeZero;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// TTThumbsViewControllerDelegate

- (void)thumbsViewController:(TTThumbsViewController*)controller didSelectPhoto:(id<TTPhoto>)photo {
  self.centerPhoto = photo;
  [self hideThumbnails];
}

///////////////////////////////////////////////////////////////////////////////////////////////////

- (void)setPhotoSource:(id<TTPhotoSource>)photoSource {
  if (_photoSource != photoSource) {
    [_photoSource.delegates removeObject:self];
    [_photoSource release];
    _photoSource = [photoSource retain];
    [_photoSource.delegates addObject:self];
  
    [self moveToPhotoAtIndex:0 withDelay:NO];
    [self invalidateView];
  }
}

- (void)setCenterPhoto:(id<TTPhoto>)photo {
  if (_centerPhoto != photo) {
    if (photo.photoSource != _photoSource) {
      [_photoSource.delegates removeObject:self];
      [_photoSource release];
      _photoSource = [photo.photoSource retain];
      [_photoSource.delegates addObject:self];
    }

    [self moveToPhotoAtIndex:photo.index withDelay:NO];
    [self invalidateView];
  }
}

- (TTPhotoView*)createPhotoView {
  return [[[TTPhotoView alloc] initWithFrame:CGRectZero] autorelease];
}

- (TTThumbsViewController*)createThumbsViewController {
  return [[[TTThumbsViewController alloc] init] autorelease];
}

@end
