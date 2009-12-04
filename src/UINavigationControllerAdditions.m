/**
 * Copyright 2009 Facebook
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#import "Three20/TTGlobal.h"
#import "Three20/TTURLRequestQueue.h"
#import "Three20/TTNavigator.h"
#import "Three20/TTURLMap.h"

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation UINavigationController (TTCategory)

///////////////////////////////////////////////////////////////////////////////////////////////////
// private

- (void)pushAnimationDidStop {
  [TTURLRequestQueue mainQueue].suspended = NO;
}

- (UIViewAnimationTransition)invertTransition:(UIViewAnimationTransition)transition {
  switch (transition) {
    case UIViewAnimationTransitionCurlUp:
      return UIViewAnimationTransitionCurlDown;
    case UIViewAnimationTransitionCurlDown:
      return UIViewAnimationTransitionCurlUp;
    case UIViewAnimationTransitionFlipFromLeft:
      return UIViewAnimationTransitionFlipFromRight;
    case UIViewAnimationTransitionFlipFromRight:
      return UIViewAnimationTransitionFlipFromLeft;
    default:
      return UIViewAnimationTransitionNone;
  }
}

- (UIViewController*)popViewControllerAnimated2:(BOOL)animated {
  if (animated) {
    NSString* URL = self.topViewController.originalNavigatorURL;
    UIViewAnimationTransition transition = URL
      ? [[TTNavigator navigator].URLMap transitionForURL:URL]
      : UIViewAnimationTransitionNone;
    if (transition) {
      UIViewAnimationTransition inverseTransition = [self invertTransition:transition];
      return [self popViewControllerAnimatedWithTransition:inverseTransition];
    }
  }
  return [self popViewControllerAnimated2:animated];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// UIViewController

- (UIView*)rotatingHeaderView {
  UIViewController* popup = [self popupViewController];
  if (popup) {
    return [popup rotatingHeaderView];
  } else {
    return [super rotatingHeaderView];
  }
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// UIViewController (TTCategory)

- (BOOL)canContainControllers {
  return YES;
}

- (UIViewController*)topSubcontroller {
  return self.topViewController;
}

- (void)addSubcontroller:(UIViewController*)controller animated:(BOOL)animated
        transition:(UIViewAnimationTransition)transition {
  if (animated && transition) {
    [self pushViewController:controller animatedWithTransition:transition];
  } else {
    [self pushViewController:controller animated:animated];
  }
}

- (void)bringControllerToFront:(UIViewController*)controller animated:(BOOL)animated {
  if ([self.viewControllers indexOfObject:controller] != NSNotFound
      && controller != self.topViewController) {
    [self popToViewController:controller animated:animated];
  }
}

- (NSString*)keyForSubcontroller:(UIViewController*)controller {
  NSInteger index = [self.viewControllers indexOfObject:controller];
  if (index != NSNotFound) {
    return [NSNumber numberWithInt:index].stringValue;
  } else {
    return nil;
  }
}

- (UIViewController*)subcontrollerForKey:(NSString*)key {
  NSInteger index = key.intValue;
  if (index < self.viewControllers.count) {
    return [self.viewControllers objectAtIndex:index];
  } else {
    return nil;
  }
}

- (void)persistNavigationPath:(NSMutableArray*)path {
  for (UIViewController* controller in self.viewControllers) {
    [[TTNavigator navigator] persistController:controller path:path];
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

- (UIViewController*)popViewControllerAnimatedWithTransition:(UIViewAnimationTransition)transition {
  [TTURLRequestQueue mainQueue].suspended = YES;

  UIViewController* poppedController = [self popViewControllerAnimated:NO];
  
  [UIView beginAnimations:nil context:NULL];
  [UIView setAnimationDuration:TT_FLIP_TRANSITION_DURATION];
  [UIView setAnimationDelegate:self];
  [UIView setAnimationDidStopSelector:@selector(pushAnimationDidStop)];
  [UIView setAnimationTransition:transition forView:self.view cache:NO];
  [UIView commitAnimations];
  
  return poppedController;
}

@end
