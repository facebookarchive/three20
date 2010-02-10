//
// Copyright 2009-2010 Facebook
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

#import "Three20/UIViewControllerAdditions.h"

#import "Three20/TTGlobalUI.h"
#import "Three20/TTDebugFlags.h"
#import "Three20/TTNavigator.h"
#import "Three20/TTURLMap.h"

///////////////////////////////////////////////////////////////////////////////////////////////////

static NSMutableDictionary* gNavigatorURLs = nil;
static NSMutableDictionary* gSuperControllers = nil;
static NSMutableDictionary* gPopupViewControllers = nil;

///////////////////////////////////////////////////////////////////////////////////////////////////

@interface TTPopupView : UIView {
  UIViewController* _popupViewController;
}

@property(nonatomic,retain) UIViewController* popupViewController;

@end

@implementation TTPopupView

@synthesize popupViewController = _popupViewController;

- (id)initWithFrame:(CGRect)frame {
  if (self = [super initWithFrame:frame]) {
    _popupViewController = nil;
  }
  return self;
}

- (void)dealloc {
  [_popupViewController release];
  [super dealloc];
}

- (void)didAddSubview:(UIView*)subview {
  TTDCONDITIONLOG(TTDFLAG_VIEWCONTROLLERS, @"ADD %@", subview);
}

- (void)willRemoveSubview:(UIView*)subview {
  TTDCONDITIONLOG(TTDFLAG_VIEWCONTROLLERS, @"REMOVE %@", subview);
  [self removeFromSuperview];
}

@end

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation UIViewController (TTCategory)

///////////////////////////////////////////////////////////////////////////////////////////////////
// NSObject

// Swapped with dealloc by TTURLMap (only if you're using TTURLMap)
- (void)ttdealloc {
  NSString* URL = self.originalNavigatorURL;
  if (URL) {
    [[TTNavigator navigator].URLMap removeObjectForURL:URL];
    self.originalNavigatorURL = nil;
  }

  self.superController = nil;
  self.popupViewController = nil;
  
  // Calls the original dealloc, swizzled away
  [self ttdealloc];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// public

- (id)initWithNavigatorURL:(NSURL*)URL query:(NSDictionary*)query {
  return [self init];
}

- (NSString*)navigatorURL {
  return self.originalNavigatorURL;
}

- (NSString*)originalNavigatorURL {
  NSString* key = [NSString stringWithFormat:@"%d", self.hash];
  return [gNavigatorURLs objectForKey:key];
}

- (void)setOriginalNavigatorURL:(NSString*)URL {
  NSString* key = [NSString stringWithFormat:@"%d", self.hash];
  if (URL) {
    if (!gNavigatorURLs) {
      gNavigatorURLs = [[NSMutableDictionary alloc] init];
    }
    [gNavigatorURLs setObject:URL forKey:key];
  } else {
    [gNavigatorURLs removeObjectForKey:key];
  }
}

- (NSDictionary*)frozenState {
  return nil;
}

- (void)setFrozenState:(NSDictionary*)frozenState {
}

- (BOOL)canContainControllers {
  return NO;
}

- (UIViewController*)superController {
  UIViewController* parent = self.parentViewController;
  if (parent) {
    return parent;
  } else {
    NSString* key = [NSString stringWithFormat:@"%d", self.hash];
    return [gSuperControllers objectForKey:key];
  }
}

- (void)setSuperController:(UIViewController*)viewController {
  NSString* key = [NSString stringWithFormat:@"%d", self.hash];
  if (viewController) {
    if (!gSuperControllers) {
      gSuperControllers = TTCreateNonRetainingDictionary();
    }
    [gSuperControllers setObject:viewController forKey:key];
  } else {
    [gSuperControllers removeObjectForKey:key];
  }
}

- (UIViewController*)topSubcontroller {
  return nil;
}


/**
 * The view controller that comes before this one in a navigation controller's history.
 *
 * This is an App Store-compatible version of previousViewController.
 */
- (UIViewController*)ttPreviousViewController {
  NSArray* viewControllers = self.navigationController.viewControllers;
  if (viewControllers.count > 1) {
    NSUInteger index = [viewControllers indexOfObject:self];
    if (index != NSNotFound && index > 0) {
      return [viewControllers objectAtIndex:index-1];
    }
  }
  
  return nil;
}

#ifdef DEBUG

/**
 * The view controller that comes before this one in a navigation controller's history.
 *
 * This has been deprecated due to App Store rejections. Please use ttPreviousViewController
 * from now on.
 *
 * @deprecated
 */
- (UIViewController*)previousViewController {
  return [self ttPreviousViewController];
}

#endif

- (UIViewController*)nextViewController {
  NSArray* viewControllers = self.navigationController.viewControllers;
  if (viewControllers.count > 1) {
    NSUInteger index = [viewControllers indexOfObject:self];
    if (index != NSNotFound && index+1 < viewControllers.count) {
      return [viewControllers objectAtIndex:index+1];
    }
  }
  return nil;
}

- (UIViewController*)popupViewController {
  NSString* key = [NSString stringWithFormat:@"%d", self.hash];
  return [gPopupViewControllers objectForKey:key];
}

- (void)setPopupViewController:(UIViewController*)viewController {
  NSString* key = [NSString stringWithFormat:@"%d", self.hash];
  if (viewController) {
    if (!gPopupViewControllers) {
      gPopupViewControllers = TTCreateNonRetainingDictionary();
    }
    [gPopupViewControllers setObject:viewController forKey:key];
  } else {
    [gPopupViewControllers removeObjectForKey:key];
  }
}

- (void)addSubcontroller:(UIViewController*)controller animated:(BOOL)animated
        transition:(UIViewAnimationTransition)transition {
  if (self.navigationController) {
    [self.navigationController addSubcontroller:controller animated:animated
                               transition:transition];
  }
}

- (void)removeFromSupercontroller {
  [self removeFromSupercontrollerAnimated:YES];
}

- (void)removeFromSupercontrollerAnimated:(BOOL)animated {
  if (self.navigationController) {
    [self.navigationController popViewControllerAnimated:animated];
  }
}

- (void)bringControllerToFront:(UIViewController*)controller animated:(BOOL)animated {
}

- (NSString*)keyForSubcontroller:(UIViewController*)controller {
  return nil;
}

- (UIViewController*)subcontrollerForKey:(NSString*)key {
  return nil;
}

- (BOOL)persistView:(NSMutableDictionary*)state {
  return YES;
}

- (void)restoreView:(NSDictionary*)state {
}

- (void)persistNavigationPath:(NSMutableArray*)path {
}

- (void)delayDidEnd {
}

- (void)showBars:(BOOL)show animated:(BOOL)animated {
  [[UIApplication sharedApplication] setStatusBarHidden:!show animated:animated];

  if (animated) {
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:TT_TRANSITION_DURATION];
  }
  self.navigationController.navigationBar.alpha = show ? 1 : 0;
  if (animated) {
    [UIView commitAnimations];
  }
}

- (void)dismissModalViewController {
  [self dismissModalViewControllerAnimated:YES];
}

@end
