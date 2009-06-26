#import "Three20/TTTableViewCell.h"

@class TTTableField, TTImageView, TTErrorView, TTActivityLabel, TTStyledTextLabel, TTSearchBar;

@interface TTTableFieldCell : TTTableViewCell {
  TTTableField* _field;
}
@end

@interface TTStyledTextTableFieldCell : TTTableFieldCell {
  TTStyledTextLabel* _label;
}
@end

@interface TTTextTableFieldCell : TTTableFieldCell
@end

@interface TTTitledTableFieldCell : TTTextTableFieldCell
@end

@interface TTSubtextTableFieldCell : TTTextTableFieldCell
@end

@interface TTMoreButtonTableFieldCell : TTTextTableFieldCell {
  UIActivityIndicatorView* _spinnerView;
  BOOL _animating;
}

@property(nonatomic) BOOL animating;

@end

@interface TTIconTableFieldCell : TTTextTableFieldCell {
  TTImageView* _iconView;
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

@interface TTSearchBarTableFieldCell : TTTableViewCell {
  TTSearchBar* _searchBar;
}

@end
