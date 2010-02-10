//
// Copyright 2009-2010 Facebook
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

#import "Three20/TTTableViewDataSource.h"

///////////////////////////////////////////////////////////////////////////////////////////////////

@interface TTListDataSource : TTTableViewDataSource {
  NSMutableArray* _items;
}

@property(nonatomic,retain) NSMutableArray* items;

+ (TTListDataSource*)dataSourceWithObjects:(id)object,...;
+ (TTListDataSource*)dataSourceWithItems:(NSMutableArray*)items;

- (id)initWithItems:(NSArray*)items;

- (NSIndexPath*)indexPathOfItemWithUserInfo:(id)userInfo;

@end

///////////////////////////////////////////////////////////////////////////////////////////////////

@interface TTSectionedDataSource : TTTableViewDataSource {
  NSMutableArray* _sections;
  NSMutableArray* _items;
}

@property(nonatomic,retain) NSMutableArray* items;
@property(nonatomic,retain) NSMutableArray* sections;

/**
 * Objects should be in this format:
 *
 *   @"section title", item, item, @"section title", item, item, ...
 *
 */
+ (TTSectionedDataSource*)dataSourceWithObjects:(id)object,...;

/**
 * Objects should be in this format:
 *
 *   @"section title", arrayOfItems, @"section title", arrayOfItems, ...
 *
 */
+ (TTSectionedDataSource*)dataSourceWithArrays:(id)object,...;

+ (TTSectionedDataSource*)dataSourceWithItems:(NSArray*)items sections:(NSArray*)sections;

- (id)initWithItems:(NSArray*)items sections:(NSArray*)sections;

- (NSIndexPath*)indexPathOfItemWithUserInfo:(id)userInfo;

- (void)removeItemAtIndexPath:(NSIndexPath*)indexPath;
- (BOOL)removeItemAtIndexPath:(NSIndexPath*)indexPath andSectionIfEmpty:(BOOL)andSection;

@end
