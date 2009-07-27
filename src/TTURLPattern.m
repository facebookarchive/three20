#import "Three20/TTURLPattern.h"
#import <objc/runtime.h>

///////////////////////////////////////////////////////////////////////////////////////////////////
// global

static NSString* kUniversalURLPattern = @"*";

///////////////////////////////////////////////////////////////////////////////////////////////////

typedef enum {
  TTURLArgumentTypeNone,
  TTURLArgumentTypePointer,
  TTURLArgumentTypeBool,
  TTURLArgumentTypeInteger,
  TTURLArgumentTypeLongLong,
  TTURLArgumentTypeFloat,
  TTURLArgumentTypeDouble,
} TTURLArgumentType;

static TTURLArgumentType TTConvertArgumentType(char argType) {
  if (argType == 'c'
      || argType == 'i'
      || argType == 's'
      || argType == 'l'
      || argType == 'C'
      || argType == 'I'
      || argType == 'S'
      || argType == 'L') {
    return TTURLArgumentTypeInteger;
  } else if (argType == 'q' || argType == 'Q') {
    return TTURLArgumentTypeLongLong;
  } else if (argType == 'f') {
    return TTURLArgumentTypeFloat;
  } else if (argType == 'd') {
    return TTURLArgumentTypeDouble;
  } else if (argType == 'B') {
    return TTURLArgumentTypeBool;
  } else {
    return TTURLArgumentTypePointer;
  }
}

static TTURLArgumentType TTURLArgumentTypeForProperty(Class cls, NSString* propertyName) {
  objc_property_t prop = class_getProperty(cls, propertyName.UTF8String);
  if (prop) {
    const char* type = property_getAttributes(prop);
    return TTConvertArgumentType(type[1]);
  } else {
    return TTURLArgumentTypeNone;
  }
}

///////////////////////////////////////////////////////////////////////////////////////////////////

@interface TTURLSelector : NSObject {
  NSString* _name;
  SEL _selector;
  TTURLSelector* _next;
}

@property(nonatomic,readonly) NSString* name;
@property(nonatomic,retain) TTURLSelector* next;

- (id)initWithName:(NSString*)name;

- (NSString*)perform:(id)object returnType:(TTURLArgumentType)returnType;

@end

@implementation TTURLSelector

@synthesize name = _name, next = _next;

- (id)initWithName:(NSString*)name {
  if (self = [super init]) {
    _name = [name copy];
    _selector = NSSelectorFromString(_name);
    _next = nil;
  }
  return self;
}

- (void)dealloc {
  TT_RELEASE_SAFELY(_name);
  TT_RELEASE_SAFELY(_next);
  [super dealloc];
}

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

///////////////////////////////////////////////////////////////////////////////////////////////////

@protocol TTURLPatternText <NSObject>

- (BOOL)match:(NSString*)text;

- (NSString*)convertPropertyOfObject:(id)object;

@end

///////////////////////////////////////////////////////////////////////////////////////////////////

@interface TTURLLiteral : NSObject <TTURLPatternText> {
  NSString* _name;
}

@property(nonatomic,copy) NSString* name;

@end

@implementation TTURLLiteral

@synthesize name = _name;

- (id)init {
  if (self = [super init]) {
    _name = nil;
  }
  return self;
}

- (void)dealloc {
  TT_RELEASE_SAFELY(_name);
  [super dealloc];
}

- (BOOL)match:(NSString*)text {
  return [text isEqualToString:_name];
}

- (NSString*)convertPropertyOfObject:(id)object {
  return _name;
}

@end

///////////////////////////////////////////////////////////////////////////////////////////////////

@interface TTURLWildcard : NSObject <TTURLPatternText> {
  NSString* _name;
  NSInteger _argIndex;
  TTURLArgumentType _argType;
  TTURLSelector* _selector;
}

@property(nonatomic,copy) NSString* name;
@property(nonatomic) NSInteger argIndex;
@property(nonatomic) TTURLArgumentType argType;
@property(nonatomic,retain) TTURLSelector* selector;

- (void)deduceSelectorForClass:(Class)cls;

@end

@implementation TTURLWildcard

@synthesize name = _name, argIndex = _argIndex, argType = _argType, selector = _selector;

- (id)init {
  if (self = [super init]) {
    _name = nil;
    _argIndex = NSNotFound;
    _argType = TTURLArgumentTypeNone;
    _selector = nil;
  }
  return self;
}

- (void)dealloc {
  TT_RELEASE_SAFELY(_name);
  TT_RELEASE_SAFELY(_selector);
  [super dealloc];
}

- (BOOL)match:(NSString*)text {
  return YES;
}

- (NSString*)convertPropertyOfObject:(id)object {
  if (_selector) {
    return [_selector perform:object returnType:_argType];
  } else {
    return @"";
  }
}

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


///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation TTURLNavigatorPattern

@synthesize targetClass = _targetClass, targetObject = _targetObject,
            navigationMode = _navigationMode, parentURL = _parentURL,
            transition = _transition, argumentCount = _argumentCount;

///////////////////////////////////////////////////////////////////////////////////////////////////
// private

- (BOOL)instantiatesClass {
  return _targetClass && _navigationMode;
}

- (BOOL)callsInstanceMethod {
  return (_targetObject && [_targetObject class] != _targetObject) || _targetClass;
}

- (NSComparisonResult)compareSpecificity:(TTURLPattern*)pattern2 {
  if (_specificity > pattern2.specificity) {
    return NSOrderedAscending;
  } else if (_specificity < pattern2.specificity) {
    return NSOrderedDescending;
  } else {
    return NSOrderedSame;
  }
}

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

- (void)analyzeArgument:(id<TTURLPatternText>)pattern method:(Method)method
        argNames:(NSArray*)argNames {
  if ([pattern isKindOfClass:[TTURLWildcard class]]) {
    TTURLWildcard* wildcard = (TTURLWildcard*)pattern;
    wildcard.argIndex = [argNames indexOfObject:wildcard.name];
    if (wildcard.argIndex == NSNotFound) {
      TTWARN(@"Argument %@ not found in @selector(%s)", wildcard.name, sel_getName(_selector));
    } else {
      char argType[256];
      method_getArgumentType(method, wildcard.argIndex+2, argType, 256);
      wildcard.argType = TTConvertArgumentType(argType[0]);
    }
  }
}

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

- (BOOL)setArgument:(NSString*)text pattern:(id<TTURLPatternText>)patternText
        forInvocation:(NSInvocation*)invocation {
  if ([patternText isKindOfClass:[TTURLWildcard class]]) {
    TTURLWildcard* wildcard = (TTURLWildcard*)patternText;
    NSInteger index = wildcard.argIndex;
    if (index != NSNotFound && index < _argumentCount) {
      switch (wildcard.argType) {
        case TTURLArgumentTypeNone: {
          break;
        }
        case TTURLArgumentTypeInteger: {
          int val = [text intValue];
          [invocation setArgument:&val atIndex:index+2];
          break;
        }
        case TTURLArgumentTypeLongLong: {
          long long val = [text longLongValue];
          [invocation setArgument:&val atIndex:index+2];
          break;
        }
        case TTURLArgumentTypeFloat: {
          float val = [text floatValue];
          [invocation setArgument:&val atIndex:index+2];
          break;
        }
        case TTURLArgumentTypeDouble: {
          double val = [text doubleValue];
          [invocation setArgument:&val atIndex:index+2];
          break;
        }
        case TTURLArgumentTypeBool: {
          BOOL val = [text boolValue];
          [invocation setArgument:&val atIndex:index+2];
          break;
        }
        default: {
          [invocation setArgument:&text atIndex:index+2];
          break;
        }
      }
      return YES;
    }
  }
  return NO;
}

- (void)setArgumentsFromURL:(NSURL*)URL forInvocation:(NSInvocation*)invocation
        query:(NSDictionary*)query {
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
  
  NSDictionary* URLQuery = [URL.query queryDictionaryUsingEncoding:NSUTF8StringEncoding];
  if (URLQuery.count) {
    for (NSString* name in [URLQuery keyEnumerator]) {
      id<TTURLPatternText> patternText = [_query objectForKey:name];
      NSString* text = [URLQuery objectForKey:name];
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
// NSObject

- (id)initWithTarget:(id)target {
  return [self initWithTarget:target mode:TTNavigationModeNone];
}

- (id)initWithTarget:(id)target mode:(TTNavigationMode)navigationMode {
  if (self = [super init]) {
    _targetClass = nil;
    _targetObject = nil;
    _navigationMode = navigationMode;
    _parentURL = nil;
    _transition = 0;
    _argumentCount = 0;

    if ([target class] == target && navigationMode) {
      _targetClass = target;
    } else {
      _targetObject = target;
    }
  }
  return self;
}

- (id)init {
  return [self initWithTarget:nil];
}

- (void)dealloc {
  TT_RELEASE_SAFELY(_parentURL);
  [super dealloc];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// TTURLPattern

- (Class)classForInvocation {
  return _targetClass ? _targetClass : [_targetObject class];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// public

- (BOOL)isUniversal {
  return [_URL isEqualToString:kUniversalURLPattern];
}

- (BOOL)isFragment {
  return [_URL rangeOfString:@"#" options:NSBackwardsSearch].location != NSNotFound;
}

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

- (id)invoke:(id)target withURL:(NSURL*)URL query:(NSDictionary*)query {
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

- (id)createObjectFromURL:(NSURL*)URL query:(NSDictionary*)query {
  id target = nil;
  if (self.instantiatesClass) {
    target = [_targetClass alloc];
  } else {
    target = [_targetObject retain];
  }

  id returnValue = nil;
  if (_selector) {
    returnValue = [self invoke:target withURL:URL query:query];
  } else if (self.instantiatesClass) {
    returnValue = [target init];
  }

  [target autorelease];
  return returnValue;
}

@end

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation TTURLGeneratorPattern

@synthesize targetClass = _targetClass;

///////////////////////////////////////////////////////////////////////////////////////////////////
// NSObject

- (id)initWithTargetClass:(id)targetClass {
  if (self = [super init]) {
    _targetClass = targetClass;
  }
  return self;
}

- (id)init {
  return [self initWithTargetClass:nil];
}

- (void)dealloc {
  [super dealloc];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// TTURLPattern

- (Class)classForInvocation {
  return _targetClass;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// public

- (void)compile {
  [self compileURL];

  for (id<TTURLPatternText> pattern in _path) {
    if ([pattern isKindOfClass:[TTURLWildcard class]]) {
      TTURLWildcard* wildcard = (TTURLWildcard*)pattern;
      [wildcard deduceSelectorForClass:_targetClass];
    }
  }

  for (id<TTURLPatternText> pattern in [_query objectEnumerator]) {
    if ([pattern isKindOfClass:[TTURLWildcard class]]) {
      TTURLWildcard* wildcard = (TTURLWildcard*)pattern;
      [wildcard deduceSelectorForClass:_targetClass];
    }
  }
}

- (NSString*)generateURLFromObject:(id)object {
  NSMutableArray* paths = [NSMutableArray array];
  NSMutableArray* queries = nil;
  [paths addObject:[NSString stringWithFormat:@"%@:/", _scheme]];

  for (id<TTURLPatternText> patternText in _path) {
    NSString* value = [patternText convertPropertyOfObject:object];
    [paths addObject:value];
  }

  for (NSString* name in [_query keyEnumerator]) {
    id<TTURLPatternText> patternText = [_query objectForKey:name];
    NSString* value = [patternText convertPropertyOfObject:object];
    NSString* pair = [NSString stringWithFormat:@"%@=%@", name, value];
    if (!queries) {
      queries = [NSMutableArray array];
    }
    [queries addObject:pair];
  }
  
  NSString* path = [paths componentsJoinedByString:@"/"];
  if (queries) {
    NSString* query = [queries componentsJoinedByString:@"&"];
    return [path stringByAppendingFormat:@"?%@", query];
  } else {
    return path;
  }
}

@end
