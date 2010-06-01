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

#import "Three20Style/TTStyleSheet.h"

/**
 * A general purpose CSS style sheet object for accessing a CSS style sheet's properties.
 *
 * This is useful if you want to use style sheets to manually customize certain aspects of
 * your UI.
 *
 * Example apps: three20/samples/Style/TTCSSStyleSheets
 */
@interface TTCSSStyleSheet : TTStyleSheet {
@private
  NSDictionary*         _cssStyles;

  NSMutableDictionary*  _cachedCssStyles;

  NSDictionary*         _colorLookupTable;
}

/**
 * Load the style sheet into memory from disk.
 *
 * @return NO if the file does not exist.
 */
- (BOOL)loadFromFilename:(NSString*)filename;


/**
 * Get (text) color from a specific rule set.
 */
- (UIColor*)colorWithCssSelector:(NSString*)selector forState:(UIControlState)state;

/**
 * Get background-color from a specific rule set.
 */
- (UIColor*)backgroundColorWithCssSelector:(NSString*)selector forState:(UIControlState)state;

/**
 * Get font from a specific rule set.
 */
- (UIFont*)fontWithCssSelector:(NSString*)selector forState:(UIControlState)state;

/**
 * Get text shadow color from a specific rule set.
 */
- (UIColor*)textShadowColorWithCssSelector:(NSString*)selector forState:(UIControlState)state;

/**
 * Get text shadow offset from a specific rule set.
 */
- (CGSize)textShadowOffsetWithCssSelector:(NSString*)selector forState:(UIControlState)state;


/**
 * Release all cached data.
 */
- (void)freeMemory;


@end
