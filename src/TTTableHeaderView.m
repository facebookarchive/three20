#include "Three20/TTTableHeaderView.h"
#include "Three20/TTAppearance.h"

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation TTTableHeaderView

- (id)initWithTitle:(NSString*)title {
  if (self = [super initWithFrame:CGRectZero]) {
    self.backgroundColor = [UIColor clearColor];
    self.style = [TTAppearance appearance].tableHeaderStyle;
    
    _label = [[UILabel alloc] initWithFrame:CGRectZero];
    _label.text = title;
    _label.backgroundColor = [UIColor clearColor];
    _label.textColor = [TTAppearance appearance].tableHeaderTextColor
      ? [TTAppearance appearance].tableHeaderTextColor : [TTAppearance appearance].linkTextColor;
    _label.shadowColor = [TTAppearance appearance].tableHeaderShadowColor
      ? [TTAppearance appearance].tableHeaderShadowColor : [UIColor whiteColor];
    _label.shadowOffset = CGSizeMake(0, 1);
    _label.font = [UIFont boldSystemFontOfSize:18];
    [self addSubview:_label];
  }
  return self;
}

- (void)dealloc {
  [_label release];
  [super dealloc];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// UIView

- (void)layoutSubviews {
  _label.frame = CGRectMake(12, 0, self.width, 23);
}

@end

