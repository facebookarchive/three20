#import "Three20/TTStyledTextParser.h"
#import "Three20/TTStyledTextNode.h"

//////////////////////////////////////////////////////////////////////////////////////////////////

@implementation TTStyledTextParser

@synthesize rootNode = _rootNode;

//////////////////////////////////////////////////////////////////////////////////////////////////
// private

- (void)addNode:(TTStyledTextNode*)node {
  if (!_rootNode) {
    _rootNode = [node retain];
  } else {
    _lastNode.nextNode = node;
  }
  _lastNode = node;
}

- (void)flushCharacters {
  if (_chars.length) {
    if (_openNode) {
      _openNode.text = _chars;
      _openNode = nil;
    } else if (1) {
      [self parseURLs:_chars];
    } else {
      TTStyledTextNode* node = [[[TTStyledTextNode alloc] initWithText:_chars] autorelease];
      [self addNode:node];
    }
  }
  
  [_chars release];
  _chars = nil;
}

//////////////////////////////////////////////////////////////////////////////////////////////////
// NSObject

- (id)init {
  if (self = [super init]) {
    _rootNode = nil;
    _openNode = nil;
    _lastNode = nil;
    _chars = nil;
  }
  return self;
}

- (void)dealloc {
  [_rootNode release];
  [_chars release];
  [super dealloc];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// NSXMLParserDelegate

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName
    namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qualifiedName
    attributes:(NSDictionary *)attributeDict {
  [self flushCharacters];

  NSString* tag = [elementName lowercaseString];
  if ([tag isEqualToString:@"b"]) {
    TTStyledBoldNode* node = [[[TTStyledBoldNode alloc] init] autorelease];
    [self addNode:node];
    if (_openNode) {
      // XXXjoe Merge styles
    } else {
      _openNode = node;
    }
  } else if ([tag isEqualToString:@"i"]) {
    TTStyledItalicNode* node = [[[TTStyledItalicNode alloc] init] autorelease];
    [self addNode:node];
    if (_openNode) {
      // XXXjoe Merge styles
    } else {
      _openNode = node;
    }
  } else if ([tag isEqualToString:@"a"]) {
    TTStyledLinkNode* node = [[[TTStyledLinkNode alloc] init] autorelease];
    node.url =  [attributeDict objectForKey:@"href"];

    [self addNode:node];
    if (_openNode) {
      // XXXjoe Merge styles
    } else {
      _openNode = node;
    }
  } else if ([tag isEqualToString:@"img"]) {
    TTStyledImageNode* node = [[[TTStyledImageNode alloc] init] autorelease];
    node.url =  [attributeDict objectForKey:@"src"];
    [self addNode:node];
  }
}
 
- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
  if (!_chars) {
    _chars = [string mutableCopy];
  } else {
    [_chars appendString:string];
  }
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName
    namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
  [self flushCharacters];
  _openNode = nil;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// public

- (void)parseXHTML:(NSString*)html {
  NSString* document = [NSString stringWithFormat:@"<x>%@</x>", html];
  NSData* data = [document dataUsingEncoding:html.fastestEncoding];
  NSXMLParser* parser = [[[NSXMLParser alloc] initWithData:data] autorelease];
  parser.delegate = self;
  [parser parse];
}

- (void)parseURLs:(NSString*)string {
  NSInteger index = 0;
  while (index < string.length) {
    NSRange searchRange = NSMakeRange(index, string.length - index);
    NSRange startRange = [string rangeOfString:@"http://" options:NSCaseInsensitiveSearch
                                 range:searchRange];
    if (startRange.location == NSNotFound) {
      NSString* text = [string substringWithRange:searchRange];
      TTStyledTextNode* node = [[[TTStyledTextNode alloc] initWithText:text] autorelease];
      [self addNode:node];
      break;
    } else {
      NSRange beforeRange = NSMakeRange(searchRange.location,
        startRange.location - searchRange.location);
      if (beforeRange.length) {
        NSString* text = [string substringWithRange:beforeRange];
        
        TTStyledTextNode* node = [[[TTStyledTextNode alloc] initWithText:text] autorelease];
        [self addNode:node];
      }

      NSRange searchRange = NSMakeRange(startRange.location, string.length - startRange.location);
      NSRange endRange = [string rangeOfString:@" " options:NSCaseInsensitiveSearch
                                 range:searchRange];
      if (endRange.location == NSNotFound) {
        NSString* url = [string substringWithRange:searchRange];
        TTStyledLinkNode* node = [[[TTStyledLinkNode alloc] initWithText:url] autorelease];
        node.url = url;
        [self addNode:node];
        break;
      } else {
        NSRange urlRange = NSMakeRange(startRange.location,
                                             endRange.location - startRange.location);
        NSString* url = [string substringWithRange:urlRange];
        TTStyledLinkNode* node = [[[TTStyledLinkNode alloc] initWithText:url] autorelease];
        node.url = url;
        [self addNode:node];
        index = endRange.location;
      }
    }
  }
}

@end
