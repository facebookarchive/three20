#import "Three20/TTViewController.h"
#import "Three20/TTErrorView.h"
#import "Three20/TTURLRequestQueue.h"
#import "Three20/TTStyleSheet.h"

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation TTViewController

@synthesize modelState = _modelState, modelError = _modelError,
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
    _navigationBarStyle = UIBarStyleDefault;
    _navigationBarTintColor = nil;
    _statusBarStyle = UIStatusBarStyleDefault;
    _modelState = TTModelStateEmpty;
    _modelError = nil;
    _hasViewAppeared = NO;
    _isViewAppearing = NO;
    _autoresizesForKeyboard = NO;
    _isModelInvalid = YES;
    _isViewInvalid = YES;
    _isLoadingViewInvalid = NO;
    _isLoadedViewInvalid = YES;
    _isValidatingModel = NO;
    _isValidatingView = NO;
    
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
  TT_RELEASE_MEMBER(_modelError);

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

    [self invalidateView];
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
// TTLoadableDelegate

- (void)loadableDidStartLoad:(id<TTLoadable>)loadable {
  if (loadable.isLoadingMore) {
    self.modelState = (_modelState & TTModelLoadedStates) | TTModelStateLoadingMore;
  } else if (_modelState & TTModelLoadedStates) {
    self.modelState = (_modelState & TTModelLoadedStates) | TTModelStateRefreshing;
  } else {
    self.modelState = TTModelStateLoading;
  }
}

- (void)loadableDidFinishLoad:(id<TTLoadable>)loadable {
  if (loadable.isEmpty) {
    self.modelState = TTModelStateEmpty;
  } else {
    self.modelState = TTModelStateLoaded;
  }
}

- (void)loadable:(id<TTLoadable>)loadable didFailLoadWithError:(NSError*)error {
  self.modelError = error;
  self.modelState = TTModelStateLoadedError;
}

- (void)loadableDidCancelLoad:(id<TTLoadable>)loadable {
  self.modelError = nil;
  self.modelState = TTModelStateLoadedError;
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

- (void)setModelState:(TTModelState)state {
  if (!_isLoadingViewInvalid) {
    _isLoadingViewInvalid = (_modelState & TTModelLoadingStates) != (state & TTModelLoadingStates);
  }
  if (!_isLoadedViewInvalid) {
    _isLoadedViewInvalid = state == TTModelStateLoaded || state == TTModelStateEmpty
                       || (_modelState & TTModelLoadedStates) != (state & TTModelLoadedStates);
  }
  
  _modelState = state;
  
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

- (void)reload {
}

- (void)reloadIfNeeded {
}

- (void)invalidateModel {
  _isModelInvalid = YES;
  if (self.isViewLoaded) {
    [self validateModel];
  }
}

- (void)validateModel {
  if (!_isValidatingModel && _isModelInvalid) {
    _isValidatingModel = YES;
    [self updateModel];
    _isModelInvalid = NO;
    _isValidatingModel = NO;

    if (_isViewAppearing) {
      [self validateView];
    }
  }
}

- (void)invalidateView {
  _isViewInvalid = YES;
  _modelState = TTModelStateEmpty;
  _isLoadingViewInvalid = NO;
  _isLoadedViewInvalid = YES;
}

- (void)validateView {
  if (_isModelInvalid) {
    [self validateModel];
  } else if (!_isValidatingView) {
    _isValidatingView = YES;
    
    if (_isViewInvalid) {
      // Ensure the view is loaded
      self.view;

      [self modelDidChange];

      if (_frozenState && !(self.modelState & TTModelLoadingStates)) {
        [self restoreView:_frozenState];
        TT_RELEASE_MEMBER(_frozenState);
      }

      _isViewInvalid = NO;
    }
    
    if (_isLoadingViewInvalid) {
      [self modelDidChangeLoadingState];
      _isLoadingViewInvalid = NO;
    }

    if (_isLoadedViewInvalid) {
      [self modelDidChangeLoadedState];
      _isLoadedViewInvalid = NO;
    }

    _isValidatingView = NO;

    [self reloadIfNeeded];
  }
}

- (void)updateModel {
}

- (void)modelDidChange {
}

- (void)modelDidChangeLoadingState {
}

- (void)modelDidChangeLoadedState {
}

- (void)keyboardWillAppear:(BOOL)animated {
}

- (void)keyboardWillDisappear:(BOOL)animated {
}

@end
