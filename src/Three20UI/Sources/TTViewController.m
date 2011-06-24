//
// Copyright 2009-2011 Facebook
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//    http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

#import "Three20UI/TTViewController.h"

// UI
#import "Three20UI/TTNavigator.h"
#import "Three20UI/TTTableViewController.h"
#import "Three20UI/TTSearchDisplayController.h"
#import "Three20UI/UIViewAdditions.h"

// UINavigator
#import "Three20UINavigator/TTGlobalNavigatorMetrics.h"
#import "Three20UINavigator/UIViewController+TTNavigator.h"

// UICommon
#import "Three20UICommon/TTGlobalUICommon.h"
#import "Three20UICommon/UIViewControllerAdditions.h"

// Style
#import "Three20Style/TTGlobalStyle.h"
#import "Three20Style/TTStyleSheet.h"

// Network
#import "Three20Network/TTURLRequestQueue.h"

// Core
#import "Three20Core/TTCorePreprocessorMacros.h"
#import "Three20Core/TTDebug.h"
#import "Three20Core/TTDebugFlags.h"

static NSMutableDictionary *customParentViewControllers;

///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@interface TTViewController (Private)

+ (void) setCustomParentViewController: (id) parent withChildViewController: (id) child;

+ (void) removeCustomParentViewControllerWithChild: (id) child;

- (void) customViewAnimationDidStop: (NSString *)animationID finished: (NSNumber *)finished context: (void *)context;

@end

///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation TTViewController

@synthesize customModalViewController = _customModalViewController;

///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
  if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
    self.navigationBarTintColor = TTSTYLEVAR(navigationBarTintColor);
  }

  return self;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)init {
  if (self = [self initWithNibName:nil bundle:nil]) {
  }

  return self;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)dealloc {
  
  [[TTURLRequestQueue mainQueue] cancelRequestsWithDelegate:self];

  if(_customModalViewController != nil) {
	[self dismissCustomModalViewControllerAnimated: NO];  
  }
	
  /* Should be parent's reference holder released when empty???
  if([customParentViewControllers count] == 0) {
	 
  }*/
	
  TT_RELEASE_SAFELY(_customModalViewController);

  [super dealloc];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark UIViewController


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)loadView {
  if (nil != self.nibName) {
    [super loadView];

  } else {
    CGRect frame = self.wantsFullScreenLayout ? TTScreenBounds() : TTNavigationFrame();
    self.view = [[[UIView alloc] initWithFrame:frame] autorelease];
    self.view.autoresizesSubviews = YES;
    self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.view.backgroundColor = TTSTYLEVAR(backgroundColor);
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)viewDidUnload {
  [super viewDidUnload];
  TT_RELEASE_SAFELY(_searchController);
  TT_RELEASE_SAFELY(_customModalViewController);
  TT_RELEASE_SAFELY(_modalOverlayView);
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];

  [TTURLRequestQueue mainQueue].suspended = YES;

  // Ugly hack to work around UISearchBar's inability to resize its text field
  // to avoid being overlapped by the table section index
//  if (_searchController && !_searchController.active) {
//    [_searchController setActive:YES animated:NO];
//    [_searchController setActive:NO animated:NO];
//  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)viewDidAppear:(BOOL)animated {
  [super viewDidAppear:animated];

  [TTURLRequestQueue mainQueue].suspended = NO;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Public


///////////////////////////////////////////////////////////////////////////////////////////////////
- (TTTableViewController *) searchViewController {
  return _searchController.searchResultsViewController;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void) setSearchViewController: (TTTableViewController *) searchViewController {
	
  if (searchViewController) {
    if (nil == _searchController) {
      UISearchBar* searchBar = [[[UISearchBar alloc] init] autorelease];
      [searchBar sizeToFit];

      _searchController = [[TTSearchDisplayController alloc] initWithSearchBar:searchBar
                                                             contentsController:self];
    }

    searchViewController.superController = self;
    _searchController.searchResultsViewController = searchViewController;

  }
  else {
    _searchController.searchResultsViewController = nil;
    TT_RELEASE_SAFELY(_searchController);
  }
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (TTNavigatorViewController *) customParentViewController {
	
	/*id valueKey = (_customModalViewController) ? _customModalViewController : self;
	
	return [customParentViewControllers objectForKey: [NSValue valueWithPointer: valueKey]];*/
	return [customParentViewControllers objectForKey: [NSValue valueWithPointer: self]];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void) presentCustomModalViewController: (TTViewController *) modalViewController animated: (BOOL) animated {
	
	/// Make sure that possibly existing modal stack is dismissed before new view is presented
	if(self.customModalViewController.customModalViewController) {
		[self.customModalViewController dismissCustomModalViewControllerAnimated: animated];
	}
	
	TT_RELEASE_SAFELY(_customModalViewController);
	
	/// Retain reference to new modal view controller
	_customModalViewController = [modalViewController retain];
	
	/// Set self as parent view controller for new view controller
	[TTViewController setCustomParentViewController: self withChildViewController: modalViewController];
	
	CGRect screenBounds = TTScreenBounds();
	
	TTViewController *parentViewController = self.customParentViewController;
	
	if (parentViewController == nil) {
		_modalOverlayView = [[UIView alloc] initWithFrame: screenBounds];
		_modalOverlayView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent: 0.65];
		_modalOverlayView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
	}
	
	/// Set modal view's position to the middle of the screen, one third vertically
	CGFloat x = floorf((screenBounds.size.width / 2.0f) - (modalViewController.view.width / 2.0f));
	CGFloat y = floorf((screenBounds.size.height / 2.0f) - (modalViewController.view.height / 2.0f));
	
	modalViewController.view.origin = CGPointMake(x, y);
	
	if(animated) {
		[UIView beginAnimations: @"PresentCustomModalView" context: nil];
		[UIView setAnimationDuration: TT_TRANSITION_DURATION];
		
		_modalOverlayView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent: 0.0];
		_customModalViewController.view.alpha = 0.0;
	}
	
	/// Send viewWillAppear: message
	[modalViewController viewWillAppear: animated];
	
	/// Check if there's a modal view displayed
	UIViewController *topController = [[[TTNavigator navigator] rootViewController] modalViewController];
	
	if (!topController) {
		/// Use root view controller otherwise (typically tab bar or navigation controller)
		topController = [[TTNavigator navigator] rootViewController];
	}
	
	/// Set overylay view as subview of current top view controller's view 
	if (parentViewController == nil) {
		[topController.view addSubview: _modalOverlayView];
	}
	else {
		self.view.alpha = 0.0f;
	}
	
	[topController.view addSubview: modalViewController.view];
	
	/// Make sure our view will reposition itself correctly when orientation changes
	modalViewController.view.autoresizingMask = (UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin);
	
	if (animated) {
		
		/// Finalize animation
		_modalOverlayView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent: 0.65];
		_customModalViewController.view.alpha = 1.0;
		
		[UIView commitAnimations];
	}
	
	/// Send viewDidAppear: message
	[_customModalViewController viewDidAppear: animated];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void) dismissCustomModalViewControllerAnimated: (BOOL) animated {
	
	id parent = self.customParentViewController;
	
	/// Forward message to parent if message was sent to controller on top of the stack.
	if (_customModalViewController == nil && parent != nil) {
		
		[parent dismissCustomModalViewControllerAnimated: animated];
		
		return;
	}
	
	if (_customModalViewController.customModalViewController != nil) {
		[_customModalViewController dismissCustomModalViewControllerAnimated: animated];
	}
	else if (animated) {
		
		/// If animation is requested, start fade out animation
		
		TTViewController *customModalViewController = _customModalViewController;
		_customModalViewController = nil;
		
		/// Use block-based animations on iOS >= 4.0
		if([UIView respondsToSelector: @selector(animateWithDuration:animations:completion:)]) {
			
			[UIView animateWithDuration: TT_TRANSITION_DURATION 
							 animations: ^{
								 
								 if (parent == nil) {
									 _modalOverlayView.alpha = 0.0;
								 }
								 else {
									 self.view.alpha = 1.0f;
								 }
								 
								 customModalViewController.view.alpha = 0.0;
							 }
							 completion: ^(BOOL finished) {
								 
								 if (parent == nil) {
									 
									 [_modalOverlayView removeFromSuperview];
									 
									 TT_RELEASE_SAFELY(_modalOverlayView);
								 }
								 
								 [customModalViewController viewWillDisappear: animated];
								 
								 [customModalViewController.view removeFromSuperview];
								 
								 [customModalViewController viewDidDisappear: animated];
								 
								 /// Make sure to remove any hanging reference in global dictionary
								 [TTViewController removeCustomParentViewControllerWithChild: customModalViewController];
								 
								 [customModalViewController release];
								 
								 [self didDismissCustomModalViewControllerAnimated: animated];
							 }];
		}
		else {
			/// Use traditional animations using delegate
			[UIView beginAnimations: @"DismissCustomModalView" context: customModalViewController];
			[UIView setAnimationDelegate: self];
			[UIView setAnimationDidStopSelector: @selector(customViewAnimationDidStop:finished:context:)];
			[UIView setAnimationDuration: TT_TRANSITION_DURATION];
			
			if (parent == nil) {
				_modalOverlayView.alpha = 0.0;
			}
			else {
				self.view.alpha = 1.0f;
			}
			
			customModalViewController.view.alpha = 0.0;
			
			[UIView commitAnimations];
		}
		
		return;
	}
	
	if (_modalOverlayView != nil) {
		
		[_modalOverlayView removeFromSuperview];
		
		TT_RELEASE_SAFELY(_modalOverlayView);
	}
	
	[_customModalViewController viewWillDisappear: animated];
	
	[_customModalViewController.view removeFromSuperview];
	
	[_customModalViewController viewDidDisappear: animated];
	
	/// Make sure to remove any hanging reference in global dictionary
	[TTViewController removeCustomParentViewControllerWithChild: _customModalViewController];
	
	TT_RELEASE_SAFELY(_customModalViewController);
}

- (void)didDismissCustomModalViewControllerAnimated:(BOOL)animated {
}

///////////////////////////////////////////////////////////////////////////////////////////////////
+ (void)doGarbageCollection {
  [UIViewController doNavigatorGarbageCollection];
  [UIViewController doCommonGarbageCollection];
}


@end

///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation TTViewController (Private)

+ (void) setCustomParentViewController: (id) parent withChildViewController: (id) child {
	
	/// We need to set customParentViewController property, but it's declared as readonly,
	/// so we need to trick it somehow. The trick is to store reference to self in global
	/// dictionary under modal's controller reference key
	if(customParentViewControllers == nil) {
		customParentViewControllers = [[NSMutableDictionary alloc] init];
	}
	
	[customParentViewControllers setObject: parent forKey: [NSValue valueWithPointer: child]];
}

+ (void) removeCustomParentViewControllerWithChild: (id) child {
	
	[customParentViewControllers removeObjectForKey: [NSValue valueWithPointer: child]];
	
	if([customParentViewControllers count] == 0) {
		TT_RELEASE_SAFELY(customParentViewControllers);
	}
}

- (void) customViewAnimationDidStop: (NSString *) animationID finished: (NSNumber *) finished context: (void *) context {
	
	if (_modalOverlayView != nil) {
		
		[_modalOverlayView removeFromSuperview];
		
		TT_RELEASE_SAFELY(_modalOverlayView);
	}
	
	TTViewController *customModalViewController = (TTViewController *)context;

	[customModalViewController viewWillDisappear: YES];
	
	[customModalViewController.view removeFromSuperview];
	
	[customModalViewController viewDidDisappear: YES];
	
	/// Make sure to remove any hanging reference in global dictionary
	[TTViewController removeCustomParentViewControllerWithChild: customModalViewController];
	
	[customModalViewController release];
	
	[self didDismissCustomModalViewControllerAnimated: YES];
}

@end
