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


// When the items your TTTableViewDataSource collects conform to this protocol
// the datasource can ask the items what cell class should be used to render the item
@protocol TTTableItemSelectingClass <NSObject>
@required
+(Class)cellClass;
@end

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface TTTableItem : NSObject <NSCoding> {
  id _userInfo;
}

@property (nonatomic, retain) id userInfo;

@end
