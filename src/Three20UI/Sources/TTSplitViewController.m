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

#import "Three20UI/TTSplitViewController.h"

// UI
#import "Three20UI/TTNavigator.h"
#import "Three20UI/UIViewAdditions.h"

// UINavigator
#import "Three20UINavigator/TTGlobalNavigatorMetrics.h"

// UICommon
#import "Three20UICommon/TTGlobalUICommon.h"
#import "Three20UICommon/UIViewControllerAdditions.h"

// Core
#import "Three20Core/TTCorePreprocessorMacros.h"
#import "Three20Core/TTDebug.h"

static const CGFloat kMasterWidthInPortrait = 270;
static const CGFloat kMasterWidthInLandscape = 330;


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation TTSplitViewController

@synthesize primaryViewController   = _primaryViewController;
@synthesize secondaryViewController = _secondaryViewController;

@synthesize primaryNavigator        = _primaryNavigator;
@synthesize secondaryNavigator      = _secondaryNavigator;

@synthesize primaryDimmerView       = _primaryDimmerView;


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)dealloc {
  TT_RELEASE_SAFELY(_primaryViewController);
  TT_RELEASE_SAFELY(_secondaryViewController);
  TT_RELEASE_SAFELY(_primaryDimmerView);
  TT_RELEASE_SAFELY(_primaryNavigator);
  TT_RELEASE_SAFELY(_secondaryNavigator);

  [super dealloc];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
  if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
    _secondaryNavigator = [[TTNavigator alloc] init];
    _primaryNavigator = [[TTNavigator alloc] init];

    // The split view controller must be the root container for the app, so we set the
    // root container for each of the navigators here.
    _secondaryNavigator.rootContainer = self;
    _primaryNavigator.rootContainer = self;

    // Set up per-navigator persistence.
    _secondaryNavigator.persistenceKey = @"splitNavPersistenceLeft";
    _primaryNavigator.persistenceKey = @"splitNavPersistenceRight";
  }

  return self;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (CGFloat)secondaryWidthWithOrientation:(UIInterfaceOrientation)interfaceOrientation {
  return (UIInterfaceOrientationIsLandscape(interfaceOrientation)
          ? kMasterWidthInLandscape
          : kMasterWidthInPortrait);
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)updateLayoutWithOrientation:(UIInterfaceOrientation)interfaceOrientation {
  CGFloat masterWidth = [self secondaryWidthWithOrientation:interfaceOrientation];

  // Right side, large view.
  _primaryViewController.view.height = self.view.height;
  _primaryViewController.view.width = self.view.width - masterWidth;
  _primaryViewController.view.left = masterWidth;
  _primaryViewController.view.top = 0;

  // Left side, small view.
  _secondaryViewController.view.height = self.view.height;
  _secondaryViewController.view.width = masterWidth;
  _secondaryViewController.view.left = 0;
  _secondaryViewController.view.top = 0;

  _primaryDimmerView.frame = _primaryViewController.view.frame;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark UIViewController


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)loadView {
  [super loadView];

  self.view.autoresizingMask = (UIViewAutoresizingFlexibleWidth
                                | UIViewAutoresizingFlexibleHeight);

  [self.view addSubview:self.secondaryViewController.view];
  [self.view addSubview:self.primaryViewController.view];
  [self.view addSubview:_primaryDimmerView];

  [self updateLayoutWithOrientation:TTInterfaceOrientation()];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];

  [_primaryViewController viewWillAppear:animated];
  [_secondaryViewController viewWillAppear:animated];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)viewDidAppear:(BOOL)animated {
  [super viewDidAppear:animated];

  [_primaryViewController viewDidAppear:animated];
  [_secondaryViewController viewDidAppear:animated];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)viewWillDisappear:(BOOL)animated {
  [super viewWillDisappear:animated];

  [_primaryViewController viewWillDisappear:animated];
  [_secondaryViewController viewWillDisappear:animated];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)viewDidDisappear:(BOOL)animated {
  [super viewDidDisappear:animated];

  [_primaryViewController viewDidDisappear:animated];
  [_secondaryViewController viewDidDisappear:animated];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
  return TTIsSupportedOrientation(interfaceOrientation);
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)willRotateToInterfaceOrientation: (UIInterfaceOrientation)toInterfaceOrientation
                                duration: (NSTimeInterval)duration {
  [_primaryViewController willRotateToInterfaceOrientation: toInterfaceOrientation
                                                  duration: duration];
  [_secondaryViewController willRotateToInterfaceOrientation: toInterfaceOrientation
                                                    duration: duration];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)willAnimateRotationToInterfaceOrientation: (UIInterfaceOrientation)toInterfaceOrientation
                                         duration: (NSTimeInterval)duration {
  [self updateLayoutWithOrientation:toInterfaceOrientation];

  [_primaryViewController willAnimateRotationToInterfaceOrientation: toInterfaceOrientation
                                                           duration: duration];
  [_secondaryViewController willAnimateRotationToInterfaceOrientation: toInterfaceOrientation
                                                             duration: duration];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
  [_primaryViewController didRotateFromInterfaceOrientation:fromInterfaceOrientation];
  [_secondaryViewController didRotateFromInterfaceOrientation:fromInterfaceOrientation];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)willAnimateFirstHalfOfRotationToInterfaceOrientation:
                                                     (UIInterfaceOrientation)toInterfaceOrientation
                                                    duration:(NSTimeInterval)duration {
  [_primaryViewController willAnimateFirstHalfOfRotationToInterfaceOrientation:
   toInterfaceOrientation
                                                                      duration:duration];
  [_secondaryViewController willAnimateFirstHalfOfRotationToInterfaceOrientation:
   toInterfaceOrientation
                                                                        duration:duration];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)didAnimateFirstHalfOfRotationToInterfaceOrientation:
                                                  (UIInterfaceOrientation)toInterfaceOrientation {
  [_primaryViewController didAnimateFirstHalfOfRotationToInterfaceOrientation:
   toInterfaceOrientation];
  [_secondaryViewController didAnimateFirstHalfOfRotationToInterfaceOrientation:
   toInterfaceOrientation];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)willAnimateSecondHalfOfRotationFromInterfaceOrientation:
                                                (UIInterfaceOrientation)fromInterfaceOrientation
                                                       duration:(NSTimeInterval)duration {
  [_primaryViewController willAnimateSecondHalfOfRotationFromInterfaceOrientation:
   fromInterfaceOrientation
                                                                         duration:duration];
  [_secondaryViewController willAnimateSecondHalfOfRotationFromInterfaceOrientation:
   fromInterfaceOrientation
                                                                           duration:duration];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Properties


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setPrimaryViewController:(UIViewController *)primaryViewController {
  if (_primaryViewController != primaryViewController) {

    // We don't bother with this if the view hasn't been loaded.
    if ([self isViewLoaded]) {
      [_primaryViewController viewWillDisappear:NO];
      [_primaryViewController.view removeFromSuperview];
      [_primaryViewController viewDidDisappear:NO];
    }

    TT_RELEASE_SAFELY(_primaryViewController);

    if (primaryViewController != nil) {
      _primaryViewController = [primaryViewController retain];

      _primaryViewController.superController = self;

      UIView* primaryView = self.primaryViewController.view;
      primaryView.autoresizingMask = (UIViewAutoresizingFlexibleWidth
                                      | UIViewAutoresizingFlexibleHeight);

      if ([self isViewLoaded]) {
        [self updateLayoutWithOrientation:TTInterfaceOrientation()];

        [_primaryViewController viewWillAppear:NO];
        {
          [self.view addSubview:primaryView];

          // The primary view should be displayed on top of every other view, except the dimmer.
          [self.view bringSubviewToFront:primaryView];

          // Just in case we've swapped out the primary view while it was dimmed, let's ensure the
          // dimmer is frontmost.
          [self.view bringSubviewToFront:_primaryDimmerView];
        }
        [_primaryViewController viewDidAppear:NO];
      }
    }
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setSecondaryViewController:(UIViewController *)secondaryViewController {
  if (_secondaryViewController != secondaryViewController) {

    if ([self isViewLoaded]) {
      [_secondaryViewController viewWillDisappear:NO];
      [_secondaryViewController.view removeFromSuperview];
      [_secondaryViewController viewDidDisappear:NO];
    }

    TT_RELEASE_SAFELY(_secondaryViewController);

    if (secondaryViewController != nil) {
      _secondaryViewController = [secondaryViewController retain];

      _secondaryViewController.superController = self;

      UIView* secondaryView = self.secondaryViewController.view;
      secondaryView.autoresizingMask = UIViewAutoresizingFlexibleHeight;

      if ([self isViewLoaded]) {
        [self updateLayoutWithOrientation:TTInterfaceOrientation()];

        [_secondaryViewController viewWillAppear:NO];
        {
          [self.view addSubview:secondaryView];
        }
        [_secondaryViewController viewDidAppear:NO];
      }
    }
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
- (TTBaseNavigator*)navigatorForRootController:(UIViewController*)controller {
  if (controller == self.secondaryViewController) {
    return _secondaryNavigator;

  } else if (controller == self.primaryViewController) {
    return _primaryNavigator;
  }

  return nil;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)navigator:(TTBaseNavigator*)navigator setRootViewController:(UIViewController*)controller {
  if (_primaryNavigator == navigator) {
    [self setPrimaryViewController:controller];

  } else if (_secondaryNavigator == navigator) {
    [self setSecondaryViewController:controller];

  } else {
    // Invalid navigator sent here.
    TTDASSERT(NO);
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark TTNavigator


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)canContainControllers {
  return YES;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)canBeTopViewController {
  return YES;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (UIViewController*)superController {
  return nil;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Public Methods


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)dimPrimaryViewController:(BOOL)isDimmed animated:(BOOL)isAnimated {
  if (nil == _primaryDimmerView) {
    _primaryDimmerView = [[UIView alloc] init];
    _primaryDimmerView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
    _primaryDimmerView.alpha = isDimmed ? 0 : 1;
    _primaryDimmerView.autoresizingMask = (UIViewAutoresizingFlexibleWidth
                                           | UIViewAutoresizingFlexibleHeight);

    UITapGestureRecognizer* tap =
    [[[UITapGestureRecognizer alloc] initWithTarget: self
                                             action: @selector(primaryDimmerDidTap:)]
     autorelease];
    [_primaryDimmerView addGestureRecognizer:tap];
  }

  _primaryDimmerView.frame = _primaryViewController.view.frame;
  [self.view addSubview:_primaryDimmerView];

  if (isAnimated) {
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:TT_TRANSITION_DURATION];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(detailDimmerDidFade)];
  }

  _primaryDimmerView.alpha = isDimmed ? 1 : 0;

  if (isAnimated) {
    [UIView commitAnimations];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)detailDimmerDidFade {
  if (0 == _primaryDimmerView.alpha) {
    [_primaryDimmerView removeFromSuperview];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)primaryDimmerDidTap:(UITapGestureRecognizer*)gesture {
  if ([_primaryViewController respondsToSelector:
       @selector(splitViewControllerDimmerWasTapped:)]) {
    [(UIViewController<TTSplitViewControllerProtocol>*)_primaryViewController
     splitViewControllerDimmerWasTapped:self];
  }

  if ([_secondaryViewController respondsToSelector:
       @selector(splitViewControllerDimmerWasTapped:)]) {
    [(UIViewController<TTSplitViewControllerProtocol>*)_secondaryViewController
     splitViewControllerDimmerWasTapped:self];
  }
}


@end

