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
// See Also: http://bit.ly/hgpqd2

#import <SenTestingKit/SenTestingKit.h>

// extXML
#import "extThree20XML/TTXMLParser.h"

// Core
#import "Three20Core/TTCorePreprocessorMacros.h"

/**
 * Unit tests for the Core XML parser. These tests are a part of the comprehensive test suite
 * for the Core functionality of the library.
 */
@interface extXMLTests : SenTestCase
@end


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation extXMLTests


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)testXMLParser {
  NSBundle* testBundle = [NSBundle bundleWithIdentifier:@"com.facebook.three20.UnitTests"];
  STAssertTrue(nil != testBundle, @"Unable to find the bundle %@", [NSBundle allBundles]);

  NSString* xmlDataPath = [[testBundle bundlePath]
    stringByAppendingPathComponent:@"testcase.xml"];
  NSData* xmlData = [[NSData alloc] initWithContentsOfFile:xmlDataPath];

  STAssertTrue(nil != xmlData, @"Unable to find the xml test file in %@", xmlDataPath);

  TTXMLParser* parser = [[TTXMLParser alloc] initWithData:xmlData];
  [parser parse];
  STAssertTrue([parser.rootObject isKindOfClass:[NSDictionary class]],
               @"Root object should be an NSDictionary");

  NSDictionary* rootObject = parser.rootObject;
  STAssertTrue([[rootObject nameForXMLNode] isEqualToString:@"issues"],
               @"Root object name should be 'issues'");
  STAssertTrue([[rootObject typeForXMLNode] isEqualToString:@"array"],
               @"Root object type should be 'array'");
  STAssertTrue([[rootObject objectForXMLNode] isKindOfClass:[NSArray class]],
               @"Root object type should be 'array'");

  NSArray* issues = [rootObject objectForXMLNode];
  STAssertEquals((NSUInteger)50, [issues count], @"There should be 50 issues in the array");

  NSDictionary* issue = [issues objectAtIndex:0];
  STAssertTrue([issue isKindOfClass:[NSDictionary class]],
               @"The issue node should be an NSDictionary");
  STAssertTrue([[issue objectForKey:@"number"] isKindOfClass:[NSDictionary class]],
               @"The number node should be an NSDictionary");

  NSDictionary* number = [issue objectForKey:@"number"];
  STAssertTrue([[number objectForXMLNode] isKindOfClass:[NSNumber class]],
               @"The number object should be an NSNumber");
  STAssertEquals(3, [[number objectForXMLNode] intValue],
               @"The number value should be 3");


  TT_RELEASE_SAFELY(parser);
}


@end
