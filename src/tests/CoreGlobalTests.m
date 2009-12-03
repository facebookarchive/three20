/**
 * Copyright 2009 Facebook
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

// See: http://developer.apple.com/iphone/library/documentation/Xcode/Conceptual/iphone_development/905-A-Unit-Test_Result_Macro_Reference/unit-test_results.html#//apple_ref/doc/uid/TP40007959-CH21-SW2
// for unit test macros.

#import "CoreGlobalTests.h"

#import "Three20/Three20.h"


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation CoreGlobalTests


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)testSuccess {
  // This is just a test to ensure that you're building the unit tests properly.
  STAssertTrue(YES, @"Something is terribly, terribly wrong.");
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Non Retaining Objects


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)testNonRetainingArray {
  NSMutableArray* array = TTCreateNonRetainingArray();
  id testObject = [[NSArray alloc] init];

  STAssertTrue([testObject retainCount] == 1, @"Improper initial retain count");

  [array addObject:testObject];
  STAssertTrue([testObject retainCount] == 1, @"Improper new retain count");

  TT_RELEASE_SAFELY(array);
  STAssertTrue([testObject retainCount] == 1, @"Improper retain count after release");

  TT_RELEASE_SAFELY(testObject);
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)testNonRetainingDictionary {
  NSMutableDictionary* dictionary = TTCreateNonRetainingDictionary();
  id testObject = [[NSArray alloc] init];

  STAssertTrue([testObject retainCount] == 1, @"Improper initial retain count");

  [dictionary setObject:testObject forKey:@"obj"];
  STAssertTrue([testObject retainCount] == 1, @"Improper new retain count");

  TT_RELEASE_SAFELY(dictionary);
  STAssertTrue([testObject retainCount] == 1, @"Improper retain count after release");

  TT_RELEASE_SAFELY(testObject);
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Empty Objects


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)testIsEmptyArray {
  STAssertTrue(!TTIsEmptyArray(nil), @"nil should not be an empty array.");

  NSArray* array = [[NSArray alloc] init];

  STAssertTrue(TTIsEmptyArray(array), @"This should be an empty array.");

  NSDictionary* dictionary = [[NSDictionary alloc] init];
  STAssertTrue(!TTIsEmptyArray(dictionary), @"This should not be an empty array.");

  TT_RELEASE_SAFELY(array);
  TT_RELEASE_SAFELY(dictionary);
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)testIsEmptySet {
  STAssertTrue(!TTIsEmptySet(nil), @"nil should not be an empty set.");

  NSSet* set = [[NSSet alloc] init];

  STAssertTrue(TTIsEmptySet(set), @"This should be an empty set.");

  NSDictionary* dictionary = [[NSDictionary alloc] init];
  STAssertTrue(!TTIsEmptySet(dictionary), @"This should not be an empty set.");

  TT_RELEASE_SAFELY(set);
  TT_RELEASE_SAFELY(dictionary);
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)testIsEmptyString {
  STAssertTrue(!TTIsEmptyString(nil), @"nil should not be an empty string.");

  NSString* string = [[NSString alloc] init];

  STAssertTrue(TTIsEmptyString(string), @"This should be an empty string.");

  NSDictionary* dictionary = [[NSDictionary alloc] init];
  STAssertTrue(!TTIsEmptyString(dictionary), @"This should not be an empty string.");

  TT_RELEASE_SAFELY(string);
  TT_RELEASE_SAFELY(dictionary);
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark CGRect Transformations


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)testRects {
  STAssertTrue(CGRectEqualToRect(
    TTRectContract(CGRectMake(0, 0, 5, 5), 5, 5),
    CGRectMake(0, 0, 0, 0)),
    @"The two rects are not equal");

  STAssertTrue(CGRectEqualToRect(
    TTRectShift(CGRectMake(0, 0, 5, 5), 5, 5),
    CGRectMake(5, 5, 0, 0)),
    @"The two rects are not equal");

  STAssertTrue(CGRectEqualToRect(
    TTRectInset(CGRectMake(0, 0, 5, 5), UIEdgeInsetsMake(1, 1, 1, 1)),
    CGRectMake(1, 1, 3, 3)),
    @"The two rects are not equal");
}


@end
