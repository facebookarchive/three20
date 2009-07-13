#import "Three20/TTViewController.h"
#import "Three20/TTErrorView.h"
#import "Three20/TTURLRequestQueue.h"
#import "Three20/TTStyleSheet.h"

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation TTViewController

@synthesize viewState = _viewState, contentError = _contentError,
  navigationBarStyle = _navigationBarStyle,
  navigationBarTintColor = _navigationBarTintColor, statusBarStyle = _statusBarStyle,
  isViewAppearing = _isViewAppearing, hasViewAppeared = _hasViewAppeared,
  autoresizesForKeyboard = _autoresizesForKeyboard;

///////////////////////////////////////////////////////////////////////////////////////////////////
// private

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
// NSObject

- (id)init {
  if (self = [super init]) {  
    _frozenState = nil;
    _viewState = TTViewEmpty;
    _contentError = nil;
    _navigationBarStyle = UIBarStyleDefault;
    _navigationBarTintColor = nil;
    _statusBarStyle = UIStatusBarStyleDefault;
    _invalidView = YES;
    _invalidViewLoading = NO;
    _invalidViewData = YES;
    _validating = NO;
    _isViewAppearing = NO;
    _hasViewAppeared = NO;
    _autoresizesForKeyboard = NO;
    
    self.navigationBarTintColor = TTSTYLEVAR(navigationBarTintColor);
  }
  return self;
}

- (void)awakeFromNib {
  [self init];
}

- (void)dealloc {
  TTLOG(@"DEALLOC %@", self);

  [[TTURLRequestQueue mainQueue] cancelRequestsWithDelegate:self];
  
  // Removes keyboard notification observers for 
  self.autoresizesForKeyboard = NO;

  TT_RELEASE_MEMBER(_navigationBarTintColor);
  TT_RELEASE_MEMBER(_frozenState);
  TT_RELEASE_MEMBER(_contentError);

  // You would think UIViewController would call this in dealloc, but it doesn't!
  // I would prefer not to have to redundantly put all view releases in dealloc and
  // viewDidUnload, so my solution is just to call viewDidUnload here.
  [self viewDidUnload];
  [super dealloc];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// UIViewController

- (void)loadView {
  [super loadView];

  self.view.frame = TTNavigationFrame();
	self.view.autoresizesSubviews = YES;
	self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
  self.view.backgroundColor = TTSTYLEVAR(backgroundColor);
}

- (void)viewWillAppear:(BOOL)animated {
  _isViewAppearing = YES;
  _hasViewAppeared = YES;

  [self validateView];

  [TTURLRequestQueue mainQueue].suspended = YES;

  if (!self.popupViewController) {
    UINavigationBar* bar = self.navigationController.navigationBar;
    bar.tintColor = _navigationBarTintColor;
    bar.barStyle = _navigationBarStyle;
    [[UIApplication sharedApplication] setStatusBarStyle:_statusBarStyle animated:YES];
  }
}

- (void)viewDidUnload {
}

- (void)viewDidAppear:(BOOL)animated {
  [TTURLRequestQueue mainQueue].suspended = NO;
}

- (void)viewWillDisappear:(BOOL)animated {
  _isViewAppearing = NO;
}

- (void)didReceiveMemoryWarning {
  TTLOG(@"MEMORY WARNING FOR %@", self);

  if (_hasViewAppeared && !_isViewAppearing) {
    NSMutableDictionary* state = [[NSMutableDictionary alloc] init];
    [self persistView:state];
    self.frozenState = state;
  
    // This will come around to calling viewDidUnload
    [super didReceiveMemoryWarning];

    _viewState = TTViewEmpty;
    _invalidView = YES;
    _hasViewAppeared = NO;
  }
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// UIViewController (TTCategory)

- (NSDictionary*)frozenState {
  return _frozenState;
}

- (void)setFrozenState:(NSDictionary*)frozenState {
  [_frozenState release];
  _frozenState = [frozenState retain];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// UIKeyboardNotifications

- (void)keyboardWillShow:(NSNotification*)notification {
  if (self.isViewAppearing) {
    BOOL animated = [self resizeForKeyboard:notification];
    [self keyboardWillAppear:animated];
  }
}

- (void)keyboardWillHide:(NSNotification*)notification {
  if (self.isViewAppearing) {
    BOOL animated = [self resizeForKeyboard:notification];
    [self keyboardWillDisappear:animated];
  }
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// public

- (void)setViewState:(TTViewState)state {
  if (!_invalidViewLoading) {
    _invalidViewLoading = (_viewState & TTViewLoadingStates) != (state & TTViewLoadingStates);
  }
  if (!_invalidViewData) {
    _invalidViewData = state == TTViewLoaded || state == TTViewEmpty
                       || (_viewState & TTViewLoadedStates) != (state & TTViewLoadedStates);
  }
  
  _viewState = state;
  
  if (_isViewAppearing) {
    [self validateView];
  }
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

- (void)reloadContent {
}

- (void)refreshContent {
}

- (void)invalidateView {
  _invalidView = YES;
  _viewState = TTViewEmpty;
  if (_isViewAppearing) {
    [self validateView];
  }
}

- (void)validateView {
  if (!_validating) {
    _validating = YES;
    if (_invalidView) {
      // Ensure the view is loaded
      self.view;

      [self updateView];

      if (_frozenState && !(self.viewState & TTViewLoadingStates)) {
        [self restoreView:_frozenState];
        TT_RELEASE_MEMBER(_frozenState);
      }

      _invalidView = NO;
    }
    
    if (_invalidViewLoading) {
      [self updateLoadingView];
      _invalidViewLoading = NO;
    }

    if (_invalidViewData) {
      [self updateLoadedView];
      _invalidViewData = NO;
    }

    _validating = NO;

    [self refreshContent];
  }
}

- (void)updateView {
}

- (void)updateLoadingView {
}

- (void)updateLoadedView {
}

- (void)keyboardWillAppear:(BOOL)animated {
}

- (void)keyboardWillDisappear:(BOOL)animated {
}

@end
