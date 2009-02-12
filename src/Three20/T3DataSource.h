#import "Three20/T3Global.h"

@class T3TableViewCell;

@interface T3DataSource : NSObject <UITableViewDataSource>

- (id)objectForRowAtIndexPath:(NSIndexPath*)indexPath;

- (Class)cellClassForObject:(id)object;

- (void)decorateCell:(T3TableViewCell*)cell forRowAtIndexPath:(NSIndexPath*)indexPath;

@end
