#import "Three20/T3Theme.h"

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation T3Theme

@synthesize linkTextColor = _linkTextColor;

+ (T3Theme*)theme {
  static T3Theme* theme = nil;
  if (!theme) {
    theme = [[T3Theme alloc] init];
  }
  return theme;
}

- (id)init {
  if (self = [super init]) {
    self.linkTextColor = RGBCOLOR(87, 107, 149);
  }
  return self;
}

- (void)dealloc {
  [super dealloc];
}

@end
