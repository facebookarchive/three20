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

#import "TTFacebookSearchFeedDataSource.h"

#import "TTFacebookSearchFeedModel.h"
#import "TTFacebookPost.h"

// Three20 Additions
#import <Three20/NSDateAdditions.h>


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation TTFacebookSearchFeedDataSource


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithSearchQuery:(NSString*)searchQuery {
  if (self = [super init]) {
    _searchFeedModel = [[TTFacebookSearchFeedModel alloc] initWithSearchQuery:searchQuery];
  }

  return self;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)dealloc {
  TT_RELEASE_SAFELY(_searchFeedModel);

  [super dealloc];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id<TTModel>)model {
  return _searchFeedModel;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)tableViewDidLoadModel:(UITableView*)tableView {
  NSMutableArray* items = [[NSMutableArray alloc] init];

  for (TTFacebookPost* post in _searchFeedModel.posts) {
    //TTDPRINT(@"Response text: %@", response.text);
    TTStyledText* styledText = [TTStyledText textFromXHTML:
                                [NSString stringWithFormat:@"%@\n<b>%@</b>",
                                 [[post.text stringByReplacingOccurrencesOfString:@"&"
                                                                        withString:@"&amp;"]
                                  stringByReplacingOccurrencesOfString:@"<"
                                  withString:@"&lt;"],
                                 [post.created formatRelativeTime]]
                                                lineBreaks:YES URLs:YES];
    // If this asserts, it's likely that the post.text contains an HTML character that caused
    // the XML parser to fail.
    TTDASSERT(nil != styledText);
    [items addObject:[TTTableStyledTextItem itemWithText:styledText]];
  }

  self.items = items;
  TT_RELEASE_SAFELY(items);
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSString*)titleForLoading:(BOOL)reloading {
  if (reloading) {
    return NSLocalizedString(@"Updating Facebook feed...", @"Facebook feed updating text");
  } else {
    return NSLocalizedString(@"Loading Facebook feed...", @"Facebook feed loading text");
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSString*)titleForEmpty {
  return NSLocalizedString(@"No posts found.", @"Facebook feed no results");
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSString*)subtitleForError:(NSError*)error {
  return NSLocalizedString(@"Sorry, there was an error loading the Facebook stream.", @"");
}


@end

