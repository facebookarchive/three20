//
// Copyright 2009-2010 Facebook
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

#import "Three20Core/NSDateAdditions.h"

// Core
#import "Three20Core/TTCorePreprocessorMacros.h"
#import "Three20Core/TTGlobalCoreLocale.h"


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
/**
 * Additions.
 */
@implementation NSDate (TTCategory)


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Class public


///////////////////////////////////////////////////////////////////////////////////////////////////
+ (NSDate*)dateWithToday {
  NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
  formatter.dateFormat = @"yyyy-d-M";

  NSString* formattedTime = [formatter stringFromDate:[NSDate date]];
  NSDate* date = [formatter dateFromString:formattedTime];
  TT_RELEASE_SAFELY(formatter);

  return date;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Public


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSDate*)dateAtMidnight {
  NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
  formatter.dateFormat = @"yyyy-d-M";

  NSString* formattedTime = [formatter stringFromDate:self];
  NSDate* date = [formatter dateFromString:formattedTime];
  TT_RELEASE_SAFELY(formatter);

  return date;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSDate*)time {
	
	NSDateFormatter* formatter = [[[NSDateFormatter alloc] init] autorelease];
	formatter.dateFormat = @"HH:mm";
	
	NSString* formattedTime = [formatter stringFromDate:self];
	NSDate* date = [formatter dateFromString:formattedTime];
	return date;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSInteger)year {
	
	NSCalendar *calendar = [NSCalendar currentCalendar];
	
	NSDateComponents *comps = [calendar components: NSYearCalendarUnit fromDate: self];
	
	return [comps year];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSInteger)month {
	
	NSCalendar *calendar = [NSCalendar currentCalendar];
	
	NSDateComponents *comps = [calendar components: NSMonthCalendarUnit fromDate: self];
	
	return [comps month];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSInteger)weekInYear {
	
	NSCalendar *calendar = [NSCalendar currentCalendar];
	
	NSDateComponents *comps = [calendar components: NSWeekCalendarUnit fromDate: self];
	
	return [comps week];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSInteger)dayInMonth {
	
	NSCalendar *calendar = [NSCalendar currentCalendar];
	
	NSDateComponents *comps = [calendar components: NSWeekdayOrdinalCalendarUnit fromDate: self];
	
	return [comps weekdayOrdinal];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSInteger)dayInWeek {
	
	NSCalendar *calendar = [NSCalendar currentCalendar];
	
	NSDateComponents *comps = [calendar components: NSWeekdayCalendarUnit fromDate: self];
	
	return [comps weekday];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSInteger)dayInYear {
	
	NSCalendar *calendar = [NSCalendar currentCalendar];
	
	NSDateComponents *comps = [calendar components: NSDayCalendarUnit fromDate: self];
	
	return [comps day];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSInteger)hour {
	
	NSCalendar *calendar = [NSCalendar currentCalendar];
	
	NSDateComponents *comps = [calendar components: NSHourCalendarUnit fromDate: self];
	
	return [comps hour];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSInteger)minute {
	
	NSCalendar *calendar = [NSCalendar currentCalendar];
	
	NSDateComponents *comps = [calendar components: NSMinuteCalendarUnit fromDate: self];
	
	return [comps minute];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSInteger)second {
	
	NSCalendar *calendar = [NSCalendar currentCalendar];
	
	NSDateComponents *comps = [calendar components: NSSecondCalendarUnit fromDate: self];
	
	return [comps second];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSString*)formatTime {
  static NSDateFormatter* formatter = nil;
  if (!formatter) {
    formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = TTLocalizedString(@"h:mm a", @"Date format: 1:05 pm");
    formatter.locale = TTCurrentLocale();
  }
  return [formatter stringFromDate:self];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSString*)formatDate {
  static NSDateFormatter* formatter = nil;
  if (!formatter) {
    formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat =
      TTLocalizedString(@"EEEE, LLLL d, YYYY", @"Date format: Monday, July 27, 2009");
    formatter.locale = TTCurrentLocale();
  }
  return [formatter stringFromDate:self];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSString*)formatShortTime {
  NSTimeInterval diff = abs([self timeIntervalSinceNow]);

  if (diff < TT_DAY) {
    return [self formatTime];

  } else if (diff < TT_5_DAYS) {
    static NSDateFormatter* formatter = nil;
    if (!formatter) {
      formatter = [[NSDateFormatter alloc] init];
      formatter.dateFormat = TTLocalizedString(@"EEEE", @"Date format: Monday");
      formatter.locale = TTCurrentLocale();
    }
    return [formatter stringFromDate:self];

  } else {
    static NSDateFormatter* formatter = nil;
    if (!formatter) {
      formatter = [[NSDateFormatter alloc] init];
      formatter.dateFormat = TTLocalizedString(@"M/d/yy", @"Date format: 7/27/09");
      formatter.locale = TTCurrentLocale();
    }
    return [formatter stringFromDate:self];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSString*)formatDateTime {
  NSTimeInterval diff = abs([self timeIntervalSinceNow]);
  if (diff < TT_DAY) {
    return [self formatTime];

  } else if (diff < TT_5_DAYS) {
    static NSDateFormatter* formatter = nil;
    if (!formatter) {
      formatter = [[NSDateFormatter alloc] init];
      formatter.dateFormat = TTLocalizedString(@"EEE h:mm a", @"Date format: Mon 1:05 pm");
      formatter.locale = TTCurrentLocale();
    }
    return [formatter stringFromDate:self];

  } else {
    static NSDateFormatter* formatter = nil;
    if (!formatter) {
      formatter = [[NSDateFormatter alloc] init];
      formatter.dateFormat = TTLocalizedString(@"MMM d h:mm a", @"Date format: Jul 27 1:05 pm");
      formatter.locale = TTCurrentLocale();
    }
    return [formatter stringFromDate:self];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSString*)formatRelativeTime {
  NSTimeInterval elapsed = abs([self timeIntervalSinceNow]);
  if (elapsed <= 1) {
    return TTLocalizedString(@"just a moment ago", @"");

  } else if (elapsed < TT_MINUTE) {
    int seconds = (int)(elapsed);
    return [NSString stringWithFormat:TTLocalizedString(@"%d seconds ago", @""), seconds];

  } else if (elapsed < 2*TT_MINUTE) {
    return TTLocalizedString(@"about a minute ago", @"");

  } else if (elapsed < TT_HOUR) {
    int mins = (int)(elapsed/TT_MINUTE);
    return [NSString stringWithFormat:TTLocalizedString(@"%d minutes ago", @""), mins];

  } else if (elapsed < TT_HOUR*1.5) {
    return TTLocalizedString(@"about an hour ago", @"");

  } else if (elapsed < TT_DAY) {
    int hours = (int)((elapsed+TT_HOUR/2)/TT_HOUR);
    return [NSString stringWithFormat:TTLocalizedString(@"%d hours ago", @""), hours];

  } else {
    return [self formatDateTime];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSString*)formatShortRelativeTime {
  NSTimeInterval elapsed = abs([self timeIntervalSinceNow]);

  if (elapsed < TT_MINUTE) {
    return TTLocalizedString(@"<1m", @"Date format: less than one minute ago");

  } else if (elapsed < TT_HOUR) {
    int mins = (int)(elapsed / TT_MINUTE);
    return [NSString stringWithFormat:TTLocalizedString(@"%dm", @"Date format: 50m"), mins];

  } else if (elapsed < TT_DAY) {
    int hours = (int)((elapsed + TT_HOUR / 2) / TT_HOUR);
    return [NSString stringWithFormat:TTLocalizedString(@"%dh", @"Date format: 3h"), hours];

  } else if (elapsed < TT_WEEK) {
    int day = (int)((elapsed + TT_DAY / 2) / TT_DAY);
    return [NSString stringWithFormat:TTLocalizedString(@"%dd", @"Date format: 3d"), day];

  } else {
    return [self formatShortTime];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSString*)formatDay:(NSDateComponents*)today yesterday:(NSDateComponents*)yesterday {
  static NSDateFormatter* formatter = nil;
  if (!formatter) {
    formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = TTLocalizedString(@"MMMM d", @"Date format: July 27");
    formatter.locale = TTCurrentLocale();
  }

  NSCalendar* cal = [NSCalendar currentCalendar];
  NSDateComponents* day = [cal components:NSDayCalendarUnit|NSMonthCalendarUnit|NSYearCalendarUnit
                               fromDate:self];

  if (day.day == today.day && day.month == today.month && day.year == today.year) {
    return TTLocalizedString(@"Today", @"");
  } else if (day.day == yesterday.day && day.month == yesterday.month
             && day.year == yesterday.year) {
    return TTLocalizedString(@"Yesterday", @"");
  } else {
    return [formatter stringFromDate:self];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSString*)formatMonth {
  static NSDateFormatter* formatter = nil;
  if (!formatter) {
    formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = TTLocalizedString(@"MMMM", @"Date format: July");
    formatter.locale = TTCurrentLocale();
  }
  return [formatter stringFromDate:self];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSString*)formatYear {
  static NSDateFormatter* formatter = nil;
  if (!formatter) {
    formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = TTLocalizedString(@"yyyy", @"Date format: 2009");
    formatter.locale = TTCurrentLocale();
  }
  return [formatter stringFromDate:self];
}


@end
