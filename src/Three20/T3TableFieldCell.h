#import "Three20/T3TableViewCell.h"

@class T3ImageView, T3ErrorView;

@interface T3TableFieldCell : T3TableViewCell {
  UILabel* _label;
}
@end

@interface T3TextTableFieldCell : T3TableFieldCell
@end

@interface T3TitledTableFieldCell : T3TableFieldCell {
  UILabel* _titleLabel;
}
@end

@interface T3MoreButtonTableFieldCell : T3TableFieldCell {
  UIActivityIndicatorView* _spinnerView;
  UILabel* _subtitleLabel;
  BOOL _animating;
}

@property(nonatomic) BOOL animating;

@end

@interface T3ImageTableFieldCell : T3TableFieldCell {
  T3ImageView* _iconView;
}
@end

@interface T3IconTableFieldCell : T3ImageTableFieldCell

@end

@interface T3ActivityTableFieldCell : T3TableFieldCell {
  UIActivityIndicatorView* _spinnerView;
  BOOL _animating;
}

@property(nonatomic) BOOL animating;

@end

@interface T3ErrorTableFieldCell : T3TableViewCell {
  T3ErrorView* _errorView;
}
@end

@interface T3TextFieldTableFieldCell : T3TableViewCell <UITextFieldDelegate>  {
  UILabel* _titleLabel;
  UITextField* _textField;
}

@property(nonatomic,readonly) UITextField* textField;

@end

@interface T3TextViewTableFieldCell : T3TableViewCell <UITextViewDelegate> {
  UITextView* _textView;
}

@property(nonatomic,readonly) UITextView* textView;

@end


@interface T3SwitchTableFieldCell : T3TableFieldCell {
  UISwitch* _switch;
}

@end
