#import "Three20/TTGlobal.h"
#import "Three20/TTURLRequestQueue.h"
#import "Three20/TTAppMap.h"

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation UINavigationController (TTCategory)

///////////////////////////////////////////////////////////////////////////////////////////////////
// private

- (void)pushAnimationDidStop {
  [TTURLRequestQueue mainQueue].suspended = NO;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// UIViewController (TTCategory)

- (void)presentController:(UIViewController*)controller animated:(BOOL)animated {
  [self pushViewController:controller animated:animated];
}

- (void)bringControllerToFront:(UIViewController*)controller animated:(BOOL)animated {
  [self popToViewController:controller animated:animated];
}

- (void)persistNavigationPath:(NSMutableArray*)path {
  for (UIViewController* controller in self.viewControllers) {
    [[TTAppMap sharedMap] persistController:controller path:path];
  }
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// public

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
