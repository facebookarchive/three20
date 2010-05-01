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

#import "Three20UINavigator/TTNavigator.h"


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation TTNavigator


///////////////////////////////////////////////////////////////////////////////////////////////////
+ (TTNavigator*)navigator {
  static TTNavigator* navigator = nil;
  if (nil == navigator) {
    navigator = [[TTNavigator alloc] init];
  }
  return navigator;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
/**
 * A popup controller is a view controller that is presented over another controller, but doesn't
 * necessarily completely hide the original controller (like a modal controller would). A classic
 * example is a status indicator while something is loading.
 *
 * @private
 */
- (void)presentPopupController: (TTPopupViewController*)controller
              parentController: (UIViewController*)parentController
                      animated: (BOOL)animated {
  parentController.popupViewController = controller;
  controller.superController = parentController;
  [controller showInView: parentController.view
                animated: animated];
}


@end
