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

#import "Three20/TTURLMap.h"

#import "Three20/TTURLNavigatorPattern.h"
#import "Three20/TTURLGeneratorPattern.h"
#import "Three20/TTGlobalCore.h"

#import <objc/runtime.h>


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation TTURLMap


///////////////////////////////////////////////////////////////////////////////////////////////////
/**
 * @return a unique key for a class with a given name.
 * @private
 */
- (NSString*)keyForClass:(Class)cls withName:(NSString*)name {
  const char* className = class_getName(cls);
  return [NSString stringWithFormat:@"%s_%@", className, (nil != name) ? name : @""];  
}


///////////////////////////////////////////////////////////////////////////////////////////////////
/**
 * What's a scheme?
 * It's a specific URL that is registered with the URL map.
 * Example:
 *  @"tt://some/path"
 *
 * This method registers them.
 *
 * @private
 */
- (void)registerScheme:(NSString*)scheme {
  if (nil != scheme) {
    if (nil == _schemes) {
      _schemes = [[NSMutableDictionary alloc] init];
    }
    [_schemes setObject:[NSNull null] forKey:scheme];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
/**
 * @private
 */
- (void)addObjectPattern: (TTURLNavigatorPattern*)pattern
                  forURL: (NSString*)URL {
  pattern.URL = URL;
  [pattern compile];
  [self registerScheme:pattern.scheme];

  if (pattern.isUniversal) {
    [_defaultObjectPattern release];
    _defaultObjectPattern = [pattern retain];

  } else if (pattern.isFragment) {
    if (!_fragmentPatterns) {
      _fragmentPatterns = [[NSMutableArray alloc] init];
    }
    [_fragmentPatterns addObject:pattern];

  } else {
    _invalidPatterns = YES;

    if (!_objectPatterns) {
      _objectPatterns = [[NSMutableArray alloc] init];
    }

    [_objectPatterns addObject:pattern];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
/**
 * @private
 */
- (void)addStringPattern: (TTURLGeneratorPattern*)pattern
                  forURL: (NSString*)URL
                withName: (NSString*)name {
  pattern.URL = URL;
  [pattern compile];
  [self registerScheme:pattern.scheme];

  if (!_stringPatterns) {
    _stringPatterns = [[NSMutableDictionary alloc] init];
  }

  NSString* key = [self keyForClass:pattern.targetClass withName:name];
  [_stringPatterns setObject:pattern forKey:key];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
/**
 * @private
 */
- (TTURLNavigatorPattern*)matchObjectPattern:(NSURL*)URL {
  if (_invalidPatterns) {
    [_objectPatterns sortUsingSelector:@selector(compareSpecificity:)];
    _invalidPatterns = NO;
  }

  for (TTURLNavigatorPattern* pattern in _objectPatterns) {
    if ([pattern matchURL:URL]) {
      return pattern;
    }
  }


  return _defaultObjectPattern;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
/**
 * @private
 */
- (BOOL)isWebURL:(NSURL*)URL {
  return [URL.scheme caseInsensitiveCompare:@"http"] == NSOrderedSame
         || [URL.scheme caseInsensitiveCompare:@"https"] == NSOrderedSame
         || [URL.scheme caseInsensitiveCompare:@"ftp"] == NSOrderedSame
         || [URL.scheme caseInsensitiveCompare:@"ftps"] == NSOrderedSame
         || [URL.scheme caseInsensitiveCompare:@"data"] == NSOrderedSame;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
/**
 * @private
 */
- (BOOL)isExternalURL:(NSURL*)URL {
  if ([URL.host isEqualToString:@"maps.google.com"]
      || [URL.host isEqualToString:@"itunes.apple.com"]
      || [URL.host isEqualToString:@"phobos.apple.com"]) {
    return YES;
  } else {
    return NO;
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark NSObject


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)init {
  if (self = [super init]) {
    _objectMappings = nil;
    _objectPatterns = nil;
    _fragmentPatterns = nil;
    _stringPatterns = nil;
    _schemes = nil;
    _defaultObjectPattern = nil;
    _invalidPatterns = NO;
  }
  return self;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)dealloc {
  TT_RELEASE_SAFELY(_objectMappings);
  TT_RELEASE_SAFELY(_objectPatterns);
  TT_RELEASE_SAFELY(_fragmentPatterns);
  TT_RELEASE_SAFELY(_stringPatterns);
  TT_RELEASE_SAFELY(_schemes);
  TT_RELEASE_SAFELY(_defaultObjectPattern);
  [super dealloc];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Mapping


///////////////////////////////////////////////////////////////////////////////////////////////////
/**
 * @public
 */
- (void)from:(NSString*)URL toObject:(id)target {
  TTURLNavigatorPattern* pattern = [[TTURLNavigatorPattern alloc] initWithTarget:target];
  [self addObjectPattern:pattern forURL:URL];
  [pattern release];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
/**
 * @public
 */
- (void)from:(NSString*)URL toObject:(id)target selector:(SEL)selector {
  TTURLNavigatorPattern* pattern = [[TTURLNavigatorPattern alloc] initWithTarget:target];
  pattern.selector = selector;
  [self addObjectPattern:pattern forURL:URL];
  [pattern release];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
/**
 * @public
 */
- (void)from:(NSString*)URL toViewController:(id)target {
  TTURLNavigatorPattern* pattern = [[TTURLNavigatorPattern alloc] initWithTarget:target
                                                                  mode:TTNavigationModeCreate];
  [self addObjectPattern:pattern forURL:URL];
  [pattern release];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
/**
 * @public
 */
- (void)from:(NSString*)URL toViewController:(id)target selector:(SEL)selector {
  TTURLNavigatorPattern* pattern = [[TTURLNavigatorPattern alloc] initWithTarget:target
                                                                  mode:TTNavigationModeCreate];
  pattern.selector = selector;
  [self addObjectPattern:pattern forURL:URL];
  [pattern release];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
/**
 * @public
 */
- (void)from:(NSString*)URL toViewController:(id)target transition:(NSInteger)transition {
  TTURLNavigatorPattern* pattern = [[TTURLNavigatorPattern alloc] initWithTarget:target
                                                                  mode:TTNavigationModeCreate];
  pattern.transition = transition;
  [self addObjectPattern:pattern forURL:URL];
  [pattern release];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
/**
 * @public
 */
- (void)from:(NSString*)URL parent:(NSString*)parentURL
        toViewController:(id)target selector:(SEL)selector transition:(NSInteger)transition {
  TTURLNavigatorPattern* pattern = [[TTURLNavigatorPattern alloc] initWithTarget:target
                                                                  mode:TTNavigationModeCreate];
  pattern.parentURL = parentURL;
  pattern.selector = selector;
  pattern.transition = transition;
  [self addObjectPattern:pattern forURL:URL];
  [pattern release];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
/**
 * @public
 */
- (void)from:(NSString*)URL toSharedViewController:(id)target {
  TTURLNavigatorPattern* pattern = [[TTURLNavigatorPattern alloc] initWithTarget:target
                                                                  mode:TTNavigationModeShare];
  [self addObjectPattern:pattern forURL:URL];
  [pattern release];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
/**
 * @public
 */
- (void)from:(NSString*)URL toSharedViewController:(id)target selector:(SEL)selector {
  TTURLNavigatorPattern* pattern = [[TTURLNavigatorPattern alloc] initWithTarget:target
                                                                  mode:TTNavigationModeShare];
  pattern.selector = selector;
  [self addObjectPattern:pattern forURL:URL];
  [pattern release];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
/**
 * @public
 */
- (void)from:(NSString*)URL parent:(NSString*)parentURL
        toSharedViewController:(id)target {
  TTURLNavigatorPattern* pattern = [[TTURLNavigatorPattern alloc] initWithTarget:target
                                                                  mode:TTNavigationModeShare];
  [self addObjectPattern:pattern forURL:URL];
  [pattern release];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
/**
 * @public
 */
- (void)from:(NSString*)URL parent:(NSString*)parentURL
        toSharedViewController:(id)target selector:(SEL)selector {
  TTURLNavigatorPattern* pattern = [[TTURLNavigatorPattern alloc] initWithTarget:target
                                                                  mode:TTNavigationModeShare];
  pattern.parentURL = parentURL;
  pattern.selector = selector;
  [self addObjectPattern:pattern forURL:URL];
  [pattern release];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
/**
 * @public
 */
- (void)from:(NSString*)URL toModalViewController:(id)target {
  TTURLNavigatorPattern* pattern = [[TTURLNavigatorPattern alloc] initWithTarget:target
                                                                  mode:TTNavigationModeModal];
  [self addObjectPattern:pattern forURL:URL];
  [pattern release];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
/**
 * @public
 */
- (void)from:(NSString*)URL toModalViewController:(id)target selector:(SEL)selector {
  TTURLNavigatorPattern* pattern = [[TTURLNavigatorPattern alloc] initWithTarget:target
                                                                  mode:TTNavigationModeModal];
  pattern.selector = selector;
  [self addObjectPattern:pattern forURL:URL];
  [pattern release];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
/**
 * @public
 */
- (void)from:(NSString*)URL toModalViewController:(id)target transition:(NSInteger)transition {
  TTURLNavigatorPattern* pattern = [[TTURLNavigatorPattern alloc] initWithTarget:target
                                                                  mode:TTNavigationModeModal];
  pattern.transition = transition;
  [self addObjectPattern:pattern forURL:URL];
  [pattern release];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
/**
 * @public
 */
- (void)from:(NSString*)URL parent:(NSString*)parentURL
        toModalViewController:(id)target selector:(SEL)selector transition:(NSInteger)transition {
  TTURLNavigatorPattern* pattern = [[TTURLNavigatorPattern alloc] initWithTarget:target
                                                                  mode:TTNavigationModeModal];
  pattern.parentURL = parentURL;
  pattern.selector = selector;
  pattern.transition = transition;
  [self addObjectPattern:pattern forURL:URL];
  [pattern release];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
/**
 * @public
 */
- (void)from:(Class)cls toURL:(NSString*)URL {
  TTURLGeneratorPattern* pattern = [[TTURLGeneratorPattern alloc] initWithTargetClass:cls];
  [self addStringPattern:pattern forURL:URL withName:nil];
  [pattern release];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
/**
 * @public
 */
- (void)from:(Class)cls name:(NSString*)name toURL:(NSString*)URL {
  TTURLGeneratorPattern* pattern = [[TTURLGeneratorPattern alloc] initWithTargetClass:cls];
  [self addStringPattern:pattern forURL:URL withName:name];
  [pattern release];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
/**
 * @public
 */
- (void)setObject:(id)object forURL:(NSString*)URL {
  if (!_objectMappings) {
    _objectMappings = TTCreateNonRetainingDictionary();
  }
  // XXXjoe Normalize the URL first
  [_objectMappings setObject:object forKey:URL];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
/**
 * @public
 */
- (void)removeURL:(NSString*)URL {
  [_objectMappings removeObjectForKey:URL];

  for (TTURLNavigatorPattern* pattern in _objectPatterns) {
    if ([URL isEqualToString:pattern.URL]) {
      [_objectPatterns removeObject:pattern];
      break;
    }
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
/**
 * @public
 */
- (void)removeObject:(id)object {
  // XXXjoe IMPLEMENT ME
}


///////////////////////////////////////////////////////////////////////////////////////////////////
/**
 * @public
 */
- (void)removeObjectForURL:(NSString*)URL {
  [_objectMappings removeObjectForKey:URL];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
/**
 * @public
 */
- (void)removeAllObjects {
  TT_RELEASE_SAFELY(_objectMappings);
}


///////////////////////////////////////////////////////////////////////////////////////////////////
/**
 * @public
 */
- (id)objectForURL:(NSString*)URL {
  return [self objectForURL:URL query:nil pattern:nil];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
/**
 * @public
 */
- (id)objectForURL:(NSString*)URL query:(NSDictionary*)query {
  return [self objectForURL:URL query:query pattern:nil];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
/**
 * @public
 */
- (id)objectForURL:(NSString*)URL query:(NSDictionary*)query pattern:(TTURLNavigatorPattern**)outPattern {
  id object = nil;
  if (_objectMappings) {
    object = [_objectMappings objectForKey:URL];
    if (object && !outPattern) {
      return object;
    }
  }

  NSURL* theURL = [NSURL URLWithString:URL];
  TTURLNavigatorPattern* pattern  = [self matchObjectPattern:theURL];
  if (pattern) {
    if (!object) {
      object = [pattern createObjectFromURL:theURL query:query];
    }
    if (pattern.navigationMode == TTNavigationModeShare && object) {
      [self setObject:object forURL:URL];
    }
    if (outPattern) {
      *outPattern = pattern;
    }
    return object;
  } else {
    return nil;
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
/**
 * @public
 */
- (id)dispatchURL:(NSString*)URL toTarget:(id)target query:(NSDictionary*)query {
  NSURL* theURL = [NSURL URLWithString:URL];
  for (TTURLNavigatorPattern* pattern in _fragmentPatterns) {
    if ([pattern matchURL:theURL]) {
      return [pattern invoke:target withURL:theURL query:query];
    }
  }

  // If there is no match, check if the fragment points to a method on the target
  if (theURL.fragment) {
    SEL selector = NSSelectorFromString(theURL.fragment);
    if (selector && [target respondsToSelector:selector]) {
      [target performSelector:selector];
    }
  }

  return nil;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
/**
 * @public
 */
- (TTNavigationMode)navigationModeForURL:(NSString*)URL {
  NSURL* theURL = [NSURL URLWithString:URL];
  if (![self isAppURL:theURL]) {
    TTURLNavigatorPattern* pattern = [self matchObjectPattern:theURL];
    if (pattern) {
      return pattern.navigationMode;
    }
  }
  return TTNavigationModeExternal;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
/**
 * @public
 */
- (NSInteger)transitionForURL:(NSString*)URL {
  TTURLNavigatorPattern* pattern = [self matchObjectPattern:[NSURL URLWithString:URL]];
  return pattern.transition;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
/**
 * @public
 */
- (BOOL)isSchemeSupported:(NSString*)scheme {
  return nil != scheme && !![_schemes objectForKey:scheme];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
/**
 * @public
 */
- (BOOL)isAppURL:(NSURL*)URL {
  return [self isExternalURL:URL]
          || ([[UIApplication sharedApplication] canOpenURL:URL]
              && ![self isSchemeSupported:URL.scheme]
              && ![self isWebURL:URL]);
}


///////////////////////////////////////////////////////////////////////////////////////////////////
/**
 * @public
 */
- (NSString*)URLForObject:(id)object {
  return [self URLForObject:object withName:nil];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
/**
 * @public
 */
- (NSString*)URLForObject:(id)object withName:(NSString*)name {
  Class cls = [object class] == object ? object : [object class];
  while (cls) {
    NSString* key = [self keyForClass:cls withName:name];
    TTURLGeneratorPattern* pattern = [_stringPatterns objectForKey:key];
    if (pattern) {
      return [pattern generateURLFromObject:object];
    } else {
      cls = class_getSuperclass(cls);
    }
  }
  return nil;
}


@end
