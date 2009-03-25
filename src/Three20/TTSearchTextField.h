#import "Three20/TTTableViewDataSource.h"

@protocol TTTableViewDataSource;
@class TTSearchTextFieldInternal, TTBackgroundView;

@interface TTSearchTextField : UITextField <UITableViewDelegate> {
  id<TTTableViewDataSource> _dataSource;
  TTSearchTextFieldInternal* _internal;
  UITableView* _tableView;
  TTBackgroundView* _shadowView;
  UIButton* _screenView;
  UINavigationItem* _previousNavigationItem;
  UIBarButtonItem* _previousRightBarButtonItem;
  NSTimer* _searchTimer;
  CGFloat _rowHeight;
  BOOL _searchesAutomatically;
  BOOL _showsDoneButton;
  BOOL _showsDarkScreen;
}

@property(nonatomic,retain) id<TTTableViewDataSource> dataSource;
@property(nonatomic,readonly) UITableView* tableView;
@property(nonatomic) CGFloat rowHeight;
@property(nonatomic,readonly) BOOL hasText;
@property(nonatomic) BOOL searchesAutomatically;
@property(nonatomic) BOOL showsDoneButton;
@property(nonatomic) BOOL showsDarkScreen;

- (void)search;

- (void)showSearchResults:(BOOL)show;

- (UIView*)superviewForSearchResults;

- (CGRect)rectForSearchResults:(BOOL)withKeyboard;

- (BOOL)shouldUpdate:(BOOL)emptyText;

@end

///////////////////////////////////////////////////////////////////////////////////////////////////

@protocol TTSearchTextFieldDelegate <UITextFieldDelegate>

- (void)textField:(TTSearchTextField*)textField didSelectObject:(id)object;

@end

