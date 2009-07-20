#import "Three20/TTGlobal.h"

///////////////////////////////////////////////////////////////////////////////////////////////////
// global 

#define ONE_MINUTE 60
#define ONE_HOUR (60*ONE_MINUTE)
#define ONE_DAY (24*ONE_HOUR)
#define ONE_WEEK (7*ONE_DAY)
#define ONE_MONTH (30.5*ONE_DAY)
#define ONE_YEAR (365*ONE_DAY)

static NSDateFormatter* dayFormatter = nil;

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation NSDate (TTCategory)

///////////////////////////////////////////////////////////////////////////////////////////////////
// class public

+ (NSDate*)dateWithToday {
  NSDateFormatter* formatter = [[[NSDateFormatter alloc] init] autorelease];
  formatter.dateFormat = @"yyyy-d-M";
  
  NSString* time = [formatter stringFromDate:[NSDate date]];
  NSDate* date = [formatter dateFromString:time];
  return date;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// public

- (NSDate*)dateAtMidnight {
  NSDateFormatter* formatter = [[[NSDateFormatter alloc] init] autorelease];
  formatter.dateFormat = @"yyyy-d-M";
  
  NSString* time = [formatter stringFromDate:self];
  NSDate* date = [formatter dateFromString:time];
  return date;
}

- (NSString*)formatTime {
  static NSDateFormatter* timeFormatter = nil;
  if (!timeFormatter) {
    timeFormatter = [[NSDateFormatter alloc] init];
    timeFormatter.dateFormat = TTLocalizedString(@"h:mm a", @"");
    timeFormatter.locale = TTCurrentLocale();
  }
  return [timeFormatter stringFromDate:self];
}

- (NSString*)formatDate {
  static NSDateFormatter* fullDateFormatter = nil;
  if (!fullDateFormatter) {
    fullDateFormatter = [[NSDateFormatter alloc] init];
    fullDateFormatter.dateFormat = TTLocalizedString(@"EEEE, LLLL d, YYYY", @"");
    fullDateFormatter.locale = TTCurrentLocale();
  }
  return [fullDateFormatter stringFromDate:self];
}

- (NSString*)formatShortTime {
  NSTimeInterval diff = abs([self timeIntervalSinceNow]);
  if (diff < ONE_DAY) {
    return [self formatTime];
  } else if (diff < ONE_WEEK) {
    static NSDateFormatter* shortTimeFormatterWeek = nil;
    if (!shortTimeFormatterWeek) {
      shortTimeFormatterWeek = [[NSDateFormatter alloc] init];
      shortTimeFormatterWeek.dateFormat = TTLocalizedString(@"EEEE", @"");
      shortTimeFormatterWeek.locale = TTCurrentLocale();
    }
    return [shortTimeFormatterWeek stringFromDate:self];
  } else {
    static NSDateFormatter* shortTimeFormatterYear = nil;
    if (!shortTimeFormatterYear) {
      shortTimeFormatterYear = [[NSDateFormatter alloc] init];
      shortTimeFormatterYear.dateFormat = TTLocalizedString(@"M/d/yy", @"");
      shortTimeFormatterYear.locale = TTCurrentLocale();
    }
    return [shortTimeFormatterYear stringFromDate:self];
  }
}

- (NSString*)formatDateTime {
  NSTimeInterval diff = abs([self timeIntervalSinceNow]);
  if (diff < ONE_DAY) {
    return [self formatTime];
  } else if (diff < ONE_WEEK) {
    static NSDateFormatter* shortTimeFormatterWeek = nil;
    if (!shortTimeFormatterWeek) {
      shortTimeFormatterWeek = [[NSDateFormatter alloc] init];
      shortTimeFormatterWeek.dateFormat = TTLocalizedString(@"EEE h:mm a", @"");
      shortTimeFormatterWeek.locale = TTCurrentLocale();
    }
    return [shortTimeFormatterWeek stringFromDate:self];
  } else {
    static NSDateFormatter* shortTimeFormatterYear = nil;
    if (!shortTimeFormatterYear) {
      shortTimeFormatterYear = [[NSDateFormatter alloc] init];
      shortTimeFormatterYear.dateFormat = TTLocalizedString(@"MMM d h:mm a", @"");
      shortTimeFormatterYear.locale = TTCurrentLocale();
    }
    return [shortTimeFormatterYear stringFromDate:self];
  }
}

- (NSString*)formatRelativeTime {
  NSTimeInterval elapsed = abs([self timeIntervalSinceNow]);
  if (elapsed <= 1) {
    return TTLocalizedString(@"just a moment ago", @"");
  } else if (elapsed < ONE_MINUTE) {
    int seconds = (int)(elapsed);
    return [NSString stringWithFormat:TTLocalizedString(@"%d seconds ago", @""), seconds];
  } else if (elapsed < 2*ONE_MINUTE) {
    return TTLocalizedString(@"about a minute ago", @"");
  } else if (elapsed < ONE_HOUR) {
    int mins = (int)(elapsed/ONE_MINUTE);
    return [NSString stringWithFormat:TTLocalizedString(@"%d minutes ago", @""), mins];
  } else if (elapsed < ONE_HOUR*1.5) {
    return TTLocalizedString(@"about an hour ago", @"");
  } else if (elapsed < ONE_DAY) {
    int hours = (int)((elapsed+ONE_HOUR/2)/ONE_HOUR);
    return [NSString stringWithFormat:TTLocalizedString(@"%d hours ago", @""), hours];
  } else {
    return [self formatDateTime];
//  } else if (elapsed < ONE_DAY*5) {
//    if (!weekdayFormatter) {
//      weekdayFormatter = [[NSDateFormatter alloc] init];
//      weekdayFormatter.dateFormat = @"EEEE";
//      weekdayFormatter.locale = TTCurrentLocale();
//    }
//    NSString* weekday = [weekdayFormatter stringFromDate:self];
//    return [NSString stringWithFormat:TTLocalizedString(@"on %@", @""), weekday];
//  } else if (elapsed < ONE_WEEK*1.5) {
//    return TTLocalizedString(@"about a week ago", @"");
//  } else if (elapsed < ONE_WEEK*3.5) {
//    int weeks = (int)((elapsed+ONE_WEEK/2)/ONE_WEEK);
//    return [NSString stringWithFormat:TTLocalizedString(@"%d weeks ago", @""), weeks];
//  } else if (elapsed < ONE_MONTH*1.5) {
//    return TTLocalizedString(@"about a month ago", @"");
//  } else if (elapsed < ONE_YEAR) {
//    int months = (int)((elapsed+ONE_MONTH/2)/ONE_MONTH);
//    return [NSString stringWithFormat:TTLocalizedString(@"%d months ago", @""), months];
//  } else {
//    return TTLocalizedString(@"over a year ago", @"");
  }
}

- (NSString*)formatDay:(NSDateComponents*)today yesterday:(NSDateComponents*)yest {
  if (!dayFormatter) {
    dayFormatter = [[NSDateFormatter alloc] init];
    dayFormatter.dateFormat = TTLocalizedString(@"MMMM d", @"");
    dayFormatter.locale = TTCurrentLocale();
  }

  NSCalendar* cal = [NSCalendar currentCalendar];
  NSDateComponents* day = [cal components:NSDayCalendarUnit|NSMonthCalendarUnit|NSYearCalendarUnit
                               fromDate:self];

  if (day.day == today.day && day.month == today.month && day.year == today.year) {
    return TTLocalizedString(@"Today", @"");
  } else if (day.day == yest.day && day.month == yest.month && day.year == yest.year) {
    return TTLocalizedString(@"Yesterday", @"");
  } else {
    return [dayFormatter stringFromDate:self];
  }
}

@end
