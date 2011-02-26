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

#import "Three20UINavigator/private/TTURLPatternInternal.h"

// Core
#import "Three20Core/TTCorePreprocessorMacros.h"


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
TT_FIX_CATEGORY_BUG(TTURLPatternInternal)

@implementation TTURLPattern (TTInternal)


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setSelectorWithNames:(NSArray*)names {
  NSString* selectorName = [[names componentsJoinedByString:@":"] stringByAppendingString:@":"];
  SEL selector = NSSelectorFromString(selectorName);
  [self setSelectorIfPossible:selector];
}


@end
