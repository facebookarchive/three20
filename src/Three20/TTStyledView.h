#import "Three20/TTStyle.h"

@class TTStyle;

/**
 * A decorational view that can styled using a TTStyle object.
 */
@interface TTStyledView : UIView <TTStyleDelegate> {
  TTStyle* _style;
  UIEdgeInsets _backgroundInset;
}

@property(nonatomic,retain) TTStyle* style;
@property(nonatomic) UIEdgeInsets backgroundInset;

- (void)drawContent:(CGRect)rect;

@end
