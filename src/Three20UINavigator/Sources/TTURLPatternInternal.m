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


#import "Three20UINavigator/TTURLPatternInternal.h"
#import "Three20UINavigator/TTURLWildcard.h"

#import "Three20UINavigator/private/TTURLPatternInternal.h"

// Core
#import "Three20Core/TTCorePreprocessorMacros.h"



///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
TT_FIX_CATEGORY_BUG(TTURLPatternInternal)

@implementation TTURLPattern (TTInternal)


///////////////////////////////////////////////////////////////////////////////////////////////////
//
//- (void)setSelectorWithNames:(NSArray*)names {
//  NSString* selectorName = [[names componentsJoinedByString:@":"] stringByAppendingString:@":"];
//  SEL selector = NSSelectorFromString(selectorName);
//  [self setSelectorIfPossible:selector];
//}
///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setSelectorWithNames:(NSArray*)names {
    //NSLog(@"    Names: %@", names);
    //NSLog(@"    Names components joined by string: %@", [names componentsJoinedByString:@":"]);
    //NSLog(@"    Names components joined by string with appending: %@",
    //[[names componentsJoinedByString:@":"] stringByAppendingString:@":"]);

	//	NSString* aselectorName = [[names componentsJoinedByString:@":"] stringByAppendingString:@":"];
	//	SEL aselector = NSSelectorFromString(aselectorName);
	//	[self setSelectorIfPossible:aselector];
	//	return;

	NSMutableArray *orderedNames = [NSMutableArray array];
	//NSLog(@"queryKeyOrder: %@", self.queryKeyOrder);
	for (NSString *orderedQueryKey in self.queryKeyOrder) {
		TTURLWildcard *wildcard = [_query objectForKey:orderedQueryKey];
		NSString *orderedQueryValue = wildcard.name;
		//NSLog(@"  looking at %@ (for key %@)", orderedQueryValue, orderedQueryKey);
		if ([names containsObject:orderedQueryValue]) {
			//NSLog(@"  Adding %@", orderedQueryValue);
			[orderedNames addObject:orderedQueryValue];
		}
	}

	if ([orderedNames count] > 0 && [names containsObject:@"query"]) {
		[orderedNames addObject:@"query"];
	}

	//NSLog(@"names: %@", names);
//	NSLog(@"orderedNames: %@", orderedNames);
	NSString* selectorName = nil;
	if ([orderedNames count] > 0){
		selectorName = [[orderedNames componentsJoinedByString:@":"] stringByAppendingString:@":"];
	}else {
		selectorName = [[names componentsJoinedByString:@":"] stringByAppendingString:@":"];
	}
	SEL selector = NSSelectorFromString(selectorName);

	[self setSelectorIfPossible:selector];
	if (!_selector) {
		//NSLog(@"  COULD NOT SET SELECTOR - !!!!!!!!!!!!!!!");
		// This is still happening sometimes, I'm not sure why. Everything seems fine.
		//NSLog(@"  COULD NOT SET SELECTOR - !!!!!!!!!!!!!!!");
		//NSLog(@"  !!!!! selector: %@", NSStringFromSelector(selector)); // It's out of order!!!
	}
}



@end
