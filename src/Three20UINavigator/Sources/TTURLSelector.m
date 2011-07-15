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

#import "Three20UINavigator/private/TTURLSelector.h"

// UINavigator (private)
#import "Three20UINavigator/private/TTURLArguments.h"

// Core
#import "Three20Core/TTCorePreprocessorMacros.h"


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation TTURLSelector

@synthesize name = _name;
@synthesize next = _next;


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithName:(NSString*)name {
	self = [super init];
  if (self) {
    _name     = [name copy];
    _selector = NSSelectorFromString(_name);
  }

  return self;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)dealloc {
  TT_RELEASE_SAFELY(_name);
  TT_RELEASE_SAFELY(_next);

  [super dealloc];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSString*)perform:(id)object returnType:(TTURLArgumentType)returnType {
  if (_next) {
    id value = [object performSelector:_selector];
    return [_next perform:value returnType:returnType];

  } else {
    NSMethodSignature *sig = [object methodSignatureForSelector:_selector];
    NSInvocation* invocation = [NSInvocation invocationWithMethodSignature:sig];
    [invocation setTarget:object];
    [invocation setSelector:_selector];
    [invocation invoke];

    if (!returnType) {
      returnType = TTURLArgumentTypeForProperty([object class], _name);
    }

    switch (returnType) {
      case TTURLArgumentTypeNone: {
        return @"";
      }
      case TTURLArgumentTypeInteger: {
        int val;
        [invocation getReturnValue:&val];
        return [NSString stringWithFormat:@"%d", val];
      }
      case TTURLArgumentTypeLongLong: {
        long long val;
        [invocation getReturnValue:&val];
        return [NSString stringWithFormat:@"%lld", val];
      }
      case TTURLArgumentTypeFloat: {
        float val;
        [invocation getReturnValue:&val];
        return [NSString stringWithFormat:@"%f", val];
      }
      case TTURLArgumentTypeDouble: {
        double val;
        [invocation getReturnValue:&val];
        return [NSString stringWithFormat:@"%f", val];
      }
      case TTURLArgumentTypeBool: {
        BOOL val;
        [invocation getReturnValue:&val];
        return [NSString stringWithFormat:@"%d", val];
      }
      default: {
        id val;
        [invocation getReturnValue:&val];
        return [NSString stringWithFormat:@"%@", val];
      }
    }
    return @"";
  }
}


@end
