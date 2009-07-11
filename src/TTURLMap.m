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

- (void)addObjectPattern:(TTURLPattern*)pattern forURL:(NSString*)URL {
  pattern.URL = URL;
  [pattern compileForObject];

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

///////////////////////////////////////////////////////////////////////////////////////////////////
// NSObject

- (id)init {
  if (self = [super init]) {
    _objectMappings = nil;
    _objectPatterns = nil;
    _fragmentPatterns = nil;
    _stringPatterns = nil;
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
  TT_RELEASE_MEMBER(_defaultObjectPattern);
  [super dealloc];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// public

- (void)from:(NSString*)URL toObject:(id)object {
  if (!_objectMappings) {
    _objectMappings = TTCreateNonRetainingDictionary();
  }
  // XXXjoe Normalize the URL first
  [_objectMappings setObject:object forKey:URL];
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

- (void)from:(NSString*)URL parent:(NSString*)parentURL
        toViewController:(id)target selector:(SEL)selector {
  TTURLPattern* pattern = [[TTURLPattern alloc] initWithMode:TTNavigationModeCreate target:target];
  pattern.parentURL = parentURL;
  pattern.selector = selector;
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

- (void)from:(NSString*)URL parent:(NSString*)parentURL
        toModalViewController:(id)target selector:(SEL)selector {
  TTURLPattern* pattern = [[TTURLPattern alloc] initWithMode:TTNavigationModeModal target:target];
  pattern.parentURL = parentURL;
  pattern.selector = selector;
  [self addObjectPattern:pattern forURL:URL];
  [pattern release];
}

- (void)from:(NSString*)URL toPopupViewController:(id)target {
  TTURLPattern* pattern = [[TTURLPattern alloc] initWithMode:TTNavigationModePopup target:target];
  [self addObjectPattern:pattern forURL:URL];
  [pattern release];
}

- (void)from:(NSString*)URL toPopupViewController:(id)target selector:(SEL)selector {
  TTURLPattern* pattern = [[TTURLPattern alloc] initWithMode:TTNavigationModePopup target:target];
  pattern.selector = selector;
  [self addObjectPattern:pattern forURL:URL];
  [pattern release];
}

- (void)from:(NSString*)URL parent:(NSString*)parentURL
        toPopupViewController:(id)target selector:(SEL)selector {
  TTURLPattern* pattern = [[TTURLPattern alloc] initWithMode:TTNavigationModePopup target:target];
  pattern.parentURL = parentURL;
  pattern.selector = selector;
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

- (void)removeObjectWithURL:(NSString*)URL {
  [_objectMappings removeObjectForKey:URL];
}

- (id)objectForURL:(NSString*)URL {
  return [self objectForURL:URL query:nil pattern:nil];
}

- (id)objectForURL:(NSString*)URL query:(NSDictionary*)query {
  return [self objectForURL:URL query:query pattern:nil];
}

- (id)objectForURL:(NSString*)URL query:(NSDictionary*)query pattern:(TTURLPattern**)outPattern {
  if (_objectMappings) {
    // XXXjoe Normalize the URL first
    id object = [_objectMappings objectForKey:URL];
    if (object) {
      return object;
    }
  }

  NSURL* theURL = [NSURL URLWithString:URL];
  TTURLPattern* pattern  = [self matchObjectPattern:theURL];
  if (pattern) {
    id object = [pattern createObjectFromURL:theURL query:query];
    if (pattern.navigationMode == TTNavigationModeShare && object) {
      [self from:URL toObject:object];
    }
    if (outPattern) {
      *outPattern = pattern;
    }
    return object;
  } else {
    return nil;
  }
}

- (void)dispatchURL:(NSString*)URL toTarget:(id)target query:(NSDictionary*)query {
  NSURL* theURL = [NSURL URLWithString:URL];
  for (TTURLPattern* pattern in _fragmentPatterns) {
    if ([pattern matchURL:theURL]) {
      [pattern invoke:target withURL:theURL query:query];
    }
  }
}

- (TTNavigationMode)navigationModeForURL:(NSString*)URL {
  TTURLPattern* pattern = [self matchObjectPattern:[NSURL URLWithString:URL]];
  return pattern.navigationMode;
}

- (NSString*)URLForObject:(id)object {
  return [self URLForObject:object withName:nil];
}

- (NSString*)URLForObject:(id)object withName:(NSString*)name {
  Class cls = [object class] == object ? object : [object class];
  NSString* key = [self keyForClass:cls withName:name];
  TTURLPattern* pattern = [_stringPatterns objectForKey:key];
  if (pattern) {
    return [pattern generateURLFromObject:object];
  } else {
    return nil;
  }
}

@end
