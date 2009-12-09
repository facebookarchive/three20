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

#import "Three20/UINSStringAdditions.h"
#import "Three20/UINSObjectAdditions.h"

/**
 * Gets the current interface orientation.
 */
UIInterfaceOrientation TTInterfaceOrientation();

/**
 * Gets the bounds of the screen with device orientation factored in.
 */
CGRect TTScreenBounds();

/**
 * Gets the application frame below the navigation bar.
 */
CGRect TTNavigationFrame();

/**
 * Gets the application frame below the navigation bar and above a toolbar.
 */
CGRect TTToolbarNavigationFrame();

/**
 * Gets the application frame below the navigation bar and above the keyboard.
 */
CGRect TTKeyboardNavigationFrame();

/**
 * The height of the area containing the status bar and possibly the in-call status bar.
 */
CGFloat TTStatusHeight();

/**
 * The height of the area containing the status bar and navigation bar.
 */
CGFloat TTBarsHeight();

/**
 * The height of a toolbar.
 */
CGFloat TTToolbarHeight();

/**
 * The height of the keyboard.
 */
CGFloat TTKeyboardHeight();
