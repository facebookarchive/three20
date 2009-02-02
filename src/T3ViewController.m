#import "Three20/T3ViewController.h"
#import "Three20/T3ActivityLabel.h"
#import "Three20/T3ErrorView.h"
#import "Three20/T3URLCache.h"

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation T3ViewController

@synthesize viewState = _viewState, contentState = _contentState, contentError = _contentError,
  appearing = _appearing, appeared = _appeared;

- (id)init {
  if (self = [super init]) {  
    _viewState = nil;
    _validity = T3ViewValid;
    _contentState = T3ContentUnknown;
    _contentError = nil;
    _statusView = nil;
    _appearing = NO;
    _appeared = NO;
    _unloaded = NO;
  }
  return self;
}

- (void)dealloc {
  T3LOG(@"DEALLOC %@", self);
  [_viewState release];
  [_contentError release];

  [_statusView release];
  [self unloadView];

  if (_appeared) {
    // The controller is supposed to handle this but sometimes due to leaks it does not, so
    // we have to force it here
    [self.view removeSubviews];
  }

  [super dealloc];
}

///////////////////////////////////////////////////////////////////////////////////////////////////

- (void)restoreViewFromState {
  if (_viewState) {
    [self restoreView:_viewState];
    [_viewState release];
    _viewState = nil;
  }
}

- (void)updateViewInternal {
  T3ViewControllerState validity = _validity;
  _validity = T3ViewValid;
  
  if (validity & T3ViewInvalidContent) {
    [self updateContent];
  }

  if (validity & T3ViewInvalidView) {
    // Ensure the view is loaded
    self.view;

    [self updateView];
    [self restoreViewFromState];
  }
}

//- (void)changeStyleFrom:(T3ViewControllerStyle)from {
//  if (from != style) {
//    UINavigationBar* bar = self.navigationController.navigationBar;
//    if (style == T3ViewControllerStyleTranslucent) {
//      bar.tintColor = nil;
//      bar.barStyle = UIBarStyleBlackTranslucent;
//      [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackTranslucent
//        animated:YES];
//    } else {
//      bar.tintColor = [T3Resources facebookDarkBlue];
//      bar.barStyle = UIBarStyleDefault;
//      [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault
//        animated:YES];
//    }
//  }
//}
//
//- (void)updateStyle {
//  T3ViewController* topController = (T3ViewController*)self.navigationController.topViewController;
//  if (topController != self) {
//    [self changeStyleFrom:topController.style];
//  } else {
//    NSArray* controllers = self.navigationController.viewControllers;
//    if (controllers.count > 1) {
//      T3ViewController* backController = [controllers objectAtIndex:controllers.count-2];
//      [self changeStyleFrom:backController.style];
//    }
//  }
//  [topController release];
//}

- (void)showStatusView:(UIView*)view {
    [_statusView removeFromSuperview];
  [_statusView release];
  _statusView = [view retain];

  if (_statusView) {
    [self.view addSubview:_statusView];
  }
}

- (void)showStatusCover:(UIView*)view {
  [self showStatusView:view];
  _statusView.frame = self.view.bounds;
}

- (void)showStatusBanner:(UIView*)view {
  [self showStatusView:view];
  _statusView.frame = self.view.bounds;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// UIViewController

- (void)loadView {
  UIView* contentView = [[[UIView alloc]
    initWithFrame:[UIScreen mainScreen].applicationFrame] autorelease];
	contentView.autoresizesSubviews = YES;
  self.view = contentView;
}

- (void)viewWillAppear:(BOOL)animated {
  if (_unloaded) {
    _unloaded = NO;
    [self loadView];
  }

  _appearing = YES;
    
  [T3URLCache sharedCache].paused = YES;
  
  if (_validity != T3ViewValid) {
    [self updateViewInternal];
  }

  _appeared = YES;
}

- (void)viewDidAppear:(BOOL)animated {
  [T3URLCache sharedCache].paused = NO;
}

- (void)viewDidDisappear:(BOOL)animated {
  _appearing = NO;
}

- (void)didReceiveMemoryWarning {
  T3LOG(@"MEMORY WARNING FOR %@", self);

  if (!_appearing) {
    if (_appeared) {
      NSMutableDictionary* state = [[NSMutableDictionary alloc] init];
      [self persistView:state];
      _viewState = state;
      _validity = T3ViewInvalidView;

      UIView* view = self.view;
      T3LOG(@"UNLOAD VIEW %@", self);      

      [super didReceiveMemoryWarning];

      // Sometimes, like when the controller is in a tabbed bar, the view won't
      // be destroyed here like it should by the superclass - so let's do it ourselves!
      [view removeSubviews];

      _unloaded = YES;
      _appeared = NO;
      
      [_statusView release];
      _statusView = nil;
      [self unloadView];
    }
  }
  
  if (!_appeared) {
    _validity = T3ViewInvalidContent;
  }
}

///////////////////////////////////////////////////////////////////////////////////////////////////

- (id<T3Object>)viewObject {
  return nil;
}

- (NSString*)viewType {
  return nil;
}

- (void)setContentState:(T3ContentState)contentState {
  if (_contentState != contentState) {
    _contentState = contentState;
    
    if (!(_contentState & T3ContentError)) {
      [_contentError release];
      _contentError = nil;
    }
    
    [self invalidate:T3ViewInvalidView];
  }
}

- (void)showObject:(id<T3Object>)object inView:(NSString*)viewType withState:(NSDictionary*)state {
  [_viewState release];
  _viewState = [state retain];
}

- (void)persistView:(NSMutableDictionary*)state {
}

- (void)restoreView:(NSDictionary*)state {
} 

- (void)invalidate:(T3ViewControllerState)state {
  if (!(_validity & state)) {
    _validity |= state;
    if (_validity & T3ViewInvalidContent) {
      _contentState = T3ContentUnknown;
    }
    if (_appearing) {
      [self updateViewInternal];
    }
  }
}

- (void)updateContent {
  [self invalidate:T3ViewInvalidView];
}

- (void)updateView {
  if (_contentState & T3ContentReady) {
    if (_contentState & T3ContentActivity) {
      // XXXjoe Create an activity label
      [self showStatusBanner:nil];
    } else if (_contentState & T3ContentError) {
      // XXXjoe Create a yellow banner
      [self showStatusBanner:nil];
    } else {
      [self showStatusBanner:nil];
    }
  } else {
    if (_contentState & T3ContentActivity) {
      [self showStatusCover:[[[T3ActivityLabel alloc] initWithFrame:CGRectZero
        style:T3ActivityLabelStyleGray text:[self titleForActivity]] autorelease]];
    } else if (_contentState & T3ContentError) {
      [self showStatusCover:[[[T3ErrorView alloc] initWithTitle:[self titleForError:_contentError]
        caption:[self descriptionForError:_contentError]
        image:[self imageForError:_contentError]] autorelease]];
    } else {
      [self showStatusCover:[[[T3ErrorView alloc] initWithTitle:[self titleForNoContent]
        caption: [self descriptionForNoContent] image:[self imageForNoContent]] autorelease]];
    }
  }
}

- (void)reloadContent {
}

- (void)resetView {
}

- (void)unloadView {
}

- (NSString*)titleForActivity {
  return NSLocalizedString(@"Loading...", @"");
}

- (UIImage*)imageForError:(NSError*)error {
  return nil;
}

- (NSString*)titleForError:(NSError*)error {
  return nil;
}

- (NSString*)descriptionForError:(NSError*)error {
  return NSLocalizedString(@"An error occurred.", @"");
}

- (UIImage*)imageForNoContent {
  return nil;
}

- (NSString*)titleForNoContent {
  return nil;
}

- (NSString*)descriptionForNoContent {
  return NSLocalizedString(@"There is nothing to show here.", @"");
}

@end
