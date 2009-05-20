#import "Three20/TTGlobal.h"

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation NSDate (TTCategory)

+ (id)dateWithToday {
  NSString* format = @"%Y-%m-%d";
  NSDateFormatter* formatter = [[[NSDateFormatter alloc] initWithDateFormat:format
                                                         allowNaturalLanguage:NO] autorelease];
  
  NSString* time = [formatter stringFromDate:[NSDate date]];
  return [formatter dateFromString:time];
}

@end
