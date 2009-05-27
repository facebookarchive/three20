#import "Three20/TTGlobal.h"

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation NSDate (TTCategory)

+ (id)dateWithToday {
  NSDateFormatter* formatter = [[[NSDateFormatter alloc] init] autorelease];
  formatter.dateFormat = @"yyyy-d-M";
  
  NSString* time = [formatter stringFromDate:[NSDate date]];
  NSDate* date = [formatter dateFromString:time];
  return date;
}

@end
