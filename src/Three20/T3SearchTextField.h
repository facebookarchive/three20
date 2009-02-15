#import "Three20/T3DataSource.h"

@protocol T3SearchSource;
@class T3SearchTextFieldInternal, T3BackgroundView;

@interface T3SearchTextField : UITextField <UITableViewDelegate> {
  id<T3SearchSource> _searchSource;
  T3SearchTextFieldInternal* _internal;
  NSTimer* _searchTimer;
  UITableView* _tableView;
  T3BackgroundView* _shadowView;
  BOOL _searchAutomatically;
}

@property(nonatomic,retain) id<T3SearchSource> searchSource;
@property(nonatomic,readonly) UITableView* tableView;
@property(nonatomic,readonly) BOOL searchAutomatically;
@property(nonatomic,readonly) BOOL empty;

- (void)search;
- (void)updateResults;

- (BOOL)shouldUpdate:(BOOL)emptyText;

@end

@protocol T3SearchSource <T3DataSource>

- (void)textField:(T3SearchTextField*)textField searchForText:(NSString*)text;

- (NSString*)textField:(T3SearchTextField*)textField labelForRowAtIndexPath:(NSIndexPath*)indexPath;

@end
