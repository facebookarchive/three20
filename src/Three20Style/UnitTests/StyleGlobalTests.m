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
#import <UIKit/UIKit.h>

#import "Three20Style/TTGlobalStyle.h"

// Core
#import "Three20Core/TTGlobalCoreRects.h"

@interface UIGlobalTests : SenTestCase {
}

@end


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation UIGlobalTests

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
