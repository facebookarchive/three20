#import "Three20/TTGlobal.h"

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation NSDate (TTCategory)

+ (id)dateWithToday {
  NSDateFormatter* formatter = [[[NSDateFormatter alloc] init] autorelease];
  formatter.dateFormat = @"yyyy-d-M";
  
#ifdef JOE
  NSString* time = [formatter stringFromDate:[NSDate dateWithTimeIntervalSinceNow:-(60*60*24*14)]];
# else
  NSString* time = [formatter stringFromDate:[NSDate date]];
#endif  
  NSDate* date = [formatter dateFromString:time];
  return date;
}

@end
