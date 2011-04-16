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
#import "Three20Core/TTCorePreprocessorMacros.h"
#import "Three20Core/TTLicenseInfo.h"
#import "Three20Core/TTExtensionAuthor.h"
#import "Three20Core/TTExtensionInfo.h"

TT_FIX_CATEGORY_BUG(TTExtensionLoader_TTJSONExtension)


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

  NSMutableArray* licenses = [NSMutableArray array];

  extension.name = @"Three20 JSON";
  extension.description = @"The JSON extension provides support for parsing json files and receiving JSON responses.";
  extension.version = @"1.0";

  [licenses addObject:[TTLicenseInfo licenseInfoWithLicense: TTLicenseApache2_0
                                          copyrightTimespan: @"2009-2011"
                                             copyrightOwner: @"Facebook"]];

#ifdef EXTJSON_SBJSON
  extension.website = @"http://code.google.com/p/json-framework/";
  extension.version = [extension.version stringByAppendingString:@" SBJSON 2.3.1"];

  [licenses addObject:[TTLicenseInfo licenseInfoWithLicense: TTLicenseBSDNew
                                          copyrightTimespan: @"2009-2010"
                                             copyrightOwner: @"Stig Brautaset"]];

#elif defined(EXTJSON_YAJL)
  extension.website = @"https://github.com/gabriel/yajl-objc";
  extension.version = [extension.version stringByAppendingString:@" YAJL 0.2.17"];

  [licenses addObject:[TTLicenseInfo licenseInfoWithLicense: TTLicenseMIT
                                          copyrightTimespan: @"2009"
                                             copyrightOwner: @"Gabriel Handford"]];
#endif

  extension.authors = [NSArray arrayWithObjects:
                       [TTExtensionAuthor authorWithName: @"Jeff Verkoeyen"
                                                  github: @"jverkoey"
                                                 twitter: @"featherless"
                                                 website: @"http://JeffVerkoeyen.com/"
                                                   email: @"jverkoey@gmail.com"],
                       nil];

  extension.licenses = licenses;

  return [extension autorelease];
}


@end

