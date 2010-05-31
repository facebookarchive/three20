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

#import "extThree20CSSStyle/TTCSSStyleSheet.h"

// Core
#import "Three20Core/TTCorePreprocessorMacros.h"

@interface CssStyleSheetTests : SenTestCase {
  TTCSSStyleSheet* _styleSheet;
}

@end


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation CssStyleSheetTests


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setUp {
  NSBundle* testBundle = [NSBundle bundleWithIdentifier:@"com.facebook.three20.UnitTests"];
  STAssertTrue(nil != testBundle, @"Unable to find the bundle %@", [NSBundle allBundles]);

  NSString* filename = [[testBundle bundlePath]
                        stringByAppendingPathComponent:@"testcase.css"];

  _styleSheet = [[TTCSSStyleSheet alloc] init];

  STAssertTrue([_styleSheet loadFromFilename:filename],
               @"Style sheet should have loaded.");
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)tearDown {
  TT_RELEASE_SAFELY(_styleSheet);
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)testStylesheet_ShortColors {
  UIColor* color = [_styleSheet colorWithCssSelector: @".short-hex-colors"
                                            forState: UIControlStateNormal];
  STAssertNotNil(color, @"Color should be set.");

  const CGFloat* components = CGColorGetComponents([color CGColor]);

  // #F73
  STAssertEqualsWithAccuracy(components[0], (CGFloat)1, 0.0001, @"Red should be full on");
  STAssertEqualsWithAccuracy(components[1], (CGFloat)0.466667, 0.0001, @"Green should be half on");
  STAssertEqualsWithAccuracy(components[2], (CGFloat)0.2, 0.0001, @"Blue should be quarter on");
}


@end
