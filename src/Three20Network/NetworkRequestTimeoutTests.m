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

// See: http://developer.apple.com/iphone/library/documentation/Xcode/Conceptual/iphone_development/905-A-Unit-Test_Result_Macro_Reference/unit-test_results.html#//apple_ref/doc/uid/TP40007959-CH21-SW2
// for unit test macros.

// See Also: http://developer.apple.com/iphone/library/documentation/Xcode/Conceptual/iphone_development/135-Unit_Testing_Applications/unit_testing_applications.html

#import <SenTestingKit/SenTestingKit.h>

// Network
#import "Three20Network/TTURLRequest.h"
#import "Three20Network/TTURLRequestQueue.h"

// Core
#import "Three20Core/TTGlobalCorePaths.h"

// duplicate constant for testing declared in Three20Network/TTURLRequestQueue.h
static const NSTimeInterval kTimeout = 300.0;

/**
 * Unit tests for configurable request timeouts.
 *
 */

@interface NetworkRequestTimeout : SenTestCase {
}

@end


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation NetworkRequestTimeout


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark TTURLRequest


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)testTTURLRequest_timeoutIntervalAccess {
  STAssertEqualsWithAccuracy([[[[TTURLRequest alloc] init] autorelease] timeoutInterval],
                 (NSTimeInterval)TTURLRequestUseDefaultTimeout,
                             0.1,
                 @"default timeout should be set on initialization");
  
  TTURLRequest * request = [[TTURLRequest alloc] init];
  request.timeoutInterval = 20.0;
  STAssertEqualsWithAccuracy(request.timeoutInterval,(NSTimeInterval)20.0,0.1,
                             @"should return the previously set timeout");
  
  TT_RELEASE_SAFELY(request);
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)testTTURLRequestQueue_timeoutIntervalAccess {
  STAssertEqualsWithAccuracy([[[[TTURLRequestQueue alloc] init] autorelease] defaultTimeout],
                 (NSTimeInterval)kTimeout,
                             0.1,
                 @"default timeout should be set on initialization");
  
  TTURLRequestQueue * queue = [[TTURLRequestQueue alloc] init];
  queue.defaultTimeout = 20.0;
  STAssertEqualsWithAccuracy(queue.defaultTimeout,(NSTimeInterval)20.0,0.1,
                             @"should return the previously set timeout");
  
  TT_RELEASE_SAFELY(queue);
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)testTTURLRequestQueue_timeoutIntervalUsage {
  
  TTURLRequestQueue* queue = [[TTURLRequestQueue alloc] init];
  
  TTURLRequest* request = [[TTURLRequest alloc] init];
  request.urlPath = @"http://www.three20.info";
  
  NSURL* url = [NSURL URLWithString:request.urlPath];
  
  NSURLRequest* urlRequest = nil;
  
  urlRequest = [queue createNSURLRequest:request URL:url];
  
  STAssertNotNil(urlRequest,@"request queue didn't return an NSURLRequest");
  STAssertEqualsWithAccuracy([urlRequest timeoutInterval],kTimeout,0.1,@"wrong timeoutInterval set");
  
  queue.defaultTimeout = 48.5;
  
  urlRequest = [queue createNSURLRequest:request URL:url];
  
  STAssertNotNil(urlRequest,@"request queue didn't return an NSURLRequest");
  STAssertEqualsWithAccuracy([urlRequest timeoutInterval],48.5,0.1,@"wrong timeoutInterval set");
  
  request.timeoutInterval = 5.3;
  
  urlRequest = [queue createNSURLRequest:request URL:url];
  
  STAssertNotNil(urlRequest,@"request queue didn't return an NSURLRequest");
  STAssertEqualsWithAccuracy([urlRequest timeoutInterval],5.3,0.1,@"wrong timeoutInterval set");
  
  request.timeoutInterval = -17;
  
  urlRequest = [queue createNSURLRequest:request URL:url];
  
  STAssertNotNil(urlRequest,@"request queue didn't return an NSURLRequest");
  STAssertEqualsWithAccuracy([urlRequest timeoutInterval],48.5,0.1,@"wrong timeoutInterval set");
}

@end
