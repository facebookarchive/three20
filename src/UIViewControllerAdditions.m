#import "Three20/TTGlobal.h"

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation UIViewController (TTCategory)

- (void)showNavigationBar:(BOOL)show animated:(BOOL)animated {
  if (animated) {
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:TT_TRANSITION_DURATION];
  }

  self.navigationController.navigationBar.alpha = show ? 1 : 0;
  
  if (animated) {
    [UIView commitAnimations];
  }
}

///////////////////////////////////////////////////////////////////////////////////////////////////

- (UIViewController*)previousViewController {
  NSArray* viewControllers = self.navigationController.viewControllers;
  if (viewControllers.count > 1) {
    NSUInteger index = [viewControllers indexOfObject:self];
    if (index != NSNotFound) {
      return [viewControllers objectAtIndex:index-1];
    }
  }
  
  return nil;
}

- (UIViewController*)nextViewController {
  NSArray* viewControllers = self.navigationController.viewControllers;
  if (viewControllers.count > 1) {
    NSUInteger index = [viewControllers indexOfObject:self];
    if (index != NSNotFound && index+1 < viewControllers.count) {
      return [viewControllers objectAtIndex:index+1];
    }
  }
  return nil;
}

- (void)alert:(NSString*)message title:(NSString*)title delegate:(id)delegate {
  if (message) {
    UIAlertView* alert = [[[UIAlertView alloc] initWithTitle:title message:message
      delegate:delegate cancelButtonTitle:TTLocalizedString(@"OK", @"") otherButtonTitles:nil]
      autorelease];
    [alert show];
  }
}

- (void)alert:(NSString*)message {
  [self alert:message title:TTLocalizedString(@"Alert", @"") delegate:nil];
}

- (void)alertError:(NSString*)message {
  [self alert:message title:TTLocalizedString(@"Error", @"") delegate:nil];
}

- (void)showBars:(BOOL)show animated:(BOOL)animated {
  [[UIApplication sharedApplication] setStatusBarHidden:!show animated:animated];
  
  [self showNavigationBar:show animated:animated];
}

@end
