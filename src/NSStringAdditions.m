#import "Three20/TTGlobal.h"

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation NSString (TTCategory)

- (BOOL)isWhitespace {
  NSCharacterSet* whitespace = [NSCharacterSet whitespaceAndNewlineCharacterSet];
  for (NSInteger i = 0; i < self.length; ++i) {
    unichar c = [self characterAtIndex:i];
    if (![whitespace characterIsMember:c]) {
      return NO;
    }
  }
  return YES;
}

- (BOOL)beginsWithString:(NSString*)substring {
  if (self.length < substring.length) {
    return NO;
  } else {
    NSRange searchRange = NSMakeRange(0, substring.length);
    NSRange range = [self rangeOfString:substring options:0 range:searchRange];
    return range.location == searchRange.location;
  }
}

- (BOOL)endsWithString:(NSString*)substring {
  if (self.length < substring.length) {
    return NO;
  } else {
    NSRange searchRange = NSMakeRange(self.length - substring.length, substring.length);
    NSRange range = [self rangeOfString:substring options:0 range:searchRange];
    return range.location == searchRange.location;
  }

  NSRange range = [self rangeOfString:substring];
  return range.location == self.length - substring.length;
}

// Copied and pasted from http://www.mail-archive.com/cocoa-dev@lists.apple.com/msg28175.html
- (NSDictionary*)queryDictionaryUsingEncoding: (NSStringEncoding)encoding {
  NSCharacterSet* delimiterSet = [NSCharacterSet characterSetWithCharactersInString:@"&;"];
  NSMutableDictionary* pairs = [NSMutableDictionary dictionary];
  NSScanner* scanner = [[NSScanner alloc] initWithString:self];
  while (![scanner isAtEnd]) {
    NSString* pairString;
    [scanner scanUpToCharactersFromSet:delimiterSet intoString:&pairString];
    [scanner scanCharactersFromSet:delimiterSet intoString:NULL];
    NSArray* kvPair = [pairString componentsSeparatedByString:@"="];
    if (kvPair.count == 2) {
      NSString* key = [[kvPair objectAtIndex:0] stringByReplacingPercentEscapesUsingEncoding:encoding];
      NSString* value = [[kvPair objectAtIndex:1] stringByReplacingPercentEscapesUsingEncoding:encoding];
      [pairs setObject:value forKey:key];
    }
  }

  return [NSDictionary dictionaryWithDictionary:pairs];
}

@end
