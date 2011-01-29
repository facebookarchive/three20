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

// Core
#import "Three20Core/TTCorePreprocessorMacros.h"
#import "Three20Core/TTDebug.h"


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation TTSplitViewController

@synthesize leftNavigator     = _leftNavigator;
@synthesize rightNavigator    = _rightNavigator;
@synthesize splitViewButton   = _splitViewButton;
@synthesize popoverSplitController = _popoverSplitController;


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
  if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
    self.delegate = self;

    self.viewControllers = [NSArray arrayWithObjects:
                            [[[UINavigationController alloc] initWithNibName: nil
                                                                      bundle: nil] autorelease],
                            [[[UINavigationController alloc] initWithNibName: nil
                                                                      bundle: nil] autorelease],
                            nil];

    _leftNavigator = [[TTNavigator alloc] init];
    _leftNavigator.rootContainer = self;
    _leftNavigator.persistenceKey = @"splitNavPersistenceLeft";

    _rightNavigator = [[TTNavigator alloc] init];
    _rightNavigator.rootContainer = self;
    _rightNavigator.persistenceKey = @"splitNavPersistenceRight";
  }

  return self;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)dealloc {
  self.delegate = nil;
  TT_RELEASE_SAFELY(_leftNavigator);
  TT_RELEASE_SAFELY(_rightNavigator);
  TT_RELEASE_SAFELY(_splitViewButton);
  TT_RELEASE_SAFELY(_popoverSplitController);

  [super dealloc];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)updateSplitViewButton {
  if (nil != _rightNavigator.rootViewController) {

    if (nil != _leftNavigator.rootViewController) {
      UINavigationController* navController =
        (UINavigationController*)_leftNavigator.rootViewController;
      UIViewController* topViewController = navController.topViewController;
      if (nil != topViewController) {
        self.splitViewButton.title = topViewController.title;
      }
    }

    if (nil == self.splitViewButton.title) {
      self.splitViewButton.title = @"Default Title";
    }

    UINavigationController* navController =
      (UINavigationController*)_rightNavigator.rootViewController;
    UIViewController* topViewController = navController.topViewController;
    UINavigationItem* navItem = topViewController.navigationItem;

    navItem.leftBarButtonItem = _splitViewButton;
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)viewDidAppear:(BOOL)animated {
  [super viewDidAppear:animated];

  [self updateSplitViewButton];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark TTNavigatorRootContainer


///////////////////////////////////////////////////////////////////////////////////////////////////
- (TTBaseNavigator*)getNavigatorForController:(UIViewController*)controller {
  if (controller == [self.viewControllers objectAtIndex:0]) {
    return _leftNavigator;

  } else if (controller == [self.viewControllers objectAtIndex:1]) {
    return _rightNavigator;
  }

  return nil;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)navigator:(TTBaseNavigator*)navigator setRootViewController:(UIViewController*)controller {
  if (_rightNavigator == navigator) {
    self.viewControllers = [NSArray arrayWithObjects:
                            [self.viewControllers objectAtIndex:0],
                            controller,
                            nil];

    [self updateSplitViewButton];

  } else if (_leftNavigator == navigator) {
    self.viewControllers = [NSArray arrayWithObjects:
                            controller,
                            [self.viewControllers objectAtIndex:1],
                            nil];

    [self updateSplitViewButton];

  } else {
    // Invalid navigator sent here.
    TTDASSERT(NO);
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark UISplitViewControllerDelegate


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)splitViewController: (UISplitViewController*)svc
     willHideViewController: (UIViewController *)aViewController
          withBarButtonItem: (UIBarButtonItem*)barButtonItem
       forPopoverController: (UIPopoverController*)pc {
  self.splitViewButton = barButtonItem;

  [self updateSplitViewButton];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)splitViewController: (UISplitViewController*)svc
     willShowViewController: (UIViewController *)aViewController
  invalidatingBarButtonItem: (UIBarButtonItem *)barButtonItem {
  self.splitViewButton = nil;

  [self updateSplitViewButton];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)splitViewController: (UISplitViewController*)svc
          popoverController: (UIPopoverController*)pc
  willPresentViewController: (UIViewController *)aViewController {
  self.popoverSplitController = pc;

  pc.contentViewController = aViewController;
}


@end

