#import "TTURLPattern.h"
#import <objc/runtime.h>

///////////////////////////////////////////////////////////////////////////////////////////////////
// global

static NSString* kUniversalURLPattern = @"*";

///////////////////////////////////////////////////////////////////////////////////////////////////

typedef enum {
  TTURLArgumentTypePointer,
  TTURLArgumentTypeBool,
  TTURLArgumentTypeInteger,
  TTURLArgumentTypeLongLong,
  TTURLArgumentTypeFloat,
  TTURLArgumentTypeDouble,
} TTURLArgumentType;

///////////////////////////////////////////////////////////////////////////////////////////////////

@protocol TTURLPatternText <NSObject>

- (BOOL)match:(NSString*)text;

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
  TT_RELEASE_MEMBER(_name);
  [super dealloc];
}

- (BOOL)match:(NSString*)text {
  return [text isEqualToString:_name];
}

@end

///////////////////////////////////////////////////////////////////////////////////////////////////

@interface TTURLWildcard : NSObject <TTURLPatternText> {
  NSString* _name;
  NSInteger _argIndex;
  TTURLArgumentType _argType;
}

@property(nonatomic,copy) NSString* name;
@property(nonatomic) NSInteger argIndex;
@property(nonatomic) TTURLArgumentType argType;

@end

@implementation TTURLWildcard

@synthesize name = _name, argIndex = _argIndex, argType = _argType;

- (id)init {
  if (self = [super init]) {
    _name = nil;
    _argIndex = NSNotFound;
    _argType = TTURLArgumentTypePointer;
  }
  return self;
}

- (void)dealloc {
  TT_RELEASE_MEMBER(_name);
  [super dealloc];
}

- (BOOL)match:(NSString*)text {
  return YES;
}

@end

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation TTURLPattern

@synthesize openMode = _openMode, URL = _URL, parentURL = _parentURL,
            targetObject = _targetObject, targetClass = _targetClass, selector = _selector,
            specificity = _specificity, argumentCount = _argumentCount;

///////////////////////////////////////////////////////////////////////////////////////////////////
// private

- (id<TTURLPatternText>)parseText:(NSString*)text {
  NSInteger len = text.length;
  if (len && [text characterAtIndex:0] == '(' && [text characterAtIndex:len-1] == ')') {
    NSString* name = [text substringWithRange:NSMakeRange(1, len-2)];
    TTURLWildcard* wildcard = [[[TTURLWildcard alloc] init] autorelease];
    wildcard.name = name;
    ++_specificity;
    return wildcard;
  } else {
    TTURLLiteral* literal = [[[TTURLLiteral alloc] init] autorelease];
    literal.name = text;
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

- (TTURLArgumentType)convertArgumentType:(char*)argType {
  if (strcmp(argType, "c") == 0
      || strcmp(argType, "i") == 0
      || strcmp(argType, "s") == 0
      || strcmp(argType, "l") == 0
      || strcmp(argType, "C") == 0
      || strcmp(argType, "I") == 0
      || strcmp(argType, "S") == 0
      || strcmp(argType, "L") == 0) {
    return TTURLArgumentTypeInteger;
  } else if (strcmp(argType, "q") == 0 || strcmp(argType, "Q") == 0) {
    return TTURLArgumentTypeLongLong;
  } else if (strcmp(argType, "f") == 0) {
    return TTURLArgumentTypeFloat;
  } else if (strcmp(argType, "d") == 0) {
    return TTURLArgumentTypeDouble;
  } else if (strcmp(argType, "B") == 0) {
    return TTURLArgumentTypeBool;
  } else {
    return TTURLArgumentTypePointer;
  }
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

- (void)analyzeMethod {
  if (_selector) {
    Class cls = _targetClass ? _targetClass : [_targetObject class];
    Method method = class_getInstanceMethod(cls, _selector);
    if (method) {
      _argumentCount = method_getNumberOfArguments(method)-2;

      // Look up the index and type of each argument in the method
      NSString* selectorName = [NSString stringWithCString:sel_getName(_selector)];
      NSArray* argNames = [selectorName componentsSeparatedByString:@":"];

      for (id<TTURLPatternText> pattern in _path) {
        if ([pattern isKindOfClass:[TTURLWildcard class]]) {
          TTURLWildcard* wildcard = (TTURLWildcard*)pattern;
          wildcard.argIndex = [argNames indexOfObject:wildcard.name];
          if (wildcard.argIndex == NSNotFound) {
            TTWARN(@"Argument %@ not found in @selector(%s)", wildcard.name, sel_getName(_selector));
          } else {
            char argType[256];
            method_getArgumentType(method, wildcard.argIndex+2, argType, 256);
            wildcard.argType = [self convertArgumentType:argType];
          }
        }
      }

      for (id<TTURLPatternText> pattern in [_query objectEnumerator]) {
        if ([pattern isKindOfClass:[TTURLWildcard class]]) {
          TTURLWildcard* wildcard = (TTURLWildcard*)pattern;
          wildcard.argIndex = [argNames indexOfObject:wildcard.name];
          if (wildcard.argIndex == NSNotFound) {
            TTWARN(@"Argument %@ not found in @selector(%s)", wildcard.name, sel_getName(_selector));
          } else {
            char argType[256];
            method_getArgumentType(method, wildcard.argIndex+2, argType, 256);
            wildcard.argType = [self convertArgumentType:argType];
          }
        }
      }
    }
  }
}

- (void)parseURL {
  if (![_URL isEqualToString:kUniversalURLPattern]) {
    NSURL* theURL = [NSURL URLWithString:_URL];
      
    _scheme = [theURL.scheme copy];
    if (theURL.host) {
      [self parsePathComponent:theURL.host];
      if (theURL.path) {
        for (NSString* name in theURL.path.pathComponents) {
          if (![name isEqualToString:@"/"]) {
            [self parsePathComponent:name];
          }
        }
      }
    }
    
    if (theURL.query) {
      NSDictionary* query = [theURL.query queryDictionaryUsingEncoding:NSUTF8StringEncoding];
      for (NSString* name in [query keyEnumerator]) {
        NSString* value = [query objectForKey:name];
        [self parseParameter:name value:value];
      }
    }
    
    [self analyzeMethod];
  }
}

- (BOOL)setArgument:(NSString*)text pattern:(id<TTURLPatternText>)patternText
        forInvocation:(NSInvocation*)invocation {
  if ([patternText isKindOfClass:[TTURLWildcard class]]) {
    TTURLWildcard* wildcard = (TTURLWildcard*)patternText;
    NSInteger index = wildcard.argIndex;
    if (index != NSNotFound) {
      switch (wildcard.argType) {
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

///////////////////////////////////////////////////////////////////////////////////////////////////
// NSObject

- (id)initWithType:(TTOpenMode)openMode {
  if (self = [self init]) {
    _openMode = openMode;
  }
  return self;
}

- (id)init {
  if (self = [super init]) {
    _openMode = TTOpenModeNone;
    _scheme = nil;
    _path = [[NSMutableArray alloc] init];
    _query = nil;
    _selector = nil;
    _targetObject = nil;
    _targetClass = nil;
    _argumentCount = 0;
    _specificity = 0;
  }
  return self;
}

- (void)dealloc {
  TT_RELEASE_MEMBER(_parentURL);
  TT_RELEASE_MEMBER(_scheme);
  TT_RELEASE_MEMBER(_path);
  TT_RELEASE_MEMBER(_query);
  [super dealloc];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// public

- (void)setURL:(NSString*)URL {
  [_URL release];
  _URL = [URL retain];
  [self parseURL];
}

- (BOOL)isUniversal {
  return [_URL isEqualToString:kUniversalURLPattern];
}

- (void)setTargetOrClass:(id)target {
  if ([target class] == target) {
    _targetClass = target;
  } else {
    _targetObject = target;
  }
}

- (BOOL)matchURL:(NSURL*)URL {
  if (![_scheme isEqualToString:URL.scheme] || !URL.host) {
    return NO;
  }

  NSArray* pathComponents = URL.path.pathComponents;
  NSInteger componentCount = URL.path.length ? pathComponents.count : 1;
  if (componentCount != _path.count) {
    return NO;
  }

  id<TTURLPatternText>hostPattern = [_path objectAtIndex:0];
  if (![hostPattern match:URL.host]) {
    return NO;
  }
  
  for (NSInteger i = 1; i < _path.count; ++i) {
    id<TTURLPatternText>pathPattern = [_path objectAtIndex:i];
    NSString* pathText = [pathComponents objectAtIndex:i];
    if (![pathPattern match:pathText]) {
      return NO;
    }
  }

  return YES;
}

- (void)setArgumentsFromURL:(NSURL*)URL forInvocation:(NSInvocation*)invocation {
  NSInteger remainingArguments = _argumentCount;
  
  NSArray* pathComponents = URL.path.pathComponents;
  for (NSInteger i = 0; i < _path.count; ++i) {
    id<TTURLPatternText> patternText = [_path objectAtIndex:i];
    NSString* text = i == 0 ? URL.host : [pathComponents objectAtIndex:i];
    if ([self setArgument:text pattern:patternText forInvocation:invocation]) {
      --remainingArguments;
    }
  }
  
  NSDictionary* query = [URL.query queryDictionaryUsingEncoding:NSUTF8StringEncoding];
  if (query.count) {
    NSMutableDictionary* unmatched = nil;

    for (NSString* name in [query keyEnumerator]) {
      id<TTURLPatternText> patternText = [_query objectForKey:name];
      NSString* text = [query objectForKey:name];
      if (patternText) {
        if ([self setArgument:text pattern:patternText forInvocation:invocation]) {
          --remainingArguments;
        }
      } else {
        if (!unmatched) {
          unmatched = [NSMutableDictionary dictionary];
        }
        [unmatched setObject:text forKey:name];
      }
    }
    
    if (remainingArguments && unmatched.count) {
      // If there are unmatched arguments, and the method signature has extra arguments,
      // then pass the dictionary of unmatched arguments as the last argument
      [invocation setArgument:&unmatched atIndex:_argumentCount+1];
    }
  }
}

@end

