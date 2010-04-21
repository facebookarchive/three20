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

// See: http://developer.apple.com/iphone/library/documentation/Xcode/Conceptual/iphone_development/905-A-Unit-Test_Result_Macro_Reference/unit-test_results.html#//apple_ref/doc/uid/TP40007959-CH21-SW2
// for unit test macros.

// See Also: http://developer.apple.com/iphone/library/documentation/Xcode/Conceptual/iphone_development/135-Unit_Testing_Applications/unit_testing_applications.html

#import <SenTestingKit/SenTestingKit.h>

// Mocks
#import "mocks/MockModelDelegate.h"

// Network
#import "Three20/TTModel.h"

// Core
#import "Three20/TTCorePreprocessorMacros.h"

/**
 * Unit tests for the Network model found within Three20. These tests are a part of
 * the comprehensive test suite for the Network functionality of the library.
 */

@interface NetworkModelTests : SenTestCase {
}

@end


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation NetworkModelTests


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark TTModel


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)testTTModel_init {
  TTModel* model = [[TTModel alloc] init];

  STAssertTrue(model.isLoaded, @"A TTModel is supposed to be loaded by default.");
  STAssertFalse(model.isLoading, @"A TTModel is not supposed to be loading by default.");
  STAssertFalse(model.isLoadingMore, @"A TTModel is not supposed to be loading more by default.");
  STAssertFalse(model.isOutdated, @"A TTModel is not supposed to be outdated by default.");

  TT_RELEASE_SAFELY(model);
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)testTTModel_delegate {
  TTModel* model = [[TTModel alloc] init];

  MockModelDelegate* mockResults = [[MockModelDelegate alloc] init];

  [model.delegates addObject:mockResults];

  [model didStartLoad];
  STAssertTrue(mockResults.isLoading, @"The delegate is supposed to be loading now.");

  [model didFinishLoad];
  STAssertFalse(mockResults.isLoading, @"The delegate is supposed to be finished loading now.");

  TT_RELEASE_SAFELY(mockResults);
  TT_RELEASE_SAFELY(model);
}


@end
