#import "Three20/TTStyledNode.h"
#import "Three20/TTURLCache.h"
#import "Three20/TTNavigationCenter.h"

//////////////////////////////////////////////////////////////////////////////////////////////////

@implementation TTStyledNode

@synthesize nextSibling = _nextSibling, parentNode = _parentNode;

//////////////////////////////////////////////////////////////////////////////////////////////////
// private

- (TTStyledNode*)findLastSibling:(TTStyledNode*)sibling {
  while (sibling) {
    if (!sibling.nextSibling) {
      return sibling;
    }
    sibling = sibling.nextSibling;
  }
  return nil;
}

//////////////////////////////////////////////////////////////////////////////////////////////////
// NSObject

- (id)initWithNextSibling:(TTStyledNode*)nextSibling {
  if (self = [self init]) {
    self.nextSibling = nextSibling;
  }
  return self;
}

- (id)init {
  if (self = [super init]) {
    _parentNode = nil;
    _nextSibling = nil;
  }
  return self;
}

- (void)dealloc {
  [_nextSibling release];
  [super dealloc];
}

//////////////////////////////////////////////////////////////////////////////////////////////////
// public

- (void)setNextSibling:(TTStyledNode*)node {
  if (node != _nextSibling) {
    [_nextSibling release];
    _nextSibling = [node retain];
    node.parentNode = _parentNode;
  }
}

- (NSString*)outerText {
  if (_nextSibling) {
    return _nextSibling.outerText;
  } else {
    return @"";
  }
}

- (NSString*)outerHTML {
  if (_nextSibling) {
    return _nextSibling.outerHTML;
  } else {
    return @"";
  }
}

- (id)firstParentOfClass:(Class)cls {
  if ([self isKindOfClass:cls]) {
    return self;
  } else {
    return [_parentNode firstParentOfClass:cls];
  }
}

- (void) performDefaultAction {
}

@end

//////////////////////////////////////////////////////////////////////////////////////////////////

@implementation TTStyledTextNode

@synthesize text = _text;

//////////////////////////////////////////////////////////////////////////////////////////////////
// NSObject

- (id)initWithText:(NSString*)text {
  if (self = [self init]) {
    self.text = text;
  }
  return self;
}

- (id)initWithText:(NSString*)text next:(TTStyledNode*)nextSibling {
  if (self = [self initWithText:text]) {
    self.nextSibling = nextSibling;
  }
  return self;
}

- (id)init {
  if (self = [super init]) {
    _text = nil;
  }
  return self;
}

- (void)dealloc {
  [_text release];
  [super dealloc];
}

- (NSString*)description {
  return _text;
}

//////////////////////////////////////////////////////////////////////////////////////////////////
// TTStyledNode

- (NSString*)outerText {
  if (_nextSibling) {
    return [NSString stringWithFormat:@"%@%@", _text, _nextSibling.outerText];
  } else {
    return _text;
  }
}

- (NSString*)outerHTML {
  if (_nextSibling) {
    return [NSString stringWithFormat:@"%@%@", _text, _nextSibling.outerHTML];
  } else {
    return _text;
  }
}

@end

//////////////////////////////////////////////////////////////////////////////////////////////////

@implementation TTStyledElement

@synthesize firstChild = _firstChild, lastChild = _lastChild, className = _className;

//////////////////////////////////////////////////////////////////////////////////////////////////
// NSObject

- (id)initWithText:(NSString*)text {
  if (self = [self init]) {
    [self addChild:[[[TTStyledTextNode alloc] initWithText:text] autorelease]];
  }
  return self;
}

- (id)initWithText:(NSString*)text next:(TTStyledNode*)nextSibling {
  if (self = [super initWithNextSibling:nextSibling]) {
    [self addChild:[[[TTStyledTextNode alloc] initWithText:text] autorelease]];
  }
  return self;
}

- (id)init {
  if (self = [super init]) {
    _firstChild = nil;
    _lastChild = nil;
    _className = nil;
  }
  return self;
}

- (void)dealloc {
  [_firstChild release];
  [_className release];
  [super dealloc];
}

- (NSString*)description {
  return [NSString stringWithFormat:@"%@", _firstChild];
}

//////////////////////////////////////////////////////////////////////////////////////////////////
// TTStyledNode

- (NSString*)outerText {
  if (_firstChild && _nextSibling) {
    return [NSString stringWithFormat:@"%@%@", _firstChild.outerText, _nextSibling.outerText];
  } else if (_firstChild) {
    return _firstChild.outerText;
  } else if (_nextSibling) {
    return _nextSibling.outerText;
  } else {
    return @"";
  }
}

- (NSString*)outerHTML {
  NSString* html = nil;
  if (_firstChild) {
    html = [NSString stringWithFormat:@"<div>%@</div>", _firstChild.outerHTML];
  } else {
    html = @"<div/>";
  }
  if (_nextSibling) {
    return [NSString stringWithFormat:@"%@%@", html, _nextSibling.outerHTML];
  } else {
    return html;
  }
}

//////////////////////////////////////////////////////////////////////////////////////////////////
// public

- (void)addChild:(TTStyledNode*)child {
  if (!_firstChild) {
    _firstChild = [child retain];
    _lastChild = [self findLastSibling:child];
  } else {
    _lastChild.nextSibling = child;
    _lastChild = [self findLastSibling:child];
  }
  child.parentNode = self;
}

- (void)addText:(NSString*)text {
  [self addChild:[[[TTStyledTextNode alloc] initWithText:text] autorelease]];
}

- (void)replaceChild:(TTStyledNode*)oldChild withChild:(TTStyledNode*)newChild {
  if (oldChild == _firstChild) {
    newChild.nextSibling = oldChild.nextSibling;
    oldChild.nextSibling = nil;
    newChild.parentNode = self;
    if (oldChild == _lastChild) {
      _lastChild = newChild;
    }
    [_firstChild release];
    _firstChild = [newChild retain];
  } else {
    TTStyledNode* node = _firstChild;
    while (node) {
      if (node.nextSibling == oldChild) {
        [oldChild retain];
        if (newChild) {
          newChild.nextSibling = oldChild.nextSibling;
          node.nextSibling = newChild;
        } else {
          node.nextSibling = oldChild.nextSibling;
        }
        oldChild.nextSibling = nil;
        newChild.parentNode = self;
        if (oldChild == _lastChild) {
          _lastChild = newChild ? newChild : node;
        }
        [oldChild release];
        break;
      }
      node = node.nextSibling;
    }
  }
}

- (TTStyledNode*)getElementByClassName:(NSString*)className {
  TTStyledNode* node = _firstChild;
  while (node) {
    if ([node isKindOfClass:[TTStyledElement class]]) {
      TTStyledElement* element = (TTStyledElement*)node;
      if ([element.className isEqualToString:className]) {
        return element;
      }

      TTStyledNode* found = [element getElementByClassName:className];
      if (found) {
        return found;
      }
    }
    node = node.nextSibling;
  }
  return nil;
}

@end

//////////////////////////////////////////////////////////////////////////////////////////////////

@implementation TTStyledBlock
@end

//////////////////////////////////////////////////////////////////////////////////////////////////

@implementation TTStyledInline
@end

//////////////////////////////////////////////////////////////////////////////////////////////////

@implementation TTStyledInlineBlock
@end

//////////////////////////////////////////////////////////////////////////////////////////////////

@implementation TTStyledBoldNode

//////////////////////////////////////////////////////////////////////////////////////////////////
// NSObject

- (NSString*)description {
  return [NSString stringWithFormat:@"*%@*", _firstChild];
}

@end

//////////////////////////////////////////////////////////////////////////////////////////////////

@implementation TTStyledItalicNode

//////////////////////////////////////////////////////////////////////////////////////////////////
// NSObject

- (NSString*)description {
  return [NSString stringWithFormat:@"/%@/", _firstChild];
}

@end

//////////////////////////////////////////////////////////////////////////////////////////////////

@implementation TTStyledLinkNode

@synthesize url = _url, highlighted = _highlighted;

//////////////////////////////////////////////////////////////////////////////////////////////////
// NSObject

- (id)initWithURL:(NSString*)url {
  if (self = [self init]) {
    self.url = url;
  }
  return self;
}

- (id)initWithURL:(NSString*)url next:(TTStyledNode*)nextSibling {
  if (self = [super initWithNextSibling:nextSibling]) {
    self.url = url;
  }
  return self;
}

- (id)initWithText:(NSString*)text url:(NSString*)url next:(TTStyledNode*)nextSibling {
  if (self = [super initWithNextSibling:nextSibling]) {
    self.url = url;
    [self addChild:[[[TTStyledTextNode alloc] initWithText:text] autorelease]];
  }
  return self;
}

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
  return [NSString stringWithFormat:@"<%@>", _firstChild];
}

//////////////////////////////////////////////////////////////////////////////////////////////////
// TTStyledElement

- (void) performDefaultAction {
  if (_url) {
    [[TTNavigationCenter defaultCenter] displayURL:_url];
  }
}

@end

//////////////////////////////////////////////////////////////////////////////////////////////////

@implementation TTStyledButtonNode

@synthesize url = _url, highlighted = _highlighted;

//////////////////////////////////////////////////////////////////////////////////////////////////
// NSObject

- (id)initWithURL:(NSString*)url {
  if (self = [self init]) {
    self.url = url;
  }
  return self;
}

- (id)initWithURL:(NSString*)url next:(TTStyledNode*)nextSibling {
  if (self = [super initWithNextSibling:nextSibling]) {
    self.url = url;
  }
  return self;
}

- (id)initWithText:(NSString*)text url:(NSString*)url next:(TTStyledNode*)nextSibling {
  if (self = [super initWithNextSibling:nextSibling]) {
    self.url = url;
    [self addChild:[[[TTStyledTextNode alloc] initWithText:text] autorelease]];
  }
  return self;
}

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
  return [NSString stringWithFormat:@"<%@>", _firstChild];
}

//////////////////////////////////////////////////////////////////////////////////////////////////
// TTStyledElement

- (void) performDefaultAction {
  if (_url) {
    [[TTNavigationCenter defaultCenter] displayURL:_url];
  }
}

@end

//////////////////////////////////////////////////////////////////////////////////////////////////

@implementation TTStyledImageNode

@synthesize url = _url, image = _image, defaultImage = _defaultImage, width = _width,
            height = _height;

//////////////////////////////////////////////////////////////////////////////////////////////////
// NSObject

- (id)initWithURL:(NSString*)url {
  if (self = [super init]) {
    self.url = url;
  }
  return self;
}

- (id)init {
  if (self = [super init]) {
    _url = nil;
    _image = nil;
    _defaultImage = nil;
    _width = 0;
    _height = 0;
  }
  return self;
}

- (void)dealloc {
  [_url release];
  [_image release];
  [super dealloc];
}

- (NSString*)description {
  return [NSString stringWithFormat:@"(%@)", _url];
}

//////////////////////////////////////////////////////////////////////////////////////////////////
// TTStyledNode

- (NSString*)outerHTML {
  NSString* html = [NSString stringWithFormat:@"<img src=\"%@\"/>", _url];
  if (_nextSibling) {
    return [NSString stringWithFormat:@"%@%@", html, _nextSibling.outerHTML];
  } else {
    return html;
  }
}

//////////////////////////////////////////////////////////////////////////////////////////////////
// public

- (void)setUrl:(NSString*)url {
  if (!_url || ![url isEqualToString:_url]) {
    [_url release];
    _url = [url retain];

    if (_url) {
      self.image = [[TTURLCache sharedCache] imageForURL:_url];
    } else {
      self.image = nil;
    }
  }
}

@end

//////////////////////////////////////////////////////////////////////////////////////////////////

@implementation TTStyledLineBreakNode
@end
