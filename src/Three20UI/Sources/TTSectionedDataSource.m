//
// Copyright 2009-2011 Facebook
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//    http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

#import "Three20UI/TTSectionedDataSource.h"

// UI
#import "Three20UI/TTTableItem.h"

// Core
#import "Three20Core/TTCorePreprocessorMacros.h"


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation TTSectionedDataSource

@synthesize items     = _items;
@synthesize sections  = _sections;


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithItems:(NSArray*)items sections:(NSArray*)sections {
  if (self = [self init]) {
    _items    = [items mutableCopy];
    _sections = [sections mutableCopy];
  }

  return self;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)dealloc {
  TT_RELEASE_SAFELY(_items);
  TT_RELEASE_SAFELY(_sections);

  [super dealloc];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Class public


///////////////////////////////////////////////////////////////////////////////////////////////////
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


///////////////////////////////////////////////////////////////////////////////////////////////////
+ (TTSectionedDataSource*)dataSourceWithItems:(NSArray*)items sections:(NSArray*)sections {
  return [[[self alloc] initWithItems:items sections:sections] autorelease];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark UITableViewDataSource


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  return _sections ? _sections.count : 1;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  if (_sections) {
    NSArray* items = [_items objectAtIndex:section];
    return items.count;

  } else {
    return _items.count;
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
  if (_sections.count) {
    return [_sections objectAtIndex:section];

  } else {
    return nil;
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark TTTableViewDataSource


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)tableView:(UITableView*)tableView objectForRowAtIndexPath:(NSIndexPath*)indexPath {
  if (_sections) {
    NSArray* section = [_items objectAtIndex:indexPath.section];
    return [section objectAtIndex:indexPath.row];

  } else {
    return [_items objectAtIndex:indexPath.row];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSIndexPath*)tableView:(UITableView*)tableView indexPathForObject:(id)object {
  if (_sections) {
    for (int i = 0; i < _items.count; ++i) {
      NSMutableArray* section = [_items objectAtIndex:i];
      NSUInteger objectIndex = [section indexOfObject:object];
      if (objectIndex != NSNotFound) {
        return [NSIndexPath indexPathForRow:objectIndex inSection:i];
      }
    }

  } else {
    NSUInteger objectIndex = [_items indexOfObject:object];
    if (objectIndex != NSNotFound) {
      return [NSIndexPath indexPathForRow:objectIndex inSection:0];
    }
  }

  return nil;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Public


///////////////////////////////////////////////////////////////////////////////////////////////////
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


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)removeItemAtIndexPath:(NSIndexPath*)indexPath {
  [self removeItemAtIndexPath:indexPath andSectionIfEmpty:NO];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)removeItemAtIndexPath:(NSIndexPath*)indexPath andSectionIfEmpty:(BOOL)andSection {
  if (_sections.count) {
    NSMutableArray* items = [_items objectAtIndex:indexPath.section];
    [items removeObjectAtIndex:indexPath.row];
    if (andSection && !items.count) {
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
