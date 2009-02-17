#import "Three20/TTGlobal.h"

@class TTTableViewCell;

@protocol TTTableViewDataSource <UITableViewDataSource>

@property(nonatomic,readonly) NSMutableArray* delegates;

- (id)objectForRowAtIndexPath:(NSIndexPath*)indexPath;

- (Class)cellClassForObject:(id)object;

- (void)decorateCell:(UITableViewCell*)cell forRowAtIndexPath:(NSIndexPath*)indexPath;

@end

@protocol TTTableViewDataSourceDelegate <NSObject>

- (void)dataSourceLoading:(id<TTTableViewDataSource>)dataSource;

- (void)dataSourceLoaded:(id<TTTableViewDataSource>)dataSource;

- (void)dataSource:(id<TTTableViewDataSource>)dataSource loadDidFailWithError:(NSError*)error;

@end

@interface TTBaseDataSource : NSObject <TTTableViewDataSource> {
  NSMutableArray* _delegates;
}

- (void)dataSourceLoading;

- (void)dataSourceLoaded;

- (void)dataSourceLoadDidFailWithError:(NSError*)error;

@end

@interface TTListDataSource : TTBaseDataSource {
  NSMutableArray* _items;
}

+ (TTListDataSource*)dataSourceWithObjects:(id)object,...;

- (id)initWithItems:(NSArray*)items;

@end

@interface TTSectionedDataSource : TTBaseDataSource {
  NSMutableArray* _sections;
  NSMutableArray* _items;
}

@property(nonatomic,readonly) NSArray* lettersForSections;

+ (TTSectionedDataSource*)dataSourceWithObjects:(id)object,...;

- (id)initWithItems:(NSArray*)items sections:(NSArray*)sections;

@end
