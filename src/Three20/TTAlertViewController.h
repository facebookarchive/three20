#import "Three20/TTPopupViewController.h"

@protocol TTAlertViewControllerDelegate;

/**
 * A view controller that displays an alert view.
 *
 * This class exists in order to allow alert views to be displayed by TTNavigator, and gain
 * all the benefits of persistence and URL dispatch.
 */
@interface TTAlertViewController : TTPopupViewController <UIAlertViewDelegate> {
  id<TTAlertViewControllerDelegate> _delegate;
  id _userInfo;
  NSMutableArray* _URLs;
}

@property(nonatomic,assign) id<TTAlertViewControllerDelegate> delegate;
@property(nonatomic,readonly) UIAlertView* alertView;
@property(nonatomic,retain) id userInfo;

- (id)initWithTitle:(NSString*)title message:(NSString*)message;
- (id)initWithTitle:(NSString*)title message:(NSString*)message delegate:(id)delegate;

- (NSInteger)addButtonWithTitle:(NSString*)title URL:(NSString*)URL;
- (NSInteger)addCancelButtonWithTitle:(NSString*)title URL:(NSString*)URL;

- (NSString*)buttonURLAtIndex:(NSInteger)index;

@end

@protocol TTAlertViewControllerDelegate <UIAlertViewDelegate>

- (BOOL)alertViewController:(TTAlertViewController*)controller
        didDismissWithButtonIndex:(NSInteger)buttonIndex URL:(NSString*)URL;

@end
