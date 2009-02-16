#import "Three20/TTGlobal.h"

@interface TTShinyLabel : UIView {
  NSString* text;
  UIFont* font;
  UIColor* textColor;
  UIColor* spotlightColor;
  UITextAlignment textAlignment;
  NSTimer* timer;
  CGFloat spotlightPoint;
  CGContextRef maskContext;
  void* maskData;
}

@property(nonatomic,copy) NSString* text;
@property(nonatomic,retain) UIFont* font;
@property(nonatomic,retain) UIColor* textColor;
@property(nonatomic,retain) UIColor* spotlightColor;
@property(nonatomic) UITextAlignment textAlignment;

- (void)startAnimating;
- (void)stopAnimating;

@end
