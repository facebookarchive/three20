#import "Three20/TTGlobal.h"

typedef enum {
  TTActivityLabelStyleWhite,
  TTActivityLabelStyleGray,
  TTActivityLabelStyleBlackBezel,
  TTActivityLabelStyleBlackThinBezel,
  TTActivityLabelStyleWhiteBezel,
  TTActivityLabelStyleWhiteBox
} TTActivityLabelStyle;

@class TTBackgroundView;

@interface TTActivityLabel : UIView {
  TTActivityLabelStyle _style;
  TTBackgroundView* _bezelView;
  UIActivityIndicatorView* _spinner;
  UILabel* _textView;
  BOOL _centered;
  BOOL _centeredToScreen;
}

@property(nonatomic,readonly) TTActivityLabelStyle style;
@property(nonatomic,assign) NSString* text;
@property(nonatomic) BOOL centered;
@property(nonatomic) BOOL centeredToScreen;

- (id)initWithFrame:(CGRect)frame style:(TTActivityLabelStyle)style;
- (id)initWithFrame:(CGRect)frame style:(TTActivityLabelStyle)style text:(NSString*)text;

@end
