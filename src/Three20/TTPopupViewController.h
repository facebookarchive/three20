#import "Three20/TTModelViewController.h"

/**
 * A view controller which, when displayed modally, inserts its view over the parent controller.
 *
 * Normally, displaying a modal view controller will completely hide the underlying view
 * controller, and even remove its view from the view hierarchy.  Popup view controllers allow
 * you to present a "modal" view which overlaps the parent view controller but does not
 * necessarily hide it.
 * 
 * The best way to use this class is to bind 
 *
 * This class does is meant to be subclassed, not used directly.
 */
@interface TTPopupViewController : TTModelViewController {
}

- (void)showInView:(UIView*)view animated:(BOOL)animated;
- (void)dismissPopupViewControllerAnimated:(BOOL)animated;

@end
