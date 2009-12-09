/**
 * Copyright 2009 Facebook
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "Three20/TTGlobalCore.h"

#import "Three20/UIColorAdditions.h"
#import "Three20/UIFontAdditions.h"
#import "Three20/UIImageAdditions.h"
#import "Three20/UINavigationControllerAdditions.h"
#import "Three20/UITabBarControllerAdditions.h"
#import "Three20/UIViewAdditions.h"
#import "Three20/UITableViewAdditions.h"
#import "Three20/UIWebViewAdditions.h"
#import "Three20/UIToolbarAdditions.h"
#import "Three20/UIWindowAdditions.h"
#import "Three20/UIViewControllerAdditions.h"

///////////////////////////////////////////////////////////////////////////////////////////////////
// Debug logging helpers

#define TTLOGVIEWS(_VIEW) \
  { for (UIView* view = _VIEW; view; view = view.superview) { TTDINFO(@"%@", view); } }


///////////////////////////////////////////////////////////////////////////////////////////////////
// Dimensions of common iPhone OS Views

#define TT_ROW_HEIGHT 44
#define TT_TOOLBAR_HEIGHT 44
#define TT_LANDSCAPE_TOOLBAR_HEIGHT 33
#define TT_KEYBOARD_HEIGHT 216
#define TT_LANDSCAPE_KEYBOARD_HEIGHT 160
#define TT_ROUNDED -1

///////////////////////////////////////////////////////////////////////////////////////////////////
// Color helpers

#define RGBCOLOR(r,g,b) [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:1]
#define RGBACOLOR(r,g,b,a) [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:a]

#define HSVCOLOR(h,s,v) [UIColor colorWithHue:h saturation:s value:v alpha:1]
#define HSVACOLOR(h,s,v,a) [UIColor colorWithHue:h saturation:s value:v alpha:a]

#define RGBA(r,g,b,a) r/255.0, g/255.0, b/255.0, a

///////////////////////////////////////////////////////////////////////////////////////////////////
// Animation

/**
 * The standard duration for transition animations.
 */
#define TT_TRANSITION_DURATION 0.3

#define TT_FAST_TRANSITION_DURATION 0.2

#define TT_FLIP_TRANSITION_DURATION 0.7

/**
 * Gets the current runtime version of iPhone OS.
 */
float TTOSVersion();

/**
 * Checks if the link-time version of the OS is at least a certain version.
 */
BOOL TTOSVersionIsAtLeast(float version);

/**
 * Returns a rectangle with dx and dy subtracted from the width and height, respectively.
 *
 * Example result: CGRectMake(x, y, w - dx, h - dy)
 */
CGRect TTRectContract(CGRect rect, CGFloat dx, CGFloat dy);

/**
 * Returns a rectangle whose origin has been offset by dx, dy, and whose size has been
 * contracted by dx, dy.
 *
 * Example result: CGRectMake(x + dx, y + dy, w - dx, h - dy)
 */
CGRect TTRectShift(CGRect rect, CGFloat dx, CGFloat dy);

/**
 * Returns a rectangle with the given insets.
 *
 * Example result: CGRectMake(x + left, y + top, w - (left + right), h - (top + bottom))
 */
CGRect TTRectInset(CGRect rect, UIEdgeInsets insets);

/**
 * Returns TRUE if the keyboard is visible.
 */
BOOL TTIsKeyboardVisible();

/**
 * Returns TRUE if the device has phone capabilities.
 */
BOOL TTIsPhoneSupported();

/**
 * Returns the current device orientation.
 */
UIDeviceOrientation TTDeviceOrientation();

/**
 * Checks if the orientation is portrait, landscape left, or landscape right.
 *
 * This helps to ignore upside down and flat orientations.
 */
BOOL TTIsSupportedOrientation(UIInterfaceOrientation orientation);

/**
 * Returns the rotation transform for a given orientation.
 */
CGAffineTransform TTRotateTransformForOrientation(UIInterfaceOrientation orientation);

/**
 * Returns the application frame with no offset.
 *
 * From the apple docs:
 * Frame of application screen area in points (i.e. entire screen minus status bar if visible)
 */
CGRect TTApplicationFrame();

/**
 * Returns the toolbar height for a given orientation.
 *
 * The toolbar is slightly shorter in landscape.
 */
CGFloat TTToolbarHeightForOrientation(UIInterfaceOrientation orientation);

/**
 * Returns the height of the keyboard for a given orientation.
 */
CGFloat TTKeyboardHeightForOrientation(UIInterfaceOrientation orientation);

/**
 * A convenient way to show a UIAlertView with a message;
 */
void TTAlert(NSString* message);

/**
 * This method is identical to TTAlert.
 */
void TTAlertError(NSString* message) __TTDEPRECATED_METHOD;
