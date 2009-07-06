#import <Three20/Three20.h>

@interface MockDataSource : TTListDataSource <TTDataSource> {
  NSMutableArray* _allItems;
}

@end
