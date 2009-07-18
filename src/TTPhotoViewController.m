#import "Three20/TTPhotoViewController.h"
#import "Three20/TTURLCache.h"
#import "Three20/TTURLRequest.h"
#import "Three20/TTPhotoView.h"
#import "Three20/TTNavigator.h"

///////////////////////////////////////////////////////////////////////////////////////////////////
// global

static const NSTimeInterval kPhotoLoadLongDelay = 0.5;
static const NSTimeInterval kPhotoLoadShortDelay = 0.25;
static const NSTimeInterval kSlideshowInterval = 2;

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation TTPhotoViewController

@synthesize photoSource = _photoSource, centerPhoto = _centerPhoto,
  centerPhotoIndex = _centerPhotoIndex, defaultImage = _defaultImage;

///////////////////////////////////////////////////////////////////////////////////////////////////
// private

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
  if (!_photoSource.numberOfPhotos || _photoSource.numberOfPhotos == NSIntegerMax) {
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

- (void)updateVisiblePhotoViews {
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
  if ((self.hasViewAppeared || self.isViewAppearing) && progress >= 0 && !self.centerPhotoView) {
    [self.statusView showProgress:progress];
    self.statusView.hidden = NO;
  } else {
    _photoStatusView.hidden = YES;
  }
}

- (void)showStatus:(NSString*)status {
  [_statusText release];
  _statusText = [status retain];

  if ((self.hasViewAppeared || self.isViewAppearing) && status && !self.centerPhotoView) {
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

- (NSString*)URLForThumbnails {
  if ([self.photoSource respondsToSelector:@selector(URLValueWithName:)]) {
    return [self.photoSource performSelector:@selector(URLValueWithName:)
                             withObject:@"TTThumbsViewController"];
  } else {
    return nil;
  }
}

- (void)showThumbnails {
  NSString* URL = [self URLForThumbnails];
  if (!_thumbsController) {
    if (URL) {
      // The photo source has a URL mapping in TTURLMap, so we use that to show the thumbs
      NSDictionary* query = [NSDictionary dictionaryWithObject:self forKey:@"delegate"];
      _thumbsController = [[[TTNavigator navigator] viewControllerForURL:URL query:query] retain];
      [[TTNavigator navigator].URLMap setObject:_thumbsController forURL:URL];
    } else {
      // The photo source had no URL mapping in TTURLMap, so we let the subclass show the thumbs
      _thumbsController = [[self createThumbsViewController] retain];
      _thumbsController.photoSource = _photoSource;
    }
  }
    
  if (URL) {
    TTOpenURL(URL);
  } else {
    [self.navigationController pushViewController:_thumbsController
                               animatedWithTransition:UIViewAnimationTransitionCurlDown];
  }
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
  self.navigationController.navigationBarHidden = NO;
}

- (void)hideBarsAnimationDidStop {
  self.navigationController.navigationBarHidden = YES;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// NSObject

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
    self.wantsFullScreenLayout = YES;
  }
  return self;
}

- (void)dealloc {
  _thumbsController.delegate = nil;
  TT_RELEASE_MEMBER(_thumbsController);
  [_slideshowTimer invalidate];
  _slideshowTimer = nil;
  [_loadTimer invalidate];
  _loadTimer = nil;
  TT_RELEASE_MEMBER(_centerPhoto);
  TT_RELEASE_MEMBER(_photoSource);
  TT_RELEASE_MEMBER(_statusText);
  TT_RELEASE_MEMBER(_defaultImage);
  [super dealloc];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// UIViewController

- (void)loadView {
  CGRect screenFrame = [UIScreen mainScreen].bounds;
  self.view = [[[UIView alloc] initWithFrame:screenFrame] autorelease];
    
  CGRect innerFrame = CGRectMake(0, 0,
                                 screenFrame.size.width, screenFrame.size.height);
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
    CGRectMake(0, screenFrame.size.height - TOOLBAR_HEIGHT,
               screenFrame.size.width, TOOLBAR_HEIGHT)];
  _toolbar.barStyle = self.navigationBarStyle;
  _toolbar.autoresizingMask = UIViewAutoresizingFlexibleWidth
                              | UIViewAutoresizingFlexibleTopMargin;
  _toolbar.items = [NSArray arrayWithObjects:
    space, _previousButton, space, _nextButton, space, nil];
  [_innerView addSubview:_toolbar];    
}

- (void)viewDidUnload {
  [super viewDidUnload];
  _scrollView.delegate = nil;
  _scrollView.dataSource = nil;
  TT_RELEASE_MEMBER(_innerView);
  TT_RELEASE_MEMBER(_scrollView);
  TT_RELEASE_MEMBER(_photoStatusView);
  TT_RELEASE_MEMBER(_nextButton);
  TT_RELEASE_MEMBER(_previousButton);
  TT_RELEASE_MEMBER(_toolbar);
}

- (void)viewWillDisappear:(BOOL)animated {
  [super viewWillDisappear:animated];

  [self pauseAction];
  if (self.nextViewController) {
    [self showBars:YES animated:NO];
  }
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// UIViewController (TTCategory)

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
// TTModelViewController

- (BOOL)shouldLoad {
  return NO;
}

- (BOOL)shouldLoadMore {
  return !_centerPhoto;
}

- (void)modelDidChangeLoadingState {
  if (self.modelState & TTModelStateLoading) {
    [self showProgress:0];
  } else {
    [self showProgress:-1];
  }
}

- (void)modelDidChangeLoadedState {
  if (self.modelState & TTModelStateLoaded) {
    if (_photoSource.numberOfPhotos > 0) {
      [self showStatus:nil];
    } else {
      [self showStatus:TTLocalizedString(@"This photo set contains no photos.", @"")];
    }
  } else if (self.modelState & TTModelStateLoadedError) {
    [self showStatus:TTLocalizedString(@"This photo set could not be loaded.", @"")];
  }

  [self updateChrome];
  [self updatePhotoView];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// TTPhotoSourceDelegate

- (void)modelDidFinishLoad:(id<TTModel>)model {
  if (model == _model) {
    if (_centerPhotoIndex >= _photoSource.numberOfPhotos) {
      // We were positioned at an index that is past the end, so move to the last photo
      [self moveToPhotoAtIndex:_photoSource.numberOfPhotos - 1 withDelay:NO];
      [_scrollView reloadData];
      [self resetVisiblePhotoViews];
    } else {
      [self updateVisiblePhotoViews];
    }
  }
  [super modelDidFinishLoad:model];
}

- (void)model:(id<TTModel>)model didFailLoadWithError:(NSError*)error {
  if (model == _model) {
    [self resetVisiblePhotoViews];
  }
  [super model:model didFailLoadWithError:error];
}

- (void)modelDidCancelLoad:(id<TTModel>)model {
  if (model == _model) {
    [self resetVisiblePhotoViews];
  }
  [super modelDidCancelLoad:model];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// TTScrollViewDelegate

- (void)scrollView:(TTScrollView*)scrollView didMoveToPageAtIndex:(NSInteger)pageIndex {
  if (pageIndex != _centerPhotoIndex) {
    [self moveToPhotoAtIndex:pageIndex withDelay:YES];
    [self refresh];
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

- (void)scrollViewWillRotate:(TTScrollView*)scrollView
        toOrientation:(UIInterfaceOrientation)orientation {
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
  [controller removeFromSupercontroller];
}

- (BOOL)thumbsViewController:(TTThumbsViewController*)controller
        shouldNavigateToPhoto:(id<TTPhoto>)photo {
  return NO;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// public

- (void)setPhotoSource:(id<TTPhotoSource>)photoSource {
  if (_photoSource != photoSource) {
    [_photoSource release];
    _photoSource = [photoSource retain];
    
    [self moveToPhotoAtIndex:0 withDelay:NO];
    self.model = _photoSource;
  }
}

- (void)setCenterPhoto:(id<TTPhoto>)photo {
  if (_centerPhoto != photo) {
    if (photo.photoSource != _photoSource) {
      [_photoSource release];
      _photoSource = [photo.photoSource retain];

      [self moveToPhotoAtIndex:photo.index withDelay:NO];
      self.model = _photoSource;
    } else {
      [self moveToPhotoAtIndex:photo.index withDelay:NO];
      [self refresh];
    }
  }
}

- (TTPhotoView*)createPhotoView {
  return [[[TTPhotoView alloc] init] autorelease];
}

- (TTThumbsViewController*)createThumbsViewController {
  return [[[TTThumbsViewController alloc] initWithDelegate:self] autorelease];
}

@end
