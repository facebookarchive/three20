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

#import "Three20UI/TTExtensionInfoController.h"

// UI
#import "Three20UI/TTSectionedDataSource.h"
#import "Three20UI/TTTableCaptionItem.h"
#import "Three20UI/TTTableLongTextItem.h"
#import "Three20UI/TTTableTextItem.h"

// Core
#import "Three20Core/TTCorePreprocessorMacros.h"
#import "Three20Core/TTDebug.h"
#import "Three20Core/TTExtensionInfo.h"
#import "Three20Core/TTExtensionAuthor.h"
#import "Three20Core/TTExtensionLoader.h"


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation TTExtensionInfoController


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithExtensionID:(NSString*)identifier {
	self = [super initWithNibName:nil bundle:nil];
  if (self) {
    self.title = @"Extension Info";
    self.tableViewStyle = UITableViewStyleGrouped;

    _extension = [[[TTExtensionLoader availableExtensions] objectForKey:identifier] retain];

    self.variableHeightRows = YES;
  }

  return self;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
  return [self initWithExtensionID:nil];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)dealloc {
  TT_RELEASE_SAFELY(_extension);
  [super dealloc];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)viewDidLoad {
  [super viewDidLoad];

  NSMutableArray* items = [[[NSMutableArray alloc] init] autorelease];
  NSMutableArray* titles = [[[NSMutableArray alloc] init] autorelease];

  [titles addObject:@"Description"];
  [items addObject:[NSArray arrayWithObjects:
                    [TTTableLongTextItem itemWithText:_extension.description],
                    nil]];

  [titles addObject:@"General Info"];
  [items addObject:[NSArray arrayWithObjects:
                    [TTTableCaptionItem itemWithText:_extension.name caption:@"Name:"],
                    [TTTableCaptionItem itemWithText:_extension.version caption:@"Version:"],
                    [TTTableCaptionItem itemWithText:_extension.license caption:@"License:"],
                    [TTTableCaptionItem itemWithText:_extension.copyright caption:@"Copyright:"],
                    nil]];

  if ([_extension.authors count] > 0) {
    [titles addObject:@"Authors"];
    NSMutableArray* authorItems = [[[NSMutableArray alloc] initWithCapacity:
                                    [_extension.authors count]] autorelease];
    for (TTExtensionAuthor* author in _extension.authors) {
      TTDASSERT([author isKindOfClass:[TTExtensionAuthor class]]);
      [authorItems addObject:[TTTableTextItem itemWithText:author.name]];
    }

    [items addObject:authorItems];
  }

  self.dataSource = [TTSectionedDataSource dataSourceWithItems:items sections:titles];
}


@end

