#import "Three20/TTURLMap.h"
#import "Three20/TTNavigator.h"

///////////////////////////////////////////////////////////////////////////////////////////////////

static NSMutableDictionary* gNavigatorURLs = nil;
static NSMutableDictionary* gContainerControllers = nil;

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation UIViewController (TTCategory)

///////////////////////////////////////////////////////////////////////////////////////////////////
// private

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
// NSObject

// Swizzled with dealloc by TTURLMap (only if you're using TTURLMap)
- (void)ttdealloc {
  NSString* URL = self.navigatorURL;
  if (URL) {
    [[TTNavigator navigator].URLMap removeObjectWithURL:URL];
    self.navigatorURL = nil;
  }
  
  // Calls the original dealloc, swizzled away
  [self ttdealloc];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// public

- (NSString*)navigatorURL {
  NSString* key = [NSString stringWithFormat:@"%d", self];
  return [gNavigatorURLs objectForKey:key];
}

- (void)setNavigatorURL:(NSString*)URL {
  NSString* key = [NSString stringWithFormat:@"%d", self];
  if (URL) {
    if (!gNavigatorURLs) {
      gNavigatorURLs = [[NSMutableDictionary alloc] init];
    }
    [gNavigatorURLs setObject:URL forKey:key];
  } else {
    [gNavigatorURLs removeObjectForKey:key];
  }
}

- (NSDictionary*)frozenState {
  return nil;
}

- (void)setFrozenState:(NSDictionary*)frozenState {
}

- (UIViewController*)containingViewController {
  UIViewController* container = self.parentViewController;
  if (container) {
    return container;
  } else {
    NSString* key = [NSString stringWithFormat:@"%d", self];
    return [gContainerControllers objectForKey:key];
  }
}

- (void)setContainingViewController:(UIViewController*)viewController {
  NSString* key = [NSString stringWithFormat:@"%d", self];
  if (viewController) {
    if (!gContainerControllers) {
      gContainerControllers = TTCreateNonRetainingDictionary();
    }
    [gContainerControllers setObject:viewController forKey:key];
  } else {
    [gContainerControllers removeObjectForKey:key];
  }
}

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

- (UIViewController*)childViewController {
  return nil;
}

- (void)presentController:(UIViewController*)controller animated:(BOOL)animated {
  if (self.navigationController) {
    [self.navigationController pushViewController:controller animated:animated];
  }
}

- (void)bringControllerToFront:(UIViewController*)controller animated:(BOOL)animated {
}

- (BOOL)isContainerController {
  return NO;
}

- (void)persistNavigationPath:(NSMutableArray*)path {
}

- (void)persistView:(NSMutableDictionary*)state {
}

- (void)restoreView:(NSDictionary*)state {
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
