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

#import "Three20/TTGlobalUI.h"

#import "Three20/TTGlobalCoreLocale.h"

#import "Three20/UIWindowAdditions.h"
#import "Three20/TTNavigator.h"

const CGFloat ttkDefaultRowHeight = 44;

const CGFloat ttkDefaultPortraitToolbarHeight   = 44;
const CGFloat ttkDefaultLandscapeToolbarHeight  = 33;

const CGFloat ttkDefaultPortraitKeyboardHeight  = 216;
const CGFloat ttkDefaultLandscapeKeyboardHeight = 160;

const CGFloat ttkRounded = -1;

const CGFloat ttkGroupedTableCellInset = 10.0;

const CGFloat ttkDefaultTransitionDuration      = 0.3;
const CGFloat ttkDefaultFastTransitionDuration  = 0.2;
const CGFloat ttkDefaultFlipTransitionDuration  = 0.7;


///////////////////////////////////////////////////////////////////////////////////////////////////
float TTOSVersion() {
  return [[[UIDevice currentDevice] systemVersion] floatValue];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
BOOL TTOSVersionIsAtLeast(float version) {
  #ifdef __IPHONE_3_0
    return 3.0 >= version;
  #endif
  #ifdef __IPHONE_2_2
    return 2.2 >= version;
  #endif
  #ifdef __IPHONE_2_1
    return 2.1 >= version;
  #endif
  #ifdef __IPHONE_2_0
    return 2.0 >= version;
  #endif
  return NO;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
CGRect TTRectContract(CGRect rect, CGFloat dx, CGFloat dy) {
  return CGRectMake(rect.origin.x, rect.origin.y, rect.size.width - dx, rect.size.height - dy);
}


///////////////////////////////////////////////////////////////////////////////////////////////////
CGRect TTRectShift(CGRect rect, CGFloat dx, CGFloat dy) {
  return CGRectOffset(TTRectContract(rect, dx, dy), dx, dy);
}


///////////////////////////////////////////////////////////////////////////////////////////////////
CGRect TTRectInset(CGRect rect, UIEdgeInsets insets) {
  return CGRectMake(rect.origin.x + insets.left, rect.origin.y + insets.top,
                    rect.size.width - (insets.left + insets.right),
                    rect.size.height - (insets.top + insets.bottom));
}


///////////////////////////////////////////////////////////////////////////////////////////////////
BOOL TTIsKeyboardVisible() {
  // Operates on the assumption that the keyboard is visible if and only if there is a first
  // responder; i.e. a control responding to key events
  UIWindow* window = [UIApplication sharedApplication].keyWindow;
  return !![window findFirstResponder];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
BOOL TTIsPhoneSupported() {
  NSString* deviceType = [UIDevice currentDevice].model;
  return [deviceType isEqualToString:@"iPhone"];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
UIDeviceOrientation TTDeviceOrientation() {
  UIDeviceOrientation orient = [UIDevice currentDevice].orientation;
  if (UIDeviceOrientationUnknown == orient) {
    return UIDeviceOrientationPortrait;
  } else {
    return orient;
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
BOOL TTIsSupportedOrientation(UIInterfaceOrientation orientation) {
  switch (orientation) {
    case UIInterfaceOrientationPortrait:
    case UIInterfaceOrientationLandscapeLeft:
    case UIInterfaceOrientationLandscapeRight:
      return YES;
    default:
      return NO;
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
CGAffineTransform TTRotateTransformForOrientation(UIInterfaceOrientation orientation) {
  if (orientation == UIInterfaceOrientationLandscapeLeft) {
    return CGAffineTransformMakeRotation(M_PI*1.5);
  } else if (orientation == UIInterfaceOrientationLandscapeRight) {
    return CGAffineTransformMakeRotation(M_PI/2);
  } else if (orientation == UIInterfaceOrientationPortraitUpsideDown) {
    return CGAffineTransformMakeRotation(-M_PI);
  } else {
    return CGAffineTransformIdentity;
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
CGRect TTApplicationFrame() {
  CGRect frame = [UIScreen mainScreen].applicationFrame;
  return CGRectMake(0, 0, frame.size.width, frame.size.height);
}


///////////////////////////////////////////////////////////////////////////////////////////////////
CGFloat TTToolbarHeightForOrientation(UIInterfaceOrientation orientation) {
  if (UIInterfaceOrientationIsPortrait(orientation)) {
    return TT_ROW_HEIGHT;
  } else {
    return TT_LANDSCAPE_TOOLBAR_HEIGHT;
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
CGFloat TTKeyboardHeightForOrientation(UIInterfaceOrientation orientation) {
  if (UIInterfaceOrientationIsPortrait(orientation)) {
    return TT_KEYBOARD_HEIGHT;
  } else {
    return TT_LANDSCAPE_KEYBOARD_HEIGHT;
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
void TTAlert(NSString* message) {
  UIAlertView* alert = [[[UIAlertView alloc] initWithTitle:TTLocalizedString(@"Alert", @"")
                                             message:message delegate:nil
                                             cancelButtonTitle:TTLocalizedString(@"OK", @"")
                                             otherButtonTitles:nil] autorelease];
  [alert show];
}
