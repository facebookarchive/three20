/**
 * Copyright 2009 Facebook
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#import "Three20/TTViewController.h"
#import "Three20/TTTableViewController.h"
#import "Three20/TTURLRequestQueue.h"
#import "Three20/TTSearchDisplayController.h"
#import "Three20/TTStyleSheet.h"
#import "Three20/TTNavigator.h"

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation TTViewController

@synthesize navigationBarStyle = _navigationBarStyle,
  navigationBarTintColor = _navigationBarTintColor, statusBarStyle = _statusBarStyle,
  isViewAppearing = _isViewAppearing, hasViewAppeared = _hasViewAppeared,
  autoresizesForKeyboard = _autoresizesForKeyboard;

///////////////////////////////////////////////////////////////////////////////////////////////////
// private

- (void)resizeForKeyboard:(NSNotification*)notification appearing:(BOOL)appearing {
  NSValue* v1 = [notification.userInfo objectForKey:UIKeyboardBoundsUserInfoKey];
  CGRect keyboardBounds;
  [v1 getValue:&keyboardBounds];

  NSValue* v2 = [notification.userInfo objectForKey:UIKeyboardCenterBeginUserInfoKey];
  CGPoint keyboardStart;
  [v2 getValue:&keyboardStart];

  NSValue* v3 = [notification.userInfo objectForKey:UIKeyboardCenterEndUserInfoKey];
  CGPoint keyboardEnd;
  [v3 getValue:&keyboardEnd];

  BOOL animated = keyboardStart.y != keyboardEnd.y;
  if (animated) {
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:TT_TRANSITION_DURATION];
  }
  
  if (appearing) {
    [self keyboardWillAppear:animated withBounds:keyboardBounds];
    
    [self retain];
    [NSTimer scheduledTimerWithTimeInterval:TT_TRANSITION_DURATION
             target:self selector:@selector(keyboardDidAppearDelayed:)
             userInfo:[NSValue valueWithCGRect:keyboardBounds] repeats:NO];
  } else {
    [self keyboardWillDisappear:animated withBounds:keyboardBounds];

    [self retain];
    [NSTimer scheduledTimerWithTimeInterval:TT_TRANSITION_DURATION
             target:self selector:@selector(keyboardDidDisappearDelayed:)
             userInfo:[NSValue valueWithCGRect:keyboardBounds] repeats:NO];
  }
  
  if (animated) {
    [UIView commitAnimations];
  }
}

- (void)keyboardDidAppearDelayed:(NSTimer*)timer {
  NSValue* value = timer.userInfo;
  CGRect keyboardBounds;
  [value getValue:&keyboardBounds];

  [self keyboardDidAppear:YES withBounds:keyboardBounds];
  [self autorelease];
}

- (void)keyboardDidDisappearDelayed:(NSTimer*)timer {
  NSValue* value = timer.userInfo;
  CGRect keyboardBounds;
  [value getValue:&keyboardBounds];

  [self keyboardDidDisappear:YES withBounds:keyboardBounds];
  [self autorelease];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// NSObject

- (id)init {
  if (self = [super init]) {
    _frozenState = nil;
    _navigationBarStyle = UIBarStyleDefault;
    _navigationBarTintColor = nil;
    _statusBarStyle = UIStatusBarStyleDefault;
    _hasViewAppeared = NO;
    _isViewAppearing = NO;
    _autoresizesForKeyboard = NO;
    
    self.navigationBarTintColor = TTSTYLEVAR(navigationBarTintColor);
  }
  return self;
}

- (void)awakeFromNib {
  [self init];
}

- (void)dealloc {
  TTDCONDITIONLOG(TTDFLAG_VIEWCONTROLLERS, @"DEALLOC %@", self);

  [[TTURLRequestQueue mainQueue] cancelRequestsWithDelegate:self];

  TT_RELEASE_SAFELY(_navigationBarTintColor);
  TT_RELEASE_SAFELY(_frozenState);
  
  // Removes keyboard notification observers for 
  self.autoresizesForKeyboard = NO;

  // You would think UIViewController would call this in dealloc, but it doesn't!
  // I would prefer not to have to redundantly put all view releases in dealloc and
  // viewDidUnload, so my solution is just to call viewDidUnload here.
  [self viewDidUnload];
  
  [super dealloc];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// UIResponder

- (void)motionBegan:(UIEventSubtype)motion withEvent:(UIEvent *)event {
  if (event.type == UIEventSubtypeMotionShake && [TTNavigator navigator].supportsShakeToReload) {
    [[TTNavigator navigator] reload];
  }
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// UIViewController

- (void)loadView {
  [super loadView];
  
  CGRect frame = self.wantsFullScreenLayout ? TTScreenBounds() : TTNavigationFrame(); 
  self.view = [[[UIView alloc] initWithFrame:frame] autorelease];
	self.view.autoresizesSubviews = YES;
	self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth
                              | UIViewAutoresizingFlexibleHeight;
  self.view.backgroundColor = TTSTYLEVAR(backgroundColor);
}

- (void)viewDidUnload {
  [super viewDidUnload];
  TT_RELEASE_SAFELY(_searchController);
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  _isViewAppearing = YES;
  _hasViewAppeared = YES;

  [TTURLRequestQueue mainQueue].suspended = YES;

  if (!self.popupViewController) {
    UINavigationBar* bar = self.navigationController.navigationBar;
    bar.tintColor = _navigationBarTintColor;
    bar.barStyle = _navigationBarStyle;
    [[UIApplication sharedApplication] setStatusBarStyle:_statusBarStyle animated:YES];
  }

  // Ugly hack to work around UISearchBar's inability to resize its text field
  // to avoid being overlapped by the table section index
//  if (_searchController && !_searchController.active) {
//    [_searchController setActive:YES animated:NO];
//    [_searchController setActive:NO animated:NO];
//  }
}

- (void)viewDidAppear:(BOOL)animated {
  [super viewDidAppear:animated];
  [TTURLRequestQueue mainQueue].suspended = NO;
}

- (void)viewWillDisappear:(BOOL)animated {
  [super viewWillDisappear:animated];
  _isViewAppearing = NO;
}

- (void)didReceiveMemoryWarning {
  TTDCONDITIONLOG(TTDFLAG_VIEWCONTROLLERS, @"MEMORY WARNING FOR %@", self);

  if (_hasViewAppeared && !_isViewAppearing) {
    NSMutableDictionary* state = [[NSMutableDictionary alloc] init];
    [self persistView:state];
    self.frozenState = state;
    TT_RELEASE_SAFELY(state);
  
    // This will come around to calling viewDidUnload
    [super didReceiveMemoryWarning];

    _hasViewAppeared = NO;
  } else {
    [super didReceiveMemoryWarning];
  }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
  UIViewController* popup = [self popupViewController];
  if (popup) {
    return [popup shouldAutorotateToInterfaceOrientation:interfaceOrientation];
  } else {
    return [super shouldAutorotateToInterfaceOrientation:interfaceOrientation];
  }
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
        duration:(NSTimeInterval)duration {
  UIViewController* popup = [self popupViewController];
  if (popup) {
    return [popup willAnimateRotationToInterfaceOrientation:fromInterfaceOrientation
                  duration:duration];
  } else {
    return [super willAnimateRotationToInterfaceOrientation:fromInterfaceOrientation
                  duration:duration];
  }
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
  UIViewController* popup = [self popupViewController];
  if (popup) {
    return [popup didRotateFromInterfaceOrientation:fromInterfaceOrientation];
  } else {
    return [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
  }
}

- (UIView*)rotatingHeaderView {
  UIViewController* popup = [self popupViewController];
  if (popup) {
    return [popup rotatingHeaderView];
  } else {
    return [super rotatingHeaderView];
  }
}

- (UIView*)rotatingFooterView {
  UIViewController* popup = [self popupViewController];
  if (popup) {
    return [popup rotatingFooterView];
  } else {
    return [super rotatingFooterView];
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
    [self resizeForKeyboard:notification appearing:YES];
  }
}

- (void)keyboardWillHide:(NSNotification*)notification {
  if (self.isViewAppearing) {
    [self resizeForKeyboard:notification appearing:NO];
  }
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// public

- (TTTableViewController*)searchViewController {
  return _searchController.searchResultsViewController;
}

- (void)setSearchViewController:(TTTableViewController*)searchViewController {
  if (searchViewController) {
    if (!_searchController) {
      UISearchBar* searchBar = [[[UISearchBar alloc] init] autorelease];
      [searchBar sizeToFit];

      _searchController = [[TTSearchDisplayController alloc] initWithSearchBar:searchBar
                                                             contentsController:self];
    }
    
    searchViewController.superController = self;
    _searchController.searchResultsViewController = searchViewController;
  } else {
    _searchController.searchResultsViewController = nil;
    TT_RELEASE_SAFELY(_searchController);
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

- (void)keyboardWillAppear:(BOOL)animated withBounds:(CGRect)bounds {
}

- (void)keyboardWillDisappear:(BOOL)animated withBounds:(CGRect)bounds {
}

- (void)keyboardDidAppear:(BOOL)animated withBounds:(CGRect)bounds {
}

- (void)keyboardDidDisappear:(BOOL)animated withBounds:(CGRect)bounds {
}

@end
