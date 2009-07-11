#import "Three20/TTAlertViewController.h"

///////////////////////////////////////////////////////////////////////////////////////////////////

@interface TTAlertView : UIAlertView {
  UIViewController* _popupViewController;
}

@property(nonatomic,retain) UIViewController* popupViewController;

@end

@implementation TTAlertView

@synthesize popupViewController = _popupViewController;

- (id)initWithFrame:(CGRect)frame {
  if (self = [super initWithFrame:frame]) {
    _popupViewController = nil;
  }
  return self;
}

- (void)dealloc {
  [super dealloc];
}

- (void)didMoveToSuperview {
  if (!self.superview) {
    [_popupViewController release];
  }
}

@end

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation TTAlertViewController

///////////////////////////////////////////////////////////////////////////////////////////////////
// NSObject

- (id)initWithTitle:(NSString*)title message:(NSString*)message delegate:(id)delegate
      cancelButtonTitle:(NSString*)cancelButtonTitle
      otherButtonTitles:(NSString*)otherButtonTitles, ... {
  if (self = [super init]) {
    TTAlertView* alertView = [[[TTAlertView alloc] initWithTitle:title message:message
                                                   delegate:delegate
                                                   cancelButtonTitle:cancelButtonTitle
                                                   otherButtonTitles:nil] autorelease];
    alertView.popupViewController = self;

    va_list ap;
    va_start(ap, otherButtonTitles);
    while (otherButtonTitles) {
      [alertView addButtonWithTitle:otherButtonTitles];
      otherButtonTitles = va_arg(ap, id);
    }
    va_end(ap);
    
    self.view = alertView;
  }
  return self;
}

- (id)init {
  if (self = [super init]) {
    TTAlertView* alertView = [[[TTAlertView alloc] init] autorelease];
    alertView.popupViewController = self;
    self.view = alertView;
  }
  return self;
}

- (void)dealloc {
  [super dealloc];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// TTPopupViewController

- (void)showInViewController:(UIViewController*)parentViewController animated:(BOOL)animated {
  [self.alertView show];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// public

- (UIAlertView*)alertView {
  return (UIAlertView*)self.view;
}

@end
