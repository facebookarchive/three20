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

// UICommon
#import "Three20UICommon/TTGlobalUICommon.h"

@interface UICommonTests : SenTestCase {
}

@end


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation UICommonTests


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)testTTOSVersion {
  // Difficult to test this guy.
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)testTTOSVersionIsAtLeast {
#ifdef __IPHONE_4_2
  STAssertTrue(TTOSVersionIsAtLeast(4.2), @"Should be at least 4.2.");
#else
  STAssertTrue(!TTOSVersionIsAtLeast(4.2), @"Should be lower than 4.2.");
#endif

#ifdef __IPHONE_4_1
  STAssertTrue(TTOSVersionIsAtLeast(4.1), @"Should be at least 4.1.");
#else
  STAssertTrue(!TTOSVersionIsAtLeast(4.1), @"Should be lower than 4.1.");
#endif

#ifdef __IPHONE_4_0
  STAssertTrue(TTOSVersionIsAtLeast(4.0), @"Should be at least 4.0.");
#else
  STAssertTrue(!TTOSVersionIsAtLeast(4.0), @"Should be lower than 4.0.");
#endif

#ifdef __IPHONE_3_2
  STAssertTrue(TTOSVersionIsAtLeast(3.2), @"Should be at least 3.2.");
#else
  STAssertTrue(!TTOSVersionIsAtLeast(3.2), @"Should be lower than 3.2.");
#endif

#ifdef __IPHONE_3_1
  STAssertTrue(TTOSVersionIsAtLeast(3.1), @"Should be at least 3.1.");
#else
  STAssertTrue(!TTOSVersionIsAtLeast(3.1), @"Should be lower than 3.1.");
#endif

#ifdef __IPHONE_3_0
  STAssertTrue(TTOSVersionIsAtLeast(3.0), @"Should be at least 3.0.");
#else
  STAssertTrue(!TTOSVersionIsAtLeast(3.0), @"Should be lower than 3.0.");
#endif

#ifdef __IPHONE_2_2
  STAssertTrue(TTOSVersionIsAtLeast(2.2), @"Should be at least 2.2.");
#else
  STAssertTrue(!TTOSVersionIsAtLeast(2.2), @"Should be lower than 2.2.");
#endif

#ifdef __IPHONE_2_1
  STAssertTrue(TTOSVersionIsAtLeast(2.1), @"Should be at least 2.1.");
#else
  STAssertTrue(!TTOSVersionIsAtLeast(2.1), @"Should be lower than 2.1.");
#endif

#ifdef __IPHONE_2_0
  STAssertTrue(TTOSVersionIsAtLeast(2.0), @"Should be at least 2.0.");
#else
  STAssertTrue(!TTOSVersionIsAtLeast(2.0), @"Should be lower than 2.0.");
#endif
}


@end
