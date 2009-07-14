#import "Three20/TTLoadable.h"

@protocol TTTableViewDataSource <TTLoadable, TTLoadableDelegate, UITableViewDataSource>

/**
 *
 */
- (id)tableView:(UITableView*)tableView objectForRowAtIndexPath:(NSIndexPath*)indexPath;

/**
 *
 */
- (Class)tableView:(UITableView*)tableView cellClassForObject:(id)object;

/**
 *
 */
- (NSString*)tableView:(UITableView*)tableView labelForObject:(id)object;

/**
 *
 */
- (NSIndexPath*)tableView:(UITableView*)tableView indexPathForObject:(id)object;

/**
 *
 */
- (void)tableView:(UITableView*)tableView prepareCell:(UITableViewCell*)cell
        forRowAtIndexPath:(NSIndexPath*)indexPath;

/**
 *
 */
- (void)tableView:(UITableView*)tableView search:(NSString*)text;

/**
 *
 */
- (void)load:(TTURLRequestCachePolicy)cachePolicy nextPage:(BOOL)nextPage;

/**
 * Updates the data source in the event that external data it relies on have changed.
 *
 * If your data source is loaded using TTLoadable, this is called automatically after your data
 * has loaded.  That would be a good time to prepare the data for use in the data source.
 */
- (void)update;

/**
 *
 */
- (NSString*)titleForLoading:(BOOL)refreshing;

/**
 *
 */
- (UIImage*)imageForNoData;

/**
 *
 */
- (NSString*)titleForNoData;

/**
 *
 */
- (NSString*)subtitleForNoData;

/**
 *
 */
- (UIImage*)imageForError:(NSError*)error;

/**
 *
 */
- (NSString*)titleForError:(NSError*)error;

/**
 *
 */
- (NSString*)subtitleForError:(NSError*)error;

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

@interface TTTableViewDataSource : NSObject <TTTableViewDataSource> {
  NSMutableArray* _delegates;
}

/**
 * Optional method to return a loadable object to delegate the TTLoadable protocol to.
 */
@property(nonatomic,readonly) id<TTLoadable> loadable;

- (void)didStartLoad;

- (void)didFinishLoad;

- (void)didFailLoadWithError:(NSError*)error;

- (void)didCancelLoad;

@end
