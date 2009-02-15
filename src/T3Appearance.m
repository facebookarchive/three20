#import "Three20/T3Appearance.h"

///////////////////////////////////////////////////////////////////////////////////////////////////

static T3Appearance* gAppearance = nil;

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation T3Appearance

@synthesize linkTextColor = _linkTextColor;

+ (T3Appearance*)appearance {
  if (!gAppearance) {
    gAppearance = [[T3Appearance alloc] init];
  }
  return gAppearance;
}

+ (void)setAppearance:(T3Appearance*)appearance {
  if (gAppearance != appearance) {
    [gAppearance release];
    gAppearance = [appearance retain];
  }
}

///////////////////////////////////////////////////////////////////////////////////////////////////

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
