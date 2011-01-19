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

@interface MockNSHTTPURLResponse : NSHTTPURLResponse {
	NSInteger _mockStatusCode;
}
- (id)initWithStatusCode:(NSInteger)statusCode;
@end

@implementation MockNSHTTPURLResponse

- (id)initWithStatusCode:(NSInteger)statusCode {
	if(self=[super init]) {
  	_mockStatusCode = statusCode;
  }
  return self;
}

- (NSInteger)statusCode { return _mockStatusCode; }

@end




#define kDummyString @"The quick brown fox jumps over the lazy dog. 0123456789<br />&&&&"
#define kDummyStringXMLEscaped @"The quick brown fox jumps over the lazy dog. 0123456789&lt;br /&gt;&amp;&amp;&amp;&amp;"

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

- (void)testRequestBody {
	
	TTURLXMLRPCRequest *req = [[TTURLXMLRPCRequest alloc] initWithURL:@"http://mydomain.tld/path/to/post" delegate:nil];
  
  NSMutableString *str = nil;
	// method name only
  
  str = [NSMutableString stringWithString:@"<?xml version=\"1.0\"?>"];
  [str appendString:@"<methodCall>"];
    [str appendString:@"<methodName>hoge.fuga.Piyo1</methodName>"];
    [str appendString:@"<params></params>"];
  [str appendString:@"</methodCall>"];

	[req setMethod:@"hoge.fuga.Piyo1"];
	STAssertEqualObjects([req body],str,@"Check non parameters request body as string.");

	// method with parameters
	[req setMethod:@"hoge.fuga.Piyo2" withParameter:[NSDictionary dictionaryWithObjectsAndKeys:
																									 [NSNumber numberWithInt:135],      @"aIntValue",
																									 [NSNumber numberWithDouble:12.64], @"aDoubleValue",
																									 [NSNumber numberWithBool:YES],     @"aBooleanValue",
																									 [NSNull null],                     @"aNullValue",
																									 kDummyString, @"aStringValue",
																									 [NSArray arrayWithObjects:
																										[NSNumber numberWithInt:246],
																										[NSNumber numberWithDouble:21.7],
																										[NSNumber numberWithBool:NO],
																										kDummyString,
																										nil], @"anArrayValue",
																									 nil]];
                                                   
  str = [NSMutableString stringWithString:@"<?xml version=\"1.0\"?>"];
  [str appendString:@"<methodCall>"];
    [str appendString:@"<methodName>hoge.fuga.Piyo2</methodName>"];
    [str appendString:@"<params>"];
      [str appendString:@"<param><value>"];
        [str appendString:@"<struct>"];

          [str appendString:@"<member>"];
            [str appendString:@"<name>aNullValue</name>"];
          [str appendString:@"</member>"];

          [str appendString:@"<member>"];
            [str appendString:@"<name>aBooleanValue</name>"];
            [str appendString:@"<value><boolean>1</boolean></value>"];
          [str appendString:@"</member>"];

          [str appendString:@"<member>"];
            [str appendString:@"<name>aDoubleValue</name>"];
            [str appendString:@"<value><double>12.64</double></value>"];
          [str appendString:@"</member>"];

          [str appendString:@"<member>"];
            [str appendString:@"<name>aIntValue</name>"];
            [str appendString:@"<value><i4>135</i4></value>"];
          [str appendString:@"</member>"];

          [str appendString:@"<member>"];
            [str appendString:@"<name>aStringValue</name>"];
            [str appendFormat:@"<value><string>%@</string></value>",kDummyStringXMLEscaped];
          [str appendString:@"</member>"];

          [str appendString:@"<member>"];
            [str appendString:@"<name>anArrayValue</name>"];
            [str appendString:@"<value><array><data>"];
              [str appendString:@"<value><i4>246</i4></value>"];
              [str appendString:@"<value><double>21.7</double></value>"];
              [str appendString:@"<value><boolean>0</boolean></value>"];
              [str appendFormat:@"<value><string>%@</string></value>",kDummyStringXMLEscaped];
            [str appendString:@"</data></array></value>"];
          [str appendString:@"</member>"];
          
        [str appendString:@"</struct>"];
    
      [str appendString:@"</value></param>"];
    [str appendString:@"</params>"];
  [str appendString:@"</methodCall>"];        
                                                   
	STAssertEqualObjects([req body],str,@"Check request body as string.");
	
	TT_RELEASE_SAFELY(req);
}

- (void)testResponseBody {
  MockNSHTTPURLResponse *mockResponse = [[MockNSHTTPURLResponse alloc] initWithStatusCode:200];
  TTURLXMLRPCRequest *mockRequest = [[TTURLXMLRPCRequest alloc] initWithURL:@"http://www.mydomain.com/path/to/post" method:@"hoge.fuga.Piyo3" delegate:nil];
	TTURLXMLRPCResponse *res = [[TTURLXMLRPCResponse alloc] init];
  NSError *error = nil; NSDictionary *dic = nil;

	//
  error = [res request:mockRequest processResponse:mockResponse data:[self dataWithBundledXMLFileName:@"testcase1.xml"]];
  STAssertEqualObjects([res object],@"South Dakota",@"String response");
  STAssertNil(error,@"Response should be nil");
  
  //
  error = [res request:mockRequest processResponse:mockResponse data:[self dataWithBundledXMLFileName:@"testcase2.xml"]];

  dic = [NSDictionary dictionaryWithObjectsAndKeys:
    [NSNumber numberWithInt:4], @"faultCode",
    @"Too many parameters.", @"faultString",
    nil];
  STAssertEqualObjects([res object],dic,@"Check error object structure.");
  
  dic = [NSDictionary dictionaryWithObject:@"Too many parameters." forKey:@"fault"];
	STAssertEqualObjects([error userInfo],dic,@"Check error userInfo");
  STAssertEquals([error code],4,@"Check error code");
  
  //
  error = [res request:mockRequest processResponse:mockResponse data:[self dataWithBundledXMLFileName:@"testcase3.xml"]];
  dic = [NSDictionary dictionaryWithObjectsAndKeys:
																									 [NSNumber numberWithInt:135],      @"aIntValue",
																									 [NSNumber numberWithDouble:12.64], @"aDoubleValue",
																									 [NSNumber numberWithBool:YES],     @"aBooleanValue",
																									 @"",                     @"aNullValue",
																									 kDummyString, @"aStringValue",
																									 [NSArray arrayWithObjects:
																										[NSNumber numberWithInt:246],
																										[NSNumber numberWithDouble:21.7],
																										[NSNumber numberWithBool:NO],
																										kDummyString,
																										nil], @"anArrayValue",
																									 nil];
	STAssertEqualObjects([res object],dic,@"Check error userInfo");
  
  TT_RELEASE_SAFELY(res);
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
