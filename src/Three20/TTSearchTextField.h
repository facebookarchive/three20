#import "Three20/TTTableViewDataSource.h"

@protocol TTSearchSource;
@class TTSearchTextFieldInternal, TTBackgroundView;

@interface TTSearchTextField : UITextField <UITableViewDelegate> {
  id<TTSearchSource> _searchSource;
  TTSearchTextFieldInternal* _internal;
  UITableView* _tableView;
  TTBackgroundView* _shadowView;
  UIButton* _screenView;
  UIBarButtonItem* _previousRightBarButtonItem;
  NSTimer* _searchTimer;
  BOOL _searchesAutomatically;
  BOOL _showsDoneButton;
  BOOL _showsDarkScreen;
}

@property(nonatomic,retain) id<TTSearchSource> searchSource;
@property(nonatomic,readonly) UITableView* tableView;
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

@protocol TTSearchSource <TTTableViewDataSource>

- (void)textField:(TTSearchTextField*)textField searchForText:(NSString*)text;

@optional

- (NSString*)textField:(TTSearchTextField*)textField labelForObject:(id)object;

@end

@protocol TTSearchTextFieldDelegate <UITextFieldDelegate>

- (void)textField:(TTSearchTextField*)textField didSelectObject:(id)object;

@end

