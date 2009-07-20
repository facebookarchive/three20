#import "Three20/TTURLMap.h"
#import "Three20/TTURLPattern.h"
#import <objc/runtime.h>

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation TTURLMap

///////////////////////////////////////////////////////////////////////////////////////////////////
// private

- (NSString*)keyForClass:(Class)cls withName:(NSString*)name {
  const char* className = class_getName(cls);
  return [NSString stringWithFormat:@"%s_%@", className, name ? name : @""];  
}

- (void)registerScheme:(NSString*)scheme {
  if (scheme) {
    if (!_schemes) {
      _schemes = [[NSMutableDictionary alloc] init];
    }
    [_schemes setObject:[NSNull null] forKey:scheme];
  }
}

- (void)addObjectPattern:(TTURLPattern*)pattern forURL:(NSString*)URL {
  pattern.URL = URL;
  [pattern compileForObject];
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

- (void)addStringPattern:(TTURLPattern*)pattern forURL:(NSString*)URL withName:(NSString*)name {
  pattern.URL = URL;
  [pattern compileForString];
  [self registerScheme:pattern.scheme];
  
  if (!_stringPatterns) {
    _stringPatterns = [[NSMutableDictionary alloc] init];
  }
    
  NSString* key = [self keyForClass:pattern.targetClass withName:name];
  [_stringPatterns setObject:pattern forKey:key];
}

- (TTURLPattern*)matchObjectPattern:(NSURL*)URL {
  if (_invalidPatterns) {
    [_objectPatterns sortUsingSelector:@selector(compareSpecificity:)];
    _invalidPatterns = NO;
  }
  
  for (TTURLPattern* pattern in _objectPatterns) {
    if ([pattern matchURL:URL]) {
      return pattern;
    }
  }
  
  
  return _defaultObjectPattern;
}

- (BOOL)isWebURL:(NSURL*)URL {
  return [URL.scheme isEqualToString:@"http"]
         || [URL.scheme isEqualToString:@"https"]
         || [URL.scheme isEqualToString:@"ftp"]
         || [URL.scheme isEqualToString:@"ftps"]
         || [URL.scheme isEqualToString:@"data"];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// NSObject

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

- (void)dealloc {
  TT_RELEASE_MEMBER(_objectMappings);
  TT_RELEASE_MEMBER(_objectPatterns);
  TT_RELEASE_MEMBER(_fragmentPatterns);
  TT_RELEASE_MEMBER(_stringPatterns);
  TT_RELEASE_MEMBER(_schemes);
  TT_RELEASE_MEMBER(_defaultObjectPattern);
  [super dealloc];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// public

- (void)from:(NSString*)URL toObject:(id)target {
  TTURLPattern* pattern = [[TTURLPattern alloc] initWithMode:TTNavigationModeNone target:target];
  [self addObjectPattern:pattern forURL:URL];
  [pattern release];
}

- (void)from:(NSString*)URL toObject:(id)target selector:(SEL)selector {
  TTURLPattern* pattern = [[TTURLPattern alloc] initWithMode:TTNavigationModeNone target:target];
  pattern.selector = selector;
  [self addObjectPattern:pattern forURL:URL];
  [pattern release];
}

- (void)from:(NSString*)URL toViewController:(id)target {
  TTURLPattern* pattern = [[TTURLPattern alloc] initWithMode:TTNavigationModeCreate target:target];
  [self addObjectPattern:pattern forURL:URL];
  [pattern release];
}

- (void)from:(NSString*)URL toViewController:(id)target selector:(SEL)selector {
  TTURLPattern* pattern = [[TTURLPattern alloc] initWithMode:TTNavigationModeCreate target:target];
  pattern.selector = selector;
  [self addObjectPattern:pattern forURL:URL];
  [pattern release];
}

- (void)from:(NSString*)URL toViewController:(id)target transition:(NSInteger)transition {
  TTURLPattern* pattern = [[TTURLPattern alloc] initWithMode:TTNavigationModeCreate target:target];
  pattern.transition = transition;
  [self addObjectPattern:pattern forURL:URL];
  [pattern release];
}

- (void)from:(NSString*)URL parent:(NSString*)parentURL
        toViewController:(id)target selector:(SEL)selector transition:(NSInteger)transition {
  TTURLPattern* pattern = [[TTURLPattern alloc] initWithMode:TTNavigationModeCreate target:target];
  pattern.parentURL = parentURL;
  pattern.selector = selector;
  pattern.transition = transition;
  [self addObjectPattern:pattern forURL:URL];
  [pattern release];
}

- (void)from:(NSString*)URL toSharedViewController:(id)target {
  TTURLPattern* pattern = [[TTURLPattern alloc] initWithMode:TTNavigationModeShare target:target];
  [self addObjectPattern:pattern forURL:URL];
  [pattern release];
}

- (void)from:(NSString*)URL toSharedViewController:(id)target selector:(SEL)selector {
  TTURLPattern* pattern = [[TTURLPattern alloc] initWithMode:TTNavigationModeShare target:target];
  pattern.selector = selector;
  [self addObjectPattern:pattern forURL:URL];
  [pattern release];
}

- (void)from:(NSString*)URL parent:(NSString*)parentURL
        toSharedViewController:(id)target selector:(SEL)selector {
  TTURLPattern* pattern = [[TTURLPattern alloc] initWithMode:TTNavigationModeShare target:target];
  pattern.parentURL = parentURL;
  pattern.selector = selector;
  [self addObjectPattern:pattern forURL:URL];
  [pattern release];
}

- (void)from:(NSString*)URL toModalViewController:(id)target {
  TTURLPattern* pattern = [[TTURLPattern alloc] initWithMode:TTNavigationModeModal target:target];
  [self addObjectPattern:pattern forURL:URL];
  [pattern release];
}

- (void)from:(NSString*)URL toModalViewController:(id)target selector:(SEL)selector {
  TTURLPattern* pattern = [[TTURLPattern alloc] initWithMode:TTNavigationModeModal target:target];
  pattern.selector = selector;
  [self addObjectPattern:pattern forURL:URL];
  [pattern release];
}

- (void)from:(NSString*)URL toModalViewController:(id)target transition:(NSInteger)transition {
  TTURLPattern* pattern = [[TTURLPattern alloc] initWithMode:TTNavigationModeModal target:target];
  pattern.transition = transition;
  [self addObjectPattern:pattern forURL:URL];
  [pattern release];
}

- (void)from:(NSString*)URL parent:(NSString*)parentURL
        toModalViewController:(id)target selector:(SEL)selector transition:(NSInteger)transition {
  TTURLPattern* pattern = [[TTURLPattern alloc] initWithMode:TTNavigationModeModal target:target];
  pattern.parentURL = parentURL;
  pattern.selector = selector;
  pattern.transition = transition;
  [self addObjectPattern:pattern forURL:URL];
  [pattern release];
}

- (void)from:(Class)cls toURL:(NSString*)URL {
  TTURLPattern* pattern = [[TTURLPattern alloc] initWithMode:TTNavigationModeNone target:cls];
  [self addStringPattern:pattern forURL:URL withName:nil];
  [pattern release];
}

- (void)from:(Class)cls name:(NSString*)name toURL:(NSString*)URL {
  TTURLPattern* pattern = [[TTURLPattern alloc] initWithMode:TTNavigationModeNone target:cls];
  [self addStringPattern:pattern forURL:URL withName:name];
  [pattern release];
}

- (void)setObject:(id)object forURL:(NSString*)URL {
  if (!_objectMappings) {
    _objectMappings = TTCreateNonRetainingDictionary();
  }
  // XXXjoe Normalize the URL first
  [_objectMappings setObject:object forKey:URL];
}

- (void)removeURL:(NSString*)URL {
  [_objectMappings removeObjectForKey:URL];

  for (TTURLPattern* pattern in _objectPatterns) {
    if ([URL isEqualToString:pattern.URL]) {
      [_objectPatterns removeObject:pattern];
      break;
    }
  }
}

- (void)removeObject:(id)object {
  // XXXjoe IMPLEMENT ME
}

- (void)removeObjectForURL:(NSString*)URL {
  [_objectMappings removeObjectForKey:URL];
}

- (id)objectForURL:(NSString*)URL {
  return [self objectForURL:URL query:nil pattern:nil];
}

- (id)objectForURL:(NSString*)URL query:(NSDictionary*)query {
  return [self objectForURL:URL query:query pattern:nil];
}

- (id)objectForURL:(NSString*)URL query:(NSDictionary*)query pattern:(TTURLPattern**)outPattern {
  id object = nil;
  if (_objectMappings) {
    object = [_objectMappings objectForKey:URL];
    if (object && !outPattern) {
      return object;
    }
  }

  NSURL* theURL = [NSURL URLWithString:URL];
  TTURLPattern* pattern  = [self matchObjectPattern:theURL];
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

- (id)dispatchURL:(NSString*)URL toTarget:(id)target query:(NSDictionary*)query {
  NSURL* theURL = [NSURL URLWithString:URL];
  for (TTURLPattern* pattern in _fragmentPatterns) {
    if ([pattern matchURL:theURL]) {
      return [pattern invoke:target withURL:theURL query:query];
    }
  }
  return nil;
}

- (TTNavigationMode)navigationModeForURL:(NSString*)URL {
  NSURL* theURL = [NSURL URLWithString:URL];
  if (![self isAppURL:theURL]) {
    TTURLPattern* pattern = [self matchObjectPattern:theURL];
    if (pattern) {
      return pattern.navigationMode;
    }
  }
  return TTNavigationModeExternal;
}

- (NSInteger)transitionForURL:(NSString*)URL {
  TTURLPattern* pattern = [self matchObjectPattern:[NSURL URLWithString:URL]];
  return pattern.transition;
}

- (BOOL)isSchemeSupported:(NSString*)scheme {
  return scheme && !![_schemes objectForKey:scheme];
}

- (BOOL)isAppURL:(NSURL*)URL {
  return [[UIApplication sharedApplication] canOpenURL:URL]
          && ![self isSchemeSupported:URL.scheme]
          && ![self isWebURL:URL];
}

- (NSString*)URLForObject:(id)object {
  return [self URLForObject:object withName:nil];
}

- (NSString*)URLForObject:(id)object withName:(NSString*)name {
  Class cls = [object class] == object ? object : [object class];
  while (cls) {
    NSString* key = [self keyForClass:cls withName:name];
    TTURLPattern* pattern = [_stringPatterns objectForKey:key];
    if (pattern) {
      return [pattern generateURLFromObject:object];
    } else {
      cls = class_getSuperclass(cls);
    }
  }
  return nil;
}

@end
