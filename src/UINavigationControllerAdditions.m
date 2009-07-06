#import "Three20/TTGlobal.h"
#import "Three20/TTURLRequestQueue.h"

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation UINavigationController (TTCategory)

- (void)pushAnimationDidStop {
  [TTURLRequestQueue mainQueue].suspended = NO;
}

- (void)pushViewController:(UIViewController*)controller
    animatedWithTransition:(UIViewAnimationTransition)transition {
  [TTURLRequestQueue mainQueue].suspended = YES;

  [self pushViewController:controller animated:NO];
  
  [UIView beginAnimations:nil context:nil];
  [UIView setAnimationDuration:TT_FLIP_TRANSITION_DURATION];
  [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(pushAnimationDidStop)];
  [UIView setAnimationTransition:transition forView:self.view cache:YES];
  [UIView commitAnimations];
}

- (void)popViewControllerAnimatedWithTransition:(UIViewAnimationTransition)transition {
  [TTURLRequestQueue mainQueue].suspended = YES;

  [self popViewControllerAnimated:NO];
  
  [UIView beginAnimations:nil context:NULL];
  [UIView setAnimationDuration:TT_FLIP_TRANSITION_DURATION];
  [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(pushAnimationDidStop)];
  [UIView setAnimationTransition:transition forView:self.view cache:YES];
  [UIView commitAnimations];
}

@end
