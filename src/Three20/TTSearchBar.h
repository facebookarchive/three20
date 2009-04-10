#import "Three20/TTView.h"

@protocol TTTableViewDataSource, TTSearchTextFieldDelegate;
@class TTSearchTextField, TTButton;

@interface TTSearchBar : TTView {
  TTSearchTextField* _searchField;
  TTView* _boxView;
  UIColor* _tintColor;
  TTStyle* _textFieldStyle;
  TTButton* _cancelButton;
  BOOL _showsCancelButton;
  BOOL _showsSearchIcon;
}

@property(nonatomic,assign) id<UITextFieldDelegate> delegate;
@property(nonatomic,retain) id<TTTableViewDataSource> dataSource;
@property(nonatomic,copy) NSString* text;
@property(nonatomic,copy) NSString* placeholder;
@property(nonatomic,readonly) UITableView* tableView;
@property(nonatomic,readonly) TTView* boxView;
@property(nonatomic,retain) UIColor* tintColor;
@property(nonatomic,retain) UIColor* textColor;
@property(nonatomic,retain) UIFont* font;
@property(nonatomic,retain) TTStyle* textFieldStyle;
@property(nonatomic) UIReturnKeyType returnKeyType;
@property(nonatomic) CGFloat rowHeight;
@property(nonatomic,readonly) BOOL editing;
@property(nonatomic) BOOL searchesAutomatically;
@property(nonatomic) BOOL showsCancelButton;
@property(nonatomic) BOOL showsDoneButton;
@property(nonatomic) BOOL showsDarkScreen;
@property(nonatomic) BOOL showsSearchIcon;

- (void)search;

- (void)showSearchResults:(BOOL)show;

@end
