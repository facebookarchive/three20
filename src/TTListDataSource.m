/**
 * Copyright 2009 Facebook
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#import "Three20/TTListDataSource.h"
#import "Three20/TTTableItem.h"

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
  TT_RELEASE_SAFELY(_items);
  [super dealloc];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return _items.count;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// TTTableViewDataSource

- (id)tableView:(UITableView*)tableView objectForRowAtIndexPath:(NSIndexPath*)indexPath {
  if (indexPath.row < _items.count) {
    return [_items objectAtIndex:indexPath.row];
  } else {
    return nil;
  }
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

- (NSIndexPath*)indexPathOfItemWithUserInfo:(id)userInfo {
  for (NSInteger i = 0; i < _items.count; ++i) {
    TTTableItem* item = [_items objectAtIndex:i];
    if (item.userInfo == userInfo) {
      return [NSIndexPath indexPathForRow:i inSection:0];
    }
  }
  return nil;
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
  TT_RELEASE_SAFELY(_items);
  TT_RELEASE_SAFELY(_sections);
  [super dealloc];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return _sections ? _sections.count : 1;
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

- (NSIndexPath*)indexPathOfItemWithUserInfo:(id)userInfo {
  if (_sections.count) {
    for (NSInteger i = 0; i < _items.count; ++i) {
      NSArray* items = [_items objectAtIndex:i];
      for (NSInteger j = 0; j < items.count; ++j) {
        TTTableItem* item = [items objectAtIndex:j];
        if (item.userInfo == userInfo) {
          return [NSIndexPath indexPathForRow:j inSection:i];
        }
      }
    }
  } else {
    for (NSInteger i = 0; i < _items.count; ++i) {
      TTTableItem* item = [_items objectAtIndex:i];
      if (item.userInfo == userInfo) {
        return [NSIndexPath indexPathForRow:i inSection:0];
      }
    }
  }
  return nil;
}

- (void)removeItemAtIndexPath:(NSIndexPath*)indexPath {
  [self removeItemAtIndexPath:indexPath andSectionIfEmpty:NO];
}

- (BOOL)removeItemAtIndexPath:(NSIndexPath*)indexPath andSectionIfEmpty:(BOOL)andSection {
  if (_sections.count) {
    NSMutableArray* items = [_items objectAtIndex:indexPath.section];
    [items removeObjectAtIndex:indexPath.row];
    if (!items.count) {
      [_sections removeObjectAtIndex:indexPath.section];
      [_items removeObjectAtIndex:indexPath.section];
      return YES;
    }
  } else if (!indexPath.section) {
    [_items removeObjectAtIndex:indexPath.row];
  }
  return NO;
}

@end
