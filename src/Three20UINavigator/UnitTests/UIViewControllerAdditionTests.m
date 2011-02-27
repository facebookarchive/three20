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

// UINavigator
#import "Three20UINavigator/UIViewController+TTNavigator.h"

// UICommon
#import "Three20UICommon/UIViewControllerAdditions.h"

// Core
#import "Three20Core/TTCorePreprocessorMacros.h"

@interface UIViewControllerAdditionTests : SenTestCase {
}

@end


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation UIViewControllerAdditionTests


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)testsingle_navigatorURL {
  static NSString* kURLPath = @"tt://url";
  UIViewController* controller = [[UIViewController alloc] init];

  STAssertNil([controller originalNavigatorURL], @"No navigator url should be set.");

  controller.originalNavigatorURL = kURLPath;

  STAssertEquals([controller originalNavigatorURL], kURLPath, @"New navigator url should be set.");

  // We need to set originalNavigatorURL to nil in order to properly remove it from the internal
  // global mapping.
  controller.originalNavigatorURL = nil;
  TT_RELEASE_SAFELY(controller);
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)testmultiple_navigatorURL {
  static NSString* kURLPath = @"tt://url";
  static NSString* kURLPath2 = @"tt://url2";
  static NSString* kURLPath3 = @"tt://url3";
  UIViewController* controller = [[UIViewController alloc] init];
  UIViewController* controller2 = [[UIViewController alloc] init];
  UIViewController* controller3 = [[UIViewController alloc] init];

  STAssertNil([controller originalNavigatorURL], @"No navigator url should be set.");
  STAssertNil([controller2 originalNavigatorURL], @"No navigator url should be set.");
  STAssertNil([controller3 originalNavigatorURL], @"No navigator url should be set.");

  controller.originalNavigatorURL = kURLPath;
  controller2.originalNavigatorURL = kURLPath2;
  controller3.originalNavigatorURL = kURLPath3;

  STAssertEquals([controller originalNavigatorURL], kURLPath,
                 @"New navigator url should be set.");

  // We need to set originalNavigatorURL to nil in order to properly remove it from the internal
  // global mapping.
  controller.originalNavigatorURL = nil;
  TT_RELEASE_SAFELY(controller);

  STAssertEquals([controller2 originalNavigatorURL], kURLPath2,
                 @"New navigator url should be set.");

  controller2.originalNavigatorURL = nil;
  TT_RELEASE_SAFELY(controller2);

  STAssertEquals([controller3 originalNavigatorURL], kURLPath3,
                 @"New navigator url should be set.");

  controller3.originalNavigatorURL = nil;
  TT_RELEASE_SAFELY(controller3);
}


@end
