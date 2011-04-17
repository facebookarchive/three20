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

#import "Three20UI/TTExtensionAuthorController.h"

// UI
#import "Three20UI/TTSectionedDataSource.h"
#import "Three20UI/TTTableCaptionItem.h"
#import "Three20UI/TTTableImageItem.h"

// Core
#import "Three20Core/TTCorePreprocessorMacros.h"
#import "Three20Core/TTGlobalCore.h"
#import "Three20Core/NSStringAdditions.h"
#import "Three20Core/TTExtensionInfo.h"
#import "Three20Core/TTExtensionAuthor.h"
#import "Three20Core/TTExtensionLoader.h"


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation TTExtensionAuthorController


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)dealloc {
  TT_RELEASE_SAFELY(_author);

  [super dealloc];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithExtensionID:(NSString*)identifier authorIndex:(NSInteger)authorIndex {
  self = [super initWithNibName:nil bundle:nil];
  if (nil != self) {
    TTExtensionInfo* extensionInfo = [[TTExtensionLoader availableExtensions]
                                      objectForKey:identifier];

    _author = [[extensionInfo.authors objectAtIndex:authorIndex] retain];

    self.title = _author.name;
    self.tableViewStyle = UITableViewStyleGrouped;

    self.variableHeightRows = YES;
  }

  return self;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
  return [self initWithExtensionID:nil authorIndex:0];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSString*)urlPathForGravatar:(NSString*)email size:(NSInteger)size {
  return [NSString stringWithFormat:
          @"http://gravatar.com/avatar/%@?size=%d",
          [email md5Hash],
          size];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)viewDidLoad {
  [super viewDidLoad];

  NSMutableArray* items = [[[NSMutableArray alloc] init] autorelease];
  NSMutableArray* titles = [[[NSMutableArray alloc] init] autorelease];

  [titles addObject:@"Author Information"];

  NSMutableArray* generalInfo = [NSMutableArray array];

  [generalInfo addObjectsFromArray:
   [NSArray arrayWithObjects:
    [TTTableImageItem itemWithText: _author.name
                          imageURL: [self urlPathForGravatar: _author.email
                                                        size: 50]
                      defaultImage: nil
                               URL: nil],
    nil]];

  if (TTIsStringWithAnyText(_author.email)) {
    [generalInfo addObject:
     [TTTableCaptionItem itemWithText:_author.email caption:@"Email:"
                                  URL:[@"mailto:" stringByAppendingString:
                                       _author.email]]];
  }

  if (TTIsStringWithAnyText(_author.github)) {
    [generalInfo addObject:
     [TTTableCaptionItem itemWithText:_author.github caption:@"Github:"
                                  URL:[@"http://github.com/" stringByAppendingString:
                                       _author.github]]];
  }

  if (TTIsStringWithAnyText(_author.twitter)) {
    [generalInfo addObject:
     [TTTableCaptionItem itemWithText:_author.twitter caption:@"Twitter:"
                                  URL:[@"http://twitter.com/" stringByAppendingString:
                                       _author.twitter]]];
  }

  if (TTIsStringWithAnyText(_author.website)) {
    NSString* trimmedWebsite = _author.website;
    NSString* httpPrefix = @"http://";
    if ([trimmedWebsite hasPrefix:httpPrefix]) {
      trimmedWebsite = [trimmedWebsite substringFromIndex:[httpPrefix length]];
    }
    [generalInfo addObject:
     [TTTableCaptionItem itemWithText:trimmedWebsite caption:@"Website:"
                                  URL:_author.website]];
  }

  [items addObject:generalInfo];

  self.dataSource = [TTSectionedDataSource dataSourceWithItems:items sections:titles];
}


@end

