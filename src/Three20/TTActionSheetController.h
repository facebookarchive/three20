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

#import "Three20/TTPopupViewController.h"

@protocol TTActionSheetControllerDelegate;

/**
 * A view controller that displays an action sheet.
 *
 * This class exists in order to allow action sheets to be displayed by TTNavigator, and gain
 * all the benefits of persistence and URL dispatch.
 *
 * By default this controller is not persisted in the navigation history.
 */
@interface TTActionSheetController : TTPopupViewController <UIActionSheetDelegate> {
@private
  id<TTActionSheetControllerDelegate> _delegate;
  id                                  _userInfo;
  NSMutableArray*                     _URLs;
}

@property (nonatomic, assign)   id<TTActionSheetControllerDelegate> delegate;
@property (nonatomic, readonly) UIActionSheet*                      actionSheet;
@property (nonatomic, retain)   id                                  userInfo;

/**
 * Create an action sheet controller without a delegate.
 *
 * @param title The title of the action sheet.
 */
- (id)initWithTitle:(NSString*)title;

/**
 * The designated initializer.
 *
 * @param title     The title of the action sheet.
 * @param delegate  A delegate that implements the TTActionSheetControllerDelegate protocol.
 */
- (id)initWithTitle:(NSString*)title delegate:(id)delegate;

/**
 * Append a button with the given title and TTNavigator URL.
 *
 * @param title The title of the new button.
 * @param URL   The TTNavigator url.
 * @return The index of the new button. Button indices start at 0 and increase in the order they
 *         are added.
 */
- (NSInteger)addButtonWithTitle:(NSString*)title URL:(NSString*)URL;

/**
 * Create a cancel button with the given title and TTNavigator URL.
 *
 * There can be only one cancel button.
 *
 * @param title The title of the cancel button.
 * @param URL   The TTNavigator url.
 * @return The index of the cancel button. Button indices start at 0 and increase in the order they
 *         are added.
 */
- (NSInteger)addCancelButtonWithTitle:(NSString*)title URL:(NSString*)URL;

/**
 * Create a destructive button with the given title and TTNavigator URL.
 *
 * There can be only one destructive button.
 *
 * @param title The title of the cancel button.
 * @param URL   The TTNavigator url.
 * @return The index of the destructive button. Button indices start at 0 and increase in the order
 *         they are added.
 */
- (NSInteger)addDestructiveButtonWithTitle:(NSString*)title URL:(NSString*)URL;

/**
 * Retrieve the button URL at the given index.
 *
 * @param index The index of the button in question
 * @return nil if index is out of range. Otherwise returns the button's URL at index.
 */
- (NSString*)buttonURLAtIndex:(NSInteger)index;

@end

/**
 * Inherits the UIActionSheetDelegate protocol and adds TTNavigator support.
 */
@protocol TTActionSheetControllerDelegate <UIActionSheetDelegate>
@optional
/**
 * Sent to the delegate after an action sheet is dismissed from the screen.
 *
 * This method is invoked after the animation ends and the view is hidden.
 *
 * If this method is not implemented, the default action is to open the given URL.
 * If this method is implemented and returns NO, then the caller will not navigate to the given
 * URL.
 *
 * @param controller  The controller that was dismissed.
 * @param buttonIndex The index of the button that was clicked. The button indices start at 0. If
 *                    this is the cancel button index, the action sheet is canceling. If -1, the
 *                    cancel button index is not set.
 * @param URL         The URL of the selected button.
 *
 * @return YES to open the given URL with TTOpenURL.
 */
- (BOOL)actionSheetController:(TTActionSheetController*)controller
        didDismissWithButtonIndex:(NSInteger)buttonIndex URL:(NSString*)URL;

@end
