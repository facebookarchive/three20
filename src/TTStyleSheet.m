#import "Three20/TTStyleSheet.h"
#import "Three20/TTDefaultStyleSheet.h"

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

- (TTStyle*)styleWithSelector:(NSString*)selector {
  return [self styleWithSelector:selector forState:UIControlStateNormal];
}

- (TTStyle*)styleWithSelector:(NSString*)selector forState:(UIControlState)state {
  NSString* key = state == UIControlStateNormal
    ? selector
    : [NSString stringWithFormat:@"%@%d", selector, state];
  TTStyle* style = [_styles objectForKey:key];
  if (!style) {
    SEL sel = NSSelectorFromString(selector);
    if ([self respondsToSelector:sel]) {
      style = [self performSelector:sel withObject:(id)state];
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
