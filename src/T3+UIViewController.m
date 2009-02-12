#import "Three20/T3Global.h"
#import "Three20/T3URLRequestQueue.h"

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation UIViewController (T3Category)

- (void)showNavigationBar:(BOOL)show animated:(BOOL)animated {
  if (animated) {
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3];
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
      delegate:delegate cancelButtonTitle:@"Ok" otherButtonTitles:nil] autorelease];
    [alert show];
  }
}

- (void)alert:(NSString*)message {
  [self alert:message title:@"Alert" delegate:nil];
}

- (void)alertError:(NSString*)message {
  [self alert:message title:@"Error" delegate:nil];
}

- (void)showBars:(BOOL)show animated:(BOOL)animated {
  [[UIApplication sharedApplication] setStatusBarHidden:!show animated:animated];
  
  [self showNavigationBar:show animated:animated];
}

@end

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation UINavigationController (T3Category)

- (void)pushAnimationDidStop {
  [T3URLRequestQueue mainQueue].suspended = NO;
}

- (void)pushViewController:(UIViewController*)controller
    withTransition:(UIViewAnimationTransition)transition {
  [T3URLRequestQueue mainQueue].suspended = YES;

  [self pushViewController:controller animated:NO];
  
  [UIView beginAnimations:nil context:NULL];
  [UIView setAnimationDuration:T3_FLIP_TRANSITION_DURATION];
  [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(pushAnimationDidStop)];
  [UIView setAnimationTransition:transition forView:self.view.window cache:YES];
  [UIView commitAnimations];
}

- (void)popViewControllerWithTransition:(UIViewAnimationTransition)transition {
  [T3URLRequestQueue mainQueue].suspended = YES;

  [self popViewControllerAnimated:NO];
  
  [UIView beginAnimations:nil context:NULL];
  [UIView setAnimationDuration:T3_FLIP_TRANSITION_DURATION];
  [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(pushAnimationDidStop)];
  [UIView setAnimationTransition:transition forView:self.view.window cache:YES];
  [UIView commitAnimations];
}

@end
