//
// Copyright 2009-2011 Facebook
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
#import "Three20UINavigator/TTNavigatorViewController.h"

// UICommon
#import "Three20UICommon/UIViewControllerAdditions.h"

// UICommon (private)
#import "Three20UICommon/private/UIViewControllerGarbageCollection.h"

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
/**
 * Additions.
 */
TT_FIX_CATEGORY_BUG(UIViewController_TTNavigator)

@implementation UIViewController (TTNavigator)


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithNavigatorURL:(NSURL*)URL query:(NSDictionary*)query {
  if (self = [self initWithNibName:nil bundle:nil]) {
  }

  return self;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Garbage Collection


///////////////////////////////////////////////////////////////////////////////////////////////////
+ (NSMutableSet*)ttNavigatorControllers {
  if (nil == gsNavigatorControllers) {
    gsNavigatorControllers = [[NSMutableSet alloc] init];
  }
  return gsNavigatorControllers;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
+ (void)doNavigatorGarbageCollection {
  NSMutableSet* controllers = [UIViewController ttNavigatorControllers];

  [self doGarbageCollectionWithSelector: @selector(unsetNavigatorProperties)
                          controllerSet: controllers];

  if ([controllers count] == 0) {
    TTDCONDITIONLOG(TTDFLAG_CONTROLLERGARBAGECOLLECTION,
                    @"Killing the navigator garbage collector.");
    [gsGarbageCollectorTimer invalidate];
    TT_RELEASE_SAFELY(gsGarbageCollectorTimer);
    TT_RELEASE_SAFELY(gsNavigatorControllers);
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
+ (void)ttAddNavigatorController:(UIViewController*)controller {

  // TTNavigatorViewController calls unsetNavigatorProperties in its dealloc.
  // UICommon has its own garbage collector that will unset another set of properties.
  if (![controller isKindOfClass:[TTNavigatorViewController class]]) {

    TTDCONDITIONLOG(TTDFLAG_CONTROLLERGARBAGECOLLECTION,
                    @"Adding a navigator controller.");

    [[UIViewController ttNavigatorControllers] addObject:controller];

    if (nil == gsGarbageCollectorTimer) {
      gsGarbageCollectorTimer =
        [[NSTimer scheduledTimerWithTimeInterval: kGarbageCollectionInterval
                                          target: [UIViewController class]
                                        selector: @selector(doNavigatorGarbageCollection)
                                        userInfo: nil
                                         repeats: YES] retain];
    }
#if TTDFLAG_CONTROLLERGARBAGECOLLECTION

  } else {
    TTDCONDITIONLOG(TTDFLAG_CONTROLLERGARBAGECOLLECTION,
                    @"Not adding a navigator controller.");
#endif
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
    [gNavigatorURLs setObject:URL forKey:key];

    [UIViewController ttAddNavigatorController:self];

  } else {
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


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation UIViewController (TTNavigatorGarbageCollection)


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)unsetNavigatorProperties {
  TTDCONDITIONLOG(TTDFLAG_CONTROLLERGARBAGECOLLECTION,
                  @"Unsetting this controller's properties: %X", (unsigned int)self);

  NSString* urlPath = self.originalNavigatorURL;
  if (nil != urlPath) {
    TTDCONDITIONLOG(TTDFLAG_CONTROLLERGARBAGECOLLECTION,
                    @"Removing this URL path: %@", urlPath);

    [[TTBaseNavigator globalNavigator].URLMap removeObjectForURL:urlPath];
    self.originalNavigatorURL = nil;
  }
}


@end
