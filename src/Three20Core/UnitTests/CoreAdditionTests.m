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

// Core
#import "Three20Core/TTCorePreprocessorMacros.h"
#import "Three20Core/NSArrayAdditions.h"
#import "Three20Core/NSDataAdditions.h"
#import "Three20Core/NSMutableArrayAdditions.h"
#import "Three20Core/NSMutableDictionaryAdditions.h"
#import "Three20Core/NSStringAdditions.h"

/**
 * Unit tests for the Core additions found within Three20. These tests are a part of
 * the comprehensive test suite for the Core functionality of the library.
 *
 * Notice:
 *
 * NSDateAdditions cannot be easily tested from a library unit test due to their dependence upon
 * TTLocalizedString. This is because the Three20.bundle file needs to be loaded for
 * TTLocalizedString to work, but the octest framework does not play well with bundles.
 * It tries to load the bundle from the simulator's /bin directory
 * which is not a place we can normally copy to from the Xcode project settings.
 */

@interface CoreAdditionTests : SenTestCase {
}

@end


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation CoreAdditionTests


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark NSDataAdditions


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)testNSData_md5Hash {
  const char* bytes = "three20";
  NSData* data = [[NSData alloc] initWithBytes:bytes length:strlen(bytes)];

  STAssertTrue([[data md5Hash] isEqualToString:@"2804d14501153a0c8495afb3c1185012"],
    @"MD5 hashes don't match.");

  TT_RELEASE_SAFELY(data);
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)testNSData_sha1Hash {
  const char* bytes = "three20";
  NSData* data = [[NSData alloc] initWithBytes:bytes length:strlen(bytes)];

  STAssertTrue([[data sha1Hash] isEqualToString:@"ca264456199abfcc3023a880b6e924026ca57164"],
               @"SHA1 hashes don't match.");

  TT_RELEASE_SAFELY(data);
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark NSStringAdditions


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)testNSString_isWhitespace {
  // From the Apple docs:
  // Returns a character set containing only the whitespace characters space (U+0020) and tab
  // (U+0009) and the newline and nextline characters (U+000A–U+000D, U+0085).
  STAssertTrue([@"" isWhitespaceAndNewlines], @"Empty string should be whitespace.");
  STAssertTrue([@" " isWhitespaceAndNewlines], @"Space character should be whitespace.");
  STAssertTrue([@"\t" isWhitespaceAndNewlines], @"Tab character should be whitespace.");
  STAssertTrue([@"\n" isWhitespaceAndNewlines], @"Newline character should be whitespace.");
  STAssertTrue([@"\r" isWhitespaceAndNewlines], @"Carriage return character should be whitespace.");

  // Unicode whitespace
  for (int unicode = 0x000A; unicode <= 0x000D; ++unicode) {
    NSString* str = [NSString stringWithFormat:@"%C", unicode];
    STAssertTrue([str isWhitespaceAndNewlines],
                 @"Unicode string #%X should be whitespace.", unicode);
  }

  NSString* str = [NSString stringWithFormat:@"%C", 0x0085];
  STAssertTrue([str isWhitespaceAndNewlines], @"Unicode string should be whitespace.");

  STAssertTrue([@" \t\r\n" isWhitespaceAndNewlines], @"Empty string should be whitespace.");

  STAssertTrue(![@"a" isWhitespaceAndNewlines], @"Text should not be whitespace.");
  STAssertTrue(![@" \r\n\ta\r\n " isWhitespaceAndNewlines], @"Text should not be whitespace.");
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)testNSString_isEmptyOrWhitespace {
  // From the Apple docs:
  // Returns a character set containing only the in-line whitespace characters space (U+0020)
  // and tab (U+0009).
  STAssertTrue([@"" isEmptyOrWhitespace], @"Empty string should be empty.");
  STAssertTrue([@" " isEmptyOrWhitespace], @"Space character should be whitespace.");
  STAssertTrue([@"\t" isEmptyOrWhitespace], @"Tab character should be whitespace.");
  STAssertTrue(![@"\n" isEmptyOrWhitespace], @"Newline character should not be whitespace.");
  STAssertTrue(![@"\r" isEmptyOrWhitespace],
    @"Carriage return character should not be whitespace.");

  // Unicode whitespace
  for (int unicode = 0x000A; unicode <= 0x000D; ++unicode) {
    NSString* str = [NSString stringWithFormat:@"%C", unicode];
    STAssertTrue(![str isEmptyOrWhitespace],
      @"Unicode string #%X should not be whitespace.", unicode);
  }

  NSString* str = [NSString stringWithFormat:@"%C", 0x0085];
  STAssertTrue(![str isEmptyOrWhitespace], @"Unicode string should not be whitespace.");

  STAssertTrue([@" \t" isEmptyOrWhitespace], @"Empty string should be whitespace.");

  STAssertTrue(![@"a" isEmptyOrWhitespace], @"Text should not be whitespace.");
  STAssertTrue(![@" \r\n\ta\r\n " isEmptyOrWhitespace], @"Text should not be whitespace.");
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)testNSString_stringByRemovingHTMLTags {
  STAssertTrue([[@"" stringByRemovingHTMLTags] isEqualToString:@""], @"Empty case failed");

  STAssertTrue([[@"&nbsp;"  stringByRemovingHTMLTags] isEqualToString:@" "],
    @"Didn't translate nbsp entity");
  STAssertTrue([[@"&amp;"   stringByRemovingHTMLTags] isEqualToString:@"&"],
    @"Didn't translate amp entity");
  STAssertTrue([[@"&quot;"  stringByRemovingHTMLTags] isEqualToString:@"\""],
    @"Didn't translate quot entity");
  STAssertTrue([[@"&lt;"    stringByRemovingHTMLTags] isEqualToString:@"<"],
    @"Didn't translate < entity");
  STAssertTrue([[@"&gt;"    stringByRemovingHTMLTags] isEqualToString:@">"],
    @"Didn't translate > entity");

  STAssertTrue([[@"<html>" stringByRemovingHTMLTags] isEqualToString:@""], @"Failed to remove tag");
  STAssertTrue([[@"<html>three20</html>" stringByRemovingHTMLTags] isEqualToString:@"three20"],
    @"Failed to remove tag");
  STAssertTrue([[@"<span class=\"large\">three20</span>"
    stringByRemovingHTMLTags] isEqualToString:@"three20"], @"Failed to remove tag");
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)testNSString_queryDictionaryUsingEncoding {
  NSDictionary* query;

  query = [@"" queryDictionaryUsingEncoding:NSUTF8StringEncoding];
  STAssertTrue([query count] == 0, @"Query: %@", query);

  query = [@"q" queryDictionaryUsingEncoding:NSUTF8StringEncoding];
  STAssertTrue([query count] == 0, @"Query: %@", query);

  query = [@"q=" queryDictionaryUsingEncoding:NSUTF8StringEncoding];
  STAssertTrue([[query objectForKey:@"q"] isEqualToString:@""], @"Query: %@", query);

  query = [@"q=three20" queryDictionaryUsingEncoding:NSUTF8StringEncoding];
  STAssertTrue([[query objectForKey:@"q"] isEqualToString:@"three20"], @"Query: %@", query);

  query = [@"q=three20%20github" queryDictionaryUsingEncoding:NSUTF8StringEncoding];
  STAssertTrue([[query objectForKey:@"q"] isEqualToString:@"three20 github"], @"Query: %@", query);

  query = [@"q=three20&hl=en" queryDictionaryUsingEncoding:NSUTF8StringEncoding];
  STAssertTrue([[query objectForKey:@"q"] isEqualToString:@"three20"], @"Query: %@", query);
  STAssertTrue([[query objectForKey:@"hl"] isEqualToString:@"en"], @"Query: %@", query);

  query = [@"q=three20&hl=" queryDictionaryUsingEncoding:NSUTF8StringEncoding];
  STAssertTrue([[query objectForKey:@"q"] isEqualToString:@"three20"], @"Query: %@", query);
  STAssertTrue([[query objectForKey:@"hl"] isEqualToString:@""], @"Query: %@", query);

  query = [@"q=&&hl=" queryDictionaryUsingEncoding:NSUTF8StringEncoding];
  STAssertTrue([[query objectForKey:@"q"] isEqualToString:@""], @"Query: %@", query);
  STAssertTrue([[query objectForKey:@"hl"] isEqualToString:@""], @"Query: %@", query);

  query = [@"q=three20=repo&hl=en" queryDictionaryUsingEncoding:NSUTF8StringEncoding];
  STAssertNil([query objectForKey:@"q"], @"Query: %@", query);
  STAssertTrue([[query objectForKey:@"hl"] isEqualToString:@"en"], @"Query: %@", query);

  query = [@"&&" queryDictionaryUsingEncoding:NSUTF8StringEncoding];
  STAssertTrue([query count] == 0, @"Query: %@", query);
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)testNSString_queryContentsUsingEncoding {
	NSDictionary* query;

	query = [@"" queryContentsUsingEncoding:NSUTF8StringEncoding];
	STAssertTrue([query count] == 0, @"Query: %@", query);

	query = [@"q" queryContentsUsingEncoding:NSUTF8StringEncoding];
	STAssertTrue([[query objectForKey:@"q"] isEqual:[NSArray arrayWithObject:[NSNull null]]],
               @"Query: %@", query);

	query = [@"q=" queryContentsUsingEncoding:NSUTF8StringEncoding];
	STAssertTrue([[query objectForKey:@"q"] isEqual:[NSArray arrayWithObject:@""]],
               @"Query: %@", query);

	query = [@"q=three20" queryContentsUsingEncoding:NSUTF8StringEncoding];
	STAssertTrue([[query objectForKey:@"q"] isEqual:[NSArray arrayWithObject:@"three20"]],
               @"Query: %@", query);

	query = [@"q=three20%20github" queryContentsUsingEncoding:NSUTF8StringEncoding];
	STAssertTrue([[query objectForKey:@"q"] isEqual:[NSArray arrayWithObject:@"three20 github"]],
               @"Query: %@", query);

	query = [@"q=three20&hl=en" queryContentsUsingEncoding:NSUTF8StringEncoding];
	STAssertTrue([[query objectForKey:@"q"] isEqual:[NSArray arrayWithObject:@"three20"]],
               @"Query: %@", query);
	STAssertTrue([[query objectForKey:@"hl"] isEqual:[NSArray arrayWithObject:@"en"]],
               @"Query: %@", query);

	query = [@"q=three20&hl=" queryContentsUsingEncoding:NSUTF8StringEncoding];
	STAssertTrue([[query objectForKey:@"q"] isEqual:[NSArray arrayWithObject:@"three20"]],
               @"Query: %@", query);
	STAssertTrue([[query objectForKey:@"hl"] isEqual:[NSArray arrayWithObject:@""]],
               @"Query: %@", query);

	query = [@"q=&&hl=" queryContentsUsingEncoding:NSUTF8StringEncoding];
	STAssertTrue([[query objectForKey:@"q"] isEqual:[NSArray arrayWithObject:@""]],
               @"Query: %@", query);
	STAssertTrue([[query objectForKey:@"hl"] isEqual:[NSArray arrayWithObject:@""]],
               @"Query: %@", query);

	query = [@"q=three20=repo&hl=en" queryContentsUsingEncoding:NSUTF8StringEncoding];
	STAssertNil([query objectForKey:@"q"], @"Query: %@", query);
	STAssertTrue([[query objectForKey:@"hl"] isEqual:[NSArray arrayWithObject:@"en"]],
               @"Query: %@", query);

	query = [@"&&" queryContentsUsingEncoding:NSUTF8StringEncoding];
	STAssertTrue([query count] == 0, @"Query: %@", query);

	query = [@"q=foo&q=three20" queryContentsUsingEncoding:NSUTF8StringEncoding];
	NSArray* qArr = [NSArray arrayWithObjects:@"foo", @"three20", nil];
	STAssertTrue([[query objectForKey:@"q"] isEqual:qArr], @"Query: %@", query);

	query = [@"q=foo&q=three20&hl=en" queryContentsUsingEncoding:NSUTF8StringEncoding];
	qArr = [NSArray arrayWithObjects:@"foo", @"three20", nil];
	STAssertTrue([[query objectForKey:@"q"] isEqual:qArr], @"Query: %@", query);
	STAssertTrue([[query objectForKey:@"hl"] isEqual:[NSArray arrayWithObject:@"en"]],
               @"Query: %@", query);

	query = [@"q=foo&q=three20&hl=en&g" queryContentsUsingEncoding:NSUTF8StringEncoding];
	qArr = [NSArray arrayWithObjects:@"foo", @"three20", nil];
	STAssertTrue([[query objectForKey:@"q"] isEqual:qArr], @"Query: %@", query);
	STAssertTrue([[query objectForKey:@"hl"] isEqual:[NSArray arrayWithObject:@"en"]],
               @"Query: %@", query);
	STAssertTrue([[query objectForKey:@"g"] isEqual:[NSArray arrayWithObject:[NSNull null]]],
               @"Query: %@", query);

	query = [@"q&q=three20&hl=en&g" queryContentsUsingEncoding:NSUTF8StringEncoding];
	qArr = [NSArray arrayWithObjects:[NSNull null], @"three20", nil];
	STAssertTrue([[query objectForKey:@"q"] isEqual:qArr], @"Query: %@", query);
	STAssertTrue([[query objectForKey:@"hl"] isEqual:[NSArray arrayWithObject:@"en"]],
               @"Query: %@", query);
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)testNSString_stringByAddingQueryDictionary {
  NSString* baseUrl = @"http://google.com/search";
  STAssertTrue([[baseUrl stringByAddingQueryDictionary:nil] isEqualToString:
    [baseUrl stringByAppendingString:@"?"]], @"Empty dictionary fail.");

  STAssertTrue([[baseUrl stringByAddingQueryDictionary:[NSDictionary dictionary]] isEqualToString:
    [baseUrl stringByAppendingString:@"?"]], @"Empty dictionary fail.");

  STAssertTrue([[baseUrl stringByAddingQueryDictionary:[NSDictionary
    dictionaryWithObject:@"three20" forKey:@"q"]] isEqualToString:
    [baseUrl stringByAppendingString:@"?q=three20"]], @"Single parameter fail.");

  NSDictionary* query = [NSDictionary
    dictionaryWithObjectsAndKeys:
      @"three20", @"q",
      @"en",      @"hl",
      nil];
  NSString* baseUrlWithQuery = [baseUrl stringByAddingQueryDictionary:query];
  STAssertTrue([baseUrlWithQuery isEqualToString:[baseUrl
                                                  stringByAppendingString:@"?hl=en&q=three20"]]
               || [baseUrlWithQuery isEqualToString:[baseUrl
                                                     stringByAppendingString:@"?q=three20&hl=en"]],
    @"Additional query parameters not correct. %@", [baseUrl stringByAddingQueryDictionary:query]);
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)testNSString_versionStringCompare {
  STAssertTrue([@"3.0"   versionStringCompare:@"3.0"]    == NSOrderedSame, @"same version");
  STAssertTrue([@"3.0a2" versionStringCompare:@"3.0a2"]  == NSOrderedSame, @"same version alpha");
  STAssertTrue([@"3.0"   versionStringCompare:@"2.5"]    == NSOrderedDescending, @"major no alpha");
  STAssertTrue([@"3.1"   versionStringCompare:@"3.0"]    == NSOrderedDescending, @"minor no alpha");
  STAssertTrue([@"3.0a1" versionStringCompare:@"3.0"]    == NSOrderedAscending, @"alpha-no alpha");
  STAssertTrue([@"3.0a1" versionStringCompare:@"3.0a4"]  == NSOrderedAscending, @"alpha diff");
  STAssertTrue([@"3.0a2" versionStringCompare:@"3.0a19"] == NSOrderedAscending, @"numeric alpha");
  STAssertTrue([@"3.0a"  versionStringCompare:@"3.0a1"]  == NSOrderedAscending, @"empty alpha");
  STAssertTrue([@"3.02"  versionStringCompare:@"3.03"]   == NSOrderedAscending, @"point diff");
  STAssertTrue([@"3.0.2" versionStringCompare:@"3.0.3"]  == NSOrderedAscending, @"point diff");
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark NSArrayAdditions


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)testNSArray_perform {
  NSMutableArray* obj1 = [[NSMutableArray alloc] init];
  NSMutableArray* obj2 = [[NSMutableArray alloc] init];
  NSMutableArray* obj3 = [[NSMutableArray alloc] init];

  NSArray* arrayWithObjects = [[NSArray alloc] initWithObjects:obj1, obj2, obj3, nil];

  // Invalid selector

  [arrayWithObjects perform:@selector(three20)];

  // No parameters

  [arrayWithObjects perform:@selector(retain)];

  for (id obj in arrayWithObjects) {
    STAssertTrue([obj retainCount] == 3, @"Retain count wasn't modified, %d", [obj retainCount]);
  }

  [arrayWithObjects perform:@selector(release)];

  for (id obj in arrayWithObjects) {
    STAssertTrue([obj retainCount] == 2, @"Retain count wasn't modified, %d", [obj retainCount]);
  }

  // One parameter

  NSMutableArray* obj4 = [[NSMutableArray alloc] init];
  [arrayWithObjects perform:@selector(addObject:) withObject:obj4];

  for (id obj in arrayWithObjects) {
    STAssertTrue([obj count] == 1, @"The new object wasn't added, %d", [obj count]);
  }

  // Two parameters

  NSMutableArray* obj5 = [[NSMutableArray alloc] init];
  [arrayWithObjects perform:@selector(replaceObjectAtIndex:withObject:)
                 withObject:0 withObject:obj5];

  for (id obj in arrayWithObjects) {
    STAssertTrue([obj count] == 1, @"The array should have the same count, %d", [obj count]);
    STAssertEquals([obj objectAtIndex:0], obj5, @"The new object should have been swapped");
  }

  TT_RELEASE_SAFELY(arrayWithObjects);
  TT_RELEASE_SAFELY(obj1);
  TT_RELEASE_SAFELY(obj2);
  TT_RELEASE_SAFELY(obj3);
  TT_RELEASE_SAFELY(obj4);
  TT_RELEASE_SAFELY(obj5);
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)testNSArray_makeObjectsPerformSelector {
  NSMutableArray* obj1 = [[NSMutableArray alloc] init];
  NSMutableArray* obj2 = [[NSMutableArray alloc] init];
  NSMutableArray* obj3 = [[NSMutableArray alloc] init];

  NSArray* arrayWithObjects = [[NSArray alloc] initWithObjects:obj1, obj2, obj3, nil];

  // Two parameters

  NSMutableArray* obj5 = [[NSMutableArray alloc] init];
  [arrayWithObjects makeObjectsPerformSelector:@selector(insertObject:atIndex:)
    withObject:obj5 withObject:0];

  for (id obj in arrayWithObjects) {
    STAssertTrue([obj count] == 1, @"The array should have the same count, %d", [obj count]);
    STAssertEquals([obj objectAtIndex:0], obj5, @"The new object should have been swapped");
  }

  TT_RELEASE_SAFELY(arrayWithObjects);
  TT_RELEASE_SAFELY(obj1);
  TT_RELEASE_SAFELY(obj2);
  TT_RELEASE_SAFELY(obj3);
  TT_RELEASE_SAFELY(obj5);
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)testNSArray_objectWithValue {
  NSArray* arrayWithObjects = [[NSArray alloc] initWithObjects:
    [NSDictionary dictionaryWithObject:@"three20" forKey:@"name"],
    [NSDictionary dictionaryWithObject:@"objc"    forKey:@"name"],
    nil];

  STAssertNotNil([arrayWithObjects objectWithValue:@"three20" forKey:@"name"],
    @"Should have found an object");

  STAssertNil([arrayWithObjects objectWithValue:@"three20" forKey:@"no"],
    @"Should not have found an object");

  STAssertNil([arrayWithObjects objectWithValue:@"three20" forKey:nil],
    @"Should not have found an object");

  STAssertNil([arrayWithObjects objectWithValue:nil forKey:@"name"],
    @"Should not have found an object");

  STAssertNil([arrayWithObjects objectWithValue:nil forKey:nil],
    @"Should not have found an object");

  TT_RELEASE_SAFELY(arrayWithObjects);
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)testNSArray_objectWithClass {
  NSArray* arrayWithObjects = [[NSArray alloc] initWithObjects:
    [NSMutableDictionary dictionaryWithObject:@"three20" forKey:@"name"],
    [NSMutableDictionary dictionaryWithObject:@"objc" forKey:@"name"],
    nil];

  STAssertNotNil([arrayWithObjects objectWithClass:[NSDictionary class]],
    @"Should have found an object");

  STAssertNotNil([arrayWithObjects objectWithClass:[NSMutableDictionary class]],
    @"Should have found an object");

  STAssertNil([arrayWithObjects objectWithClass:[NSArray class]],
    @"Should not have found an object");

  STAssertNil([arrayWithObjects objectWithClass:nil],
    @"Should not have found an object");

  TT_RELEASE_SAFELY(arrayWithObjects);
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Non-empty strings for NSMutableArray and NSMutableDictionary


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)testNSMutableArray_NonEmptyStrings {
  NSMutableArray* arrayOfStrings = [[NSMutableArray alloc] init];

  [arrayOfStrings addNonEmptyString:nil];
  STAssertTrue([arrayOfStrings count] == 0, @"nil shouldn't be added");

  [arrayOfStrings addNonEmptyString:@""];
  STAssertTrue([arrayOfStrings count] == 0, @"empty string shouldn't be added");

  [arrayOfStrings addNonEmptyString:@"three20"];
  STAssertTrue([arrayOfStrings count] == 1, @"string should have been added");

  TT_RELEASE_SAFELY(arrayOfStrings);
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)testNSMutableDictionary_NonEmptyStrings {
  NSMutableDictionary* dictionaryOfStrings = [[NSMutableDictionary alloc] init];

  [dictionaryOfStrings setNonEmptyString:nil forKey:@"name"];
  STAssertTrue([dictionaryOfStrings count] == 0, @"nil shouldn't be added");

  [dictionaryOfStrings setNonEmptyString:@"" forKey:@"name"];
  STAssertTrue([dictionaryOfStrings count] == 0, @"empty string shouldn't be added");

  [dictionaryOfStrings setNonEmptyString:@"three20" forKey:@"name"];
  STAssertTrue([dictionaryOfStrings count] == 1, @"string should have been added");

  TT_RELEASE_SAFELY(dictionaryOfStrings);
}


@end
