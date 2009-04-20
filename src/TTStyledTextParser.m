#import "Three20/TTStyledTextParser.h"
#import "Three20/TTStyledNode.h"

//////////////////////////////////////////////////////////////////////////////////////////////////

@implementation TTStyledTextParser

@synthesize rootNode = _rootNode, parseLineBreaks = _parseLineBreaks, parseURLs = _parseURLs;

//////////////////////////////////////////////////////////////////////////////////////////////////
// private

- (void)addNode:(TTStyledNode*)node {
  if (!_rootNode) {
    _rootNode = [node retain];
    _lastNode = node;
  } else if (_topElement) {
    [_topElement addChild:node];
  } else {
    _lastNode.nextSibling = node;
    _lastNode = node;
  }
}

- (void)pushNode:(TTStyledElement*)element {
  if (!_stack) {
    _stack = [[NSMutableArray alloc] init];
  }

  [self addNode:element];
  [_stack addObject:element];
  _topElement = element;
}

- (void)popNode {
  TTStyledElement* element = [_stack lastObject];
  if (element) {
    [_stack removeLastObject];
  }

  _topElement = [_stack lastObject];
}

- (void)flushCharacters {
  if (_chars.length) {
    if (_parseLineBreaks) {
      NSCharacterSet* newLines = [NSCharacterSet newlineCharacterSet];
      NSInteger index = 0;
      NSInteger length = _chars.length;
      while (1) {
        NSRange searchRange = NSMakeRange(index, length - index);
        NSRange range = [_chars rangeOfCharacterFromSet:newLines options:0 range:searchRange];
        if (range.location != NSNotFound) {
          // Find all text before the line break and parse it
          NSRange textRange = NSMakeRange(index, range.location - index);
          NSString* substr = [_chars substringWithRange:textRange];
          [self parseURLs:substr];
          
          // Add a line break node after the text
          TTStyledLineBreakNode* br = [[[TTStyledLineBreakNode alloc] init] autorelease];
          [self addNode:br];

          index = index + substr.length + 1;
        } else {
          // Find all text until the end of hte string and parse it
          NSString* substr = [_chars substringFromIndex:index];
          [self parseURLs:substr];
          break;
        }
      }
    } else if (_parseURLs) {
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
    _topElement = nil;
    _lastNode = nil;
    _chars = nil;
    _stack = nil;
    _parseLineBreaks = NO;
    _parseURLs = YES;
  }
  return self;
}

- (void)dealloc {
  [_rootNode release];
  [_chars release];
  [_stack release];
  [super dealloc];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// NSXMLParserDelegate

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName
    namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qualifiedName
    attributes:(NSDictionary *)attributeDict {
  [self flushCharacters];

  NSString* tag = [elementName lowercaseString];
  if ([tag isEqualToString:@"span"]) {
    TTStyledInline* node = [[[TTStyledInline alloc] init] autorelease];
    node.className =  [attributeDict objectForKey:@"class"];
    [self pushNode:node];
  } else if ([tag isEqualToString:@"br"]) {
    TTStyledLineBreakNode* node = [[[TTStyledLineBreakNode alloc] init] autorelease];
    node.className =  [attributeDict objectForKey:@"class"];
    [self pushNode:node];
  } else if ([tag isEqualToString:@"div"] || [tag isEqualToString:@"p"]) {
    TTStyledBlock* node = [[[TTStyledBlock alloc] init] autorelease];
    node.className =  [attributeDict objectForKey:@"class"];
    [self pushNode:node];
  } else if ([tag isEqualToString:@"b"]) {
    TTStyledBoldNode* node = [[[TTStyledBoldNode alloc] init] autorelease];
    [self pushNode:node];
  } else if ([tag isEqualToString:@"i"]) {
    TTStyledItalicNode* node = [[[TTStyledItalicNode alloc] init] autorelease];
    [self pushNode:node];
  } else if ([tag isEqualToString:@"a"]) {
    TTStyledLinkNode* node = [[[TTStyledLinkNode alloc] init] autorelease];
    node.url =  [attributeDict objectForKey:@"href"];
    [self pushNode:node];
  } else if ([tag isEqualToString:@"button"]) {
    TTStyledButtonNode* node = [[[TTStyledButtonNode alloc] init] autorelease];
    node.url =  [attributeDict objectForKey:@"href"];
    [self pushNode:node];
  } else if ([tag isEqualToString:@"img"]) {
    TTStyledImageNode* node = [[[TTStyledImageNode alloc] init] autorelease];
    node.url =  [attributeDict objectForKey:@"src"];
    [self pushNode:node];
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
  [self popNode];
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
