#import <Three20/Three20.h>

@interface MockDataSource : TTSectionedDataSource {
  NSArray* _names;
}

+ (MockDataSource*)mockDataSource:(BOOL)forSearch;

- (id)initWithNames:(NSArray*)names;

- (void)rebuildItems;

@end
