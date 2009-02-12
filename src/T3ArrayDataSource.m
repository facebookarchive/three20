#import "Three20/T3ArrayDataSource.h"

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation T3ArrayDataSource

- (id)init {
  if (self = [super init]) {
  }
  return self;
}

- (void)dealloc {
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
