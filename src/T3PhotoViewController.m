#import "Three20/T3PhotoViewController.h"
#import "Three20/T3ThumbsViewController.h"
#import "Three20/T3URLCache.h"
#import "Three20/T3UnclippedView.h"
#import "Three20/T3PhotoSource.h"

///////////////////////////////////////////////////////////////////////////////////////////////////

@interface T3PhotoScrollView : UIScrollView
@end

@implementation T3PhotoScrollView

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent*)event {
  if (self.pagingEnabled) {
    [super touchesBegan:touches withEvent:event];
  }
  
  UITouch* touch = [touches anyObject];
  if (touch.view == self) {
    [self.delegate performSelector:@selector(photoTouchBegan:) withObject:touch];
  }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent*)event {
  if (self.pagingEnabled) {
    [super touchesMoved:touches withEvent:event];
  }
}

- (void)touchesEnded:(NSSet*)touches withEvent:(UIEvent *)event {
  if (self.pagingEnabled) {
    [super touchesEnded:touches withEvent:event];
  }
  
  UITouch* touch = [touches anyObject];
  if (touch.view == self) {
    [self.delegate performSelector:@selector(photoTouchEnded:) withObject:touch];
  }
}

@end

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation T3PhotoViewController

@synthesize photoSource, visiblePhoto, visiblePhotoIndex;

- (id)init {
  if (self = [super init]) {
    photoSource = nil;
    visiblePhoto = nil;
    visiblePhotoIndex = T3_NULL_PHOTO_INDEX;
    previousBarStyle = 0;
    orientation = 0;
    
    self.hidesBottomBarWhenPushed = YES;
    self.navigationItem.backBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:@"Photo"
      style:UIBarButtonItemStylePlain target:nil action:nil] autorelease];
  }
  return self;
}

- (void)dealloc {
  [photoSource release];
  [super dealloc];
}

///////////////////////////////////////////////////////////////////////////////////////////////////

- (UIInterfaceOrientation)getCurrentOrientation {
  UIInterfaceOrientation orient = [UIDevice currentDevice].orientation;
  if (!orient) {
    return UIInterfaceOrientationPortrait;
  } else {
    return orient;
  }
}

- (BOOL)isShowingChrome {
  UINavigationBar* bar = self.navigationController.navigationBar;
  return bar ? bar.alpha != 0 : 1;
}

- (void)showNavigationBar:(BOOL)show {
  self.navigationController.navigationBar.alpha = show ? 1 : 0;
}

- (void)updateTitle {
  if (photoSource.numberOfPhotos > 1) {
    self.title = [NSString stringWithFormat:@"%d of %d", visiblePhoto.index+1,
      photoSource.numberOfPhotos];
  } else {
    self.title = photoSource.title;
  }
}

- (void)updateScrollViewSize {
  int count = photoSource.numberOfPhotos;
  CGRect screenFrame = [UIScreen mainScreen].bounds;
  if (orientation == UIInterfaceOrientationLandscapeLeft
        || orientation == UIInterfaceOrientationLandscapeRight) {
    scrollView.contentSize = CGSizeMake(screenFrame.size.width,
      screenFrame.size.height*count);
  } else {
    scrollView.contentSize = CGSizeMake(screenFrame.size.width*count,
      screenFrame.size.height);
  }
}

- (NSString*)loadingCaptionForPhotosource {
  return photoSource.title
    ? [NSString stringWithFormat:@"Loading %@...", photoSource.title]
    : @"Loading...";
}

- (void)loadPhotos {
  if (!photoSource.loading) {
    self.title = photoSource.title;
    
    [photoSource loadPhotosFromIndex:photoSource.isInvalid ? 0 : photoSource.maxPhotoIndex+1
      toIndex:-1 delegate:self];
  }
}

- (void)loadImages {
  [photoViewRight loadThumbnail];    
  [photoViewLeft loadThumbnail];    
  [photoView loadImage];
}

- (NSUInteger)photoIndexOfScrollOffset {
  if (orientation == UIInterfaceOrientationLandscapeLeft) {
    CGFloat maxWidth = scrollView.contentSize.height;
    return (maxWidth - (scrollView.contentOffset.y + scrollView.frame.size.height))
      / scrollView.frame.size.height;
  } else if (orientation == UIInterfaceOrientationLandscapeRight) {
    return scrollView.contentOffset.y/scrollView.frame.size.height;
  } else {
    return scrollView.contentOffset.x/scrollView.frame.size.width;
  }
}

- (void)showPhoto:(id<T3Photo>)aPhoto index:(NSUInteger)index inView:(T3PhotoView*)view {
  if (!aPhoto) {
    [view showActivity:[self loadingCaptionForPhotosource]];
  } else {
    [view showActivity:nil];
  }

  view.photo = aPhoto;

  if (orientation == UIInterfaceOrientationLandscapeLeft) {
    CGFloat maxWidth = scrollView.contentSize.height;
    view.frame = CGRectMake(0, maxWidth - ((index+1) * scrollView.height),
      scrollView.width, scrollView.height);
  } else if (orientation == UIInterfaceOrientationLandscapeRight) {
    view.frame = CGRectMake(0, index * scrollView.height, scrollView.width, scrollView.height);
  } else {
    CGFloat x = index == NSUIntegerMax ? 0 : index * scrollView.width;
    view.frame = CGRectMake(x, 0, scrollView.width, scrollView.height);
  }
}

- (void)rotate:(UIInterfaceOrientation)toOrient from:(UIInterfaceOrientation)fromOrient
    animated:(BOOL)animated {
  if (toOrient != fromOrient) {
    orientation = toOrient;

    [photoViewLeft layout:toOrient from:0 stage:0];
    [photoViewRight layout:toOrient from:0 stage:0];

    if (animated) {
      [UIView beginAnimations:nil context:(void*)toOrient];
      [UIView setAnimationDuration:0.3];
      [UIView setAnimationDelegate:self];
      [UIView setAnimationDidStopSelector:@selector(rotateAnimationStopped:finished:context:)];
      [photoView layout:toOrient from:fromOrient stage:1];
      [UIView commitAnimations];
    } else {
      [photoView layout:toOrient from:fromOrient stage:0];
    }
  }
}

- (void)autorotate:(UIInterfaceOrientation)toOrient animated:(BOOL)animated {
  if (toOrient != orientation) {
    UIInterfaceOrientation fromOrient = orientation;
    orientation = toOrient;
      
    if (photoSource) {
      [self updateScrollViewSize];

      if (!photoViewRight.hidden) {
        [self showPhoto:photoViewRight.photo index:visiblePhotoIndex+1 inView:photoViewRight];
      }
      if (!photoViewLeft.hidden) {
        [self showPhoto:photoViewLeft.photo index:visiblePhotoIndex-1 inView:photoViewLeft];
      }
      [self showPhoto:photoView.photo index:visiblePhotoIndex inView:photoView];

      [scrollView scrollRectToVisible:photoView.frame animated:NO];
    }
    
    [self rotate:toOrient from:fromOrient animated:animated];
  }
}

- (void)rotateAnimationStopped:(NSString*)animationId finished:(NSNumber*)finished
    context:(void*)context {
  [photoView layout:(UIInterfaceOrientation)context from:0 stage:2];

  [UIView beginAnimations:nil context:NULL];
  [UIView setAnimationDuration:0.3];

  [photoView layout:(UIInterfaceOrientation)context from:0 stage:0];
  
  [UIView commitAnimations];
}

- (void)moveToPhoto:(id<T3Photo>)aPhoto atIndex:(NSUInteger)index animated:(BOOL)animated {
  visiblePhotoIndex = index;
  visiblePhoto = aPhoto;

  if (index+1 < photoSource.numberOfPhotos && index != T3_NULL_PHOTO_INDEX) {
    id<T3Photo> nextPhoto = !photoSource.isInvalid ? [photoSource photoAtIndex:index+1] : nil;
    [self showPhoto:nextPhoto index:index+1 inView:photoViewRight];
    photoViewRight.hidden = NO;
  } else {
    photoViewRight.photo = nil;
    photoViewRight.hidden = YES;
  }

  if (index > 0 && index != T3_NULL_PHOTO_INDEX) {
    id<T3Photo> prevPhoto = !photoSource.isInvalid ? [photoSource photoAtIndex:index-1] : nil;
    [self showPhoto:prevPhoto index:index-1 inView:photoViewLeft];
    photoViewLeft.hidden = NO;
  } else {
    photoViewLeft.photo = nil;
    photoViewLeft.hidden = YES;
  }
  
  if (visiblePhoto) {
    photoView.hidden = NO;
    [self showPhoto:visiblePhoto index:visiblePhotoIndex inView:photoView];
    [self updateTitle];
    if (animated) {
      scrollView.contentOffset = CGPointMake(photoView.x, photoView.y);
    }
  } else {
    [self showPhoto:nil index:visiblePhotoIndex inView:photoView];
  }

  if (!animated) {
    [self loadImages];

    if (photoSource.isInvalid || visiblePhotoIndex >= photoSource.maxPhotoIndex+1) {
      [self loadPhotos];
    }
  } else {
    [photoView loadPreview];

    if (!visiblePhoto) {
      [self loadPhotos];
    }
  }
}

- (void)selectPhotoDelayed:(NSTimer*)timer {
  [T3URLCache sharedCache].paused = NO;
  [self loadImages];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// UIViewController

- (void)loadView {
  [super loadView];
  
  CGRect screenFrame = [UIScreen mainScreen].bounds;
  self.view = [[[T3UnclippedView alloc] initWithFrame:screenFrame] autorelease];
  self.view.backgroundColor = [UIColor blackColor];
  
  scrollView = [[T3PhotoScrollView alloc]
    initWithFrame:CGRectOffset(screenFrame, 0, -CHROME_HEIGHT)];
  scrollView.delegate = self;
  scrollView.backgroundColor = [UIColor blackColor];
  scrollView.pagingEnabled = YES;
  scrollView.showsHorizontalScrollIndicator = NO;
  scrollView.showsVerticalScrollIndicator = NO;
  scrollView.delaysContentTouches = NO;
  scrollView.multipleTouchEnabled = YES;
  [self.view addSubview:scrollView];
  
  photoView = [[T3PhotoView alloc] initWithFrame:screenFrame];
  photoView.delegate = self;
  [scrollView addSubview:photoView];

  photoViewLeft = [[T3PhotoView alloc] initWithFrame:screenFrame];
  photoViewLeft.delegate = self;
  [scrollView addSubview:photoViewLeft];

  photoViewRight = [[T3PhotoView alloc] initWithFrame:screenFrame];
  photoViewRight.delegate = self;
  [scrollView addSubview:photoViewRight];
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];

  UINavigationBar* bar = self.navigationController.navigationBar;
  if (bar.barStyle != UIBarStyleBlackTranslucent) {
    if (!self.nextViewController) {
      previousBarStyle = bar.barStyle;
    }

    bar.barStyle = UIBarStyleBlackTranslucent;
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackTranslucent
      animated:YES];
  }
  
  orientation = [self getCurrentOrientation];
  [[NSNotificationCenter defaultCenter] addObserver:self
    selector:@selector(deviceOrientationDidChange:)
    name:@"UIDeviceOrientationDidChangeNotification" object:nil];
}

- (void)viewDidAppear:(BOOL)animated {
  [super viewDidAppear:animated];
  [self loadImages];

  if (0) {
    scrollView.frame = CGRectOffset(scrollView.frame, 0, TOOLBAR_HEIGHT);
  } else {
    self.view.superview.frame = CGRectOffset(self.view.superview.frame, 0, TOOLBAR_HEIGHT);
  }
}

- (void)viewWillDisappear:(BOOL)animated {
  [super viewWillDisappear:animated];

  if (1) {
    scrollView.frame = CGRectOffset(scrollView.frame, 0, TOOLBAR_HEIGHT);
  } else {
    self.view.superview.frame = CGRectOffset(self.view.superview.frame, 0, TOOLBAR_HEIGHT);
  }

  // If we're going backwards...
  if (!self.nextViewController) {
    UINavigationBar* bar = self.navigationController.navigationBar;
    if (previousBarStyle != UIBarStyleBlackTranslucent) {
      bar.barStyle = previousBarStyle;
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

- (void)viewDidDisappear:(BOOL)animated {
  [super viewDidDisappear:animated];

  [[NSNotificationCenter defaultCenter] removeObserver:self
    name:@"UIDeviceOrientationDidChangeNotification" object:nil];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// T3ViewController

- (id<T3Object>)viewObject {
  return visiblePhoto;
}

- (void)showObject:(id<T3Object>)object inView:(NSString*)name withState:(NSDictionary*)state {
  [super showObject:object inView:name withState:state];
  
  if ([object conformsToProtocol:@protocol(T3PhotoSource)]) {
    self.photoSource = (id<T3PhotoSource>)object;
  } else if ([object conformsToProtocol:@protocol(T3Photo)]) {
    self.visiblePhoto = (id<T3Photo>)object;
  }
}

- (void)updateContent {
  if (photoSource.isInvalid || !visiblePhoto.url) {
    [self loadPhotos];
  } else if (photoSource.numberOfPhotos) {
    self.contentState = T3ViewContentReady;
  } else {
    self.contentState = T3ViewContentEmpty;
  }
}

- (void)updateView {
  [self updateScrollViewSize];
  [self rotate:[self getCurrentOrientation] from:orientation animated:NO];

  if (visiblePhotoIndex == T3_NULL_PHOTO_INDEX) {
    int actualIndex = [photoSource indexOfPhoto:visiblePhoto];
    if (actualIndex == NSNotFound) {
      id<T3Photo> actualPhoto = [photoSource photoAtIndex:0];
      [self moveToPhoto:actualPhoto atIndex:0 animated:NO];
    } else {
      [self moveToPhoto:visiblePhoto atIndex:actualIndex animated:NO];
    }
  } else if (visiblePhotoIndex > photoSource.numberOfPhotos-1) {
    [self moveToPhoto:[photoSource photoAtIndex:0] atIndex:0 animated:NO];
  } else {
    [self moveToPhoto:[photoSource photoAtIndex:visiblePhotoIndex] atIndex:visiblePhotoIndex
      animated:NO];
  }
}

- (void)updateViewWithEmptiness {
  [photoView showActivity:nil];
}

- (void)updateViewWithActivity:(NSString*)activityText {
  [photoView showActivity:activityText];
}

- (void)updateViewWithError:(NSError*)error {
  [photoView showActivity:nil];
}

- (void)unloadView {
  [scrollView release];
  [photoView release];
  [photoViewLeft release];
  [photoViewRight release];
  scrollView = nil;
  photoView = nil;
  photoViewLeft = nil;
  photoViewRight = nil;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// T3PhotoSourceDelegate

- (void)photoSourceLoading:(id<T3PhotoSource>)aPhotoSource fromIndex:(NSUInteger)fromIndex
   toIndex:(NSUInteger)toIndex {
  [self setContentStateActivity:[self loadingCaptionForPhotosource]];
}

- (void)photoSourceLoaded:(id<T3PhotoSource>)aPhotoSource {
  if (photoSource.numberOfPhotos) {
    self.contentState = T3ViewContentReady;
  } else {
    self.contentState = T3ViewContentEmpty;
  }
}

- (void)photoSource:(id<T3PhotoSource>)aPhotoSource loadFailedWithError:(NSError*)error {
  [self setContentStateError:error];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// UIScrollViewDelegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
  [self showChrome:NO animated:NO];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)aScrollView {
  NSUInteger index = [self photoIndexOfScrollOffset];
  if (index != visiblePhotoIndex) {
    id<T3Photo> aPhoto = !photoSource.isInvalid ? [photoSource photoAtIndex:index] : nil;
    if (aPhoto) {
      if (photoViewLeft.photo == aPhoto) {
        T3PhotoView* a = photoViewRight;
        photoViewRight = photoView;
        photoView = photoViewLeft;
        photoViewLeft = a;
      } else if (photoViewRight.photo == aPhoto) {
        T3PhotoView* a = photoViewLeft;
        photoViewLeft = photoView;
        photoView = photoViewRight;
        photoViewRight = a;
      }
    }
    
    [self moveToPhoto:aPhoto atIndex:index animated:NO];
  }
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// UIDeviceOrientationDidChangeNotification

- (void)deviceOrientationDidChange:(void*)object {
  // Make sure we only try to rotate to one of the three supported orientations
  UIInterfaceOrientation orient = [self getCurrentOrientation];
  if (orient != UIInterfaceOrientationLandscapeLeft
        && orient != UIInterfaceOrientationLandscapeRight
        && orient != UIInterfaceOrientationPortrait) {
    orient = orientation;
  }
        
  if (orient != orientation) {
    [self showChrome:NO animated:YES];
    [self autorotate:orient animated:YES];
  }
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// T3PhotoScrollViewDelegate

- (void)photoTouchBegan:(UITouch*)touch {
  [photoView photoTouchBegan:touch];
}

- (void)photoTouchEnded:(UITouch*)touch {
  [photoView photoTouchEnded:touch];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// T3PhotoViewDelegate

- (void)photoViewTapped:(T3PhotoView*)aPhotoView {
  [self showChrome:![self isShowingChrome] animated:YES];
}

///////////////////////////////////////////////////////////////////////////////////////////////////

- (void)setPhotoSource:(id<T3PhotoSource>)aSource {
  if (photoSource != aSource) {
    [photoSource release];
    photoSource = [aSource retain];
  
    visiblePhoto = [photoSource photoAtIndex:0];
    [self invalidate:T3ViewInvalidContent];
  }
}

- (void)setVisiblePhoto:(id<T3Photo>)aPhoto {
  if (visiblePhoto != aPhoto) {
    visiblePhoto = aPhoto;

    if (visiblePhoto.photoSource != photoSource) {
      [photoSource release];
      photoSource = [visiblePhoto.photoSource retain];
    }
  
    [self invalidate:T3ViewInvalidContent];
  }
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

@end
