//
// Copyright 2009-2010 Facebook
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//    http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

#import "Three20UICommon/UIViewControllerAdditions.h"

// UICommon
#import "Three20UICommon/TTGlobalUICommon.h"
#import "Three20UICommon/TTBaseViewController.h"

// UICommon (private)
#import "Three20UICommon/private/UIViewControllerGarbageCollection.h"

// Core
#import "Three20Core/TTCorePreprocessorMacros.h"
#import "Three20Core/TTGlobalCore.h"
#import "Three20Core/TTDebug.h"
#import "Three20Core/TTDebugFlags.h"

static NSMutableDictionary* gSuperControllers = nil;
static NSMutableDictionary* gPopupViewControllers = nil;

// Garbage collection state
static NSMutableSet*        gsCommonControllers     = nil;
static NSTimer*             gsGarbageCollectorTimer = nil;

static const NSTimeInterval kGarbageCollectionInterval = 20;


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation UIViewController (TTCategory)


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Garbage Collection
/**
 * What's this for?
 *
 * When view controllers are deallocated, we need to remove them from a set of
 * global data structures. These global data structures provide additional functionality on
 * top of the UIViewController class, such as setting the super controller.
 *
 * Removal was previously accomplished by swizzling the dealloc method of UIViewController with a
 * custom implementation. Apple has now stated that we can no longer due this.
 *
 * See TTGarbageCollection additions at the bottom of this file for more implementation details.
 *
 * TODO (jverkoey May 19, 2010): Consider phasing out the use of an addition entirely. Instead,
 * place all functionality within the TTBaseViewController class.
 */


///////////////////////////////////////////////////////////////////////////////////////////////////
/**
 * Common used here in the name because this is the UICommon lib.
 */
+ (NSMutableSet*)ttCommonControllers {
  if (nil == gsCommonControllers) {
    gsCommonControllers = [[NSMutableSet alloc] init];
  }

  return gsCommonControllers;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
+ (void)doCommonGarbageCollection {
  NSMutableSet* controllers = [UIViewController ttCommonControllers];

  [self doGarbageCollectionWithSelector: @selector(unsetCommonProperties)
                          controllerSet: controllers];

  if ([controllers count] == 0) {
    TTDCONDITIONLOG(TTDFLAG_CONTROLLERGARBAGECOLLECTION,
                    @"Killing the common garbage collector.");
    [gsGarbageCollectorTimer invalidate];
    TT_RELEASE_SAFELY(gsGarbageCollectorTimer);
    TT_RELEASE_SAFELY(gsCommonControllers);
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
+ (void)ttAddCommonController:(UIViewController*)controller {

  // TTBaseViewController calls unsetCommonProperties in its dealloc, so we don't need
  // to set up the garbage collector in that case.
  if (![controller isKindOfClass:[TTBaseViewController class]]) {
    [[UIViewController ttCommonControllers] addObject:controller];

    TTDCONDITIONLOG(TTDFLAG_CONTROLLERGARBAGECOLLECTION,
                    @"Adding a common controller.");

    if (nil == gsGarbageCollectorTimer) {
      gsGarbageCollectorTimer =
        [[NSTimer scheduledTimerWithTimeInterval: kGarbageCollectionInterval
                                          target: [UIViewController class]
                                        selector: @selector(doCommonGarbageCollection)
                                        userInfo: nil
                                         repeats: YES] retain];
    }
#if TTDFLAG_CONTROLLERGARBAGECOLLECTION
  } else {
    TTDCONDITIONLOG(TTDFLAG_CONTROLLERGARBAGECOLLECTION,
                    @"Not adding a common controller.");
#endif
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Public


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)canContainControllers {
  return NO;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)canBeTopViewController {
  return YES;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (UIViewController*)superController {
  UIViewController* parent = self.parentViewController;
  if (nil != parent) {
    return parent;

  } else {
    NSString* key = [NSString stringWithFormat:@"%d", self.hash];
    return [gSuperControllers objectForKey:key];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setSuperController:(UIViewController*)viewController {
  NSString* key = [NSString stringWithFormat:@"%d", self.hash];
  if (nil != viewController) {
    if (nil == gSuperControllers) {
      gSuperControllers = TTCreateNonRetainingDictionary();
    }
    [gSuperControllers setObject:viewController forKey:key];

    [UIViewController ttAddCommonController:self];

  } else {
    [gSuperControllers removeObjectForKey:key];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (UIViewController*)topSubcontroller {
  return nil;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (UIViewController*)ttPreviousViewController {
  NSArray* viewControllers = self.navigationController.viewControllers;
  if (viewControllers.count > 1) {
    NSUInteger controllerIndex = [viewControllers indexOfObject:self];
    if (controllerIndex != NSNotFound && controllerIndex > 0) {
      return [viewControllers objectAtIndex:controllerIndex-1];
    }
  }

  return nil;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (UIViewController*)nextViewController {
  NSArray* viewControllers = self.navigationController.viewControllers;
  if (viewControllers.count > 1) {
    NSUInteger controllerIndex = [viewControllers indexOfObject:self];
    if (controllerIndex != NSNotFound && controllerIndex+1 < viewControllers.count) {
      return [viewControllers objectAtIndex:controllerIndex+1];
    }
  }
  return nil;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (UIViewController*)popupViewController {
  NSString* key = [NSString stringWithFormat:@"%d", self.hash];
  return [gPopupViewControllers objectForKey:key];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setPopupViewController:(UIViewController*)viewController {
  NSString* key = [NSString stringWithFormat:@"%d", self.hash];
  if (viewController) {
    if (!gPopupViewControllers) {
      gPopupViewControllers = TTCreateNonRetainingDictionary();
    }
    [gPopupViewControllers setObject:viewController forKey:key];

    [UIViewController ttAddCommonController:self];

  } else {
    [gPopupViewControllers removeObjectForKey:key];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)addSubcontroller:(UIViewController*)controller animated:(BOOL)animated
        transition:(UIViewAnimationTransition)transition {
  if (self.navigationController) {
    [self.navigationController addSubcontroller:controller animated:animated
                               transition:transition];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)removeFromSupercontroller {
  [self removeFromSupercontrollerAnimated:YES];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)removeFromSupercontrollerAnimated:(BOOL)animated {
  if (self.navigationController) {
    [self.navigationController popViewControllerAnimated:animated];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)bringControllerToFront:(UIViewController*)controller animated:(BOOL)animated {
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSString*)keyForSubcontroller:(UIViewController*)controller {
  return nil;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (UIViewController*)subcontrollerForKey:(NSString*)key {
  return nil;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)persistView:(NSMutableDictionary*)state {
  return YES;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)restoreView:(NSDictionary*)state {
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)persistNavigationPath:(NSMutableArray*)path {
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)delayDidEnd {
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)showBars:(BOOL)show animated:(BOOL)animated {
#ifdef __IPHONE_3_2
	if ([[UIApplication sharedApplication] respondsToSelector:@selector(setStatusBarHidden:withAnimation:)])
		[[UIApplication sharedApplication] setStatusBarHidden:!show withAnimation:animated ? UIStatusBarAnimationFade : UIStatusBarAnimationNone];
	else
#endif
		[[UIApplication sharedApplication] setStatusBarHidden:!show animated:animated];

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
- (void)dismissModalViewController {
  [self dismissModalViewControllerAnimated:YES];
}


@end


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation UIViewController (TTGarbageCollection)


///////////////////////////////////////////////////////////////////////////////////////////////////
/**
 * The basic idea.
 * Whenever you set the original navigator URL path for a controller, we add the controller
 * to a global navigator controllers list. We then run the following garbage collection every
 * kGarbageCollectionInterval seconds. If any controllers have a retain count of 1, then
 * we can safely say that nobody is using it anymore and release it.
 */
+ (void)doGarbageCollectionWithSelector:(SEL)selector controllerSet:(NSMutableSet*)controllers {
  if ([controllers count] > 0) {
    TTDCONDITIONLOG(TTDFLAG_CONTROLLERGARBAGECOLLECTION,
                    @"Checking %d controllers for garbage.", [controllers count]);

    NSSet* fullControllerList = [controllers copy];
    for (UIViewController* controller in fullControllerList) {

      // Subtract one from the retain count here due to the copied set.
      NSInteger retainCount = [controller retainCount] - 1;

      TTDCONDITIONLOG(TTDFLAG_CONTROLLERGARBAGECOLLECTION,
                      @"Retain count for %X is %d", (unsigned int)controller, retainCount);

      if (retainCount == 1) {
        // If this fails, you've somehow added a controller that doesn't use
        // the given selector. Check the controller type and the selector itself.
        TTDASSERT([controller respondsToSelector:selector]);
        if ([controller respondsToSelector:selector]) {
          [controller performSelector:selector];
        }

        // The object's retain count is now 1, so when we release the copied set below,
        // the object will be completely released.
        [controllers removeObject:controller];
      }
    }

    TT_RELEASE_SAFELY(fullControllerList);
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)unsetCommonProperties {
  TTDCONDITIONLOG(TTDFLAG_CONTROLLERGARBAGECOLLECTION,
                  @"Unsetting this controller's properties: %X", (unsigned int)self);

  self.superController = nil;
  self.popupViewController = nil;
}


@end
