#import "Three20/TTStyle.h"

@class TTStyle;

/**
 * A decorational view that can styled using a TTStyle object.
 */
@interface TTView : UIView <TTStyleDelegate> {
  TTStyle* _style;
}

@property(nonatomic,retain) TTStyle* style;

- (void)drawContent:(CGRect)rect;

@end
