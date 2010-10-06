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

// Core
#import "Three20Core/TTCorePreprocessorMacros.h"
#import "Three20Core/TTMarkupStripper.h"

/**
 * Unit tests for the markup stripper found within Three20. These tests are a part of
 * the comprehensive test suite for the Core functionality of the library.
 */

@interface CoreMarkupStripperTests : SenTestCase {
}

@end


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation CoreMarkupStripperTests


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)testIsMaskSet {
  TTMarkupStripper* stripper = [[TTMarkupStripper alloc] init];

  STAssertTrue([[stripper parse:nil] isEqualToString:@"(null)"]
               || [[stripper parse:nil] isEqualToString:@""],
               @"Nil returns an empty string.");

  STAssertTrue([[stripper parse:@""] isEqualToString:@""],
               @"Empty string returns an empty string.");

  STAssertTrue([[stripper parse:@"a"] isEqualToString:@"a"],
               @"No markup should still be no markup.");

  STAssertTrue([[stripper parse:@"<a href=\"localhost\">a</a>"] isEqualToString:@"a"],
               @"Link should be removed.");

  STAssertTrue([[stripper parse:@"<a href=\"localhost\"><b>a</b></a>"] isEqualToString:@"a"],
               @"Nested markup should be removed.");

  STAssertTrue([[stripper parse:@"<a href=\"localhost\"><b>a</a></b>"] isEqualToString:@"a"],
               @"Improperly nested markup should be removed.");

  // Entity decoding.
  STAssertTrue([[stripper parse:@"&nbsp;"] isEqualToString:@" "],
               @"Entity decoding should be in effect.");

  STAssertTrue([[stripper parse:@"&amp;"] isEqualToString:@"&"],
               @"Entity decoding should be in effect.");

  STAssertTrue([[stripper parse:@"&quot;"] isEqualToString:@"\""],
               @"Entity decoding should be in effect.");

  STAssertTrue([[stripper parse:@"&apos;"] isEqualToString:@"'"],
               @"Entity decoding should be in effect.");

  STAssertTrue([[stripper parse:@"&Eacute;"] isEqualToString:@"É"],
               @"Entity decoding should be in effect.");

  STAssertTrue([[stripper parse:@"&oslash;"] isEqualToString:@"ø"],
               @"Entity decoding should be in effect.");

  TT_RELEASE_SAFELY(stripper);
}


@end
