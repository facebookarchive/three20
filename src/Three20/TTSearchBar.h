#import "Three20/TTStyleView.h"

@protocol TTTableViewDataSource, TTSearchTextFieldDelegate;
@class TTSearchTextField;

@interface TTSearchBar : TTStyleView {
  TTSearchTextField* _searchField;
  TTStyleView* _boxView;
  UIColor* _tintColor;
  UIButton* _cancelButton;
  BOOL _showsCancelButton;
  BOOL _showsSearchIcon;
}

@property(nonatomic,assign) id<UITextFieldDelegate> delegate;
@property(nonatomic,retain) id<TTTableViewDataSource> dataSource;
@property(nonatomic,copy) NSString* text;
@property(nonatomic,copy) NSString* placeholder;
@property(nonatomic,readonly) UITableView* tableView;
@property(nonatomic,readonly) TTStyleView* boxView;
@property(nonatomic,retain) UIColor* tintColor;
@property(nonatomic,retain) UIColor* textColor;
@property(nonatomic,retain) UIFont* font;
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
