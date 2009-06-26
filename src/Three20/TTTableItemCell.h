#import "Three20/TTTableViewCell.h"

@class TTTableItem, TTImageView, TTErrorView, TTActivityLabel, TTStyledTextLabel, TTSearchBar;

@interface TTTableItemCell : TTTableViewCell {
  TTTableItem* _field;
}
@end

@interface TTStyledTextTableItemCell : TTTableItemCell {
  TTStyledTextLabel* _label;
}
@end

@interface TTTextTableItemCell : TTTableItemCell
@end

@interface TTTitledTableItemCell : TTTextTableItemCell
@end

@interface TTSubtextTableItemCell : TTTextTableItemCell
@end

@interface TTMoreButtonTableItemCell : TTTextTableItemCell {
  UIActivityIndicatorView* _spinnerView;
  BOOL _animating;
}

@property(nonatomic) BOOL animating;

@end

@interface TTIconTableItemCell : TTTextTableItemCell {
  TTImageView* _iconView;
}
@end

@interface TTImageTableItemCell : TTIconTableItemCell
@end

@interface TTActivityTableItemCell : TTTableItemCell {
  TTActivityLabel* _activityLabel;
}

@end

@interface TTErrorTableItemCell : TTTableViewCell {
  TTTableItem* _field;
  TTErrorView* _errorView;
}
@end

@interface TTTextFieldTableItemCell : TTTextTableItemCell <UITextFieldDelegate>  {
  UITextField* _textField;
}

@property(nonatomic,readonly) UITextField* textField;

@end

@interface TTTextViewTableItemCell : TTTableViewCell <UITextViewDelegate> {
  TTTableItem* _field;
  UITextView* _textView;
}

@property(nonatomic,readonly) UITextView* textView;

@end

@interface TTSwitchTableItemCell : TTTextTableItemCell {
  UISwitch* _switch;
}

@end

@interface TTSearchBarTableItemCell : TTTableViewCell {
  TTSearchBar* _searchBar;
}

@end
    