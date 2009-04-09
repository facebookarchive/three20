#import "Three20/TTStyleSheet.h"
#import "Three20/TTDefaultStyleSheet.h"
#import "Three20/TTStyle.h"
#import "Three20/TTShape.h"

///////////////////////////////////////////////////////////////////////////////////////////////////
// global

static TTStyleSheet* gStyleSheet = nil;

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation TTStyleSheet

///////////////////////////////////////////////////////////////////////////////////////////////////
// class public

+ (TTStyleSheet*)globalStyleSheet {
  if (!gStyleSheet) {
    gStyleSheet = [[TTDefaultStyleSheet alloc] init];
  }
  return gStyleSheet;
}

+ (void)setGlobalStyleSheet:(TTStyleSheet*)styleSheet {
  [gStyleSheet release];
  gStyleSheet = [styleSheet retain];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// NSObject

- (id)init {
  if (self = [super init]) {
    _styles = nil;
  }
  return self;
}

- (void)dealloc {
  [_styles release];
  [super dealloc];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// public

- (TTStyle*)styleWithClassName:(NSString*)className {
  return [self styleWithClassName:className forState:UIControlStateNormal];
}

- (TTStyle*)styleWithClassName:(NSString*)className forState:(UIControlState)state {
  NSString* key = state == UIControlStateNormal
    ? className
    : [NSString stringWithFormat:@"%@%d", className, state];
  TTStyle* style = [_styles objectForKey:key];
  if (!style) {
    SEL selector = NSSelectorFromString(className);
    if ([self respondsToSelector:selector]) {
      style = [self performSelector:selector withObject:(id)state];
      if (style) {
        if (!_styles) {
          _styles = [[NSMutableDictionary alloc] init];
        }
        [_styles setObject:style forKey:key];
      }
    }
  }
  return style;
}

- (void)freeMemory {
  [_styles release];
  _styles = nil;
}

@end
