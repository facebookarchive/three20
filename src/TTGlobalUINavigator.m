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

#import "Three20/TTGlobalUINavigator.h"

#import "Three20/TTGlobalUI.h"

#import "Three20/TTNavigator.h"


///////////////////////////////////////////////////////////////////////////////////////////////////
UIInterfaceOrientation TTInterfaceOrientation() {
  UIInterfaceOrientation orient = [UIApplication sharedApplication].statusBarOrientation;
  if (UIDeviceOrientationUnknown == orient) {
    return [TTNavigator navigator].visibleViewController.interfaceOrientation;
  } else {
    return orient;
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
CGRect TTScreenBounds() {
  CGRect bounds = [UIScreen mainScreen].bounds;
  if (UIInterfaceOrientationIsLandscape(TTInterfaceOrientation())) {
    CGFloat width = bounds.size.width;
    bounds.size.width = bounds.size.height;
    bounds.size.height = width;
  }
  return bounds;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
CGRect TTNavigationFrame() {
  CGRect frame = [UIScreen mainScreen].applicationFrame;
  return CGRectMake(0, 0, frame.size.width, frame.size.height - TTToolbarHeight());
}


///////////////////////////////////////////////////////////////////////////////////////////////////
CGRect TTToolbarNavigationFrame() {
  CGRect frame = [UIScreen mainScreen].applicationFrame;
  return CGRectMake(0, 0, frame.size.width, frame.size.height - TTToolbarHeight()*2);
}


///////////////////////////////////////////////////////////////////////////////////////////////////
CGRect TTKeyboardNavigationFrame() {
  return TTRectContract(TTNavigationFrame(), 0, TTKeyboardHeight());
}


///////////////////////////////////////////////////////////////////////////////////////////////////
CGFloat TTStatusHeight() {
  UIInterfaceOrientation orientation = TTInterfaceOrientation();
  if (orientation == UIInterfaceOrientationLandscapeLeft) {
    return [UIScreen mainScreen].applicationFrame.origin.x;
  } else if (orientation == UIInterfaceOrientationLandscapeRight) {
    return -[UIScreen mainScreen].applicationFrame.origin.x;
  } else {
    return [UIScreen mainScreen].applicationFrame.origin.y;
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
CGFloat TTBarsHeight() {
  CGRect frame = [UIApplication sharedApplication].statusBarFrame;
  if (UIInterfaceOrientationIsPortrait(TTInterfaceOrientation())) {
    return frame.size.height + TT_ROW_HEIGHT;
  } else {
    return frame.size.width + TT_LANDSCAPE_TOOLBAR_HEIGHT;
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
CGFloat TTToolbarHeight() {
  return TTToolbarHeightForOrientation(TTInterfaceOrientation());
}


///////////////////////////////////////////////////////////////////////////////////////////////////
CGFloat TTKeyboardHeight() {
  return TTKeyboardHeightForOrientation(TTInterfaceOrientation());
}
