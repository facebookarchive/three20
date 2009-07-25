#import "Three20/TTGlobal.h"

typedef enum {
  TTActivityLabelStyleWhite,
  TTActivityLabelStyleGray,
  TTActivityLabelStyleBlackBox,
  TTActivityLabelStyleBlackBezel,
  TTActivityLabelStyleBlackBanner,
  TTActivityLabelStyleWhiteBezel,
  TTActivityLabelStyleWhiteBox
} TTActivityLabelStyle;

@class TTView, TTButton;

@interface TTActivityLabel : UIView {
  TTActivityLabelStyle _style;
  TTView* _bezelView;
  UIProgressView* _progressView;
  UIActivityIndicatorView* _activityIndicator;
  UILabel* _label;
}

@property(nonatomic,readonly) TTActivityLabelStyle style;
@property(nonatomic,assign) NSString* text;
@property(nonatomic,assign) UIFont* font;
@property(nonatomic) float progress;
@property(nonatomic) BOOL isAnimating;

- (id)initWithFrame:(CGRect)frame style:(TTActivityLabelStyle)style;
- (id)initWithFrame:(CGRect)frame style:(TTActivityLabelStyle)style text:(NSString*)text;
- (id)initWithStyle:(TTActivityLabelStyle)style;

@end
