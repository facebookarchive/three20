/**
 * Copyright 2009 Facebook
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

// See: http://developer.apple.com/iphone/library/documentation/Xcode/Conceptual/iphone_development/905-A-Unit-Test_Result_Macro_Reference/unit-test_results.html#//apple_ref/doc/uid/TP40007959-CH21-SW2
// for unit test macros.

#import "AdditionTests.h"

#import "Three20/Three20.h"


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation AdditionTests


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)testSuccess {
  STAssertTrue(YES, @"Something is terribly, terribly wrong.");
}


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
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark NSStringAdditions


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)testNSString_isWhitespace {
  // From the Apple docs:
  // Returns a character set containing only the whitespace characters space (U+0020) and tab
  // (U+0009) and the newline and nextline characters (U+000A–U+000D, U+0085).
  STAssertTrue([@"" isWhitespace], @"Empty string should be whitespace.");
  STAssertTrue([@" " isWhitespace], @"Space character should be whitespace.");
  STAssertTrue([@"\t" isWhitespace], @"Tab character should be whitespace.");
  STAssertTrue([@"\n" isWhitespace], @"Newline character should be whitespace.");
  STAssertTrue([@"\r" isWhitespace], @"Carriage return character should be whitespace.");

  // Unicode whitespace
  for (int unicode = 0x000A; unicode <= 0x000D; ++unicode) {
    NSString* str = [NSString stringWithFormat:@"%C", unicode];
    STAssertTrue([str isWhitespace], @"Unicode string #%X should be whitespace.", unicode);
  }

  NSString* str = [NSString stringWithFormat:@"%C", 0x0085];
  STAssertTrue([str isWhitespace], @"Unicode string should be whitespace.");

  STAssertTrue([@" \t\r\n" isWhitespace], @"Empty string should be whitespace.");

  STAssertTrue(![@"a" isWhitespace], @"Text should not be whitespace.");
  STAssertTrue(![@" \r\n\ta\r\n " isWhitespace], @"Text should not be whitespace.");
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
  STAssertTrue([[baseUrl stringByAddingQueryDictionary:query]
    isEqualToString:[baseUrl stringByAppendingString:@"?hl=en&q=three20"]],
    @"Empty dictionary fail.");
}


@end
