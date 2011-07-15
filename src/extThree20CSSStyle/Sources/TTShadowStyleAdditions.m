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

#import "extThree20CSSStyle/TTShadowStyleAdditions.h"

#import "extThree20CSSStyle/TTCSSGlobalStyle.h"
#import "extThree20CSSStyle/TTCSSStyleSheet.h"
#import "extThree20CSSStyle/TTDefaultCSSStyleSheet.h"

// Core
#import "Three20Core/TTCorePreprocessorMacros.h"


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
/**
 * Additions.
 */
TT_FIX_CATEGORY_BUG(TTCSSShadowStyleAdditions)

@implementation TTShadowStyle (TTCSSCategory)

///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Class public


///////////////////////////////////////////////////////////////////////////////////////////////////
+ (TTShadowStyle*)styleWithCssSelector:(NSString*)selector
                              forState:(UIControlState)state
                                  next:(TTStyle*)next {
  TTShadowStyle* style = [[[self alloc] initWithNext:next] autorelease];
  style.color  = TTCSSSTATE(selector, shadowColor,  state);
  style.blur   = TTCSSSTATE(selector, shadowRadius, state);
  style.offset = TTCSSSTATE(selector, shadowOffset, state);
  return style;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
+ (TTShadowStyle*)styleWithCssSelector:(NSString*)selector
                                  next:(TTStyle*)next {
  return [self styleWithCssSelector:selector
                           forState:UIControlStateNormal next:next];
}


@end
