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

#import "Three20Core/Three20.h"

#import "Three20Core/Three20Version.h"


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation Three20


///////////////////////////////////////////////////////////////////////////////////////////////////
+ (NSInteger)majorVersion {
  return [[[Three20Version componentsSeparatedByString:@"."] objectAtIndex:0] intValue];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
+ (NSInteger)minorVersion {
  return [[[Three20Version componentsSeparatedByString:@"."] objectAtIndex:1] intValue];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
+ (NSInteger)bugfixVersion {
  return [[[Three20Version componentsSeparatedByString:@"."] objectAtIndex:2] intValue];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
+ (NSInteger)hotfixVersion {
  NSArray* components = [Three20Version componentsSeparatedByString:@"."];
  if ([components count] > 3) {
    return [[components objectAtIndex:3] intValue];

  } else {
    return 0;
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
+ (NSString*)version {
  return Three20Version;
}


@end
