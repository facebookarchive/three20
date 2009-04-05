#import "Three20/TTTableViewCell.h"

@class TTTableField, TTStyledView, TTErrorView, TTActivityLabel, TTStyledLabel;

@interface TTTableFieldCell : TTTableViewCell {
  TTTableField* _field;
}
@end

@interface TTTextTableFieldCell : TTTableFieldCell {
  UILabel* _label;
}
@end

@interface TTStyledTextTableFieldCell : TTTableFieldCell {
  TTStyledLabel* _label;
}
@end

@interface TTTitledTableFieldCell : TTTextTableFieldCell {
  UILabel* _titleLabel;
}
@end

@interface TTSubtextTableFieldCell : TTTextTableFieldCell {
  UILabel* _subtextLabel;
}
@end

@interface TTMoreButtonTableFieldCell : TTTextTableFieldCell {
  UIActivityIndicatorView* _spinnerView;
  UILabel* _subtitleLabel;
  BOOL _animating;
}

@property(nonatomic) BOOL animating;

@end

@interface TTIconTableFieldCell : TTTextTableFieldCell {
  TTStyledView* _iconView;
}
@end

@interface TTImageTableFieldCell : TTIconTableFieldCell

@end

@interface TTActivityTableFieldCell : TTTableFieldCell {
  TTActivityLabel* _activityLabel;
}

@end

@interface TTErrorTableFieldCell : TTTableViewCell {
  TTTableField* _field;
  TTErrorView* _errorView;
}
@end

@interface TTTextFieldTableFieldCell : TTTextTableFieldCell <UITextFieldDelegate>  {
  UITextField* _textField;
}

@property(nonatomic,readonly) UITextField* textField;

@end

@interface TTTextViewTableFieldCell : TTTableViewCell <UITextViewDelegate> {
  TTTableField* _field;
  UITextView* _textView;
}

@property(nonatomic,readonly) UITextView* textView;

@end

@interface TTSwitchTableFieldCell : TTTextTableFieldCell {
  UISwitch* _switch;
}

@end
