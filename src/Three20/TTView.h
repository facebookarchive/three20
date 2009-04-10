#import "Three20/TTStyle.h"

@class TTStyle, TTLayout;

/**
 * A decorational view that can styled using a TTStyle object.
 */
@interface TTView : UIView <TTStyleDelegate> {
  TTStyle* _style;
  TTLayout* _layout;
}

@property(nonatomic,retain) TTStyle* style;
@property(nonatomic,retain) TTLayout* layout;

- (void)drawContent:(CGRect)rect;

@end
