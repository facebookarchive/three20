#import "Three20/T3UnclippedView.h"

@implementation T3UnclippedView

- (void)didMoveToSuperview {
  // This allows the view to be shown "full screen", and not offset by the toolbar and status bar
  self.superview.clipsToBounds = NO;

  for (UIView* p = self; p; p = p.superview) {
    p.backgroundColor = self.backgroundColor;
  }
}

@end
