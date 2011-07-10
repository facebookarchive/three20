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

#import "TTExtensionsController.h"

// UI
#import "Three20UI/TTExtensionInfoController.h"
#import "Three20UI/TTNavigator.h"
#import "Three20UI/TTSectionedDataSource.h"
#import "Three20UI/TTTableSubtitleItem.h"
#import "Three20UI/TTTableLongTextItem.h"

// UINavigator
#import "Three20UINavigator/TTURLMap.h"
#import "Three20UINavigator/UIViewController+TTNavigator.h"

// Core
#import "Three20Core/TTExtensionInfo.h"
#import "Three20Core/TTExtensionLoader.h"


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation TTExtensionsController


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  if (self) {
    self.title = @"Extensions";
    self.variableHeightRows = YES;

    self.tableViewStyle = UITableViewStyleGrouped;
  }

  return self;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
+ (void)registerUrlPathsWithNavigator:(TTNavigator*)navigator prefix:(NSString*)prefix {
  TTURLMap* map = navigator.URLMap;

  NSString* extensionsUrlPath = [prefix stringByAppendingString:@"extensions"];
  [map          from: extensionsUrlPath
    toViewController: [TTExtensionsController class]];
  [map          from: [extensionsUrlPath
                       stringByAppendingString:@"/(initWithExtensionID:)"]
    toViewController: [TTExtensionInfoController class]];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (TTTableItem*)tableItemForExtension:(TTExtensionInfo*)extension {
  NSString* urlPath = [[self navigatorURL] stringByAppendingFormat:@"/%@",
                       extension.identifier];
  TTTableSubtitleItem* item = [TTTableSubtitleItem itemWithText: extension.name
                                                       subtitle: extension.version
                                                            URL: urlPath];

  return item;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)viewDidLoad {
  [super viewDidLoad];

  NSDictionary* loadedExtensions = [TTExtensionLoader loadedExtensions];
  NSDictionary* failedExtensions = [TTExtensionLoader failedExtensions];
  NSMutableDictionary* availableExtensions = [NSMutableDictionary dictionaryWithDictionary:
                                              [TTExtensionLoader availableExtensions]];

  NSMutableArray* loadedItems = [[[NSMutableArray alloc]
                                  initWithCapacity:[loadedExtensions count]] autorelease];
  NSMutableArray* failedItems = [[[NSMutableArray alloc]
                                  initWithCapacity:[failedExtensions count]] autorelease];
  NSMutableArray* availableItems = [[[NSMutableArray alloc]
                                     initWithCapacity:[availableExtensions count]] autorelease];

  NSMutableArray* sectionTitles = [[[NSMutableArray alloc] initWithCapacity:3] autorelease];
  NSMutableArray* sectionItems = [[[NSMutableArray alloc] initWithCapacity:3] autorelease];

  if ([loadedExtensions count] > 0) {
    [sectionTitles addObject:@"Loaded extensions"];
    for (NSString* extensionID in loadedExtensions) {
      [availableExtensions removeObjectForKey:extensionID];

      TTExtensionInfo* extension = [loadedExtensions objectForKey:extensionID];
      [loadedItems addObject:[self tableItemForExtension:extension]];
    }
    [sectionItems addObject:loadedItems];
  }

  if ([failedExtensions count] > 0) {
    [sectionTitles addObject:@"Failed extensions"];
    for (NSString* extensionID in failedExtensions) {
      [availableExtensions removeObjectForKey:extensionID];

      TTExtensionInfo* extension = [failedExtensions objectForKey:extensionID];
      [failedItems addObject:[self tableItemForExtension:extension]];
    }
    [sectionItems addObject:failedItems];
  }

  if ([availableExtensions count] > 0) {
    [sectionTitles addObject:@"Linked, but not loaded extensions"];
    for (NSString* extensionID in availableExtensions) {
      TTExtensionInfo* extension = [availableExtensions objectForKey:extensionID];
      [availableItems addObject:[self tableItemForExtension:extension]];
    }
    [availableItems addObject:
     [TTTableLongTextItem itemWithText:
      @"Call [TTExtensionLoader loadAllExtensions] in your app delegate to load extensions."]];
    [sectionItems addObject:availableItems];
  }

  self.dataSource = [TTSectionedDataSource dataSourceWithItems: sectionItems
                                                      sections: sectionTitles];
}

@end

