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

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

/**
 * This protocol provides information to controllers that are being displayed in a popover.
 * Only the initial content controller will receive these notifications.
 */
@protocol TTNavigatorPopoverProtocol

@optional

/**
 * Sent immediately before viewWillAppear: to notify the controller that it is being displayed
 * within a popover.
 */
- (void)viewWillAppearInPopover:(UIPopoverController*)popoverController;

// Sent when the popover is about to be dismissed. Returning NO will stop the popover from being
// dismissed.
- (BOOL)shouldDismissPopover:(UIPopoverController*)popoverController;

@end
