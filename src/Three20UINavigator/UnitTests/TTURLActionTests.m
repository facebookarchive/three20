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

#import <SenTestingKit/SenTestingKit.h>

// UINavigator
#import "Three20UINavigator/TTURLAction.h"

// Core
#import "Three20Core/TTCorePreprocessorMacros.h"

@interface TTURLActionTests : SenTestCase {
}

@end


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation TTURLActionTests


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)testDefaults {
  static NSString* kURLPath = @"tt://url";
  TTURLAction* action = [[TTURLAction alloc] initWithURLPath:kURLPath];

  STAssertEquals(action.urlPath, kURLPath, @"urlPath should be set.");
  STAssertNil(action.parentURLPath, @"parentURLPath should be nil.");
  STAssertNil(action.query, @"query should be nil.");
  STAssertNil(action.state, @"state should be nil.");
  STAssertFalse(action.animated, @"animated should be false.");
  STAssertFalse(action.withDelay, @"withDelay should be false.");
  STAssertEquals(action.transition, UIViewAnimationTransitionNone,
                 @"transition should be UIViewAnimationTransitionNone.");

  TT_RELEASE_SAFELY(action);
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)testChaining {
  static NSString* kURLPath = @"tt://url";
  TTURLAction* action = [[[[[TTURLAction alloc] initWithURLPath:kURLPath]
                           applyAnimated:YES]
                          applyWithDelay:YES]
                         applyTransition:UIViewAnimationTransitionCurlUp];

  STAssertEquals(action.urlPath, kURLPath, @"urlPath should be set.");
  STAssertNil(action.parentURLPath, @"parentURLPath should be nil.");
  STAssertNil(action.query, @"query should be nil.");
  STAssertNil(action.state, @"state should be nil.");
  STAssertTrue(action.animated, @"animated should be true.");
  STAssertTrue(action.withDelay, @"withDelay should be true.");
  STAssertEquals(action.transition, UIViewAnimationTransitionCurlUp,
                 @"transition should be UIViewAnimationTransitionCurlUp.");

  TT_RELEASE_SAFELY(action);
}


@end
