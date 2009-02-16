#import "Three20/TTViewController.h"
#import "Three20/TTActivityLabel.h"
#import "Three20/TTErrorView.h"
#import "Three20/TTURLRequestQueue.h"

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation TTViewController

@synthesize viewState = _viewState, contentState = _contentState, contentError = _contentError,
  appearing = _appearing, appeared = _appeared;

- (id)init {
  if (self = [super init]) {  
    _viewState = nil;
    _contentState = TTContentUnknown;
    _contentError = nil;
    _previousBar = nil;
    _previousBarStyle = 0;
    _previousBarTintColor = nil;
    _previousStatusBarStyle = 0;
    _statusView = nil;
    _invalid = YES;
    _appearing = NO;
    _appeared = NO;
    _unloaded = NO;
  }
  return self;
}

- (void)dealloc {
  TTLOG(@"DEALLOC %@", self);

  [[TTURLRequestQueue mainQueue] cancelRequestsWithDelegate:self];

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

- (void)validateView {
  if (_invalid) {
    // Ensure the view is loaded
    self.view;

    [self updateView];

    if (_viewState) {
      [self restoreView:_viewState];
      [_viewState release];
      _viewState = nil;
    }

    _invalid = NO;
  }
}

//- (void)changeStyleFrom:(TTViewControllerStyle)from {
//  if (from != style) {
//    UINavigationBar* bar = self.navigationController.navigationBar;
//    if (style == TTViewControllerStyleTranslucent) {
//      bar.tintColor = nil;
//      bar.barStyle = UIBarStyleBlackTranslucent;
//      [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackTranslucent
//        animated:YES];
//    } else {
//      bar.tintColor = [TTResources facebookDarkBlue];
//      bar.barStyle = UIBarStyleDefault;
//      [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault
//        animated:YES];
//    }
//  }
//}
//
//- (void)updateStyle {
//  TTViewController* topController = (TTViewController*)self.navigationController.topViewController;
//  if (topController != self) {
//    [self changeStyleFrom:topController.style];
//  } else {
//    NSArray* controllers = self.navigationController.viewControllers;
//    if (controllers.count > 1) {
//      TTViewController* backController = [controllers objectAtIndex:controllers.count-2];
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
  view.frame = self.view.bounds;
  [self showStatusView:view];
}

- (void)showStatusBanner:(UIView*)view {
  view.frame = CGRectMake(0, self.view.height - 50, self.view.width, 50);
  view.userInteractionEnabled = NO;
  [self showStatusView:view];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// UIViewController

- (void)loadView {
  CGRect frame = [UIScreen mainScreen].applicationFrame;
  UIView* contentView = [[[UIView alloc] initWithFrame:frame] autorelease];
	contentView.autoresizesSubviews = YES;
	contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
  contentView.backgroundColor = [UIColor whiteColor];
  self.view = contentView;
}

- (void)viewWillAppear:(BOOL)animated {
  if (_unloaded) {
    _unloaded = NO;
    [self loadView];
  }

  [TTURLRequestQueue mainQueue].suspended = YES;

  if (_contentState == TTContentUnknown) {
    [self updateContent];
  }
  [self refreshContent];

  _appearing = YES;
  [self validateView];
  _appeared = YES;
}

- (void)viewDidAppear:(BOOL)animated {
  [TTURLRequestQueue mainQueue].suspended = NO;
}

- (void)viewDidDisappear:(BOOL)animated {
  _appearing = NO;
}

- (void)didReceiveMemoryWarning {
  TTLOG(@"MEMORY WARNING FOR %@", self);

  if (!_appearing) {
    if (_appeared) {
      NSMutableDictionary* state = [[NSMutableDictionary alloc] init];
      [self persistView:state];
      _viewState = state;

      UIView* view = self.view;
      [super didReceiveMemoryWarning];

      // Sometimes, like when the controller is in a tab bar, the view won't
      // be destroyed here like it should by the superclass - so let's do it ourselves!
      [view removeSubviews];

      _unloaded = YES;
      _invalid = YES;
      _appeared = NO;
      
      TTLOG(@"UNLOAD VIEW %@", self);      
      [_statusView release];
      _statusView = nil;
      [self unloadView];
    }
  }
  
  if (!_appeared) {
    _contentState = TTContentUnknown;
  }
}

///////////////////////////////////////////////////////////////////////////////////////////////////

- (id<TTObject>)viewObject {
  return nil;
}

- (NSString*)viewType {
  return nil;
}

- (void)setContentState:(TTContentState)contentState {
  if (_contentState != contentState) {
    _contentState = contentState;
    _invalid = YES;
    
    if (!(_contentState & TTContentError)) {
      [_contentError release];
      _contentError = nil;
    }
    
    if (_appearing) {
      [self validateView];
    }
  }
}

- (void)showObject:(id<TTObject>)object inView:(NSString*)viewType withState:(NSDictionary*)state {
  [_viewState release];
  _viewState = [state retain];
}

- (void)persistView:(NSMutableDictionary*)state {
}

- (void)restoreView:(NSDictionary*)state {
} 

- (void)invalidate {
  _contentState = TTContentUnknown;
  _invalid = YES;
  if (_appearing) {
    [self updateContent];
    [self refreshContent];
  }
}

- (void)updateContent {
  self.contentState = TTContentReady;
}

- (void)refreshContent {
}

- (void)reloadContent {
}

- (void)updateView {
  if (_contentState & TTContentReady) {
    if (_contentState & TTContentActivity) {
      TTActivityLabel* label = [[[TTActivityLabel alloc] initWithFrame:CGRectZero
        style:TTActivityLabelStyleBlackThinBezel text:[self titleForActivity]] autorelease];
      label.centeredToScreen = NO;
      [self showStatusBanner:label];
    } else if (_contentState & TTContentError) {
      // XXXjoe Create a yellow banner
      [self showStatusBanner:nil];
    } else {
      [self showStatusView:nil];
    }
  } else {
    if (_contentState & TTContentActivity) {
      [self showStatusCover:[[[TTActivityLabel alloc] initWithFrame:CGRectZero
        style:TTActivityLabelStyleGray text:[self titleForActivity]] autorelease]];
    } else if (_contentState & TTContentError) {
      [self showStatusCover:[[[TTErrorView alloc] initWithTitle:[self titleForError:_contentError]
        subtitle:[self subtitleForError:_contentError]
        image:[self imageForError:_contentError]] autorelease]];
    } else {
      [self showStatusCover:[[[TTErrorView alloc] initWithTitle:[self titleForNoContent]
        subtitle: [self subtitleForNoContent] image:[self imageForNoContent]] autorelease]];
    }
  }
}

- (void)unloadView {
}

- (NSString*)titleForActivity {
  if (_contentState & TTContentReady) {
    return NSLocalizedString(@"Updating...", @"");
  } else {
    return NSLocalizedString(@"Loading...", @"");
  }
}

- (UIImage*)imageForNoContent {
  return nil;
}

- (NSString*)titleForNoContent {
  return nil;
}

- (NSString*)subtitleForNoContent {
  return nil;
}

- (UIImage*)imageForError:(NSError*)error {
  return nil;
}

- (NSString*)titleForError:(NSError*)error {
  return NSLocalizedString(@"Error", @"");
}

- (NSString*)subtitleForError:(NSError*)error {
  return NSLocalizedString(@"Sorry, an error has occurred.", @"");
}

- (void)changeNavigationBarStyle:(UIBarStyle)barStyle barColor:(UIColor*)barColor
    statusBarStyle:(UIStatusBarStyle)statusBarStyle {
  if (!_previousBar) {
    UINavigationBar* bar = self.navigationController.navigationBar;
    if (!self.nextViewController) {
      _previousBar = bar;
      _previousBarStyle = bar.barStyle;
      _previousBarTintColor = bar.tintColor;
      _previousStatusBarStyle = [UIApplication sharedApplication].statusBarStyle;
    }

    bar.tintColor = barColor;
    bar.barStyle = barStyle;

    [[UIApplication sharedApplication] setStatusBarStyle:statusBarStyle animated:YES];
  }
}

- (void)restoreNavigationBarStyle {
  // If we're going backwards...
  if (!self.nextViewController && _previousBar) {
    _previousBar.tintColor = _previousBarTintColor;
    _previousBar.barStyle = _previousBarStyle;

    UIApplication* app = [UIApplication sharedApplication];
    if (app.statusBarHidden) {
      app.statusBarStyle = _previousStatusBarStyle;
      [app setStatusBarHidden:NO animated:YES];
    } else {
      [app setStatusBarStyle:_previousStatusBarStyle animated:YES];
    }
    
    _previousBar = nil;
  }
}

@end
