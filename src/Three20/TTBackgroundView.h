#import "Three20/TTAppearance.h"

/**
 * A decorational view that can painted using a variety of visual properties.
 */
@interface TTBackgroundView : UIView {
  TTDrawStyle _style;
  UIColor* _fillColor;
  UIColor* _fillColor2;
  UIColor* _strokeColor;
  int _strokeRadius;
  UIEdgeInsets _backgroundInset;
}

@property(nonatomic) TTDrawStyle style;
@property(nonatomic,retain) UIColor* fillColor;
@property(nonatomic,retain) UIColor* fillColor2;
@property(nonatomic,retain) UIColor* strokeColor;
@property(nonatomic) int strokeRadius;
@property(nonatomic) UIEdgeInsets backgroundInset;

@end
