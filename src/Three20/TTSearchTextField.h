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
@property(nonatomic,readonly) BOOL empty;
@property(nonatomic) BOOL showsDoneButton;
@property(nonatomic) BOOL showsDarkScreen;

- (void)search;
- (void)updateResults;

- (BOOL)shouldUpdate:(BOOL)emptyText;

@end

@protocol TTSearchSource <TTDataSource>

- (void)textField:(TTSearchTextField*)textField searchForText:(NSString*)text;

- (NSString*)textField:(TTSearchTextField*)textField labelForRowAtIndexPath:(NSIndexPath*)indexPath;

@end
