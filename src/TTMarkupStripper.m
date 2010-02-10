//
// Copyright 2009-2010 Facebook
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

#import "Three20/TTMarkupStripper.h"

#import "Three20/TTGlobalCore.h"


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation TTMarkupStripper

///////////////////////////////////////////////////////////////////////////////////////////////////
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

- (NSData *)parser: (NSXMLParser *)parser
    resolveExternalEntityName: (NSString *)entityName
                     systemID: (NSString *)systemID {
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
