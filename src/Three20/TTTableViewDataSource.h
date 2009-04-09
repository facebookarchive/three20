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

@property(nonatomic,readonly) NSMutableArray* items;

+ (TTListDataSource*)dataSourceWithObjects:(id)object,...;
+ (TTListDataSource*)dataSourceWithItems:(NSMutableArray*)items;

- (id)initWithItems:(NSArray*)items;

@end

///////////////////////////////////////////////////////////////////////////////////////////////////

@interface TTSectionedDataSource : TTDataSource {
  NSMutableArray* _sections;
  NSMutableArray* _items;
}

/**
 * Objects should be in this format:
 *
 *   @"section title", item, item, @"section title", item, item, ...
 *
 */
+ (TTSectionedDataSource*)dataSourceWithObjects:(id)object,...;

/**
 * Objects should be in this format:
 *
 *   @"section title", arrayOfItems, @"section title", arrayOfItems, ...
 *
 */
+ (TTSectionedDataSource*)dataSourceWithArrays:(id)object,...;

+ (TTSectionedDataSource*)dataSourceWithItems:(NSArray*)items sections:(NSArray*)sections;

- (id)initWithItems:(NSArray*)items sections:(NSArray*)sections;

- (NSArray*)lettersForSectionsWithSearch:(BOOL)withSearch withCount:(BOOL)withCount;

@end
