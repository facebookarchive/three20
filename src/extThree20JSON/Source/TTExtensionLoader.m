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

#import "extThree20JSON/TTExtensionLoader.h"

// Core
#import "Three20Core/TTExtensionAuthor.h"
#import "Three20Core/TTExtensionInfo.h"


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation TTExtensionLoader (TTJSONExtension)


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)loadExtensionNamedThree20JSON {
  return YES;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (TTExtensionInfo*)extensionInfoNamedThree20JSON {
  TTExtensionInfo* extension = [[TTExtensionInfo alloc] init];

  extension.name = @"Three20 JSON";
  extension.description = @"The JSON extension provides support for parsing json files and receiving JSON responses.";
  extension.version = @"1.0";
  extension.copyright = @"Copyright 2009-2010 Facebook.";
  extension.license = @"Apache 2.0";
  extension.authors = [NSArray arrayWithObjects:
                       [TTExtensionAuthor authorWithName:@"Jeff Verkoeyen"],
                       nil];

#ifdef EXTJSON_SBJSON
  extension.version = [extension.version stringByAppendingString:@" SBJSON 2.3.1"];
  extension.copyright = [extension.copyright stringByAppendingString:@" 2009-2010 Stig Brautaset."];
#elif defined(EXTJSON_YAJL)
  extension.version = [extension.version stringByAppendingString:@" YAJL 1.0.11"];
  extension.copyright = [extension.copyright stringByAppendingString:@" 2009 Gabriel Handford. 2010 Lloyd Hilaiel."];
#endif

  return [extension autorelease];
}


@end

