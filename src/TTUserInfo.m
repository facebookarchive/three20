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

#import "Three20/TTUserInfo.h"

#import "Three20/TTCorePreprocessorMacros.h"


//////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////
@implementation TTUserInfo

@synthesize topic     = _topic;
@synthesize strongRef = _strongRef;
@synthesize weakRef   = _weakRef;


//////////////////////////////////////////////////////////////////////////////////////////////////
+ (id)topic:(NSString*)topic strong:(id)strong weak:(id)weak {
  return [[[TTUserInfo alloc] initWithTopic:topic strong:strong weak:weak] autorelease];
}


//////////////////////////////////////////////////////////////////////////////////////////////////
+ (id)topic:(NSString*)topic {
  return [[[TTUserInfo alloc] initWithTopic:topic strong:nil weak:nil] autorelease];
}


//////////////////////////////////////////////////////////////////////////////////////////////////
+ (id)weak:(id)weak {
  return [[[TTUserInfo alloc] initWithTopic:nil strong:nil weak:weak] autorelease];
}


//////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithTopic:(NSString*)topic strong:(id)strong weak:(id)weak {
  if (self = [super init]) {
    self.topic      = topic;
    self.strongRef  = strong;
    self.weakRef    = weak;
  }
  return self;
}


//////////////////////////////////////////////////////////////////////////////////////////////////
- (void)dealloc {
  TT_RELEASE_SAFELY(_topic);
  TT_RELEASE_SAFELY(_strongRef);
  [super dealloc];
}


@end
