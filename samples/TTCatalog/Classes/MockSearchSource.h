#import <Three20/Three20.h>

@interface MockSearchSource : TTListDataSource <TTSearchSource> {
  NSMutableArray* _allItems;
}

@end
