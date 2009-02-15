#import "Three20/T3Global.h"

@interface T3MenuViewCell : UIView {
  id _object;
  UILabel* _labelView;
  BOOL _selected;
}

@property(nonatomic,retain) id object;
@property(nonatomic,copy) NSString* label;
@property(nonatomic,retain) UIFont* font;
@property(nonatomic) BOOL selected;

@end
