#import "Three20/T3Global.h"

@class T3ImageView, T3ErrorView;

@interface T3TableViewCell : UITableViewCell {
  id object;
}

@property(nonatomic,retain) id object;

+ (CGFloat)rowHeightForItem:(id)item tableView:(UITableView*)tableView;

- (id)initWithFrame:(CGRect)frame style:(int)style reuseIdentifier:(NSString*)identifier;

@end

@interface T3TitleTableViewCell : T3TableViewCell {
  UILabel* titleLabel;
}

@end

@interface T3TextTableViewCell : T3TableViewCell {
  UILabel* textLabel;
}

@end

@interface T3KeyValueTableViewCell : T3TableViewCell {
  UILabel* keyLabel;
  UILabel* valueLabel;
}
@end

@interface T3IconTableViewCell : T3TableViewCell {
  UILabel* titleLabel;
  T3ImageView* iconView;
}

@end

@interface T3TextFieldTableViewCell : T3TableViewCell {
  UILabel* titleLabel;
  UITextField* textField;
}

@property(nonatomic,readonly) UITextField* textField;

@end

@interface T3TextEditorTableViewCell : T3TableViewCell {
  UITextView* textEditor;
}

@property(nonatomic,readonly) UITextView* textEditor;

@end

@interface T3ActivityTableViewCell : T3TableViewCell {
  UIActivityIndicatorView* spinnerView;
  UILabel* titleLabel;
  UILabel* subtitleLabel;
  BOOL animating;
}

@property(nonatomic) BOOL animating;

@end

@interface T3ErrorTableViewCell : T3TableViewCell {
  T3ErrorView* emptyView;
}

@end
