#import "Three20/TTPopupViewController.h"

/**
 * A view controller that displays an alert view.
 *
 * This class exists in order to allow alert views to be displayed by TTNavigator, and gain
 * all the benefits of persistence and URL dispatch.
 */
@interface TTAlertViewController : TTPopupViewController <UIAlertViewDelegate> {
  id<UIAlertViewDelegate> _delegate;
  NSMutableArray* _URLs;
}

@property(nonatomic,assign) id<UIAlertViewDelegate> delegate;
@property(nonatomic,readonly) UIAlertView* alertView;

- (id)initWithTitle:(NSString*)title message:(NSString*)message;
- (id)initWithTitle:(NSString*)title message:(NSString*)message delegate:(id)delegate;

- (NSInteger)addButtonWithTitle:(NSString*)title URL:(NSString*)URL;
- (NSInteger)addCancelButtonWithTitle:(NSString*)title URL:(NSString*)URL;

- (NSString*)buttonURLAtIndex:(NSInteger)index;

@end
