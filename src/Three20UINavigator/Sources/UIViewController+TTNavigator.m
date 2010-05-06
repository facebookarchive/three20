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

#import "Three20UINavigator/UIViewController+TTNavigator.h"

// UINavigator
#import "Three20UINavigator/TTBaseNavigator.h"
#import "Three20UINavigator/TTURLMap.h"

// UINavigator (private)
#import "Three20UINavigator/private/TTBaseViewControllerInternal.h"

// UICommon
#import "Three20UICommon/UIViewControllerAdditions.h"

// Core
#import "Three20Core/TTCorePreprocessorMacros.h"
#import "Three20Core/TTDebug.h"
#import "Three20Core/TTDebugFlags.h"

static NSMutableDictionary* gNavigatorURLs          = nil;
static NSMutableSet*        gsNavigatorControllers  = nil;
static NSTimer*             gsGarbageCollectorTimer = nil;

static const NSTimeInterval kGarbageCollectionInterval = 20;


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation UIViewController (TTNavigator)


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithNavigatorURL:(NSURL*)URL query:(NSDictionary*)query {
  if (self = [self init]) {
  }

  return self;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Garbage Collection


///////////////////////////////////////////////////////////////////////////////////////////////////
+ (NSMutableSet*)globalNavigatorControllers {
  if (nil == gsNavigatorControllers) {
    gsNavigatorControllers = [[NSMutableSet alloc] init];
  }
  return gsNavigatorControllers;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)unsetNavigatorProperties {
  TTDCONDITIONLOG(TTDFLAG_NAVIGATORGARBAGECOLLECTION,
                  @"Unsetting this controller's properties: %X", self);

  NSString* urlPath = self.originalNavigatorURL;
  if (nil != urlPath) {
    TTDCONDITIONLOG(TTDFLAG_NAVIGATORGARBAGECOLLECTION,
                    @"Removing this URL path: %@", urlPath);

    [[TTBaseNavigator globalNavigator].URLMap removeObjectForURL:urlPath];
    self.originalNavigatorURL = nil;
  }

  self.superController = nil;
  self.popupViewController = nil;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
/**
 * Three20 used to provide an overridden dealloc method that all UIViewControllers
 * implementations would use to remove their originalNavigatorURLs and other properties.
 * Apple has stated that using TTSwapMethod to swap dealloc with a custom implementation isn't
 * ok, so now we do garbage collection.
 *
 * The basic idea.
 * Whenever you set the original navigator URL path for a controller, we add the controller
 * to a global navigator controllers list. We then run the following garbage collection every
 * kGarbageCollectionInterval seconds. If any controllers have a retain count of 1, then
 * we can safely say that nobody is using it anymore and release it.
 */
+ (void)doNavigatorGarbageCollection {
  NSMutableSet* controllers = [UIViewController globalNavigatorControllers];
  if ([controllers count] > 0) {
    TTDCONDITIONLOG(TTDFLAG_NAVIGATORGARBAGECOLLECTION,
                    @"Checking %d controllers for garbage.", [controllers count]);

    NSSet* fullControllerList = [controllers copy];
    for (UIViewController* controller in fullControllerList) {

      // Subtract one from the retain count here due to the copied NSArray.
      TTDCONDITIONLOG(TTDFLAG_NAVIGATORGARBAGECOLLECTION,
                      @"Retain count for %X is %d", controller, ([controller retainCount] - 1));

      // We subtract 1 here because we've made a copy of the set, which increases the retain
      // count by one.
      if ([controller retainCount] - 1 == 1) {
        [controller unsetNavigatorProperties];

        // Retain count is now 1 and when we release the copied set below, the object will
        // be completely released.
        [controllers removeObject:controller];
      }
    }

    TT_RELEASE_SAFELY(fullControllerList);
  }

  if ([controllers count] == 0) {
    TTDCONDITIONLOG(TTDFLAG_NAVIGATORGARBAGECOLLECTION, @"Killing the garbage collector.");
    [gsGarbageCollectorTimer invalidate];
    TT_RELEASE_SAFELY(gsGarbageCollectorTimer);
    TT_RELEASE_SAFELY(gsNavigatorControllers);
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Public


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSString*)navigatorURL {
  return self.originalNavigatorURL;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSString*)originalNavigatorURL {
  NSString* key = [NSString stringWithFormat:@"%d", self.hash];
  return [gNavigatorURLs objectForKey:key];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setOriginalNavigatorURL:(NSString*)URL {
  NSString* key = [NSString stringWithFormat:@"%d", self.hash];
  if (nil != URL) {
    if (nil == gNavigatorURLs) {
      gNavigatorURLs = [[NSMutableDictionary alloc] init];
    }

    if (nil == [gNavigatorURLs objectForKey:key]
        && ![self isKindOfClass:[TTNavigatorViewController class]]) {

      [[UIViewController globalNavigatorControllers] addObject:self];

      if (nil == gsGarbageCollectorTimer) {
        gsGarbageCollectorTimer =
          [[NSTimer scheduledTimerWithTimeInterval: 10
                                            target: [UIViewController class]
                                          selector: @selector(doNavigatorGarbageCollection)
                                          userInfo: nil
                                           repeats: YES] retain];
      }
#if TTDFLAG_NAVIGATORGARBAGECOLLECTION
    } else if ([self isKindOfClass:[TTNavigatorViewController class]]) {
      TTDCONDITIONLOG(TTDFLAG_NAVIGATORGARBAGECOLLECTION,
                      @"Not garbage collecting this Three20 view controller %X", self);
#endif
    }

    [gNavigatorURLs setObject:URL forKey:key];

  } else {
    if (nil != [gNavigatorURLs objectForKey:key]) {
      [[UIViewController globalNavigatorControllers] removeObject:self];
    }

    [gNavigatorURLs removeObjectForKey:key];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSDictionary*)frozenState {
  return nil;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setFrozenState:(NSDictionary*)frozenState {
}


@end
