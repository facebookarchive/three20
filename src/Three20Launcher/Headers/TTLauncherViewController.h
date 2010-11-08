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

// Launcher
#import "Three20Launcher/TTLauncherViewDelegate.h"

// UI
#import "Three20UI/TTViewController.h"

@class TTLauncherView;

/**
 * A dead simple view controller with a launcher view covering the entire view.
 *
 * Displays and hides a "Done" button in the top-right corner when editing the launcher view.
 *
 * Default background color is black.
 */
@interface TTLauncherViewController : TTViewController <
  TTLauncherViewDelegate
> {
@private
  TTLauncherView*   _launcherView;

  // Stored while editing.
  UIBarButtonItem*  _oldRightBarButtonItem;
}

@property (nonatomic, retain) TTLauncherView* launcherView;

@end
