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

#import "Three20UINavigator/TTURLNavigatorPattern.h"

// UINavigator (private)
#import "Three20UINavigator/private/TTURLPatternInternal.h"
#import "Three20UINavigator/private/TTURLWildcard.h"
#import "Three20UINavigator/private/TTURLArguments.h"

// Core
#import "Three20Core/TTCorePreprocessorMacros.h"
#import "Three20Core/TTDebug.h"
#import "Three20Core/NSStringAdditions.h"

#import <objc/runtime.h>

static NSString* kUniversalURLPattern = @"*";


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation TTURLNavigatorPattern

@synthesize targetClass     = _targetClass;
@synthesize targetObject    = _targetObject;
@synthesize navigationMode  = _navigationMode;
@synthesize parentURL       = _parentURL;
@synthesize transition      = _transition;
@synthesize argumentCount   = _argumentCount;


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithTarget: (id)target
                mode: (TTNavigationMode)navigationMode {
  if (self = [super init]) {
    _navigationMode = navigationMode;

    if ([target class] == target && navigationMode) {
      _targetClass = target;

    } else {
      _targetObject = target;
    }
  }

  return self;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithTarget:(id)target {
  if (self = [self initWithTarget:target mode:TTNavigationModeNone]) {
  }

  return self;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)init {
  if (self = [self initWithTarget:nil]) {
  }

  return self;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)dealloc {
  TT_RELEASE_SAFELY(_parentURL);

  [super dealloc];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSString *)description {
  if (nil != _targetClass) {
    return [NSString stringWithFormat:@"%@ => %@", _URL, _targetClass];

  } else {
    return [NSString stringWithFormat:@"%@ => %@", _URL, _targetObject];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Private


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)instantiatesClass {
  return nil != _targetClass && TTNavigationModeNone != _navigationMode;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)callsInstanceMethod {
  return (nil != _targetObject && [_targetObject class] != _targetObject)
         || nil != _targetClass;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSComparisonResult)compareSpecificity:(TTURLPattern*)pattern2 {
  if (_specificity > pattern2.specificity) {
    return NSOrderedAscending;

  } else if (_specificity < pattern2.specificity) {
    return NSOrderedDescending;

  } else {
    return NSOrderedSame;
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)deduceSelector {
  NSMutableArray* parts = [NSMutableArray array];

  for (id<TTURLPatternText> pattern in _path) {
    if ([pattern isKindOfClass:[TTURLWildcard class]]) {
      TTURLWildcard* wildcard = (TTURLWildcard*)pattern;
      if (wildcard.name) {
        [parts addObject:wildcard.name];
      }
    }
  }

  for (id<TTURLPatternText> pattern in [_query objectEnumerator]) {
    if ([pattern isKindOfClass:[TTURLWildcard class]]) {
      TTURLWildcard* wildcard = (TTURLWildcard*)pattern;
      if (wildcard.name) {
        [parts addObject:wildcard.name];
      }
    }
  }

  if ([_fragment isKindOfClass:[TTURLWildcard class]]) {
    TTURLWildcard* wildcard = (TTURLWildcard*)_fragment;
    if (wildcard.name) {
      [parts addObject:wildcard.name];
    }
  }

  if (parts.count) {
    [self setSelectorWithNames:parts];
    if (!_selector) {
      [parts addObject:@"query"];
      [self setSelectorWithNames:parts];
    }

  } else {
    [self setSelectorIfPossible:@selector(initWithNavigatorURL:query:)];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)analyzeArgument: (id<TTURLPatternText>)pattern
                 method: (Method)method
               argNames: (NSArray*)argNames {
  if ([pattern isKindOfClass:[TTURLWildcard class]]) {
    TTURLWildcard* wildcard = (TTURLWildcard*)pattern;
    wildcard.argIndex = [argNames indexOfObject:wildcard.name];
    if (wildcard.argIndex == NSNotFound) {
      TTDINFO(@"Argument %@ not found in @selector(%s)", wildcard.name, sel_getName(_selector));

    } else {
      char argType[256];
      method_getArgumentType(method, wildcard.argIndex+2, argType, 256);
      wildcard.argType = TTConvertArgumentType(argType[0]);
    }
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)analyzeMethod {
  Class cls = [self classForInvocation];
  Method method = [self callsInstanceMethod]
    ? class_getInstanceMethod(cls, _selector)
    : class_getClassMethod(cls, _selector);
  if (method) {
    _argumentCount = method_getNumberOfArguments(method)-2;

    // Look up the index and type of each argument in the method
    const char* selName = sel_getName(_selector);
    NSString* selectorName = [[NSString alloc] initWithBytesNoCopy:(char*)selName
                                             length:strlen(selName)
                                             encoding:NSASCIIStringEncoding freeWhenDone:NO];

    NSArray* argNames = [selectorName componentsSeparatedByString:@":"];

    for (id<TTURLPatternText> pattern in _path) {
      [self analyzeArgument:pattern method:method argNames:argNames];
    }

    for (id<TTURLPatternText> pattern in [_query objectEnumerator]) {
      [self analyzeArgument:pattern method:method argNames:argNames];
    }

    if (_fragment) {
      [self analyzeArgument:_fragment method:method argNames:argNames];
    }

    [selectorName release];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)analyzeProperties {
  Class cls = [self classForInvocation];

  for (id<TTURLPatternText> pattern in _path) {
    if ([pattern isKindOfClass:[TTURLWildcard class]]) {
      TTURLWildcard* wildcard = (TTURLWildcard*)pattern;
      [wildcard deduceSelectorForClass:cls];
    }
  }

  for (id<TTURLPatternText> pattern in [_query objectEnumerator]) {
    if ([pattern isKindOfClass:[TTURLWildcard class]]) {
      TTURLWildcard* wildcard = (TTURLWildcard*)pattern;
      [wildcard deduceSelectorForClass:cls];
    }
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)setArgument: (NSString*)text
            pattern: (id<TTURLPatternText>)patternText
      forInvocation: (NSInvocation*)invocation {
  if ([patternText isKindOfClass:[TTURLWildcard class]]) {
    TTURLWildcard* wildcard = (TTURLWildcard*)patternText;
    NSInteger argIndex = wildcard.argIndex;
    if (argIndex != NSNotFound && argIndex < _argumentCount) {
      switch (wildcard.argType) {
        case TTURLArgumentTypeNone: {
          break;
        }
        case TTURLArgumentTypeInteger: {
          int val = [text intValue];
          [invocation setArgument:&val atIndex:argIndex+2];
          break;
        }
        case TTURLArgumentTypeLongLong: {
          long long val = [text longLongValue];
          [invocation setArgument:&val atIndex:argIndex+2];
          break;
        }
        case TTURLArgumentTypeFloat: {
          float val = [text floatValue];
          [invocation setArgument:&val atIndex:argIndex+2];
          break;
        }
        case TTURLArgumentTypeDouble: {
          double val = [text doubleValue];
          [invocation setArgument:&val atIndex:argIndex+2];
          break;
        }
        case TTURLArgumentTypeBool: {
          BOOL val = [text boolValue];
          [invocation setArgument:&val atIndex:argIndex+2];
          break;
        }
        default: {
          [invocation setArgument:&text atIndex:argIndex+2];
          break;
        }
      }
      return YES;
    }
  }
  return NO;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setArgumentsFromURL: (NSURL*)URL
              forInvocation: (NSInvocation*)invocation
                      query: (NSDictionary*)query {
  NSInteger remainingArgs = _argumentCount;
  NSMutableDictionary* unmatchedArgs = query ? [[query mutableCopy] autorelease] : nil;

  NSArray* pathComponents = URL.path.pathComponents;
  for (NSInteger i = 0; i < _path.count; ++i) {
    id<TTURLPatternText> patternText = [_path objectAtIndex:i];
    NSString* text = i == 0 ? URL.host : [pathComponents objectAtIndex:i];
    if ([self setArgument:text pattern:patternText forInvocation:invocation]) {
      --remainingArgs;
    }
  }

  NSDictionary* URLQuery = [URL.query queryContentsUsingEncoding:NSUTF8StringEncoding];
  if (URLQuery.count) {
    for (NSString* name in [URLQuery keyEnumerator]) {
      id<TTURLPatternText> patternText = [_query objectForKey:name];
      NSString* text = [[URLQuery objectForKey:name] objectAtIndex:0];
      if (patternText) {
        if ([self setArgument:text pattern:patternText forInvocation:invocation]) {
          --remainingArgs;
        }

      } else {
        if (!unmatchedArgs) {
          unmatchedArgs = [NSMutableDictionary dictionary];
        }
        [unmatchedArgs setObject:text forKey:name];
      }
    }
  }

  if (remainingArgs && unmatchedArgs.count) {
    // If there are unmatched arguments, and the method signature has extra arguments,
    // then pass the dictionary of unmatched arguments as the last argument
    [invocation setArgument:&unmatchedArgs atIndex:_argumentCount+1];
  }

  if (URL.fragment && _fragment) {
    [self setArgument:URL.fragment pattern:_fragment forInvocation:invocation];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark TTURLPattern


///////////////////////////////////////////////////////////////////////////////////////////////////
- (Class)classForInvocation {
  return _targetClass ? _targetClass : [_targetObject class];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)isUniversal {
  return [_URL isEqualToString:kUniversalURLPattern];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)isFragment {
  return [_URL rangeOfString:@"#" options:NSBackwardsSearch].location != NSNotFound;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)compile {
  if ([_URL isEqualToString:kUniversalURLPattern]) {
    if (!_selector) {
      [self deduceSelector];
    }

  } else {
    [self compileURL];

    // XXXjoe Don't do this if the pattern is a URL generator
    if (!_selector) {
      [self deduceSelector];
    }
    if (_selector) {
      [self analyzeMethod];
    }
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)matchURL:(NSURL*)URL {
  if (!URL.scheme || !URL.host || ![_scheme isEqualToString:URL.scheme]) {
    return NO;
  }

  NSArray* pathComponents = URL.path.pathComponents;
  NSInteger componentCount = URL.path.length ? pathComponents.count : (URL.host ? 1 : 0);
  if (componentCount != _path.count) {
    return NO;
  }

  if (_path.count && URL.host) {
    id<TTURLPatternText>hostPattern = [_path objectAtIndex:0];
    if (![hostPattern match:URL.host]) {
      return NO;
    }
  }

  for (NSInteger i = 1; i < _path.count; ++i) {
    id<TTURLPatternText>pathPattern = [_path objectAtIndex:i];
    NSString* pathText = [pathComponents objectAtIndex:i];
    if (![pathPattern match:pathText]) {
      return NO;
    }
  }

  if ((URL.fragment && !_fragment) || (_fragment && !URL.fragment)) {
    return NO;

  } else if (URL.fragment && _fragment && ![_fragment match:URL.fragment]) {
    return NO;
  }

  return YES;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)invoke: (id)target
     withURL: (NSURL*)URL
       query: (NSDictionary*)query {
  id returnValue = nil;

  NSMethodSignature *sig = [target methodSignatureForSelector:self.selector];
  if (sig) {
    NSInvocation* invocation = [NSInvocation invocationWithMethodSignature:sig];
    [invocation setTarget:target];
    [invocation setSelector:self.selector];
    if (self.isUniversal) {
      [invocation setArgument:&URL atIndex:2];
      if (query) {
        [invocation setArgument:&query atIndex:3];
      }

    } else {
      [self setArgumentsFromURL:URL forInvocation:invocation query:query];
    }
    [invocation invoke];

    if (sig.methodReturnLength) {
      [invocation getReturnValue:&returnValue];
    }
  }

  return returnValue;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)createObjectFromURL: (NSURL*)URL
                    query: (NSDictionary*)query {
  id returnValue = nil;

  if (self.instantiatesClass) {
    //suppress static analyzer warning for this part
    // - invoke:withURL:query actually calls an - init method
    // which returns either a new object with retain count of +1
    // or returnValue (which already has +1 retain count)
#ifndef __clang_analyzer__
    returnValue = [_targetClass alloc];
    if (_selector) {
      returnValue = [self invoke:returnValue withURL:URL query:query];

    } else {
      returnValue = [returnValue init];
    }
    [returnValue autorelease];
#endif

  } else {
    id target = [_targetObject retain];
    if (_selector) {
      returnValue = [self invoke:target withURL:URL query:query];

    } else {
      TTDWARNING(@"No object created from URL:'%@' URL");
    }
    [target release];
  }
  return returnValue;
}


@end
