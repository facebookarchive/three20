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

#import "Three20UICommon/UIWindowAdditions.h"

// Core
#import "Three20Core/TTCorePreprocessorMacros.h"


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
/**
 * Additions.
 */
TT_FIX_CATEGORY_BUG(UIWindowAdditions)

@implementation UIWindow (TTCategory)


///////////////////////////////////////////////////////////////////////////////////////////////////
- (UIView*)findFirstResponder {
  return [self findFirstResponderInView:self];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (UIView*)findFirstResponderInView:(UIView*)topView {
  if ([topView isFirstResponder]) {
    return topView;
  }

  for (UIView* subView in topView.subviews) {
    if ([subView isFirstResponder]) {
      return subView;
    }

    UIView* firstResponderCheck = [self findFirstResponderInView:subView];
    if (nil != firstResponderCheck) {
      return firstResponderCheck;
    }
  }
  return nil;
}


@end
