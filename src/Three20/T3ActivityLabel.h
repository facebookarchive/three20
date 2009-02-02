#import "Three20/T3Global.h"

typedef enum {
  T3ActivityLabelStyleWhite,
  T3ActivityLabelStyleGray,
  T3ActivityLabelStyleBlackBezel,
  T3ActivityLabelStyleBlackThinBezel,
  T3ActivityLabelStyleWhiteBezel,
  T3ActivityLabelStyleWhiteBox
} T3ActivityLabelStyle;

@class T3BackgroundView;

@interface T3ActivityLabel : UIView {
  T3ActivityLabelStyle _style;
  T3BackgroundView* _bezelView;
  UIActivityIndicatorView* _spinner;
  UILabel* _textView;
  BOOL _centered;
  BOOL _centeredToScreen;
}

@property(nonatomic,readonly) T3ActivityLabelStyle style;
@property(nonatomic,assign) NSString* text;
@property(nonatomic) BOOL centered;
@property(nonatomic) BOOL centeredToScreen;

- (id)initWithFrame:(CGRect)frame style:(T3ActivityLabelStyle)style;
- (id)initWithFrame:(CGRect)frame style:(T3ActivityLabelStyle)style text:(NSString*)text;

@end
