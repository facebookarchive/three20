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

// See: http://bit.ly/hS5nNh for unit test macros.

#import <SenTestingKit/SenTestingKit.h>

// Core
#import "Three20Core/TTCorePreprocessorMacros.h"
#import "Three20Core/TTGlobalCorePaths.h"
#import "Three20Core/TTGlobalCore.h"

/**
 * Unit tests for the global methods found within Three20. These tests are a part of
 * the comprehensive test suite for the Core functionality of the library.
 */

@interface CoreGlobalTests : SenTestCase {
}

@end


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
#pragma mark Macros


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)testIsMaskSet {
  STAssertTrue(IS_MASK_SET(1, 1), @"1 is set");
  STAssertTrue(IS_MASK_SET(0, 0), @"0 is set");
  STAssertTrue(IS_MASK_SET(0xF0|0x01, 0xF1), @"0xF1 is set");
  STAssertFalse(IS_MASK_SET(0xF0|0x00, 0xF1), @"0xF1 is not set");
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Bundles


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)testDefaultBundles {
  STAssertEquals([NSBundle mainBundle], TTGetDefaultBundle(),
                 @"Default bundle should be mainBundle");
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)testSettingDefaultBundles {
  NSBundle* testBundle = [NSBundle bundleWithIdentifier:@"com.facebook.three20.UnitTests"];
  STAssertTrue(nil != testBundle, @"Unable to find the bundle %@", [NSBundle allBundles]);

  TTSetDefaultBundle(testBundle);

  STAssertEquals(testBundle, TTGetDefaultBundle(),
                 @"Default bundle should be set to the unit test bundle");

  TTSetDefaultBundle(nil);

  STAssertEquals([NSBundle mainBundle], TTGetDefaultBundle(),
                 @"Default bundle should be back to mainBundle");
}



///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Non Retaining Objects


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)testNonRetainingArray {
  NSMutableArray* array = TTCreateNonRetainingArray();
  id testObject = [[NSArray alloc] init];
  NSUInteger initialRetainCount = [testObject retainCount];

  STAssertTrue(initialRetainCount > 0, @"Improper initial retain count");

  [array addObject:testObject];
  STAssertEquals([testObject retainCount], initialRetainCount, @"Improper new retain count");

  TT_RELEASE_SAFELY(array);
  STAssertEquals([testObject retainCount], initialRetainCount,
                 @"Improper retain count after release");

  TT_RELEASE_SAFELY(testObject);
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)testNonRetainingDictionary {
  NSMutableDictionary* dictionary = TTCreateNonRetainingDictionary();
  id testObject = [[NSArray alloc] init];
  NSUInteger initialRetainCount = [testObject retainCount];

  STAssertTrue(initialRetainCount > 0, @"Improper initial retain count");

  [dictionary setObject:testObject forKey:@"obj"];
  STAssertEquals([testObject retainCount], initialRetainCount, @"Improper new retain count");

  TT_RELEASE_SAFELY(dictionary);
  STAssertEquals([testObject retainCount], initialRetainCount,
                 @"Improper retain count after release");

  TT_RELEASE_SAFELY(testObject);
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Empty Objects


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)testIsArrayWithItems {
  STAssertTrue(!TTIsArrayWithItems(nil), @"nil should not be an array with items.");

  NSMutableArray* array = [[NSMutableArray alloc] init];

  STAssertTrue(!TTIsArrayWithItems(array), @"This array should not have any items.");

  NSDictionary* dictionary = [[NSDictionary alloc] init];
  STAssertTrue(!TTIsArrayWithItems(dictionary), @"This is not an array.");

  [array addObject:dictionary];
  STAssertTrue(TTIsArrayWithItems(array), @"This array should have items.");

  TT_RELEASE_SAFELY(array);
  TT_RELEASE_SAFELY(dictionary);
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)testIsSetWithItems {
  STAssertTrue(!TTIsSetWithItems(nil), @"nil should not be a set with items.");

  NSMutableSet* set = [[NSMutableSet alloc] init];

  STAssertTrue(!TTIsSetWithItems(set), @"This set should not have any items.");

  NSDictionary* dictionary = [[NSDictionary alloc] init];
  STAssertTrue(!TTIsSetWithItems(dictionary), @"This is not an set.");

  [set addObject:dictionary];
  STAssertTrue(TTIsSetWithItems(set), @"This set should have items.");

  TT_RELEASE_SAFELY(set);
  TT_RELEASE_SAFELY(dictionary);
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)testIsStringWithAnyText {
  STAssertTrue(!TTIsStringWithAnyText(nil), @"nil should not be a string with any text.");

  NSString* string = [[NSString alloc] init];

  STAssertTrue(!TTIsStringWithAnyText(string), @"This should be an empty string.");

  NSDictionary* dictionary = [[NSDictionary alloc] init];
  STAssertTrue(!TTIsStringWithAnyText(dictionary), @"This is not a string.");

  STAssertTrue(!TTIsStringWithAnyText(@""), @"This should be an empty string.");
  STAssertTrue(TTIsStringWithAnyText(@"three20"), @"This should be a string with text.");

  TT_RELEASE_SAFELY(string);
  TT_RELEASE_SAFELY(dictionary);
}


@end
