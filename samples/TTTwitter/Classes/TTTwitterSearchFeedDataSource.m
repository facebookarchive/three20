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

#import "TTTwitterSearchFeedDataSource.h"

#import "TTTwitterSearchFeedModel.h"
#import "TTTwitterTweet.h"

// Three20 Additions
#import <Three20Core/NSDateAdditions.h>


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation TTTwitterSearchFeedDataSource


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithSearchQuery:(NSString*)searchQuery {
  if (self = [super init]) {
    _searchFeedModel = [[TTTwitterSearchFeedModel alloc] initWithSearchQuery:searchQuery];
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

  for (TTTwitterTweet* tweet in _searchFeedModel.tweets) {
    //TTDPRINT(@"Response text: %@", response.text);
    TTStyledText* styledText = [TTStyledText textFromXHTML:
                                [NSString stringWithFormat:@"%@\n<b>%@</b>",
                                 [[tweet.text stringByReplacingOccurrencesOfString:@"&"
                                                                        withString:@"&amp;"]
                                  stringByReplacingOccurrencesOfString:@"<"
                                  withString:@"&lt;"],
                                 [tweet.created formatRelativeTime]]
                                                lineBreaks:YES URLs:YES];
    // If this asserts, it's likely that the tweet.text contains an HTML character that caused
    // the XML parser to fail.
    TTDASSERT(nil != styledText);
    [items addObject:[TTTableStyledTextItem itemWithText:styledText]];
  }
  
  if (!_searchFeedModel.finished) {
    [items addObject:[TTTableMoreButton itemWithText:@"more…"]];
  }

  self.items = items;
  TT_RELEASE_SAFELY(items);
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSString*)titleForLoading:(BOOL)reloading {
  if (reloading) {
    return NSLocalizedString(@"Updating Twitter feed...", @"Twitter feed updating text");
  } else {
    return NSLocalizedString(@"Loading Twitter feed...", @"Twitter feed loading text");
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSString*)titleForEmpty {
  return NSLocalizedString(@"No tweets found.", @"Twitter feed no results");
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSString*)subtitleForError:(NSError*)error {
  return NSLocalizedString(@"Sorry, there was an error loading the Twitter stream.", @"");
}


@end

