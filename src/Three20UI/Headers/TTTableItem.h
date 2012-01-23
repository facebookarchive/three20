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

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class TTTableViewCell;

@interface TTTableItem : NSObject <NSCoding> {
  id _userInfo;
}

@property (nonatomic, retain) id userInfo;

/**
 *
 * Return class of TTTableViewCell associated with this TTTableViewItem class
 *
 * Override to associate a TTTableItem subclass with a TTTableViewCell sublcass
 *
 */
- (Class)cellClass;

/**
 *
 * Returns a unique identifier for dequeuing reusable TTTableViewCell's
 *
 * Defaults to the class name of the associated TTTableViewCell. Override for dynamic association.
 *
 */
- (NSString*)cellIdentifier;

/**
 *
 * Returns an newly-allocated TTTableViewCell appropriate for this TTTableItem. This method calls
 * [TTableViewCell setObject:] before returning.
 *
 * Override for dynamic association between TTTableItems and TTTableViewCells based on a
 * TTTableItem's properties
 *
 */
- (TTTableViewCell*)newCell;

@end
