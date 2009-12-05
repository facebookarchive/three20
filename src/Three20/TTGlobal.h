//
// Copyright 2009 Facebook
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

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "Three20/TTDebug.h"
#import "Three20/TTDebugFlags.h"
#import "Three20/TTNSObjectAdditions.h"
#import "Three20/TTNSStringAdditions.h"
#import "Three20/NSObjectAdditions.h"
#import "Three20/NSStringAdditions.h"
#import "Three20/TTNSStringAdditions.h"
#import "Three20/NSDateAdditions.h"
#import "Three20/NSDataAdditions.h"
#import "Three20/NSArrayAdditions.h"
#import "Three20/NSMutableArrayAdditions.h"
#import "Three20/NSMutableDictionaryAdditions.h"
#import "Three20/UIColorAdditions.h"
#import "Three20/UIFontAdditions.h"
#import "Three20/UIImageAdditions.h"
#import "Three20/UIViewControllerAdditions.h"
#import "Three20/UIWindowAdditions.h"
#import "Three20/UINavigationControllerAdditions.h"
#import "Three20/UITabBarControllerAdditions.h"
#import "Three20/UIViewAdditions.h"
#import "Three20/UITableViewAdditions.h"
#import "Three20/UIWebViewAdditions.h"
#import "Three20/UIToolbarAdditions.h"

#import "Three20/TTGlobalCore.h"
#import "Three20/TTGlobalCoreLocale.h"
#import "Three20/TTGlobalCorePaths.h"
#import "Three20/TTGlobalUI.h"
#import "Three20/TTGlobalUINavigator.h"
#import "Three20/TTGlobalNetwork.h"


///////////////////////////////////////////////////////////////////////////////////////////////////
// Style helpers

#define TTSTYLE(_SELECTOR) [[TTStyleSheet globalStyleSheet] styleWithSelector:@#_SELECTOR]

#define TTSTYLESTATE(_SELECTOR, _STATE) [[TTStyleSheet globalStyleSheet] \
                                           styleWithSelector:@#_SELECTOR forState:_STATE]

#define TTSTYLESHEET ((id)[TTStyleSheet globalStyleSheet])

#define TTSTYLEVAR(_VARNAME) [TTSTYLESHEET _VARNAME]

#define TTIMAGE(_URL) [[TTURLCache sharedCache] imageForURL:_URL]

typedef enum {
  TTPositionStatic,
  TTPositionAbsolute,
  TTPositionFloatLeft,
  TTPositionFloatRight,
} TTPosition;
