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

#import "Three20UINavigator/private/TTURLWildcard.h"

// UINavigator (private)
#import "Three20UINavigator/private/TTURLArguments.h"
#import "Three20UINavigator/private/TTURLSelector.h"

// Core
#import "Three20Core/TTCorePreprocessorMacros.h"


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation TTURLWildcard

@synthesize name      = _name;
@synthesize argIndex  = _argIndex;
@synthesize argType   = _argType;
@synthesize selector  = _selector;


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)init {
  if (self = [super init]) {
    _argIndex = NSNotFound;
    _argType  = TTURLArgumentTypeNone;
  }
  return self;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)dealloc {
  TT_RELEASE_SAFELY(_name);
  TT_RELEASE_SAFELY(_selector);

  [super dealloc];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)match:(NSString*)text {
  return YES;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSString*)convertPropertyOfObject:(id)object {
  if (_selector) {
    return [_selector perform:object returnType:_argType];

  } else {
    return @"";
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)deduceSelectorForClass:(Class)cls {
  NSArray* names = [_name componentsSeparatedByString:@"."];
  if (names.count > 1) {
    TTURLSelector* selector = nil;
    for (NSString* name in names) {
      TTURLSelector* newSelector = [[[TTURLSelector alloc] initWithName:name] autorelease];
      if (selector) {
        selector.next = newSelector;

      } else {
        self.selector = newSelector;
      }
      selector = newSelector;
    }

  } else {
    self.argType = TTURLArgumentTypeForProperty(cls, _name);
    self.selector = [[[TTURLSelector alloc] initWithName:_name] autorelease];
  }
}


@end
