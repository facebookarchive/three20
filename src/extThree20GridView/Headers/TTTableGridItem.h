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

#import <UIKit/UIKit.h>
#import "TTGridViewDataSource.h"

// UI
#import "Three20UI/TTTableLinkedItem.h"

@interface TTTableGridItem : TTTableLinkedItem <TTTableItemSelectingClass> {
    id _dataSource;
    UIEdgeInsets contentInset;
}

/**
 *
 */
@property (retain) id<TTGridViewDataSource> dataSource;

/**
 * The distance that the content view is inset from the
 * enclosing grid view. Use this property to add
 * an area around the content. The unit of size is points.
 * The default value is <tt>UIEdgeInsetsZero</tt>.
 */
@property (assign) UIEdgeInsets contentInset;

/**
 *
 */
+(id)initWithDataSource:(id<TTGridViewDataSource>)anDataSource;

@end
