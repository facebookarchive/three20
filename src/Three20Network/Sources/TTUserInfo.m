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

#import "Three20Network/TTUserInfo.h"

// Core
#import "Three20Core/TTCorePreprocessorMacros.h"


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation TTUserInfo

@synthesize topic     = _topic;
@synthesize strongRef = _strongRef;
@synthesize weakRef   = _weakRef;


///////////////////////////////////////////////////////////////////////////////////////////////////
+ (id)topic:(NSString*)topic strongRef:(id)strongRef weakRef:(id)weakRef {
  return [[[TTUserInfo alloc] initWithTopic:topic strongRef:strongRef weakRef:weakRef] autorelease];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
+ (id)topic:(NSString*)topic {
  return [[[TTUserInfo alloc] initWithTopic:topic strongRef:nil weakRef:nil] autorelease];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
+ (id)weakRef:(id)weakRef {
  return [[[TTUserInfo alloc] initWithTopic:nil strongRef:nil weakRef:weakRef] autorelease];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithTopic:(NSString*)topic strongRef:(id)strongRef weakRef:(id)weakRef {
	self = [super init];
  if (self) {
    self.topic      = topic;
    self.strongRef  = strongRef;
    self.weakRef    = weakRef;
  }
  return self;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)dealloc {
  TT_RELEASE_SAFELY(_topic);
  TT_RELEASE_SAFELY(_strongRef);
  [super dealloc];
}


@end
