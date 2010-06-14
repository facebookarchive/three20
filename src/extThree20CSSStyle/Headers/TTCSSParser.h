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

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

/**
 * CSS Jargon:
 *
 * Rule Set: A selector and a set of property/value pairs.
 * Selector: An identifier for a rule set. Example: "img"
 * Property: A name for a set of values. Example: "color"
 * Value:    A value for a property.
 *
 * img {                \
 *   border-color: red; |  A single rule set.
 * }                    /
 */
@interface TTCSSParser : NSObject {
@private
  NSMutableDictionary*  _ruleSets;
  NSMutableArray*       _activeCssSelectors;
  NSMutableDictionary*  _activeRuleSet;
  NSString*             _activePropertyName;

  NSString*             _lastTokenText;
  int                   _lastToken;

  union {
    struct {
      int InsideDefinition : 1;
      int InsideProperty : 1;
      int InsideFunction : 1;
    } Flags;
    int _data;
  } _state;
}

- (NSDictionary*)parseFilename:(NSString*)filename;

@end
