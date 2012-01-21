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

// See: http://developer.apple.com/iphone/library/documentation/Xcode/Conceptual/iphone_development/905-A-Unit-Test_Result_Macro_Reference/unit-test_results.html#//apple_ref/doc/uid/TP40007959-CH21-SW2
// for unit test macros.

// See Also: http://developer.apple.com/iphone/library/documentation/Xcode/Conceptual/iphone_development/135-Unit_Testing_Applications/unit_testing_applications.html

#import <SenTestingKit/SenTestingKit.h>

#import "extThree20JSON/SBJson.h"

/**
 * Unit tests for the Core JSON parser. These tests are a part of the comprehensive test suite
 * for the Core functionality of the library.
 */
@interface extJSONTests : SenTestCase
@end


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation extJSONTests


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)testJSONParser_invalid {
  // Empty/failure cases
  STAssertNil([@"" JSONValue], @"Empty string should be a nil value");
  STAssertNil([@"  " JSONValue], @"Blank string should be a nil value");
  STAssertNil([@"garble" JSONValue], @"Garble string should be a nil value");
  STAssertNil([@"\"hai\"" JSONValue], @"Quoted string should be a nil value");
  STAssertNil([@"0" JSONValue], @"Number should be a nil value");
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)testJSONParser_empty {
  STAssertTrue([[@"[]" JSONValue] isKindOfClass:[NSArray class]], @"Array should be an array");
  STAssertTrue([[@"{}" JSONValue] isKindOfClass:[NSDictionary class]],
               @"Dictionary should be a dictionary");
  STAssertEquals([[@"[]" JSONValue] count], (NSUInteger)0, @"Empty array should be empty");
  STAssertEquals([[@"{}" JSONValue] count], (NSUInteger)0, @"Empty dictionary should be empty");
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)testJSONParser_oneItem {
  STAssertTrue([[@"[0]" JSONValue] isKindOfClass:[NSArray class]], @"Array should be an array");
  STAssertTrue([[@"{\"a\":0}" JSONValue] isKindOfClass:[NSDictionary class]],
               @"Dictionary should be a dictionary");
  STAssertEquals([[@"[0]" JSONValue] count], (NSUInteger)1,
                 @"Single-item array should have one item");
  STAssertEquals([[@"{\"a\":0}" JSONValue] count], (NSUInteger)1,
                 @"Single-item dictionary should have one item");
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)testJSONParser_nested {
  id json = [@"[{\"a\":0}]" JSONValue];
  STAssertTrue([json isKindOfClass:[NSArray class]], @"Array should be an array");
  STAssertTrue([[json objectAtIndex:0] isKindOfClass:[NSDictionary class]],
               @"Nested dictionary should be a dictionary");
  STAssertEquals([[json objectAtIndex:0] count], (NSUInteger)1,
                 @"Single-item dictionary should have one item");
}


@end
