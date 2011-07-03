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

@synthesize primaryNavigator     = _primaryNavigator;
@synthesize detailsNavigator    = _detailsNavigator;
@synthesize rootPopoverSplitButtonItem   = _rootPopoverSplitButtonItem;
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

    _primaryNavigator = [[TTNavigator alloc] init];
    _primaryNavigator.rootContainer = self;
    _primaryNavigator.persistenceKey = @"splitNavPersistenceLeft";

    _detailsNavigator = [[TTNavigator alloc] init];
    _detailsNavigator.rootContainer = self;
    _detailsNavigator.persistenceKey = @"splitNavPersistenceRight";
  }

  return self;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)dealloc {
  self.delegate = nil;
  TT_RELEASE_SAFELY(_primaryNavigator);
  TT_RELEASE_SAFELY(_detailsNavigator);
  TT_RELEASE_SAFELY(_rootPopoverSplitButtonItem);
  TT_RELEASE_SAFELY(_popoverSplitController);

  [super dealloc];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)updateSplitViewButton {
  if (nil != _detailsNavigator.rootViewController) {

    if (nil != _primaryNavigator.rootViewController) {
      UINavigationController* navController =
      (UINavigationController*)_primaryNavigator.rootViewController;
      UIViewController* topViewController = navController.topViewController;
      if (nil != topViewController) {
        self.rootPopoverSplitButtonItem.title = topViewController.title;
      }
    }

    if (nil == self.rootPopoverSplitButtonItem.title) {
      self.rootPopoverSplitButtonItem.title = @"Default Title";
    }

    UINavigationController* navController =
    (UINavigationController*)_detailsNavigator.rootViewController;
    UIViewController* topViewController = navController.topViewController;
    UINavigationItem* navItem = topViewController.navigationItem;

    if ([[navController viewControllers] count]<=1) {
      navItem.leftBarButtonItem = _rootPopoverSplitButtonItem;
    }
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
    return _primaryNavigator;

  } else if (controller == [self.viewControllers objectAtIndex:1]) {
    return _detailsNavigator;
  }

  return nil;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)navigator:(TTBaseNavigator*)navigator setRootViewController:(UIViewController*)controller {
  if (_detailsNavigator == navigator) {
    self.viewControllers = [NSArray arrayWithObjects:
                            [self.viewControllers objectAtIndex:0],
                            controller,
                            nil];


  } else if (_primaryNavigator == navigator) {
    self.viewControllers = [NSArray arrayWithObjects:
                            controller,
                            [self.viewControllers objectAtIndex:1],
                            nil];


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
  self.rootPopoverSplitButtonItem = barButtonItem;

  [self updateSplitViewButton];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)splitViewController: (UISplitViewController*)svc
     willShowViewController: (UIViewController *)aViewController
  invalidatingBarButtonItem: (UIBarButtonItem *)barButtonItem {
  self.rootPopoverSplitButtonItem = nil;

  [self updateSplitViewButton];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)splitViewController: (UISplitViewController*)svc
          popoverController: (UIPopoverController*)pc
  willPresentViewController: (UIViewController *)aViewController {
  self.popoverSplitController = pc;

  pc.contentViewController = aViewController;
}


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


@end

