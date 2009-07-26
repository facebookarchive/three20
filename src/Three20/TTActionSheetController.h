#import "Three20/TTPopupViewController.h"

@protocol TTActionSheetControllerDelegate;

/**
 * A view controller that displays an action sheet.
 *
 * This class exists in order to allow action sheets to be displayed by TTNavigator, and gain
 * all the benefits of persistence and URL dispatch.
 */
@interface TTActionSheetController : TTPopupViewController <UIActionSheetDelegate> {
  id<TTActionSheetControllerDelegate> _delegate;
  id _userInfo;
  NSMutableArray* _URLs;
}

@property(nonatomic,assign) id<TTActionSheetControllerDelegate> delegate;
@property(nonatomic,readonly) UIActionSheet* actionSheet;
@property(nonatomic,retain) id userInfo;

- (id)initWithTitle:(NSString*)title;
- (id)initWithTitle:(NSString*)title delegate:(id)delegate;

- (NSInteger)addButtonWithTitle:(NSString*)title URL:(NSString*)URL;
- (NSInteger)addCancelButtonWithTitle:(NSString*)title URL:(NSString*)URL;
- (NSInteger)addDestructiveButtonWithTitle:(NSString*)title URL:(NSString*)URL;

- (NSString*)buttonURLAtIndex:(NSInteger)index;

@end

@protocol TTActionSheetControllerDelegate <UIActionSheetDelegate>

- (BOOL)actionSheetController:(TTActionSheetController*)controller
        didDismissWithButtonIndex:(NSInteger)buttonIndex URL:(NSString*)URL;

@end
