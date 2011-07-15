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

#import "Three20UINavigator/TTURLPattern.h"

// UINavigator (Private)
#import "Three20UINavigator/private/TTURLWildcard.h"
#import "Three20UINavigator/private/TTURLLiteral.h"

// Core
#import "Three20Core/TTCorePreprocessorMacros.h"
#import "Three20Core/NSStringAdditions.h"

#import <objc/runtime.h>

///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation TTURLPattern

@synthesize URL         = _URL;
@synthesize scheme      = _scheme;
@synthesize specificity = _specificity;
@synthesize selector    = _selector;


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)init {
	self = [super init];
  if (self) {
    _path = [[NSMutableArray alloc] init];
  }
  return self;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)dealloc {
  TT_RELEASE_SAFELY(_URL);
  TT_RELEASE_SAFELY(_scheme);
  TT_RELEASE_SAFELY(_path);
  TT_RELEASE_SAFELY(_query);
  TT_RELEASE_SAFELY(_fragment);

  [super dealloc];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Private


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id<TTURLPatternText>)parseText:(NSString*)text {
  NSInteger len = text.length;
  if (len >= 2
      && [text characterAtIndex:0] == '('
      && [text characterAtIndex:len - 1] == ')') {
    NSInteger endRange = len > 3 && [text characterAtIndex:len - 2] == ':'
      ? len - 3
      : len - 2;

    NSString* name = len > 2 ? [text substringWithRange:NSMakeRange(1, endRange)] : nil;

    TTURLWildcard* wildcard = [[[TTURLWildcard alloc] init] autorelease];
    wildcard.name = name;

    ++_specificity;

    return wildcard;

  } else {
    TTURLLiteral* literal = [[[TTURLLiteral alloc] init] autorelease];
    literal.name = text;
    _specificity += 2;
    return literal;
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)parsePathComponent:(NSString*)value {
  id<TTURLPatternText> component = [self parseText:value];
  [_path addObject:component];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)parseParameter:(NSString*)name value:(NSString*)value {
  if (nil == _query) {
    _query = [[NSMutableDictionary alloc] init];
  }

  id<TTURLPatternText> component = [self parseText:value];
  [_query setObject:component forKey:name];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Public


///////////////////////////////////////////////////////////////////////////////////////////////////
- (Class)classForInvocation {
  return nil;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setSelectorIfPossible:(SEL)selector {
  Class cls = [self classForInvocation];
  if (nil == cls
      || class_respondsToSelector(cls, selector)
      || class_getClassMethod(cls, selector)) {
    _selector = selector;
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)compileURL {
  NSURL* URL = [NSURL URLWithString:_URL];
  _scheme = [URL.scheme copy];
  if (URL.host) {
    [self parsePathComponent:URL.host];

    if (URL.path) {
      for (NSString* name in URL.path.pathComponents) {
        if (![name isEqualToString:@"/"]) {
          [self parsePathComponent:name];
        }
      }
    }
  }

  if (URL.query) {
    NSDictionary* query = [URL.query queryContentsUsingEncoding:NSUTF8StringEncoding];
    for (NSString* name in [query keyEnumerator]) {
      NSString* value = [[query objectForKey:name] objectAtIndex:0];
      [self parseParameter:name value:value];
    }
  }

  if (URL.fragment) {
    _fragment = [[self parseText:URL.fragment] retain];
  }
}


@end
