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

#import "extThree20GridView/TTExtensionLoader.h"

// Core
#import "Three20Core/TTExtensionAuthor.h"
#import "Three20Core/TTExtensionInfo.h"


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation TTExtensionLoader (TTCSSStyleExtension)


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)loadExtensionNamedThree20CSSStyle {
  return YES;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (TTExtensionInfo*)extensionInfoNamedThree20CSSStyle {
  TTExtensionInfo* extension = [[TTExtensionInfo alloc] init];

  extension.name = @"Three20 Grid View";
  extension.description = @"Missing.";
  extension.version = @"1.0";
  extension.copyright = @"--";
  extension.license = @"Apache 2.0";
  extension.authors = [NSArray arrayWithObjects:
                       [TTExtensionAuthor authorWithName:@"Paulo Oliveira"],
                       nil];

  return [extension autorelease];
}


@end

