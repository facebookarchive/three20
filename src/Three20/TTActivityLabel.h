#import "Three20/TTGlobal.h"

typedef enum {
  TTActivityLabelStyleWhite,
  TTActivityLabelStyleGray,
  TTActivityLabelStyleBlackBezel,
  TTActivityLabelStyleBlackThinBezel,
  TTActivityLabelStyleWhiteBezel,
  TTActivityLabelStyleWhiteBox
} TTActivityLabelStyle;

@protocol TTActivityLabelDelegate;
@class TTStyleView;

@interface TTActivityLabel : UIView {
  id<TTActivityLabelDelegate> _delegate;
  TTActivityLabelStyle _style;
  TTStyleView* _bezelView;
  UIActivityIndicatorView* _spinner;
  UILabel* _textView;
  UIButton* _stopButton;
  BOOL _centered;
  BOOL _centeredToScreen;
  BOOL _showsStopButton;
}

@property(nonatomic,assign) id<TTActivityLabelDelegate> delegate;
@property(nonatomic,readonly) TTActivityLabelStyle style;
@property(nonatomic,assign) NSString* text;
@property(nonatomic) BOOL centered;
@property(nonatomic) BOOL centeredToScreen;
@property(nonatomic) BOOL showsStopButton;

- (id)initWithFrame:(CGRect)frame style:(TTActivityLabelStyle)style;
- (id)initWithFrame:(CGRect)frame style:(TTActivityLabelStyle)style text:(NSString*)text;

@end

@protocol TTActivityLabelDelegate <NSObject>

- (void)activityLabelDidStop:(TTActivityLabel*)label;

@end
