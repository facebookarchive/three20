#import "Three20/T3Global.h"

@class T3TableViewCell;

@interface T3DataSource : NSObject <UITableViewDataSource>

- (id)objectForRowAtIndexPath:(NSIndexPath*)indexPath;

- (Class)cellClassForObject:(id)object;

- (void)decorateCell:(UITableViewCell*)cell forRowAtIndexPath:(NSIndexPath*)indexPath;

@end

@interface T3BasicDataSource : T3DataSource {
  NSMutableArray* _items;
}

+ (T3BasicDataSource*)dataSourceWithObjects:(id)object,...;

- (id)initWithItems:(NSArray*)items;

@end

@interface T3SectionedDataSource : T3DataSource {
  NSMutableArray* _sections;
  NSMutableArray* _items;
}

+ (T3SectionedDataSource*)dataSourceWithObjects:(id)object,...;

- (id)initWithItems:(NSArray*)items sections:(NSArray*)sections;

@end
