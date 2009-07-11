#import "Three20/TTPopupViewController.h"

/**
 * A view controller that displays an alert view.
 *
 * This class exists in order to allow alert views to be displayed by TTNavigator, and gain
 * all the benefits of persistence and URL dispatch.
 */
@interface TTAlertViewController : TTPopupViewController {
}

@property(nonatomic,readonly) UIAlertView* alertView;

- (id)initWithTitle:(NSString*)title message:(NSString*)message delegate:(id)delegate
      cancelButtonTitle:(NSString*)cancelButtonTitle
      otherButtonTitles:(NSString*)otherButtonTitles, ...;

@end
