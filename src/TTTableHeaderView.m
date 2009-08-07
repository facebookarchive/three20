#include "Three20/TTTableHeaderView.h"
#include "Three20/TTDefaultStyleSheet.h"

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation TTTableHeaderView

- (id)initWithTitle:(NSString*)title {
  if (self = [super init]) {
    self.backgroundColor = [UIColor clearColor];
    self.style = TTSTYLE(tableHeader);
    
    _label = [[UILabel alloc] init];
    _label.text = title;
    _label.backgroundColor = [UIColor clearColor];
    _label.textColor = TTSTYLEVAR(tableHeaderTextColor)
                       ? TTSTYLEVAR(tableHeaderTextColor)
                       : TTSTYLEVAR(linkTextColor);
    _label.shadowColor = TTSTYLEVAR(tableHeaderShadowColor)
                         ? TTSTYLEVAR(tableHeaderShadowColor)
                         : [UIColor clearColor];
    _label.shadowOffset = CGSizeMake(0, -1);
    _label.font = TTSTYLEVAR(tableHeaderPlainFont);
    [self addSubview:_label];
  }
  return self;
}

- (void)dealloc {
  TT_RELEASE_SAFELY(_label);
  [super dealloc];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// UIView

- (void)layoutSubviews {
  _label.frame = CGRectMake(12, 0, self.width, self.height);
}

@end

