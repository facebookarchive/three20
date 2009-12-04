/**
 * Copyright 2009 Facebook
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#import "Three20/TTGlobal.h"
#import "Three20/TTURLMap.h"
#import "Three20/TTNavigator.h"

//////////////////////////////////////////////////////////////////////////////////////////////////

@interface TTMarkupStripper : NSObject {
  NSMutableArray* _strings;
}

- (NSString*)parse:(NSString*)string;

@end

@implementation TTMarkupStripper

//////////////////////////////////////////////////////////////////////////////////////////////////
// NSObject

- (id)init {
  if (self = [super init]) {
    _strings = nil;
  }
  return self;
}

- (void)dealloc {
  TT_RELEASE_SAFELY(_strings);
  [super dealloc];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// NSXMLParserDelegate

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
  [_strings addObject:string];
}

- (NSData *)parser:(NSXMLParser *)parser resolveExternalEntityName:(NSString *)entityName systemID:(NSString *)systemID {
  static NSDictionary* entityTable = nil;
  if (!entityTable) {
    // XXXjoe Gotta get a more complete set of entities
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
// public

- (NSString*)parse:(NSString*)text {
  _strings = [[NSMutableArray alloc] init];

  NSString* document = [NSString stringWithFormat:@"<x>%@</x>", text];
  NSData* data = [document dataUsingEncoding:text.fastestEncoding];
  NSXMLParser* parser = [[[NSXMLParser alloc] initWithData:data] autorelease];
  parser.delegate = self;
  [parser parse];
  
  return [_strings componentsJoinedByString:@""];
}

@end

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation NSString (TTCategory)

///////////////////////////////////////////////////////////////////////////////////////////////////
// public

- (BOOL)isWhitespace {
  NSCharacterSet* whitespace = [NSCharacterSet whitespaceAndNewlineCharacterSet];
  for (NSInteger i = 0; i < self.length; ++i) {
    unichar c = [self characterAtIndex:i];
    if (![whitespace characterIsMember:c]) {
      return NO;
    }
  }
  return YES;
}

- (BOOL)isEmptyOrWhitespace {
  return !self.length || 
         ![self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].length;
}

- (NSString*)stringByRemovingHTMLTags {
  TTMarkupStripper* stripper = [[[TTMarkupStripper alloc] init] autorelease];
  return [stripper parse:self];
}

// Copied and pasted from http://www.mail-archive.com/cocoa-dev@lists.apple.com/msg28175.html
- (NSDictionary*)queryDictionaryUsingEncoding:(NSStringEncoding)encoding {
  NSCharacterSet* delimiterSet = [NSCharacterSet characterSetWithCharactersInString:@"&;"];
  NSMutableDictionary* pairs = [NSMutableDictionary dictionary];
  NSScanner* scanner = [[[NSScanner alloc] initWithString:self] autorelease];
  while (![scanner isAtEnd]) {
    NSString* pairString = nil;
    [scanner scanUpToCharactersFromSet:delimiterSet intoString:&pairString];
    [scanner scanCharactersFromSet:delimiterSet intoString:NULL];
    NSArray* kvPair = [pairString componentsSeparatedByString:@"="];
    if (kvPair.count == 2) {
      NSString* key = [[kvPair objectAtIndex:0]
                       stringByReplacingPercentEscapesUsingEncoding:encoding];
      NSString* value = [[kvPair objectAtIndex:1]
                         stringByReplacingPercentEscapesUsingEncoding:encoding];
      [pairs setObject:value forKey:key];
    }
  }

  return [NSDictionary dictionaryWithDictionary:pairs];
}

- (NSString*)stringByAddingQueryDictionary:(NSDictionary*)query {
  NSMutableArray* pairs = [NSMutableArray array];
  for (NSString* key in [query keyEnumerator]) {
    NSString* value = [query objectForKey:key];
    value = [value stringByReplacingOccurrencesOfString:@"?" withString:@"%3F"];
    value = [value stringByReplacingOccurrencesOfString:@"=" withString:@"%3D"];
    NSString* pair = [NSString stringWithFormat:@"%@=%@", key, value];
    [pairs addObject:pair];
  }
  
  NSString* params = [pairs componentsJoinedByString:@"&"];
  if ([self rangeOfString:@"?"].location == NSNotFound) {
    return [self stringByAppendingFormat:@"?%@", params];
  } else {
    return [self stringByAppendingFormat:@"&%@", params];
  }
}

- (id)objectValue {
  return [[TTNavigator navigator].URLMap objectForURL:self];
}

- (void)openURL {
  [[TTNavigator navigator] openURL:self animated:YES];
}

- (void)openURLFromButton:(UIView*)button {
  NSDictionary* query = [NSDictionary dictionaryWithObjectsAndKeys:button, @"__target__", nil];
  [[TTNavigator navigator] openURL:self query:query animated:YES];
}

- (NSComparisonResult)versionStringCompare:(NSString *)other {
  NSArray *oneComponents = [self componentsSeparatedByString:@"a"];
  NSArray *twoComponents = [other componentsSeparatedByString:@"a"];

  // The parts before the "a"
  NSString *oneMain = [oneComponents objectAtIndex:0];
  NSString *twoMain = [twoComponents objectAtIndex:0];

  // If main parts are different, return that result, regardless of alpha part
  NSComparisonResult mainDiff;
  if ((mainDiff = [oneMain compare:twoMain]) != NSOrderedSame) {
    return mainDiff;
  }

  // At this point the main parts are the same; just deal with alpha stuff
  // If one has an alpha part and the other doesn't, the one without is newer
  if ([oneComponents count] < [twoComponents count]) {
    return NSOrderedDescending;
  } else if ([oneComponents count] > [twoComponents count]) {
    return NSOrderedAscending;
  } else if ([oneComponents count] == 1) {
    // Neither has an alpha part, and we know the main parts are the same
    return NSOrderedSame;
  }

  // At this point the main parts are the same and both have alpha parts. Compare the alpha parts
  // numerically. If it's not a valid number (including empty string) it's treated as zero.
  NSNumber *oneAlpha = [NSNumber numberWithInt:[[oneComponents objectAtIndex:1] intValue]];
  NSNumber *twoAlpha = [NSNumber numberWithInt:[[twoComponents objectAtIndex:1] intValue]];
  return [oneAlpha compare:twoAlpha];
}

@end
