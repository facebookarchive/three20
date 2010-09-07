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

#import "Three20UI/UINSObjectAdditions.h"

// UI
#import "Three20UI/TTNavigator.h"

// UINavigator
#import "Three20UINavigator/TTURLMap.h"
#import "Three20UINavigator/TTURLAction.h"


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
/**
 * Additions.
 */
@implementation NSObject (TTCategory)


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSString*)URLValue {
  return [[TTNavigator navigator].URLMap URLForObject:self];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSString*)URLValueWithName:(NSString*)name {
  return [[TTNavigator navigator].URLMap URLForObject:self withName:name];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (TTURLAction*)URLAction {
	TTURLAction *result = [TTURLAction actionWithURLPath:[[TTNavigator navigator].URLMap URLForObject:self]];
	[result applyAnimated:YES];
	[result applyQuery:[NSDictionary dictionaryWithObject:self forKey:@"object"]];
	return result;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (TTURLAction*)URLActionWithName:(NSString*)name {
	TTURLAction *result = [TTURLAction actionWithURLPath:[[TTNavigator navigator].URLMap URLForObject:self withName:name]];
	[result applyAnimated:YES];
	[result applyQuery:[NSDictionary dictionaryWithObject:self forKey:@"object"]];
	return result;
}


@end
