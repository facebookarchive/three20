#import "Three20/TTGlobal.h"

typedef enum {
  TTActivityLabelStyleWhite,
  TTActivityLabelStyleGray,
  TTActivityLabelStyleBlackBox,
  TTActivityLabelStyleBlackBezel,
  TTActivityLabelStyleBlackThinBezel,
  TTActivityLabelStyleWhiteBezel,
  TTActivityLabelStyleWhiteBox
} TTActivityLabelStyle;

@protocol TTActivityLabelDelegate;
@class TTView, TTButton;

@interface TTActivityLabel : UIView {
  id<TTActivityLabelDelegate> _delegate;
  TTActivityLabelStyle _style;
  TTView* _bezelView;
  UIActivityIndicatorView* _spinner;
  UILabel* _textView;
  UIProgressView* _progressView;
  TTButton* _cancelButton;
  BOOL _centered;
  BOOL _centeredToScreen;
  BOOL _showsCancelButton;
}

@property(nonatomic,assign) id<TTActivityLabelDelegate> delegate;
@property(nonatomic,readonly) TTActivityLabelStyle style;
@property(nonatomic,assign) NSString* text;
@property(nonatomic,assign) UIFont* font;
@property(nonatomic) float progress;
@property(nonatomic) BOOL isAnimating;
@property(nonatomic) BOOL centered;
@property(nonatomic) BOOL centeredToScreen;
@property(nonatomic) BOOL showsCancelButton;

- (id)initWithFrame:(CGRect)frame style:(TTActivityLabelStyle)style;
- (id)initWithFrame:(CGRect)frame style:(TTActivityLabelStyle)style text:(NSString*)text;

@end

@protocol TTActivityLabelDelegate <NSObject>

- (void)activityLabelDidCancel:(TTActivityLabel*)label;

@end
