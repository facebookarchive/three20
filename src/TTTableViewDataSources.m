#import "Three20/TTTableViewDataSources.h"

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation TTListDataSource

@synthesize items = _items;

///////////////////////////////////////////////////////////////////////////////////////////////////
// class public

+ (TTListDataSource*)dataSourceWithObjects:(id)object,... {
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

+ (TTListDataSource*)dataSourceWithItems:(NSMutableArray*)items {
  return [[[self alloc] initWithItems:items] autorelease];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// NSObject

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
  TT_RELEASE_MEMBER(_items);
  [super dealloc];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return _items.count;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// TTTableViewDataSource

- (BOOL)isEmpty {
  return !_items.count;
}

- (id)tableView:(UITableView*)tableView objectForRowAtIndexPath:(NSIndexPath*)indexPath {
  return [_items objectAtIndex:indexPath.row];
}

- (NSIndexPath*)tableView:(UITableView*)tableView indexPathForObject:(id)object {
  NSUInteger index = [_items indexOfObject:object];
  if (index != NSNotFound) {
    return [NSIndexPath indexPathForRow:index inSection:0];
  }
  return nil;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// public

- (NSMutableArray*)items {
  if (!_items) {
    _items = [[NSMutableArray alloc] init];
  }
  return _items;
}

@end

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation TTSectionedDataSource

@synthesize items = _items, sections = _sections;

///////////////////////////////////////////////////////////////////////////////////////////////////
// class public

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

+ (TTSectionedDataSource*)dataSourceWithArrays:(id)object,... {
  NSMutableArray* items = [NSMutableArray array];
  NSMutableArray* sections = [NSMutableArray array];
  va_list ap;
  va_start(ap, object);
  while (object) {
    if ([object isKindOfClass:[NSString class]]) {
      [sections addObject:object];
    } else {
      [items addObject:object];
    }
    object = va_arg(ap, id);
  }
  va_end(ap);

  return [[[self alloc] initWithItems:items sections:sections] autorelease];
}

+ (TTSectionedDataSource*)dataSourceWithItems:(NSArray*)items sections:(NSArray*)sections {
  return [[[self alloc] initWithItems:items sections:sections] autorelease];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// NSObject

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
  TT_RELEASE_MEMBER(_items);
  TT_RELEASE_MEMBER(_sections);
  [super dealloc];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return _sections.count ? _sections.count : 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  if (_sections.count) {
    NSArray* items = [_items objectAtIndex:section];
    return items.count;
  } else {
    return _items.count;
  }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
  if (_sections.count) {
    return [_sections objectAtIndex:section];
  } else {
    return nil;
  }
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// TTTableViewDataSource

- (id)tableView:(UITableView*)tableView objectForRowAtIndexPath:(NSIndexPath*)indexPath {
  if (_sections) {
    NSArray* section = [_items objectAtIndex:indexPath.section];
    return [section objectAtIndex:indexPath.row];
  } else {
    return [_items objectAtIndex:indexPath.row];
  }
}

- (NSIndexPath*)tableView:(UITableView*)tableView indexPathForObject:(id)object {
  if (_sections) {
    for (int i = 0; i < _items.count; ++i) {
      NSMutableArray* section = [_items objectAtIndex:i];
      NSUInteger index = [section indexOfObject:object];
      if (index != NSNotFound) {
        return [NSIndexPath indexPathForRow:index inSection:i];
      }
    }
  } else {
    NSUInteger index = [_items indexOfObject:object];
    if (index != NSNotFound) {
      return [NSIndexPath indexPathForRow:index inSection:0];
    }
  }

  return nil;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// public

- (NSArray*)lettersForSectionsWithSearch:(BOOL)withSearch withCount:(BOOL)withCount {
  if (_sections) {
    NSMutableArray* titles = [NSMutableArray array];
    if (withSearch) {
      [titles addObject:UITableViewIndexSearch];
    }
    
    for (NSString* label in _sections) {
      if (label.length) {
        NSString* letter = [label substringToIndex:1];
        [titles addObject:letter];    
      }
    }
    
    if (withCount) {
      [titles addObject:@"#"];
    }
    
    return titles;
  } else {
    return nil;
  }
}

@end
