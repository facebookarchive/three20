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

#import "Three20Launcher/TTLauncherViewController.h"

// Launcher
#import "Three20Launcher/TTLauncherView.h"

// Core
#import "Three20Core/TTCorePreprocessorMacros.h"


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation TTLauncherViewController

@synthesize launcherView = _launcherView;


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)dealloc {
  TT_RELEASE_SAFELY(_launcherView);

  [super dealloc];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark UIViewController


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)loadView {
  [super loadView];

  self.view.backgroundColor = [UIColor blackColor];

  self.launcherView.delegate = self;

  [self.view addSubview:self.launcherView];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)viewDidUnload {
  [super viewDidUnload];

  TT_RELEASE_SAFELY(_launcherView);
}


///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Properties


///////////////////////////////////////////////////////////////////////////////////////////////////
- (TTLauncherView*)launcherView {
  if (nil == _launcherView) {
    _launcherView = [[TTLauncherView alloc] initWithFrame:self.view.bounds];
    _launcherView.autoresizingMask = (UIViewAutoresizingFlexibleWidth
                                      | UIViewAutoresizingFlexibleHeight);
  }

  return _launcherView;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark TTLauncherViewDelegate


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)launcherViewDidBeginEditing:(TTLauncherView*)launcher {
  UIBarButtonItem* doneEditingButton =
    [[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemDone
                                                  target: self.launcherView
                                                  action: @selector(endEditing)];

  [self.navigationItem setRightBarButtonItem:doneEditingButton animated:YES];

  TT_RELEASE_SAFELY(doneEditingButton);
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)launcherViewDidEndEditing:(TTLauncherView*)launcher {
  [self.navigationItem setRightBarButtonItem:nil animated:YES];
}


@end

