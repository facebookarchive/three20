#import "Three20/TTURLMap.h"
#import "Three20/TTURLPattern.h"
#import <objc/runtime.h>

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation TTURLMap

///////////////////////////////////////////////////////////////////////////////////////////////////
// private

- (void)addPattern:(TTURLPattern*)pattern forURL:(NSString*)URL {
  pattern.URL = URL;
  [pattern compile];
  
  if (pattern.isUniversal) {
    [_defaultPattern release];
    _defaultPattern = [pattern retain];
  } else {
    _invalidPatterns = YES;
        
    if (!_patterns) {
      _patterns = [[NSMutableArray alloc] init];
    }
    
    [_patterns addObject:pattern];
  }
}

- (TTURLPattern*)matchPattern:(NSURL*)URL {
  if (_invalidPatterns) {
    [_patterns sortUsingSelector:@selector(compareSpecificity:)];
    _invalidPatterns = NO;
  }
  
  for (TTURLPattern* pattern in _patterns) {
    if ([pattern matchURL:URL]) {
      return pattern;
    }
  }
  return _defaultPattern;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// NSObject

- (id)init {
  if (self = [super init]) {
    _bindings = nil;
    _patterns = nil;
    _defaultPattern = nil;
    _invalidPatterns = NO;
  }
  return self;
}

- (void)dealloc {
  TT_RELEASE_MEMBER(_bindings);
  TT_RELEASE_MEMBER(_patterns);
  TT_RELEASE_MEMBER(_defaultPattern);
  [super dealloc];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// public

- (id)objectForURL:(NSString*)URL {
  return [self objectForURL:URL query:nil pattern:nil];
}

- (id)objectForURL:(NSString*)URL query:(NSDictionary*)query {
  return [self objectForURL:URL query:query pattern:nil];
}

- (id)objectForURL:(NSString*)URL query:(NSDictionary*)query pattern:(TTURLPattern**)pattern {
  if (_bindings) {
    // XXXjoe Normalize the URL first
    id object = [_bindings objectForKey:URL];
    if (object) {
      return object;
    }
  }

  NSURL* theURL = [NSURL URLWithString:URL];
  TTURLPattern* match = [self matchPattern:theURL];
  if (match) {
    id target = nil;
    UIViewController* controller = nil;

    if (match.targetClass) {
      target = [match.targetClass alloc];
    } else {
      target = [match.targetObject retain];
    }
    
    if (match.selector) {
      controller = [match invoke:target withURL:theURL query:query];
    } else if (match.targetClass) {
      controller = [target init];
    }
    
    if (match.navigationMode == TTNavigationModeShare && controller) {
      [self bindObject:controller toURL:URL];
    }
    
    [target autorelease];

    if (pattern) {
      *pattern = match;
    }
    return controller;
  } else {
    return nil;
  }
}

- (TTNavigationMode)navigationModeForURL:(NSString*)URL {
  TTURLPattern* pattern = [self matchPattern:[NSURL URLWithString:URL]];
  return pattern.navigationMode;
}

- (void)from:(NSString*)URL toViewController:(id)target {
  TTURLPattern* pattern = [[TTURLPattern alloc] initWithMode:TTNavigationModeCreate target:target];
  [self addPattern:pattern forURL:URL];
  [pattern release];
}

- (void)from:(NSString*)URL toViewController:(id)target selector:(SEL)selector {
  TTURLPattern* pattern = [[TTURLPattern alloc] initWithMode:TTNavigationModeCreate target:target];
  pattern.selector = selector;
  [self addPattern:pattern forURL:URL];
  [pattern release];
}

- (void)from:(NSString*)URL toViewController:(id)target selector:(SEL)selector
        parent:(NSString*)parentURL {
  TTURLPattern* pattern = [[TTURLPattern alloc] initWithMode:TTNavigationModeCreate target:target];
  pattern.parentURL = parentURL;
  pattern.selector = selector;
  [self addPattern:pattern forURL:URL];
  [pattern release];
}

- (void)from:(NSString*)URL toSharedViewController:(id)target {
  TTURLPattern* pattern = [[TTURLPattern alloc] initWithMode:TTNavigationModeShare target:target];
  [self addPattern:pattern forURL:URL];
  [pattern release];
}

- (void)from:(NSString*)URL toSharedViewController:(id)target selector:(SEL)selector {
  TTURLPattern* pattern = [[TTURLPattern alloc] initWithMode:TTNavigationModeShare target:target];
  pattern.selector = selector;
  [self addPattern:pattern forURL:URL];
  [pattern release];
}

- (void)from:(NSString*)URL toSharedViewController:(id)target selector:(SEL)selector
        parent:(NSString*)parentURL {
  TTURLPattern* pattern = [[TTURLPattern alloc] initWithMode:TTNavigationModeShare target:target];
  pattern.parentURL = parentURL;
  pattern.selector = selector;
  [self addPattern:pattern forURL:URL];
  [pattern release];
}

- (void)from:(NSString*)URL toModalViewController:(id)target {
  TTURLPattern* pattern = [[TTURLPattern alloc] initWithMode:TTNavigationModeModal target:target];
  [self addPattern:pattern forURL:URL];
  [pattern release];
}

- (void)from:(NSString*)URL toModalViewController:(id)target selector:(SEL)selector {
  TTURLPattern* pattern = [[TTURLPattern alloc] initWithMode:TTNavigationModeModal target:target];
  pattern.selector = selector;
  [self addPattern:pattern forURL:URL];
  [pattern release];
}

- (void)from:(NSString*)URL toModalViewController:(id)target selector:(SEL)selector
        parent:(NSString*)parentURL {
  TTURLPattern* pattern = [[TTURLPattern alloc] initWithMode:TTNavigationModeModal target:target];
  pattern.parentURL = parentURL;
  pattern.selector = selector;
  [self addPattern:pattern forURL:URL];
  [pattern release];
}

- (void)from:(id)object toURL:(NSString*)URL {
}

- (void)from:(id)object name:(NSString*)name toURL:(NSString*)URL {
}

- (void)removeURL:(NSString*)URL {
  for (TTURLPattern* pattern in _patterns) {
    if ([URL isEqualToString:pattern.URL]) {
      [_patterns removeObject:pattern];
      break;
    }
  }
}

- (void)bindObject:(id)object toURL:(NSString*)URL {
  if (!_bindings) {
    _bindings = TTCreateNonRetainingDictionary();
  }
  // XXXjoe Normalize the URL first
  [_bindings setObject:object forKey:URL];
}

- (void)removeBindingForURL:(NSString*)URL {
  [_bindings removeObjectForKey:URL];
}

- (void)removeBindingForObject:(id)object {
  // XXXjoe IMPLEMENT ME
}

@end
