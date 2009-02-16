#import "Three20/TTDataSource.h"
#import "Three20/TTTableField.h"
#import "Three20/TTTableFieldCell.h"

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation TTBaseDataSource

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
  
  if ([cell isKindOfClass:[TTTableViewCell class]]) {
    [(TTTableViewCell*)cell setObject:object];
  }
  
  [self decorateCell:cell forRowAtIndexPath:indexPath];
      
  return cell;
}

///////////////////////////////////////////////////////////////////////////////////////////////////

- (id)objectForRowAtIndexPath:(NSIndexPath*)indexPath {
  return nil;
}

- (Class)cellClassForObject:(id)object {
  if ([object isKindOfClass:[TTTableField class]]) {
    if ([object isKindOfClass:[TTTextTableField class]]) {
      return [TTTextTableFieldCell class];
    } else if ([object isKindOfClass:[TTTitledTableField class]]) {
      return [TTTitledTableFieldCell class];
    } else if ([object isKindOfClass:[TTSubtextTableField class]]) {
      return [TTSubtextTableFieldCell class];
    } else if ([object isKindOfClass:[TTMoreButtonTableField class]]) {
      return [TTMoreButtonTableFieldCell class];
    } else if ([object isKindOfClass:[TTIconTableField class]]) {
      return [TTIconTableFieldCell class];
    } else if ([object isKindOfClass:[TTImageTableField class]]) {
      return [TTImageTableFieldCell class];
    } else if ([object isKindOfClass:[TTActivityTableField class]]) {
      return [TTActivityTableFieldCell class];
    } else if ([object isKindOfClass:[TTErrorTableField class]]) {
      return [TTErrorTableFieldCell class];
    } else if ([object isKindOfClass:[TTTextFieldTableField class]]) {
      return [TTTextFieldTableFieldCell class];
    } else if ([object isKindOfClass:[TTTextViewTableField class]]) {
      return [TTTextViewTableFieldCell class];
    } else if ([object isKindOfClass:[TTSwitchTableField class]]) {
      return [TTSwitchTableFieldCell class];
    } else {
      return [TTTableFieldCell class];
    }
  }
  
  return nil;
}

- (void)decorateCell:(UITableViewCell*)cell forRowAtIndexPath:(NSIndexPath*)indexPath {
}

@end

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation TTBasicDataSource

+ (TTBasicDataSource*)dataSourceWithObjects:(id)object,... {
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
// TTDataSource

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

@implementation TTSectionedDataSource

+ (TTSectionedDataSource*)dataSourceWithObjects:(id)object,... {
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
// TTDataSource

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

///////////////////////////////////////////////////////////////////////////////////////////////////

- (NSArray*)lettersForSections {
  NSMutableArray* titles = [NSMutableArray array];
  
  for (NSString* label in _sections) {
    if (label.length) {
      NSString* letter = [label substringToIndex:1];
      [titles addObject:letter];    
    }
  }

  return titles;
}

@end
