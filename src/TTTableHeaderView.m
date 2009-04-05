#include "Three20/TTTableHeaderView.h"
#include "Three20/TTAppearance.h"

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation TTTableHeaderView

- (id)initWithTitle:(NSString*)title {
  if (self = [super initWithFrame:CGRectZero]) {
    self.backgroundColor = [UIColor clearColor];
    
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

- (void)drawRect:(CGRect)rect {
  UIColor* tint = [TTAppearance appearance].tableHeaderTintColor;
  UIColor* fill[] = {tint};
  [[TTAppearance appearance] draw:TTStyleReflection rect:rect
    fill:fill fillCount:1 stroke:nil radius:0];

  [[TTAppearance appearance] draw:TTStyleStrokeTop rect:CGRectOffset(rect, 0, 1)
    fill:nil fillCount:0 stroke:[UIColor whiteColor] radius:0];
  [[TTAppearance appearance] draw:TTStyleStrokeBottom rect:rect
    fill:nil fillCount:0 stroke:RGBACOLOR(0,0,0,0.05) radius:0];
}

- (void)layoutSubviews {
  _label.frame = CGRectMake(12, 0, self.width, 23);
}

@end

