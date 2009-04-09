#import "Three20/TTTableViewDataSource.h"
#import "Three20/TTTableField.h"
#import "Three20/TTTableFieldCell.h"
#import "Three20/TTURLCache.h"
#import <objc/runtime.h>

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation TTDataSource

@synthesize delegates = _delegates;

///////////////////////////////////////////////////////////////////////////////////////////////////
// NSObject

- (id)init {
  if (self = [super init]) {
    _delegates = nil;
  }
  return self;
}

- (void)dealloc {
  [_delegates release];
  [super dealloc];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return 0;
}

- (UITableViewCell*)tableView:(UITableView *)tableView
                    cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  id object = [self tableView:tableView objectForRowAtIndexPath:indexPath];

  Class cellClass = [self tableView:tableView cellClassForObject:object];
  const char* className = class_getName(cellClass);
  NSString* identifier = [[NSString alloc] initWithBytesNoCopy:(char*)className
                                           length:strlen(className)
                                           encoding:NSASCIIStringEncoding freeWhenDone:NO];

  UITableViewCell* cell = (UITableViewCell*)[tableView dequeueReusableCellWithIdentifier:identifier];
  if (cell == nil) {
    cell = [[[cellClass alloc] initWithFrame:CGRectZero reuseIdentifier:identifier] autorelease];
  }
  [identifier release];
  
  if ([cell isKindOfClass:[TTTableViewCell class]]) {
    [(TTTableViewCell*)cell setObject:object];
  }
  
  [self tableView:tableView prepareCell:cell forRowAtIndexPath:indexPath];
      
  return cell;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// TTLoadable

- (NSMutableArray*)delegates {
  if (!_delegates) {
    _delegates = TTCreateNonRetainingArray();
  }
  return _delegates;
}

- (NSDate*)loadedTime {
  return nil;
}

- (BOOL)isLoading {
  return NO;
}

- (BOOL)isLoadingMore {
  return NO;
}

- (BOOL)isLoaded {
  return YES;
}

- (BOOL)isOutdated {
  NSDate* loadedTime = self.loadedTime;
  if (loadedTime) {
    return -[loadedTime timeIntervalSinceNow] > [TTURLCache sharedCache].invalidationAge;
  } else {
    return NO;
  }
}

- (BOOL)isEmpty {
  return YES;
}

- (void)invalidate:(BOOL)erase {
}

- (void)cancel {
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// TTLoadable

- (id)tableView:(UITableView*)tableView objectForRowAtIndexPath:(NSIndexPath*)indexPath {
  return nil;
}

- (Class)tableView:(UITableView*)tableView cellClassForObject:(id)object {
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
    } else if ([object isKindOfClass:[TTStyledTextTableField class]]) {
      return [TTStyledTextTableFieldCell class];
    } else {
      return [TTTextTableFieldCell class];
    }
  }
  
  // This will display an empty white table cell - probably not what you want, but it
  // is better than crashing, which is what happens if you return nil here
  return [TTTableViewCell class];
}

- (NSString*)tableView:(UITableView*)tableView labelForObject:(id)object {
  return [NSString stringWithFormat:@"%@", object];
}

- (NSIndexPath*)tableView:(UITableView*)tableView indexPathForObject:(id)object {
  return nil;
}

- (void)tableView:(UITableView*)tableView prepareCell:(UITableViewCell*)cell
        forRowAtIndexPath:(NSIndexPath*)indexPath {
}

- (void)tableView:(UITableView*)tableView search:(NSString*)text {
}

- (void)load:(TTURLRequestCachePolicy)cachePolicy nextPage:(BOOL)nextPage {
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// public

- (void)dataSourceDidStartLoad {
  for (id<TTTableViewDataSourceDelegate> delegate in self.delegates) {
    if ([delegate respondsToSelector:@selector(dataSourceDidStartLoad:)]) {
      [delegate dataSourceDidStartLoad:self];
    }
  }
}

- (void)dataSourceDidFinishLoad {
  for (id<TTTableViewDataSourceDelegate> delegate in self.delegates) {
    if ([delegate respondsToSelector:@selector(dataSourceDidFinishLoad:)]) {
      [delegate dataSourceDidFinishLoad:self];
    }
  }
}

- (void)dataSourceDidFailLoadWithError:(NSError*)error {
  for (id<TTTableViewDataSourceDelegate> delegate in self.delegates) {
    if ([delegate respondsToSelector:@selector(dataSource:didFailLoadWithError:)]) {
      [delegate dataSource:self didFailLoadWithError:error];
    }
  }
}

- (void)dataSourceDidCancelLoad {
  for (id<TTTableViewDataSourceDelegate> delegate in self.delegates) {
    if ([delegate respondsToSelector:@selector(dataSourceDidCancelLoad:)]) {
      [delegate dataSourceDidCancelLoad:self];
    }
  }
}

@end

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation TTListDataSource

@synthesize items = _items;

///////////////////////////////////////////////////////////////////////////////////////////////////
// class public

+ (TTListDataSource*)dataSourceWithObjectsArray:(NSMutableArray*)items {
  return [[[self alloc] initWithItems:items] autorelease];
}

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
  [_items release];
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
  [_items release];
  [_sections release];
  [super dealloc];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return _sections.count ? _sections.count : 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  if (_sections) {
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

- (BOOL)isEmpty {
  return !_items.count;
}

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
      [titles addObject:@"{search}"];
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
