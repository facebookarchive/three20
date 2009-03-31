#import "Three20/TTStyledTextNode.h"

//////////////////////////////////////////////////////////////////////////////////////////////////

@implementation TTStyledTextNode

@synthesize text = _text, nextNode = _nextNode;

//////////////////////////////////////////////////////////////////////////////////////////////////
// NSObject

- (id)initWithText:(NSString*)text {
  if (self = [self init]) {
    self.text = text;
  }
  return self;
}

- (id)initWithText:(NSString*)text next:(TTStyledTextNode*)nextNode {
  if (self = [self initWithText:text]) {
    self.nextNode = nextNode;
  }
  return self;
}

- (id)init {
  if (self = [super init]) {
    _text = nil;
    _nextNode = nil;
  }
  return self;
}

- (void)dealloc {
  [_text release];
  [_nextNode release];
  [super dealloc];
}

- (NSString*)description {
  return _text;
}


@end

//////////////////////////////////////////////////////////////////////////////////////////////////

@implementation TTStyledBoldNode

//////////////////////////////////////////////////////////////////////////////////////////////////
// NSObject

- (NSString*)description {
  return [NSString stringWithFormat:@"*%@*", _text];
}

@end

//////////////////////////////////////////////////////////////////////////////////////////////////

@implementation TTStyledLinkNode

@synthesize url = _url, highlighted = _highlighted;

//////////////////////////////////////////////////////////////////////////////////////////////////
// NSObject

- (id)init {
  if (self = [super init]) {
    _url = nil;
    _highlighted = NO;
  }
  return self;
}

- (void)dealloc {
  [_url release];
  [super dealloc];
}

- (NSString*)description {
  return [NSString stringWithFormat:@"<%@>", _text];
}

@end
