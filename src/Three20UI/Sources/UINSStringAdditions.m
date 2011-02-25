// Copyright 2009-2011 Facebook
//
// Licensed under the Apache License, Version 2.0 (the "License"); you may
// not use this file except in compliance with the License. You may obtain
// a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
// WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
// License for the specific language governing permissions and limitations
// under the License.

#import "Three20UI/UINSStringAdditions.h"

// Core
#import "Three20Core/TTCorePreprocessorMacros.h"

// UI
#import "Three20UI/TTNavigator.h"

// UINavigator
#import "Three20UINavigator/TTURLAction.h"
#import "Three20UINavigator/TTURLMap.h"
#import "Three20UINavigator/TTURLObject.h"


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
/**
 * Additions.
 */
TT_FIX_CATEGORY_BUG(UINSStringAdditions)

@implementation NSString (TTCategory)


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)objectValue {
  return [[TTNavigator navigator].URLMap objectForURL:self];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)openURL {
  [[TTNavigator navigator] openURLAction:[[TTURLAction actionWithURLPath: self]
                                                           applyAnimated: YES]];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)openURLFromButton:(UIView*)button {
  NSDictionary* query = [NSDictionary dictionaryWithObjectsAndKeys:button, @"__target__", nil];
  [[TTBaseNavigator navigatorForView:button]
    openURLAction:[[[TTURLAction actionWithURLPath: self]
                    applyQuery: query]
                   applyAnimated: YES]];
}


@end
