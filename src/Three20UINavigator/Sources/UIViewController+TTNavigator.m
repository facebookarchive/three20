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

// UICommon (private)
#import "Three20UICommon/private/UIViewControllerAdditionsInternal.h"

// Core
#import "Three20Core/TTCorePreprocessorMacros.h"
#import "Three20Core/TTDebug.h"
#import "Three20Core/TTDebugFlags.h"

static NSMutableDictionary* gNavigatorURLs          = nil;


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
- (void)unsetNavigatorProperties {
  TTDCONDITIONLOG(TTDFLAG_CONTROLLERGARBAGECOLLECTION,
                  @"Unsetting this controller's properties: %X", self);

  NSString* urlPath = self.originalNavigatorURL;
  if (nil != urlPath) {
    TTDCONDITIONLOG(TTDFLAG_CONTROLLERGARBAGECOLLECTION,
                    @"Removing this URL path: %@", urlPath);

    [[TTBaseNavigator globalNavigator].URLMap removeObjectForURL:urlPath];
    self.originalNavigatorURL = nil;
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

      [UIViewController addGlobalController:self];

#if TTDFLAG_NAVIGATORGARBAGECOLLECTION
    } else if ([self isKindOfClass:[TTNavigatorViewController class]]) {
      TTDCONDITIONLOG(TTDFLAG_NAVIGATORGARBAGECOLLECTION,
                      @"Not garbage collecting this Three20 view controller %X", self);
#endif
    }

    [gNavigatorURLs setObject:URL forKey:key];

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
