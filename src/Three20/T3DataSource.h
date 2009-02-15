#import "Three20/T3Global.h"

@class T3TableViewCell;

@protocol T3DataSource <UITableViewDataSource>

- (id)objectForRowAtIndexPath:(NSIndexPath*)indexPath;

- (Class)cellClassForObject:(id)object;

- (void)decorateCell:(UITableViewCell*)cell forRowAtIndexPath:(NSIndexPath*)indexPath;

@end

@interface T3BaseDataSource : NSObject <T3DataSource>

- (id)objectForRowAtIndexPath:(NSIndexPath*)indexPath;

- (Class)cellClassForObject:(id)object;

- (void)decorateCell:(UITableViewCell*)cell forRowAtIndexPath:(NSIndexPath*)indexPath;

@end

@interface T3BasicDataSource : T3BaseDataSource {
  NSMutableArray* _items;
}

+ (T3BasicDataSource*)dataSourceWithObjects:(id)object,...;

- (id)initWithItems:(NSArray*)items;

@end

@interface T3SectionedDataSource : T3BaseDataSource {
  NSMutableArray* _sections;
  NSMutableArray* _items;
}

+ (T3SectionedDataSource*)dataSourceWithObjects:(id)object,...;

- (id)initWithItems:(NSArray*)items sections:(NSArray*)sections;

@end
