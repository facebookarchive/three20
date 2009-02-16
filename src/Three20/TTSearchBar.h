#import "Three20/TTGlobal.h"

@protocol TTSearchSource, TTSearchTextFieldDelegate;
@class TTSearchTextField;

@interface TTSearchBar : UIView {
  TTSearchTextField* _searchField;
  UIColor* _tintColor;
}

@property(nonatomic,assign) id<UITextFieldDelegate> delegate;
@property(nonatomic,retain) id<TTSearchSource> searchSource;
@property(nonatomic,retain) UIColor* tintColor;
@property(nonatomic) BOOL showsDoneButton;
@property(nonatomic) BOOL showsDarkScreen;

@end
