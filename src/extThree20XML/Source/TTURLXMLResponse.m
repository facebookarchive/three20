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

#import "extThree20XML/TTURLXMLResponse.h"

// extThree20XML
#import "extThree20XML/TTXMLParser.h"

// Core
#import "Three20Core/TTCorePreprocessorMacros.h"
#import "Three20Core/TTDebug.h"
#import "Three20Core/TTDebugFlags.h"


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation TTURLXMLResponse

@synthesize rootObject  = _rootObject;
@synthesize isRssFeed   = _isRssFeed;


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)dealloc {
  TT_RELEASE_SAFELY(_rootObject);

  [super dealloc];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark TTURLResponse


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSError*)request:(TTURLRequest*)request processResponse:(NSHTTPURLResponse*)response
            data:(id)data {
  // This response is designed for NSData objects, so if we get anything else it's probably a
  // mistake.
  TTDASSERT([data isKindOfClass:[NSData class]]);
  TTDASSERT(nil == _rootObject);

  if ([data isKindOfClass:[NSData class]]) {
    TTDCONDITIONLOG(TTDFLAG_XMLPARSER, @"Data: %@", [[[NSString alloc]
      initWithData: data
          encoding: NSUTF8StringEncoding] autorelease]);
    TTXMLParser* parser = [[TTXMLParser alloc] initWithData:data];
    parser.delegate = self;
    parser.treatDuplicateKeysAsArrayItems = self.isRssFeed;
    [parser parse];
    _rootObject = [parser.rootObject retain];
    TT_RELEASE_SAFELY(parser);
  }

  return nil;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)didParseXML:(id)rootObject {
  TTDASSERT(nil == _rootObject);

  [rootObject retain];
  [_rootObject release];
  _rootObject = rootObject;
}


@end
