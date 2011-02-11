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

#import "extThree20JSON/TTURLJSONResponse.h"

// extJSON
#import "extThree20JSON/TTErrorCodes.h"
#ifdef EXTJSON_SBJSON
#import "extThree20JSON/JSON.h"
#elif defined(EXTJSON_YAJL)
#import "extThree20JSON/NSObject+YAJL.h"
#endif

// Core
#import "Three20Core/TTCorePreprocessorMacros.h"
#import "Three20Core/TTDebug.h"


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation TTURLJSONResponse

@synthesize rootObject  = _rootObject;


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
  NSError* err = nil;
  if ([data isKindOfClass:[NSData class]]) {
#ifdef EXTJSON_SBJSON
    NSString* json = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    _rootObject = [[json JSONValue] retain];
    TT_RELEASE_SAFELY(json);
    if (!_rootObject) {
      err = [NSError errorWithDomain:kTTExtJSONErrorDomain
                                code:kTTExtJSONErrorCodeInvalidJSON
                            userInfo:nil];
    }
#elif defined(EXTJSON_YAJL)
    @try {
      _rootObject = [[data yajl_JSON] retain];
    }
    @catch (NSException* exception) {
      err = [NSError errorWithDomain:kTTExtJSONErrorDomain
                                code:kTTExtJSONErrorCodeInvalidJSON
                            userInfo:[exception userInfo]];
    }
#endif
  }

  return err;
}


@end

