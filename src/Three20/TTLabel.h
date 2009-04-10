#import "Three20/TTView.h"

@interface TTLabel : TTView {
  NSString* _text;
  UIFont* _font;
}

@property(nonatomic,copy) NSString* text;
@property(nonatomic,retain) UIFont* font;

- (id)initWithText:(NSString*)text;

@end
