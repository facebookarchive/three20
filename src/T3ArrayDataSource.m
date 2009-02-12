#import "Three20/T3ArrayDataSource.h"

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation T3ArrayDataSource

+ (T3ArrayDataSource*)dataSourceWithObjects:(id)object,... {
  NSMutableArray* objects = [NSMutableArray array];
  va_list ap;
  va_start(ap, object);
  while (object) {
    [objects addObject:object];
    object = va_arg(ap, id);
  }
  va_end(ap);

  return [[[self alloc] initWithArray:objects] autorelease];
}

- (id)initWithArray:(NSArray*)objects {
  if (self = [self init]) {
    _array = [[NSMutableArray alloc] initWithArray:objects];
  }
  return self;
}

- (id)init {
  if (self = [super init]) {
    _array = nil;
  }
  return self;
}

- (void)dealloc {
  [_array release];
  [super dealloc];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// T3DataSource

- (id)objectForRowAtIndexPath:(NSIndexPath*)indexPath {
  return [_array objectAtIndex:indexPath.row];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return _array.count;
}

@end
