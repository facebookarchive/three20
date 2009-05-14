#import "Three20/TTGlobal.h"

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation NSDate (TTCategory)

+ (id)dateWithToday {
  NSString* format = @"%Y-%m-%d 00:00:00 +0700";
  NSString* time = [[NSDate date] descriptionWithCalendarFormat:format timeZone:nil locale:nil];
  return [self dateWithString:time];
}

@end
