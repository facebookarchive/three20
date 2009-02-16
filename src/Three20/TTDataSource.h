#import "Three20/TTGlobal.h"

@class TTTableViewCell;

@protocol TTDataSource <UITableViewDataSource>

- (id)objectForRowAtIndexPath:(NSIndexPath*)indexPath;

- (Class)cellClassForObject:(id)object;

- (void)decorateCell:(UITableViewCell*)cell forRowAtIndexPath:(NSIndexPath*)indexPath;

@end

@interface TTBaseDataSource : NSObject <TTDataSource>

- (id)objectForRowAtIndexPath:(NSIndexPath*)indexPath;

- (Class)cellClassForObject:(id)object;

- (void)decorateCell:(UITableViewCell*)cell forRowAtIndexPath:(NSIndexPath*)indexPath;

@end

@interface TTBasicDataSource : TTBaseDataSource {
  NSMutableArray* _items;
}

+ (TTBasicDataSource*)dataSourceWithObjects:(id)object,...;

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
