#import "Three20/TTPopupViewController.h"

/**
 * A view controller that displays an action sheet.
 *
 * This class exists in order to allow action sheets to be displayed by TTNavigator, and gain
 * all the benefits of persistence and URL dispatch.
 */
@interface TTActionSheetController : TTPopupViewController {
}

@property(nonatomic,readonly) UIActionSheet* actionSheet;

- (id)initWithTitle:(NSString*)title delegate:(id)delegate
      cancelButtonTitle:(NSString*)cancelButtonTitle
      destructiveButtonTitle:(NSString*)destructiveButtonTitle
      otherButtonTitles:(NSString*)otherButtonTitles, ...;

@end
