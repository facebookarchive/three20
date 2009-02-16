#import <Three20/Three20.h>

@interface MockSearchSource : TTBasicDataSource <TTSearchSource> {
  NSMutableArray* _allItems;
}

@end
