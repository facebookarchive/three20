//
// Copyright 2009-2011 Facebook
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//    http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

#import "Three20Style/TTStyledTextParser.h"

// Style
#import "Three20Style/TTStyledElement.h"
#import "Three20Style/TTStyledTextNode.h"
#import "Three20Style/TTStyledInline.h"
#import "Three20Style/TTStyledBlock.h"
#import "Three20Style/TTStyledLineBreakNode.h"
#import "Three20Style/TTStyledBoldNode.h"
#import "Three20Style/TTStyledButtonNode.h"
#import "Three20Style/TTStyledLinkNode.h"
#import "Three20Style/TTStyledItalicNode.h"
#import "Three20Style/TTStyledImageNode.h"

// Core
#import "Three20Core/TTCorePreprocessorMacros.h"
#import "Three20Core/TTDebug.h"


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation TTStyledTextParser

@synthesize rootNode        = _rootNode;
@synthesize parseLineBreaks = _parseLineBreaks;
@synthesize parseURLs       = _parseURLs;


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)dealloc {
  TT_RELEASE_SAFELY(_rootNode);
  TT_RELEASE_SAFELY(_chars);
  TT_RELEASE_SAFELY(_stack);

  [super dealloc];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Private


///////////////////////////////////////////////////////////////////////////////////////////////////
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


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)pushNode:(TTStyledElement*)element {
  if (!_stack) {
    _stack = [[NSMutableArray alloc] init];
  }

  [self addNode:element];
  [_stack addObject:element];
  _topElement = element;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)popNode {
  TTStyledElement* element = [_stack lastObject];
  if (element) {
    [_stack removeLastObject];
  }

  _topElement = [_stack lastObject];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)flushCharacters {
  if (_chars.length) {
    [self parseText:_chars];
  }

  TT_RELEASE_SAFELY(_chars);
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)parseURLs:(NSString*)string {
  NSInteger stringIndex = 0;

  while (stringIndex < string.length) {
    NSRange searchRange = NSMakeRange(stringIndex, string.length - stringIndex);
    NSRange httpRange = [string rangeOfString:@"http://" options:NSCaseInsensitiveSearch
                                range:searchRange];
    NSRange httpsRange = [string rangeOfString:@"https://" options:NSCaseInsensitiveSearch
                                 range:searchRange];

    NSRange startRange;
    if (httpRange.location == NSNotFound) {
        startRange = httpsRange;

    } else if (httpsRange.location == NSNotFound) {
        startRange = httpRange;

    } else {
        startRange = (httpRange.location < httpsRange.location) ? httpRange : httpsRange;
    }

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

      NSRange subSearchRange = NSMakeRange(startRange.location,
                                           string.length - startRange.location);
      NSRange endRange = [string rangeOfString:@" " options:NSCaseInsensitiveSearch
                                 range:subSearchRange];
      if (endRange.location == NSNotFound) {
        NSString* URL = [string substringWithRange:subSearchRange];
        TTStyledLinkNode* node = [[[TTStyledLinkNode alloc] initWithText:URL] autorelease];
        node.URL = URL;
        [self addNode:node];
        break;

      } else {
        NSRange URLRange = NSMakeRange(startRange.location,
                                             endRange.location - startRange.location);
        NSString* URL = [string substringWithRange:URLRange];
        TTStyledLinkNode* node = [[[TTStyledLinkNode alloc] initWithText:URL] autorelease];
        node.URL = URL;
        [self addNode:node];
        stringIndex = endRange.location;
      }
    }
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark NSXMLParserDelegate


///////////////////////////////////////////////////////////////////////////////////////////////////
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

  } else if ([tag isEqualToString:@"b"] || [tag isEqualToString:@"strong"]) {
    TTStyledBoldNode* node = [[[TTStyledBoldNode alloc] init] autorelease];
    [self pushNode:node];

  } else if ([tag isEqualToString:@"i"] || [tag isEqualToString:@"em"]) {
    TTStyledItalicNode* node = [[[TTStyledItalicNode alloc] init] autorelease];
    [self pushNode:node];

  } else if ([tag isEqualToString:@"a"]) {
    TTStyledLinkNode* node = [[[TTStyledLinkNode alloc] init] autorelease];
    node.URL =  [attributeDict objectForKey:@"href"];
    node.className =  [attributeDict objectForKey:@"class"];
    [self pushNode:node];

  } else if ([tag isEqualToString:@"button"]) {
    TTStyledButtonNode* node = [[[TTStyledButtonNode alloc] init] autorelease];
    node.URL =  [attributeDict objectForKey:@"href"];
    [self pushNode:node];

  } else if ([tag isEqualToString:@"img"]) {
    TTStyledImageNode* node = [[[TTStyledImageNode alloc] init] autorelease];
    node.className =  [attributeDict objectForKey:@"class"];
    node.URL =  [attributeDict objectForKey:@"src"];
    NSString* width = [attributeDict objectForKey:@"width"];
    if (width) {
      node.width = width.floatValue;
    }
    NSString* height = [attributeDict objectForKey:@"height"];
    if (height) {
      node.height = height.floatValue;
    }
    [self pushNode:node];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
  if (!_chars) {
    _chars = [string mutableCopy];

  } else {
    [_chars appendString:string];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName
    namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
  [self flushCharacters];
  [self popNode];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSData *)          parser:(NSXMLParser *)parser
   resolveExternalEntityName:(NSString *)entityName
                    systemID:(NSString *)systemID {
  static NSDictionary* entityTable = nil;
  if (!entityTable) {
    entityTable = [[NSDictionary alloc] initWithObjectsAndKeys:
      [NSData dataWithBytes:" " length:1], @"nbsp",
      [NSData dataWithBytes:"&" length:1], @"amp",
      [NSData dataWithBytes:"\"" length:1], @"quot",
      [NSData dataWithBytes:"<" length:1], @"lt",
      [NSData dataWithBytes:">" length:1], @"gt",
      nil];
  }
  return [entityTable objectForKey:entityName];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)parseText:(NSString*)string URLs:(BOOL)shouldParseURLs {
  if (shouldParseURLs) {
    [self parseURLs:string];
  }
  else {
    TTStyledTextNode* node = [[[TTStyledTextNode alloc] initWithText:string] autorelease];
    [self addNode:node];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Public


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)parseXHTML:(NSString*)html {
  NSString* document = [NSString stringWithFormat:@"<x>%@</x>", html];
  NSData* data = [document dataUsingEncoding:html.fastestEncoding];
  NSXMLParser* parser = [[[NSXMLParser alloc] initWithData:data] autorelease];
  parser.delegate = self;
  [parser parse];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)parseText:(NSString*)string {
  if (_parseLineBreaks) {
    NSCharacterSet* newLines = [NSCharacterSet newlineCharacterSet];
    NSInteger stringIndex = 0;
    NSInteger length = string.length;

    while (1) {
      NSRange searchRange = NSMakeRange(stringIndex, length - stringIndex);
      NSRange range = [string rangeOfCharacterFromSet:newLines options:0 range:searchRange];
      if (range.location != NSNotFound) {
        // Find all text before the line break and parse it
        NSRange textRange = NSMakeRange(stringIndex, range.location - stringIndex);
        NSString* substr = [string substringWithRange:textRange];
        [self parseText:substr URLs:_parseURLs];

        // Add a line break node after the text
        TTStyledLineBreakNode* br = [[[TTStyledLineBreakNode alloc] init] autorelease];
        [self addNode:br];

        stringIndex = stringIndex + substr.length + 1;

      }
      else {
        // Find all text until the end of hte string and parse it
        NSString* substr = [string substringFromIndex:stringIndex];
        [self parseText:substr URLs:_parseURLs];
        break;
      }
    }

  }
  else {
    [self parseText:string URLs:_parseURLs];
  }
}


@end
