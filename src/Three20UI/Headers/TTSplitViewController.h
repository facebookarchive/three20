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

#import "Three20UINavigator/TTNavigatorRootContainer.h"

@class TTNavigator;

/**
 * A split view controller that implements the navigator root protocol.
 *
 * See the TTCatalog sample app for an example of this controller in action.
 */
@interface TTSplitViewController : UISplitViewController <
  UISplitViewControllerDelegate,
  TTNavigatorRootContainer
> {
@private
  TTNavigator* _primaryNavigator;
  TTNavigator* _detailsNavigator;

  UIBarButtonItem*      _rootPopoverSplitButtonItem;
  UIPopoverController*  _popoverSplitController;
}

@property (nonatomic, readonly) TTNavigator*          primaryNavigator;
@property (nonatomic, readonly) TTNavigator*          detailsNavigator;
@property (nonatomic, retain)   UIBarButtonItem*      rootPopoverSplitButtonItem;
@property (nonatomic, retain)   UIPopoverController*  popoverSplitController;


/**
 * Show/hide the button as the right-side navigator's root navigation item's left button.
 */
- (void)updateSplitViewButton;

@end
