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

// extXML
#import <extThree20XMLRPC/extThree20XMLRPC.h>

// Core
#import "Three20Core/TTCorePreprocessorMacros.h"

#define kDummyString @"The quick brown fox jumps over the lazy dog. 0123456789<br />&&&&"

/**
 * Unit tests for the Core XML parser. These tests are a part of the comprehensive test suite
 * for the Core functionality of the library.
 */
@interface extXMLRPCUnitTests : SenTestCase

- (NSData *)dataWithBundledXMLFileName:(NSString *)fileName;

@end


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation extXMLRPCUnitTests


///////////////////////////////////////////////////////////////////////////////////////////////////

#pragma mark TODO:
- (void)testRequestBody {
	
	TTURLXMLRPCRequest *req = [[TTURLXMLRPCRequest alloc] initWithURL:@"http://mydomain.tld/path/to/post" delegate:nil];
	// method name only
	[req setMethod:@"hoge.fuga.Piyo1"];
	STAssertEqualObjects([req body],@"<?xml version=\"1.0\"?><methodCall><methodName>hoge.fuga.Piyo1</methodName><params></params></methodCall>",@"Check non parameters request body as string.");

	// method with parameters
	[req setMethod:@"hoge.fuga.Piyo2" withParameter:[NSDictionary dictionaryWithObjectsAndKeys:
																									 [NSNumber numberWithInt:1],      @"aIntValue",
																									 [NSNumber numberWithDouble:1.0], @"aDoubleValue",
																									 [NSNumber numberWithBool:YES],   @"aBooleanValue",
																									 kDummyString, @"aStringValue",
																									 [NSArray arrayWithObjects:
																										[NSNumber numberWithInt:1],
																										[NSNumber numberWithDouble:1.0],
																										[NSNumber numberWithBool:YES],
																										kDummyString,
																										nil], @"aArrayValue",
																									 nil]];
	STAssertEqualObjects([req body],@"<?xml version=\"1.0\"?><methodCall><methodName>hoge.fuga.Piyo2</methodName><params><param><value><struct><member><name>aBooleanValue</name><value><boolean>1</boolean></value></member><member><name>aDoubleValue</name><value><double>1</double></value></member><member><name>aIntValue</name><value><i4>1</i4></value></member><member><name>aStringValue</name><value><string>The quick brown fox jumps over the lazy dog. 0123456789&lt;br /&gt;&amp;&amp;&amp;&amp;</string></value></member><member><name>aArrayValue</name><value><array><data><value><i4>1</i4></value><value><double>1</double></value><value><boolean>1</boolean></value><value><string>The quick brown fox jumps over the lazy dog. 0123456789&lt;br /&gt;&amp;&amp;&amp;&amp;</string></value></data></array></value></member></struct></value></param></params></methodCall>",@"Check request body as string.");
	
	TT_RELEASE_SAFELY(req);
}

#pragma mark TODO:
- (void)testResponseBody {
}


#pragma mark -
- (NSData *)dataWithBundledXMLFileName:(NSString *)fileName {
  NSBundle* testBundle = [NSBundle bundleWithIdentifier:@"com.facebook.three20.UnitTests"];
	STAssertNotNil(testBundle, @"Unable to find the bundle %@", [NSBundle allBundles]);
  NSString* xmlDataPath = [[testBundle bundlePath] stringByAppendingPathComponent:fileName];
  NSData* xmlData = [[NSData alloc] initWithContentsOfFile:xmlDataPath];
	STAssertNotNil(xmlData,@"Unable to find the xml test file in %@", xmlDataPath);
	return xmlData;
}





@end
