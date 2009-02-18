#import "Three20/TTGlobal.h"

@class TTTableViewCell;

@protocol TTTableViewDataSource <UITableViewDataSource>

@property(nonatomic,readonly) NSMutableArray* delegates;
@property(nonatomic,readonly) NSDate* loadedTimestamp;
@property(nonatomic,readonly) BOOL empty;
@property(nonatomic,readonly) BOOL loading;
@property(nonatomic,readonly) BOOL loaded;
@property(nonatomic,readonly) BOOL needsReload;

- (id)tableView:(UITableView*)tableView objectForRowAtIndexPath:(NSIndexPath*)indexPath;

- (Class)tableView:(UITableView*)tableView cellClassForObject:(id)object;

- (NSString*)tableView:(UITableView*)tableView labelForObject:(id)object;

- (void)tableView:(UITableView*)tableView prepareCell:(UITableViewCell*)cell
  forRowAtIndexPath:(NSIndexPath*)indexPath;

- (void)tableView:(UITableView*)tableView search:(NSString*)text;

- (void)loadFromIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex fromCache:(BOOL)fromCache;

@end

@protocol TTTableViewDataSourceDelegate <NSObject>

@optional

- (void)dataSourceLoading:(id<TTTableViewDataSource>)dataSource;

- (void)dataSourceLoaded:(id<TTTableViewDataSource>)dataSource;

- (void)dataSource:(id<TTTableViewDataSource>)dataSource loadDidFailWithError:(NSError*)error;

@end

@interface TTDataSource : NSObject <TTTableViewDataSource> {
  NSMutableArray* _delegates;
}

- (void)dataSourceLoading;

- (void)dataSourceLoaded;

- (void)dataSourceLoadDidFailWithError:(NSError*)error;

@end

@interface TTListDataSource : TTDataSource {
  NSMutableArray* _items;
}

+ (TTListDataSource*)dataSourceWithObjects:(id)object,...;

- (id)initWithItems:(NSArray*)items;

@end

@interface TTSectionedDataSource : TTDataSource {
  NSMutableArray* _sections;
  NSMutableArray* _items;
}

@property(nonatomic,readonly) NSArray* lettersForSections;

+ (TTSectionedDataSource*)dataSourceWithObjects:(id)object,...;

- (id)initWithItems:(NSArray*)items sections:(NSArray*)sections;

@end
