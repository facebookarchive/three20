#import "Three20/TTGlobal.h"

@protocol TTSearchSource, TTSearchTextFieldDelegate;
@class TTSearchTextField, TTBackgroundView;

@interface TTSearchBar : UIView {
  TTSearchTextField* _searchField;
  TTBackgroundView* _boxView;
  UIColor* _tintColor;
}

@property(nonatomic,assign) id<UITextFieldDelegate> delegate;
@property(nonatomic,retain) id<TTSearchSource> searchSource;
@property(nonatomic,copy) NSString* text;
@property(nonatomic,readonly) UITableView* tableView;
@property(nonatomic,retain) UIColor* tintColor;
@property(nonatomic,retain) UIFont* font;
@property(nonatomic,readonly) BOOL editing;
@property(nonatomic) BOOL searchesAutomatically;
@property(nonatomic) BOOL showsDoneButton;
@property(nonatomic) BOOL showsDarkScreen;

@end
