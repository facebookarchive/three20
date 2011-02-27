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

// Network
#import "Three20Network/TTURLCache.h"

// Core
#import "Three20Core/TTGlobalCorePaths.h"

@interface TTURLCache()

/**
 * Reveal these private methods for testing.
 */
+ (NSString*)doubleImageURLPath:(NSString*)urlPath;

@end

/**
 * Unit tests for the TTURLCache object.
 *
 * These tests are a part of the comprehensive test suite for the Network
 * functionality of the library.
 */

@interface NetworkURLCacheTests : SenTestCase {
}

@end


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation NetworkURLCacheTests


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark TTURLCache


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)testTTURLCache_doubleImageURLPath {
  STAssertNil([TTURLCache doubleImageURLPath:nil],
              @"nil should be nil.");

  STAssertTrue([[TTURLCache doubleImageURLPath:@"."]
                isEqualToString:@"."],
               @". should resolve to .");

  STAssertTrue([[TTURLCache doubleImageURLPath:@".gif"]
                isEqualToString:@".gif"],
               @".gif should resolve to .gif");

  STAssertTrue([[TTURLCache doubleImageURLPath:@"bundle://both.png"]
                isEqualToString:@"bundle://both@2x.png"],
               @"both.png should resolve to both@2x.png.");

  STAssertTrue([[TTURLCache doubleImageURLPath:@"bundle://both"]
                isEqualToString:@"bundle://both@2x"],
               @"both should resolve to both@2x.");

  STAssertTrue([[TTURLCache doubleImageURLPath:@"bundle://images/both"]
                isEqualToString:@"bundle://images/both@2x"],
               @"images/both should resolve to images/both@2x.");
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)testTTURLCache_hasImageForURL {
  NSBundle* testBundle = [NSBundle bundleWithIdentifier:@"com.facebook.three20.UnitTests"];
  STAssertTrue(nil != testBundle, @"Unable to find the bundle %@", [NSBundle allBundles]);

  TTSetDefaultBundle(testBundle);

  STAssertTrue([[TTURLCache sharedCache] hasImageForURL:@"bundle://both.png" fromDisk:YES],
               @"both.png should exist.");

  STAssertTrue([[TTURLCache sharedCache] hasImageForURL:@"bundle://only.png" fromDisk:YES],
               @"only@2x.png should exist.");

  STAssertNotNil([[TTURLCache sharedCache] imageForURL:@"bundle://both.png" fromDisk:YES],
               @"both@2x.png should exist.");

  // Release the default bundle now that we're done with it.
  TTSetDefaultBundle(nil);
}


@end
