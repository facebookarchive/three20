#import "Three20/TTPopupViewController.h"

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation TTPopupViewController

///////////////////////////////////////////////////////////////////////////////////////////////////
// NSObject

- (id)init {
  if (self = [super init]) {
    _statusBarStyle = [UIApplication sharedApplication].statusBarStyle;
  }
  return self;
}

- (void)dealloc {
  self.superController.popupViewController = nil;
  [super dealloc];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// public

- (void)showInView:(UIView*)view animated:(BOOL)animated {
}

- (void)dismissPopupViewControllerAnimated:(BOOL)animated {
}

@end
