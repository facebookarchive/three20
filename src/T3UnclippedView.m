#import "Three20/T3UnclippedView.h"

@implementation T3UnclippedView

- (void)didMoveToSuperview {
  for (UIView* p = self; p; p = p.superview) {
    // This allows the view to be shown "full screen", and not offset by the toolbar and status bar
    p.clipsToBounds = NO;
    p.backgroundColor = self.backgroundColor;
  }
}

@end
