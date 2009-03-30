#import "Three20/TTHTMLNode.h"

//////////////////////////////////////////////////////////////////////////////////////////////////

@implementation TTHTMLNode

@synthesize nextSibling = _nextSibling, firstChild = _firstChild;

//////////////////////////////////////////////////////////////////////////////////////////////////
// class public

+ (TTHTMLNode*)htmlFromXHTMLString:(NSString*)string {
  // XXXjoe HTML parser yet to be implemented
  return nil;
}

+ (TTHTMLNode*)htmlFromURLString:(NSString*)string {
  TTHTMLNode* rootNode = nil;
  TTHTMLNode* lastNode = nil;
  
  NSInteger index = 0;
  while (index < string.length) {
    NSRange searchRange = NSMakeRange(index, string.length - index);
    NSRange startRange = [string rangeOfString:@"http://" options:NSCaseInsensitiveSearch
                                 range:searchRange];
    if (startRange.location == NSNotFound) {
      NSString* text = [string substringWithRange:searchRange];
      TTHTMLText* node = [[[TTHTMLText alloc] initWithText:text] autorelease];
      if (lastNode) {
        lastNode.nextSibling = node;
      } else {
        rootNode = node;
      }
      lastNode = node;
      break;
    } else {
      NSRange beforeRange = NSMakeRange(searchRange.location,
        startRange.location - searchRange.location);
      if (beforeRange.length) {
        NSString* text = [string substringWithRange:beforeRange];

        TTHTMLText* node = [[[TTHTMLText alloc] initWithText:text] autorelease];
        if (lastNode) {
          lastNode.nextSibling = node;
        } else {
          rootNode = node;
        }
        lastNode = node;
      }

      NSRange searchRange = NSMakeRange(startRange.location, string.length - startRange.location);
      NSRange endRange = [string rangeOfString:@" " options:NSCaseInsensitiveSearch
                                 range:searchRange];
      if (endRange.location == NSNotFound) {
        NSString* url = [string substringWithRange:searchRange];
        TTHTMLLinkNode* node = [[[TTHTMLLinkNode alloc] initWithText:url] autorelease];
        if (lastNode) {
          lastNode.nextSibling = node;
        } else {
          rootNode = node;
        }
        lastNode = node;
        break;
      } else {
        NSRange urlRange = NSMakeRange(startRange.location,
                                             endRange.location - startRange.location);
        NSString* url = [string substringWithRange:urlRange];
        TTHTMLLinkNode* node = [[[TTHTMLLinkNode alloc] initWithText:url] autorelease];
        if (lastNode) {
          lastNode.nextSibling = node;
        } else {
          rootNode = node;
        }
        lastNode = node;
        index = endRange.location;
      }
    }
  }
  return rootNode;
}

//////////////////////////////////////////////////////////////////////////////////////////////////
// NSObject

- (id)init {
  if (self = [super init]) {
    _nextSibling = nil;
    _firstChild = nil;
  }
  return self;
}

- (void)dealloc {
  [_nextSibling release];
  [_firstChild release];
  [super dealloc];
}

- (NSString*)description {
  return [super description];
}

@end

//////////////////////////////////////////////////////////////////////////////////////////////////

@implementation TTHTMLText

@synthesize text = _text;

//////////////////////////////////////////////////////////////////////////////////////////////////
// NSObject

- (id)initWithText:(NSString*)text {
  if (self = [self init]) {
    self.text = text;
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

@end

//////////////////////////////////////////////////////////////////////////////////////////////////

@implementation TTHTMLBoldNode

//////////////////////////////////////////////////////////////////////////////////////////////////
// NSObject

- (NSString*)description {
  return [NSString stringWithFormat:@"*%@*", _text];
}

@end

//////////////////////////////////////////////////////////////////////////////////////////////////

@implementation TTHTMLLinkNode

@synthesize highlighted = _highlighted;

//////////////////////////////////////////////////////////////////////////////////////////////////
// NSObject

- (id)init {
  if (self = [super init]) {
    _highlighted = NO;
  }
  return self;
}

- (NSString*)description {
  return [NSString stringWithFormat:@"<%@>", _text];
}

@end
