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

#import "Three20Style/TTDefaultStyleSheet.h"

@class TTCSSStyleSheet;
@class TTCSSRuleSet;
@protocol TTCSSApplyProtocol;

///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////

@interface TTDefaultCSSStyleSheet : TTDefaultStyleSheet {
@private
  TTCSSStyleSheet* _styleSheet;

  // Maintain an control of CSS Files already loaded and cached.
  NSMutableSet*				_cachedCssFiles;

}

@property (nonatomic, readonly) TTCSSStyleSheet* styleSheet;

/**
 * Load an CSS Style Sheet from disk and cache his data.
 * If the file is already cached no data will be loaded again,
 * if you need to reload the file use addStyleSheetFromDisk:ignoreCache:
 */
- (BOOL)addStyleSheetFromDisk:(NSString*)filename;

/**
 * Load an CSS Style Sheet from disk and cache his data.
 * @param cache YES will ignore if is already cached and reload the data if needed.
 */
- (BOOL)addStyleSheetFromDisk:(NSString*)filename ignoreCache:(BOOL)cache;

+ (TTDefaultCSSStyleSheet*)globalCSSStyleSheet;

/**
 * CSS Rule Set.
 */
-(TTCSSRuleSet*)css:(NSString*)selectorName;

/**
 * CSS Rule Set, also accept an specific state.
 */
-(TTCSSRuleSet*)css:(NSString*)selectorName forState:(UIControlState)state;

/**
 * Apply the rules for the specified selector to the informed object. This object
 * must conform with the TTCSSApplyProtocol to read and properly apply the CSS rules.
 */
-(void)applyCssFromSelector:(NSString*)selectorName toObject:(id<TTCSSApplyProtocol>)anObject;

@end
