#import "Three20/TTGlobal.h"

@class TTTableViewCell;

@protocol TTTableViewDataSource <TTLoadable, UITableViewDataSource>

- (id)tableView:(UITableView*)tableView objectForRowAtIndexPath:(NSIndexPath*)indexPath;

- (Class)tableView:(UITableView*)tableView cellClassForObject:(id)object;

- (NSString*)tableView:(UITableView*)tableView labelForObject:(id)object;

- (NSIndexPath*)tableView:(UITableView*)tableView indexPathForObject:(id)object;

- (void)tableView:(UITableView*)tableView prepareCell:(UITableViewCell*)cell
        forRowAtIndexPath:(NSIndexPath*)indexPath;

- (void)tableView:(UITableView*)tableView search:(NSString*)text;

- (void)load:(TTURLRequestCachePolicy)cachePolicy nextPage:(BOOL)nextPage;

@end

///////////////////////////////////////////////////////////////////////////////////////////////////

@protocol TTTableViewDataSourceDelegate <NSObject>

@optional

- (void)dataSourceDidStartLoad:(id<TTTableViewDataSource>)dataSource;

- (void)dataSourceDidFinishLoad:(id<TTTableViewDataSource>)dataSource;

- (void)dataSource:(id<TTTableViewDataSource>)dataSource didFailLoadWithError:(NSError*)error;

- (void)dataSourceDidCancelLoad:(id<TTTableViewDataSource>)dataSource;

@end

///////////////////////////////////////////////////////////////////////////////////////////////////

@interface TTDataSource : NSObject <TTTableViewDataSource> {
  NSMutableArray* _delegates;
}

- (void)dataSourceDidStartLoad;

- (void)dataSourceDidFinishLoad;

- (void)dataSourceDidFailLoadWithError:(NSError*)error;

- (void)dataSourceDidCancelLoad;

@end

///////////////////////////////////////////////////////////////////////////////////////////////////

@interface TTListDataSource : TTDataSource {
  NSMutableArray* _items;
}

+ (TTListDataSource*)dataSourceWithObjects:(id)object,...;

- (id)initWithItems:(NSArray*)items;

@end

///////////////////////////////////////////////////////////////////////////////////////////////////

@interface TTSectionedDataSource : TTDataSource {
  NSMutableArray* _sections;
  NSMutableArray* _items;
}

+ (TTSectionedDataSource*)dataSourceWithObjects:(id)object,...;

- (id)initWithItems:(NSArray*)items sections:(NSArray*)sections;

- (NSArray*)lettersForSectionsWithSearch:(BOOL)withSearch withCount:(BOOL)withCount;

@end
