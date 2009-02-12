#import "Three20/T3DataSource.h"
#import "Three20/T3TableItems.h"
#import "Three20/T3TableViewCells.h"

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation T3DataSource

///////////////////////////////////////////////////////////////////////////////////////////////////
// UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
    cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  id object = [self objectForRowAtIndexPath:indexPath];
  Class cellClass = [self cellClassForObject:object];

  NSString* className = NSStringFromClass(cellClass);
  T3TableViewCell* cell = (T3TableViewCell*)[tableView dequeueReusableCellWithIdentifier:className];
  if (cell == nil) {
    cell = [[[cellClass alloc] initWithFrame:CGRectZero style:0
      reuseIdentifier:className] autorelease];
  }
  
  cell.object = object;
  
  [self decorateCell:cell forRowAtIndexPath:indexPath];
      
  return cell;
}

///////////////////////////////////////////////////////////////////////////////////////////////////

- (id)objectForRowAtIndexPath:(NSIndexPath*)indexPath {
  return nil;
}

- (Class)cellClassForObject:(id)object {
  if ([object isKindOfClass:[T3TableItem class]]) {
    if ([object isKindOfClass:[T3TextTableItem class]]) {
      return [T3TextTableViewCell class];
    } else if ([object isKindOfClass:[T3KeyValueTableItem class]]) {
      return [T3KeyValueTableViewCell class];
    } else if ([object isKindOfClass:[T3IconTableItem class]]) {
      return [T3IconTableViewCell class];
    } else if ([object isKindOfClass:[T3TextFieldTableItem class]]) {
      return [T3TextFieldTableViewCell class];
    } else if ([object isKindOfClass:[T3TextEditorTableItem class]]) {
      return [T3TextEditorTableViewCell class];
    } else if ([object isKindOfClass:[T3ActivityTableItem class]]) {
      return [T3ActivityTableViewCell class];
    } else if ([object isKindOfClass:[T3ErrorTableItem class]]) {
      return [T3ErrorTableViewCell class];
    } else if ([object isKindOfClass:[T3MoreLinkTableItem class]]) {
      return [T3ActivityTableViewCell class];
    } else {
      return [T3TitleTableViewCell class];
    }
  }
  
  return nil;
}

- (void)decorateCell:(T3TableViewCell*)cell forRowAtIndexPath:(NSIndexPath*)indexPath {
}

@end
