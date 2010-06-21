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

#import "Three20Core/TTMarkupStripper.h"

// Core
#import "Three20Core/TTCorePreprocessorMacros.h"
#import "Three20Core/TTEntityTables.h"


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation TTMarkupStripper


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)dealloc {
  TT_RELEASE_SAFELY(_strings);

  [super dealloc];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark NSXMLParserDelegate


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)parser:(NSXMLParser*)parser foundCharacters:(NSString*)string {
  [_strings addObject:string];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSData*)             parser: (NSXMLParser*)parser
     resolveExternalEntityName: (NSString*)entityName
                      systemID: (NSString*)systemID {
  return [[[TTEntityTables sharedInstance] iso88591] objectForKey:entityName];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Public


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSString*)parse:(NSString*)text {
  _strings = [[NSMutableArray alloc] init];

  NSString*     document  = [NSString stringWithFormat:@"<x>%@</x>", text];
  NSData*       data      = [document dataUsingEncoding:text.fastestEncoding];
  NSXMLParser*  parser    = [[NSXMLParser alloc] initWithData:data];
  parser.delegate = self;
  [parser parse];
  TT_RELEASE_SAFELY(parser);

  NSString* result = [_strings componentsJoinedByString:@""];
  TT_RELEASE_SAFELY(_strings);

  return result;
}


@end
