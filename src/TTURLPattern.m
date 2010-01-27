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

#import "Three20/TTURLPattern.h"

#import "Three20/TTURLWildcard.h"
#import "Three20/TTURLLiteral.h"

#import "Three20/TTGlobalCore.h"

#import <objc/runtime.h>

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation TTURLPattern

@synthesize URL = _URL, scheme = _scheme, specificity = _specificity, selector = _selector;

///////////////////////////////////////////////////////////////////////////////////////////////////
// private

- (id<TTURLPatternText>)parseText:(NSString*)text {
  NSInteger len = text.length;
  if (len >= 2
      && [text characterAtIndex:0] == '('
      && [text characterAtIndex:len-1] == ')') {
    NSInteger endRange = len > 3 && [text characterAtIndex:len-2] == ':'
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

- (void)parsePathComponent:(NSString*)value {
  id<TTURLPatternText> component = [self parseText:value];
  [_path addObject:component];
}

- (void)parseParameter:(NSString*)name value:(NSString*)value {
  if (!_query) {
    _query = [[NSMutableDictionary alloc] init];
  }
  
  id<TTURLPatternText> component = [self parseText:value];
  [_query setObject:component forKey:name];
}

- (void)setSelectorWithNames:(NSArray*)names {
  NSString* selectorName = [[names componentsJoinedByString:@":"] stringByAppendingString:@":"];
  SEL selector = NSSelectorFromString(selectorName);
  [self setSelectorIfPossible:selector];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// NSObject

- (id)init {
  if (self = [super init]) {
    _URL = nil;
    _scheme = nil;
    _path = [[NSMutableArray alloc] init];
    _query = nil;
    _fragment = nil;
    _specificity = 0;
    _selector = nil;
  }
  return self;
}

- (void)dealloc {
  TT_RELEASE_SAFELY(_URL);
  TT_RELEASE_SAFELY(_scheme);
  TT_RELEASE_SAFELY(_path);
  TT_RELEASE_SAFELY(_query);
  TT_RELEASE_SAFELY(_fragment);
  [super dealloc];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// public

- (Class)classForInvocation {
  return nil;
}

- (void)setSelectorIfPossible:(SEL)selector {
  Class cls = [self classForInvocation];
  if (!cls || class_respondsToSelector(cls, selector) || class_getClassMethod(cls, selector)) {
    _selector = selector;
  }
}

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
    NSDictionary* query = [URL.query queryDictionaryUsingEncoding:NSUTF8StringEncoding];
    for (NSString* name in [query keyEnumerator]) {
      NSString* value = [query objectForKey:name];
      [self parseParameter:name value:value];
    }
  }

  if (URL.fragment) {
    _fragment = [[self parseText:URL.fragment] retain];
  }
}

@end
