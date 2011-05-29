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
 * A custom split view controller implementation that implements the navigator root protocol.
 *
 * See the TTCatalog sample app for an example of this controller in action.
 */
@interface TTSplitViewController : UIViewController <
  TTNavigatorRootContainer
> {
@private
  UIViewController* _primaryViewController;
  UIViewController* _secondaryViewController;

  TTNavigator* _secondaryNavigator;
  TTNavigator* _primaryNavigator;

  // Used to "dim" the primary navigator. It's simply a black overlay view with 50% transparency.
  UIView* _primaryDimmerView;
}

/**
 * The primary view controller is the larger of the two view controllers. In practice, the
 * primary view controller is the one on the right.
 * The secondary view controller is generally reserved for left-side navigation.
 */
@property (nonatomic, retain)   UIViewController*     primaryViewController;
@property (nonatomic, retain)   UIViewController*     secondaryViewController;

/**
 * These are each independent navigators with their own URL maps.
 */
@property (nonatomic, readonly) TTNavigator*          primaryNavigator;
@property (nonatomic, readonly) TTNavigator*          secondaryNavigator;

/**
 * Access is granted to the dimmer view here for layout purposes. If you implement custom
 * layouts in a subclass, you should update the frame of the dimmer view accordingly.
 *
 * For example:
 *
 *     self.primaryDimmerView.frame = self.primaryViewController.view.frame;
 *
 */
@property (nonatomic, readonly) UIView*               primaryDimmerView;

/**
 * Dims the primary view controller.
 */
- (void)dimPrimaryViewController:(BOOL)isDimmed animated:(BOOL)isAnimated;

/**
 * This method is called on willAnimateRotationToInterfaceOrientation: and when new
 * view controllers are set. If you override this method, you should call super in order
 * to lay out the controllers.
 */
- (void)updateLayoutWithOrientation:(UIInterfaceOrientation)interfaceOrientation;

/**
 * Called after the relevant controller receives the viewDidApppear: method. Useful for doing
 * any layout adjustments after either view appears.
 *
 * The default implementation does nothing.
 */
- (void)primaryViewDidAppear:(BOOL)animated;
- (void)secondaryViewDidAppear:(BOOL)animated;

@end

/**
 * This protocol is meant to be implemented by the primary and secondary view controllers in
 * order to provide them with additional information.
 */
@protocol TTSplitViewControllerProtocol
@optional

/**
 * The primary dimmer view was tapped.
 *
 * The split view controller won't do anything by default when the dimmer is tapped.
 * If you want to hide the dimmer you will need to call dimPrimaryViewController:animated:
 */
- (void)splitViewControllerDimmerWasTapped:(TTSplitViewController*)splitViewController;

@end
