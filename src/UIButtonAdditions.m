#import "Three20/TTAppearance.h"

@implementation UIButton (TTCategory)

+ (UIButton*)blackButton {
  UIImage* image = [TTAppearance appearance].blackButtonImage;

  UIButton* button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
  button.font = [UIFont boldSystemFontOfSize:12];
  [button setBackgroundImage:image forState:UIControlStateNormal];
  [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
  [button setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
  [button setTitleShadowColor:[UIColor colorWithWhite:0 alpha:0.5]
    forState:UIControlStateNormal];
  [button setTitleShadowOffset:CGSizeMake(0, 1)];
  return button;
}

@end
