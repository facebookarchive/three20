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

#import "Three20UI/TTRootViewController.h"

// UI
#import "Three20UI/UIViewAdditions.h"
#import "Three20UI/TTNavigator.h"

// UINavigator
#import "Three20UINavigator/TTGlobalNavigatorMetrics.h"
#import "Three20UINavigator/TTBaseNavigator.h"

// UICommon
#import "Three20UICommon/UIViewControllerAdditions.h"
#import "Three20UICommon/TTGlobalUICommon.h"

// Core
#import "Three20Core/TTCorePreprocessorMacros.h"
#import "Three20Core/TTDebug.h"


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation TTRootViewController

@synthesize visibleController = _visibleController;
@synthesize stashedController = _stashedController;


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)dealloc {
  TT_RELEASE_SAFELY(_visibleController);
  TT_RELEASE_SAFELY(_stashedController);

  [super dealloc];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)layoutViewController:(UIViewController*)viewController {
  CGSize statusBarSize = [UIApplication sharedApplication].statusBarFrame.size;
  CGFloat statusBarHeight = fminf(statusBarSize.width, statusBarSize.height);

  viewController.view.frame = CGRectMake(0, 0,
                                         TTScreenBounds().size.width,
                                         TTScreenBounds().size.height - statusBarHeight);
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)finalizeTransitionFromController: (UIViewController*)fromController
                              didAnimate: (BOOL)didAnimate {
  [fromController viewDidDisappear:didAnimate];
  [_visibleController viewDidAppear:didAnimate];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)showController: (UIViewController*)controller
            transition: (UIViewAnimationTransition)transition
              animated: (BOOL)animated {
  if (_visibleController == controller) {
    return;
  }

  BOOL willAnimate = (animated && nil != _visibleController);

  controller.view.autoresizingMask = (UIViewAutoresizingFlexibleWidth
                                      | UIViewAutoresizingFlexibleHeight);
  controller.superController = self;
  [self layoutViewController:controller];

  [_visibleController viewWillDisappear:willAnimate];
  [controller viewWillAppear:willAnimate];

  // In practice, this is iPhone-specific:
  // We need to ensure that the navigation bar is flush to the top when we flip the view in.
  if ([controller isKindOfClass:[UINavigationController class]]) {
    UINavigationController* navController = (UINavigationController*)controller;
    navController.navigationBar.top = 0;
  }

  const NSTimeInterval kAnimationDuration = TT_FLIP_TRANSITION_DURATION;

  if (willAnimate) {
    [UIView beginAnimations:nil context:[_visibleController retain]];
    [UIView setAnimationDuration:kAnimationDuration];
    [UIView setAnimationTransition: transition
                           forView: self.view
                             cache: YES];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(animationDidStop:finished:context:)];
  }

  [_visibleController.view removeFromSuperview];
  [self.view addSubview:controller.view];

  if (willAnimate) {
    [UIView commitAnimations];
  }

  UIViewController* fromController = nil;
  if (!willAnimate) {
    fromController = [_visibleController retain];
  }

  _visibleController.superController = nil;
  TT_RELEASE_SAFELY(_visibleController);
  _visibleController = [controller retain];

  if (!willAnimate) {
    [self finalizeTransitionFromController:fromController didAnimate:willAnimate];
    TT_RELEASE_SAFELY(fromController);
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)pushController: (UIViewController*)controller
            transition: (UIViewAnimationTransition)transition
              animated: (BOOL)animated {
  TTDASSERT(nil == _stashedController);
  TTDASSERT(nil != _visibleController);

  if (nil != _stashedController || nil == _visibleController) {
    return;
  }

  _stashedController = [_visibleController retain];

  [self showController:controller transition:transition animated:animated];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)popControllerWithTransition: (UIViewAnimationTransition)transition
                           animated: (BOOL)animated {
  TTDASSERT(nil != _stashedController);
  TTDASSERT(nil != _visibleController);

  if (nil == _stashedController || nil == _visibleController) {
    return;
  }

  [self showController:_stashedController transition:transition animated:animated];

  TT_RELEASE_SAFELY(_stashedController);
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)animationDidStop: (NSString*)animationID
                finished: (NSNumber*)finished
                 context: (UIViewController*)oldViewController {
  [self finalizeTransitionFromController: oldViewController
                              didAnimate: YES];
  TT_RELEASE_SAFELY(oldViewController);

  // TODO: Notify delegate.
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];

  [_visibleController viewWillAppear:animated];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)viewDidAppear:(BOOL)animated {
  [super viewDidAppear:animated];

  [_visibleController viewDidAppear:animated];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)viewWillDisappear:(BOOL)animated {
  [super viewWillDisappear:animated];

  [_visibleController viewWillDisappear:animated];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)viewDidDisappear:(BOOL)animated {
  [super viewDidDisappear:animated];

  [_visibleController viewDidDisappear:animated];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
  return (nil != _visibleController
          ? [_visibleController shouldAutorotateToInterfaceOrientation:interfaceOrientation]
          : TTIsSupportedOrientation(interfaceOrientation));
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)willRotateToInterfaceOrientation: (UIInterfaceOrientation)toInterfaceOrientation
                                duration: (NSTimeInterval)duration {
  [_visibleController willRotateToInterfaceOrientation: toInterfaceOrientation
                                              duration: duration];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)willAnimateRotationToInterfaceOrientation: (UIInterfaceOrientation)toInterfaceOrientation
                                         duration: (NSTimeInterval)duration {
  [self layoutViewController:_visibleController];
  [_visibleController willAnimateRotationToInterfaceOrientation: toInterfaceOrientation
                                                       duration: duration];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
  [_visibleController didRotateFromInterfaceOrientation:fromInterfaceOrientation];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)willAnimateFirstHalfOfRotationToInterfaceOrientation:
(UIInterfaceOrientation)toInterfaceOrientation
                                                    duration:(NSTimeInterval)duration {
  [_visibleController willAnimateFirstHalfOfRotationToInterfaceOrientation:
   toInterfaceOrientation
                                                                  duration:duration];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)didAnimateFirstHalfOfRotationToInterfaceOrientation:
(UIInterfaceOrientation)toInterfaceOrientation {
  [_visibleController didAnimateFirstHalfOfRotationToInterfaceOrientation:
   toInterfaceOrientation];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)willAnimateSecondHalfOfRotationFromInterfaceOrientation:
(UIInterfaceOrientation)fromInterfaceOrientation
                                                       duration:(NSTimeInterval)duration {
  [_visibleController willAnimateSecondHalfOfRotationFromInterfaceOrientation:
   fromInterfaceOrientation
                                                                     duration:duration];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (UIView *)rotatingHeaderView {
  return [_visibleController rotatingHeaderView];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (UIView *)rotatingFooterView {
  return [_visibleController rotatingFooterView];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)presentModalViewController:(UIViewController*)controller animated:(BOOL)animated {
  // Modal view controllers should stack, so let's find the top-most modal view controller.
  UIViewController* topMostViewController = self;
  while (nil != topMostViewController.modalViewController) {
    topMostViewController = topMostViewController.modalViewController;
  }

  // Avoid an infinite loop.
  if (topMostViewController == self) {
    [super presentModalViewController:controller animated:animated];

  } else {
    [topMostViewController presentModalViewController:controller animated:animated];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark TTNavigatorRootContainer


///////////////////////////////////////////////////////////////////////////////////////////////////
- (UIViewController*)rootViewController {
  return self;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)navigator:(TTBaseNavigator*)navigator setRootViewController:(UIViewController*)controller {
  // This is handled externally, so we no-op here.
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (TTBaseNavigator*)navigatorForRootController:(UIViewController*)controller {
  return [TTNavigator navigator];
}


@end

