#import "Three20/TTGlobal.h"

@interface TTSearchlightLabel : UIView {
  NSString* _text;
  UIFont* _font;
  UIColor* textColor;
  UIColor* _spotlightColor;
  UITextAlignment _textAlignment;
  NSTimer* _timer;
  CGFloat _spotlightPoint;
  CGContextRef _maskContext;
  void* _maskData;
}

@property(nonatomic,copy) NSString* text;
@property(nonatomic,retain) UIFont* font;
@property(nonatomic,retain) UIColor* textColor;
@property(nonatomic,retain) UIColor* spotlightColor;
@property(nonatomic) UITextAlignment textAlignment;

- (void)startAnimating;
- (void)stopAnimating;

@end
