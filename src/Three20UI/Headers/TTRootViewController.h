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
 * This controller sits at the root of the view hierarchy and will always be the only root view
 * attached to the window.
 *
 * It will only show one controller at a time, but can animate to another controller at any time.
 *
 * This controller is a root container for the Three20 navigator. It will always return the
 * global navigator if this container is hit from a call to [TTNavigator navigatorForView:].
 */
@interface TTRootViewController : UIViewController <
  TTNavigatorRootContainer
> {
@private
  UIViewController* _visibleController;
  UIViewController* _stashedController;
}

/**
 * The currently visible view controller.
 */
@property (nonatomic, readonly) UIViewController* visibleController;

/**
 * The pushed view controller.
 */
@property (nonatomic, readonly) UIViewController* stashedController;

/**
 * Present a new view controller using the given transition.
 *
 * @param controller  The new controller to present.
 * @param transition  The transition to use.
 * @param animated    Whether to animate the animation or not.
 */
- (void)showController: (UIViewController*)controller
            transition: (UIViewAnimationTransition)transition
              animated: (BOOL)animated;

/**
 * Present a new view controller using the given transition and stash the old controller.
 *
 * @param controller  The new controller to present.
 * @param transition  The transition to use.
 * @param animated    Whether to animate the animation or not.
 */
- (void)pushController: (UIViewController*)controller
            transition: (UIViewAnimationTransition)transition
              animated: (BOOL)animated;

/**
 * Present the stashed controller with the given transition.
 *
 * @param transition  The transition to use.
 * @param animated    Whether to animate the animation or not.
 */
- (void)popControllerWithTransition: (UIViewAnimationTransition)transition
                           animated: (BOOL)animated;

@end
