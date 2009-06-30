#import "Three20/TTTableViewCell.h"

@class TTTableLinkedItem, TTTableActivityItem, TTTableErrorItem, TTTableControlItem,
       TTTableViewItem, TTImageView, TTErrorView, TTActivityLabel, TTStyledTextLabel;

@interface TTTableLinkedItemCell : TTTableViewCell {
  TTTableLinkedItem* _item;
}
@end

@interface TTTableTextItemCell : TTTableLinkedItemCell
@end

@interface TTTableCaptionedItemCell : TTTableLinkedItemCell
@end

@interface TTTableMoreButtonCell : TTTableCaptionedItemCell {
  UIActivityIndicatorView* _spinnerView;
  BOOL _animating;
}

@property(nonatomic) BOOL animating;

@end

@interface TTTableImageItemCell : TTTableTextItemCell {
  TTImageView* _iconView;
}
@end

@interface TTStyledTextTableItemCell : TTTableLinkedItemCell {
  TTStyledTextLabel* _label;
}
@end

@interface TTTableActivityItemCell : TTTableViewCell {
  TTTableActivityItem* _item;
  TTActivityLabel* _activityLabel;
}
@end

@interface TTTableErrorItemCell : TTTableViewCell {
  TTTableErrorItem* _item;
  TTErrorView* _errorView;
}
@end

@interface TTTableControlCell : TTTableViewCell {
  TTTableControlItem* _item;
  UIControl* _control;
}

@property(nonatomic,readonly) TTTableControlItem* item;
@property(nonatomic,readonly) UIControl* control;

@end
    
@interface TTTableFlushViewCell : TTTableViewCell {
  TTTableViewItem* _item;
  UIView* _view;
}

@property(nonatomic,readonly) TTTableViewItem* item;
@property(nonatomic,readonly) UIView* view;

@end
    