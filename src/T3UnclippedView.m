#import "Three20/T3UnclippedView.h"

@implementation T3UnclippedView

- (void)didMoveToSuperview {
  // Turns off clipping on every view that contains this view. This allows the translucent
  // toolbar and status bar to blend with the contents of this view
  for (UIView* p = self; p; p = p.superview) {
    p.clipsToBounds = NO;
  }
}

@end
