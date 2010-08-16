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

#import "Three20UINavigator/TTURLPatternInternal.h"
#import "Three20UINavigator/TTURLWildcard.h"

///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation TTURLPattern (TTInternal)


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setSelectorWithNames:(NSArray*)names {
//	NSLog(@"    Names: %@", names);
//	NSLog(@"    Names components joined by string: %@", [names componentsJoinedByString:@":"]);
//	NSLog(@"    Names components joined by string with appending: %@", [[names componentsJoinedByString:@":"] stringByAppendingString:@":"]);
	
	//	NSString* aselectorName = [[names componentsJoinedByString:@":"] stringByAppendingString:@":"];
	//	SEL aselector = NSSelectorFromString(aselectorName);
	//	[self setSelectorIfPossible:aselector];	
	//	return;
	
	//NSLog(@"    SelectorName: %@", selectorName);
	
	//// !!! Gigantic hack time !!!
	//// Thar be dragons!
	/*
	 // Calculate the factorial, the number of possibilities of orders
	 int countDown = [names count];
	 int totalPossibleValues = 1;
	 while (countDown != 0) {
	 totalPossibleValues *= countDown;
	 countDown--;
	 }
	 // Try all the possible values, until one works or we hit totalPossibleValues
	 NSMutableArray *indexes = [NSMutableArray array];
	 //  Creates an array like 0,1,2,3
	 for (int i = 0; i < [names count]; i++) {
	 [indexes addObject:[NSNumber numberWithInt:i]];
	 }

	 for (int i = 0; i < totalPossibleValues; i++) {
	 NSMutableArray *allParts = [NSMutableArray array];

	 for (NSNumber *num in indexes) {
	 [allParts addObject:[names objectAtIndex:[num intValue]]];
	 }
	 NSString* selectorName = [[allParts componentsJoinedByString:@":"] stringByAppendingString:@":"];
	 NSLog(@"  Trying selector: %@", totalPossibleValues);
	 SEL selector = NSSelectorFromString(selectorName);
	 [self setSelectorIfPossible:selector];
	 if (_selector) {
	 NSLog(@"    It worked!");
	 break;
	 }else {
	 NSLog(@"    Didn't work...");
	 }

	 // We didn't get a match, so let's alter the indexes...
	 }
	 */	
	NSMutableArray *orderedNames = [NSMutableArray array];
	//NSLog(@"queryKeyOrder: %@", self.queryKeyOrder);	
	for (NSString *orderedQueryKey in self.queryKeyOrder) {	
		TTURLWildcard *wildcard = [_query objectForKey:orderedQueryKey];
		NSString *orderedQueryValue = wildcard.name;	
		//NSLog(@"  looking at %@ (for key %@)", orderedQueryValue, orderedQueryKey);
		if ([names containsObject:orderedQueryValue]){ 
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
		NSLog(@"  COULD NOT SET SELECTOR - !!!!!!!!!!!!!!!");
		// This is still happening sometimes, I'm not sure why. Everything seems fine.
		//NSLog(@"  COULD NOT SET SELECTOR - !!!!!!!!!!!!!!!");
		//NSLog(@"  !!!!! selector: %@", NSStringFromSelector(selector)); // It's out of order!!!
	}
}


@end

