#import "Three20/TTDataSource.h"

@protocol TTSearchSource;
@class TTSearchTextFieldInternal, TTBackgroundView;

@interface TTSearchTextField : UITextField <UITableViewDelegate> {
  id<TTSearchSource> _searchSource;
  TTSearchTextFieldInternal* _internal;
  NSTimer* _searchTimer;
  UITableView* _tableView;
  TTBackgroundView* _shadowView;
  UIButton* _screenView;
  UIBarButtonItem* _previousRightBarButtonItem;
  BOOL _searchesAutomatically;
  BOOL _showsDoneButton;
  BOOL _showsDarkScreen;
}

@property(nonatomic,retain) id<TTSearchSource> searchSource;
@property(nonatomic,readonly) UITableView* tableView;
@property(nonatomic,readonly) BOOL searchesAutomatically;
@property(nonatomic,readonly) BOOL hasText;
@property(nonatomic) BOOL showsDoneButton;
@property(nonatomic) BOOL showsDarkScreen;

- (void)search;

- (void)reloadSearchResults;

- (void)showSearchResults:(BOOL)show;

- (UIView*)superviewForSearchResults;

- (CGRect)rectForSearchResults:(BOOL)withKeyboard;

- (BOOL)shouldUpdate:(BOOL)emptyText;

@end

@protocol TTSearchTextFieldDelegate <UITextFieldDelegate>

- (void)textField:(TTSearchTextField*)textField didSelectObject:(id)object;

@end

@protocol TTSearchSource <TTDataSource>

- (void)textField:(TTSearchTextField*)textField searchForText:(NSString*)text;

- (NSString*)textField:(TTSearchTextField*)textField labelForObject:(id)object;

@end
