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

#import "extThree20CSSStyle/TTCSSParser.h"

// Core
#import "Three20Core/TTCorePreprocessorMacros.h"

@interface CssParserTests : SenTestCase {
}

@end


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation CssParserTests


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)testParser {
  NSBundle* testBundle = [NSBundle bundleWithIdentifier:@"com.facebook.three20.UnitTests"];
  STAssertTrue(nil != testBundle, @"Unable to find the bundle %@", [NSBundle allBundles]);

  {
    NSString* filename = [[testBundle bundlePath]
                          stringByAppendingPathComponent:@"testcase.css"];

    TTCSSParser* parser = [[TTCSSParser alloc] init];

    NSDictionary* results = [parser parseFilename:filename];

    STAssertTrue([results isKindOfClass:[NSDictionary class]],
                 @"Should have received a dictionary.");

    NSDictionary* properties = [results objectForKey:@".classname"];

    STAssertTrue([properties isKindOfClass:[NSDictionary class]],
                 @".classname should be a dictionary.");

    NSArray* values = [properties objectForKey:@"width"];

    STAssertTrue([values isKindOfClass:[NSArray class]],
                 @"Values should be an array.");

    // Test overriding.
    STAssertTrue([[values objectAtIndex:0] isEqualToString:@"600px"],
                 @"Should be equal to 600px");

    TT_RELEASE_SAFELY(parser);
  }

  {
    NSString* filename = [[testBundle bundlePath]
                          stringByAppendingPathComponent:@"testcase.css"];

    TTCSSParser* parser = [[TTCSSParser alloc] init];

    NSDictionary* results = [parser parseFilename:filename];

    STAssertTrue([results isKindOfClass:[NSDictionary class]],
                 @"Should have received a dictionary.");

    NSDictionary* properties = [results objectForKey:@".classname"];

    STAssertTrue([properties isKindOfClass:[NSDictionary class]],
                 @".classname should be a dictionary.");

    NSArray* values = [properties objectForKey:@"width"];

    STAssertTrue([values isKindOfClass:[NSArray class]],
                 @"Values should be an array.");

    // Test overriding.
    STAssertTrue([[values objectAtIndex:0] isEqualToString:@"600px"],
                 @"Should be equal to 600px");

    TT_RELEASE_SAFELY(parser);
  }
}


@end
