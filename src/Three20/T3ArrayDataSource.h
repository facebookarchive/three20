#import "Three20/T3DataSource.h"

@interface T3ArrayDataSource : T3DataSource {
  NSMutableArray* _array;
}

+ (T3ArrayDataSource*)dataSourceWithObjects:(id)object,...;

- (id)initWithArray:(NSArray*)objects;

@end
