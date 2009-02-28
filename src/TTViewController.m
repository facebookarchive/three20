#import "Three20/TTViewController.h"
#import "Three20/TTActivityLabel.h"
#import "Three20/TTErrorView.h"
#import "Three20/TTURLRequestQueue.h"

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation TTViewController

@synthesize viewState = _viewState, contentState = _contentState, contentError = _contentError,
  appearing = _appearing, appeared = _appeared, autoresizesForKeyboard = _autoresizesForKeyboard;

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
    _autoresizesForKeyboard = NO;
  }
  return self;
}

- (void)dealloc {
  TTLOG(@"DEALLOC %@", self);
  
  self.autoresizesForKeyboard = NO;
  
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

    if (_viewState && _contentState & TTContentReady) {
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

- (BOOL)resizeForKeyboard:(NSNotification*)notification {
  NSValue* v1 = [notification.userInfo objectForKey:UIKeyboardBoundsUserInfoKey];
  CGRect keyboardBounds;
  [v1 getValue:&keyboardBounds];

  NSValue* v2 = [notification.userInfo objectForKey:UIKeyboardCenterBeginUserInfoKey];
  CGPoint keyboardStart;
  [v2 getValue:&keyboardStart];

  NSValue* v3 = [notification.userInfo objectForKey:UIKeyboardCenterEndUserInfoKey];
  CGPoint keyboardEnd;
  [v3 getValue:&keyboardEnd];
  
  CGFloat keyboardTop = keyboardEnd.y - floor(keyboardBounds.size.height/2);
  CGFloat screenBottom = self.view.screenY + self.view.height;
  if (screenBottom != keyboardTop) {
    BOOL animated = keyboardStart.y != keyboardEnd.y;
    if (animated) {
      [UIView beginAnimations:nil context:nil];
      [UIView setAnimationDuration:TT_TRANSITION_DURATION];
    }
    
    CGFloat dy = screenBottom - keyboardTop;
    self.view.frame = TTRectContract(self.view.frame, 0, dy);

    if (animated) {
      [UIView commitAnimations];
    }
    
    return animated;
  }
  
  return NO;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// UIViewController

- (void)loadView {
  UIView* contentView = [[[UIView alloc] initWithFrame:TTApplicationFrame()] autorelease];
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

  [self validate];

  [TTURLRequestQueue mainQueue].suspended = YES;
  
  _appearing = YES;
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
// UIKeyboardNotifications

- (void)keyboardWillShow:(NSNotification*)notification {
  if (self.appearing) {
    BOOL animated = [self resizeForKeyboard:notification];
    [self keyboardWillAppear:animated];
  }
}

- (void)keyboardWillHide:(NSNotification*)notification {
  if (self.appearing) {
    BOOL animated = [self resizeForKeyboard:notification];
    [self keyboardWillDisappear:animated];
  }
}

///////////////////////////////////////////////////////////////////////////////////////////////////

- (id<TTPersistable>)viewObject {
  return nil;
}

- (NSString*)viewType {
  return nil;
}

- (void)setAutoresizesForKeyboard:(BOOL)autoresizesForKeyboard {
  if (autoresizesForKeyboard != _autoresizesForKeyboard) {
    _autoresizesForKeyboard = autoresizesForKeyboard;
    
    if (_autoresizesForKeyboard) {
      [[NSNotificationCenter defaultCenter] addObserver:self
        selector:@selector(keyboardWillShow:) name:@"UIKeyboardWillShowNotification" object:nil];
      [[NSNotificationCenter defaultCenter] addObserver:self
        selector:@selector(keyboardWillHide:) name:@"UIKeyboardWillHideNotification" object:nil];
    } else {
      [[NSNotificationCenter defaultCenter] removeObserver:self
        name:@"UIKeyboardWillShowNotification" object:nil];
      [[NSNotificationCenter defaultCenter] removeObserver:self
        name:@"UIKeyboardWillHideNotification" object:nil];
    }
  }
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

- (void)showObject:(id)object inView:(NSString*)viewType withState:(NSDictionary*)state {
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

- (void)validate {
  if (_contentState == TTContentUnknown) {
    [self updateContent];
  }
  [self refreshContent];

  [self validateView];
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

- (void)keyboardWillAppear:(BOOL)animated {
}

- (void)keyboardWillDisappear:(BOOL)animated {
}

- (NSString*)titleForActivity {
  if (_contentState & TTContentReady) {
    return TTLocalizedString(@"Updating...", @"");
  } else {
    return TTLocalizedString(@"Loading...", @"");
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
  return TTLocalizedString(@"Error", @"");
}

- (NSString*)subtitleForError:(NSError*)error {
  return TTLocalizedString(@"Sorry, an error has occurred.", @"");
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
