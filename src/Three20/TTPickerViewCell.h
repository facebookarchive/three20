#import "Three20/TTStyledView.h"

@interface TTPickerViewCell : TTStyledView {
  id _object;
  UILabel* _labelView;
  BOOL _selected;
}

@property(nonatomic,retain) id object;
@property(nonatomic,copy) NSString* label;
@property(nonatomic,retain) UIFont* font;
@property(nonatomic) BOOL selected;

@end
