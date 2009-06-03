#import "Three20/TTGlobal.h"

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation NSDate (TTCategory)

+ (NSDate*)dateWithToday {
  NSDateFormatter* formatter = [[[NSDateFormatter alloc] init] autorelease];
  formatter.dateFormat = @"yyyy-d-M";
  
  NSString* time = [formatter stringFromDate:[NSDate date]];
  NSDate* date = [formatter dateFromString:time];
  return date;
}

- (NSDate*)dateAtMidnight {
  NSDateFormatter* formatter = [[[NSDateFormatter alloc] init] autorelease];
  formatter.dateFormat = @"yyyy-d-M";
  
  NSString* time = [formatter stringFromDate:self];
  NSDate* date = [formatter dateFromString:time];
  return date;
}

@end
