#import "Three20/TTStyledView.h"

@interface TTStyledLabel : TTStyledView {
  NSString* _text;
  UIFont* _font;
}

@property(nonatomic,copy) NSString* text;
@property(nonatomic,retain) UIFont* font;

- (id)initWithText:(NSString*)text;

@end
