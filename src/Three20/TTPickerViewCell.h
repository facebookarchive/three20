#import "Three20/TTView.h"

@interface TTPickerViewCell : TTView {
  id _object;
  UILabel* _labelView;
  BOOL _selected;
}

@property(nonatomic,retain) id object;
@property(nonatomic,copy) NSString* label;
@property(nonatomic,retain) UIFont* font;
@property(nonatomic) BOOL selected;

@end
