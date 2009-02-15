#import "Three20/T3DataSource.h"
#import "Three20/T3TableField.h"
#import "Three20/T3TableFieldCell.h"

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation T3BaseDataSource

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
  UITableViewCell* cell = (UITableViewCell*)[tableView dequeueReusableCellWithIdentifier:className];
  if (cell == nil) {
    cell = [[[cellClass alloc] initWithFrame:CGRectZero style:0
      reuseIdentifier:className] autorelease];
  }
  
  if ([cell isKindOfClass:[T3TableViewCell class]]) {
    [(T3TableViewCell*)cell setObject:object];
  }
  
  [self decorateCell:cell forRowAtIndexPath:indexPath];
      
  return cell;
}

///////////////////////////////////////////////////////////////////////////////////////////////////

- (id)objectForRowAtIndexPath:(NSIndexPath*)indexPath {
  return nil;
}

- (Class)cellClassForObject:(id)object {
  if ([object isKindOfClass:[T3TableField class]]) {
    if ([object isKindOfClass:[T3TextTableField class]]) {
      return [T3TextTableFieldCell class];
    } else if ([object isKindOfClass:[T3TitledTableField class]]) {
      return [T3TitledTableFieldCell class];
    } else if ([object isKindOfClass:[T3SubtextTableField class]]) {
      return [T3SubtextTableFieldCell class];
    } else if ([object isKindOfClass:[T3MoreButtonTableField class]]) {
      return [T3MoreButtonTableFieldCell class];
    } else if ([object isKindOfClass:[T3IconTableField class]]) {
      return [T3IconTableFieldCell class];
    } else if ([object isKindOfClass:[T3ImageTableField class]]) {
      return [T3ImageTableFieldCell class];
    } else if ([object isKindOfClass:[T3ActivityTableField class]]) {
      return [T3ActivityTableFieldCell class];
    } else if ([object isKindOfClass:[T3ErrorTableField class]]) {
      return [T3ErrorTableFieldCell class];
    } else if ([object isKindOfClass:[T3TextFieldTableField class]]) {
      return [T3TextFieldTableFieldCell class];
    } else if ([object isKindOfClass:[T3TextViewTableField class]]) {
      return [T3TextViewTableFieldCell class];
    } else if ([object isKindOfClass:[T3SwitchTableField class]]) {
      return [T3SwitchTableFieldCell class];
    } else {
      return [T3TableFieldCell class];
    }
  }
  
  return nil;
}

- (void)decorateCell:(UITableViewCell*)cell forRowAtIndexPath:(NSIndexPath*)indexPath {
}

@end

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation T3BasicDataSource

+ (T3BasicDataSource*)dataSourceWithObjects:(id)object,... {
  NSMutableArray* items = [NSMutableArray array];
  va_list ap;
  va_start(ap, object);
  while (object) {
    [items addObject:object];
    object = va_arg(ap, id);
  }
  va_end(ap);

  return [[[self alloc] initWithItems:items] autorelease];
}

- (id)initWithItems:(NSArray*)items {
  if (self = [self init]) {
    _items = [items mutableCopy];
  }
  return self;
}

- (id)init {
  if (self = [super init]) {
    _items = nil;
  }
  return self;
}

- (void)dealloc {
  [_items release];
  [super dealloc];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// T3DataSource

- (id)objectForRowAtIndexPath:(NSIndexPath*)indexPath {
  return [_items objectAtIndex:indexPath.row];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return _items.count;
}

@end

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation T3SectionedDataSource

+ (T3SectionedDataSource*)dataSourceWithObjects:(id)object,... {
  NSMutableArray* items = [NSMutableArray array];
  NSMutableArray* sections = [NSMutableArray array];
  NSMutableArray* section = nil;
  va_list ap;
  va_start(ap, object);
  while (object) {
    if ([object isKindOfClass:[NSString class]]) {
      [sections addObject:object];
      section = [NSMutableArray array];
      [items addObject:section];
    } else {
      [section addObject:object];
    }
    object = va_arg(ap, id);
  }
  va_end(ap);

  return [[[self alloc] initWithItems:items sections:sections] autorelease];
}

- (id)initWithItems:(NSArray*)items sections:(NSArray*)sections {
  if (self = [self init]) {
    _items = [items mutableCopy];
    _sections = [sections mutableCopy];
  }
  return self;
}

- (id)init {
  if (self = [super init]) {
    _items = nil;
    _sections = nil;
  }
  return self;
}

- (void)dealloc {
  [_items release];
  [_sections release];
  [super dealloc];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// T3DataSource

- (id)objectForRowAtIndexPath:(NSIndexPath*)indexPath {
  NSArray* section = [_items objectAtIndex:indexPath.section];
  return [section objectAtIndex:indexPath.row];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// UITableViewDataSource

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
  return [_sections objectAtIndex:section];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return _sections.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  NSArray* items = [_items objectAtIndex:section];
  return items.count;
}

@end
