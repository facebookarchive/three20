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
- (void)checkColorsForSelector:(NSString*)selector equalToColor:(UIColor*)correctColor {
  UIColor* color = [_styleSheet colorWithCssSelector: selector
                                            forState: UIControlStateNormal];
  UIColor* bgColor = [_styleSheet backgroundColorWithCssSelector: selector
                                                        forState: UIControlStateNormal];
  STAssertNotNil(color, @"Color should be set.");
  STAssertNotNil(bgColor, @"Background color should be set.");

  STAssertTrue(CGColorEqualToColor([color CGColor], [correctColor CGColor]),
               @"Colors should be equal");
  STAssertTrue(CGColorEqualToColor([bgColor CGColor], [correctColor CGColor]),
               @"Background colors should be equal");
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)testStylesheet_ShortColors {
  [self checkColorsForSelector:@".short-hex-colors"
                  equalToColor:[UIColor colorWithRed:1 green:0.466666666 blue:0.2 alpha:1.0]];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)testStylesheet_LongColors {
  [self checkColorsForSelector:@".long-hex-colors"
                  equalToColor:[UIColor colorWithRed:1 green:0.466666666 blue:0.2 alpha:1.0]];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)testStylesheet_NamedColors {
  // We can't run this test because any calls to the UIColor system colors crashes the test rig.
  //[self checkColorsForSelector:@".named-color"
  //                equalToColor:[UIColor redColor]];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)testStylesheet_NamedInvalidColors {
  // We can't run this test because any calls to the UIColor system colors crashes the test rig.
  //UIColor* color = [_styleSheet colorWithCssSelector: @".named-invalid-color"
  //                                          forState: UIControlStateNormal];
  //STAssertNil(color, @"Color should not be set.");
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)testStylesheet_FunctionRgbColors {
  [self checkColorsForSelector:@".fn-color-rgb"
                  equalToColor:[UIColor colorWithRed:1 green:0 blue:1 alpha:1]];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)testStylesheet_FunctionRgbaColors {
  [self checkColorsForSelector:@".fn-color-rgba"
                  equalToColor:[UIColor colorWithRed:1 green:1 blue:1 alpha:0.5]];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)testStylesheet_ColorCache {
  UIColor* color = [_styleSheet colorWithCssSelector: @".long-hex-colors"
                                            forState: UIControlStateNormal];

  // Call it again now, this time ideally from the cache.
  UIColor* cachedColor = [_styleSheet colorWithCssSelector: @".long-hex-colors"
                                                  forState: UIControlStateNormal];

  STAssertEquals(color, cachedColor, @"Should be the same object.");
}


@end
