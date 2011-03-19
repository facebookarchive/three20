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

#import <UIKit/UIKit.h>

@class TTBaseNavigator;

/**
 * A root container object is any object that can set a root view controller.
 *
 * On the iPhone this generally isn't necessary because you'll have one
 * navigator in the app at a time, and the window will always own the root controller.
 *
 * On the iPad there are a variety of implementations that require multiple
 * navigators to exist simultaneously. With a split-view design, for example, one might have
 * two controllers on the screen simultaneously, each with their own TTNavigator mapping.
 *
 * If no root container is specified for a TTNavigator, the key window will be assumed as the
 * root container.
 */
@protocol TTNavigatorRootContainer <NSObject>

@required

/**
 * The top-most controller this container is aware of. In practice, this is often the container
 * itself.
 */
- (UIViewController*)rootViewController;

/**
 * Set the root view controller for the given navigator.
 */
- (void)navigator:(TTBaseNavigator*)navigator setRootViewController:(UIViewController*)controller;

/**
 * Retrieve the navigator that has this controller as its root.
 */
- (TTBaseNavigator*)navigatorForRootController:(UIViewController*)controller;

@end

