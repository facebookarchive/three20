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

#import "Three20UINavigator/UIViewController+TTNavigator.h"

// UINavigator
#import "Three20UINavigator/TTBasicNavigator.h"
#import "Three20UINavigator/TTURLMap.h"

// UICommon
#import "Three20UICommon/UIViewControllerAdditions.h"


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation UIViewController (TTNavigator)


///////////////////////////////////////////////////////////////////////////////////////////////////
/**
 * Swapped with dealloc by TTBasicNavigator (only if you're using TTBasicNavigator)
 */
- (void)ttdealloc {
  NSString* URL = self.originalNavigatorURL;
  if (URL) {
    [[TTBasicNavigator globalNavigator].URLMap removeObjectForURL:URL];
    self.originalNavigatorURL = nil;
  }

  self.superController = nil;
  self.popupViewController = nil;

  // Calls the original dealloc, swizzled away
  [self ttdealloc];
}


@end

