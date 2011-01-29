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

#import "TTTwitterSearchFeedModel.h"

#import "TTTwitterTweet.h"

#import <extThree20JSON/extThree20JSON.h>

// Twitter search API documented here:
// http://apiwiki.twitter.com/w/page/22554756/Twitter-Search-API-Method:-search
static NSString* kTwitterSearchFeedFormat =
  @"http://search.twitter.com/search.json?q=%@&rpp=%u&page=%u";


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation TTTwitterSearchFeedModel

@synthesize searchQuery     = _searchQuery;
@synthesize tweets          = _tweets;
@synthesize resultsPerPage  = _resultsPerPage;
@synthesize finished        = _finished;

///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithSearchQuery:(NSString*)searchQuery {
  if (self = [super init]) {
    self.searchQuery = searchQuery;
    _resultsPerPage = 10;
    _page = 1;
    _tweets = [[NSMutableArray array] retain];
  }

  return self;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void) dealloc {
  TT_RELEASE_SAFELY(_searchQuery);
  TT_RELEASE_SAFELY(_tweets);
  [super dealloc];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)load:(TTURLRequestCachePolicy)cachePolicy more:(BOOL)more {
  if (!self.isLoading && TTIsStringWithAnyText(_searchQuery)) {
    if (more) {
      _page++;
    }
    else {
      _page = 1;
      _finished = NO;
      [_tweets removeAllObjects];
    }

    NSString* url = [NSString stringWithFormat:kTwitterSearchFeedFormat, _searchQuery, _resultsPerPage, _page];

    TTURLRequest* request = [TTURLRequest
                             requestWithURL: url
                             delegate: self];

    request.cachePolicy = cachePolicy;
    request.cacheExpirationAge = TT_CACHE_EXPIRATION_AGE_NEVER;

    TTURLJSONResponse* response = [[TTURLJSONResponse alloc] init];
    request.response = response;
    TT_RELEASE_SAFELY(response);

    [request send];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)requestDidFinishLoad:(TTURLRequest*)request {
  TTURLJSONResponse* response = request.response;
  TTDASSERT([response.rootObject isKindOfClass:[NSDictionary class]]);

  NSDictionary* feed = response.rootObject;
  TTDASSERT([[feed objectForKey:@"results"] isKindOfClass:[NSArray class]]);

  NSArray* entries = [feed objectForKey:@"results"];

  NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
  [dateFormatter setTimeStyle:NSDateFormatterFullStyle];
  [dateFormatter setDateFormat:@"EEE, dd MMMM yyyy HH:mm:ss ZZ"];

  NSMutableArray* tweets = [NSMutableArray arrayWithCapacity:[entries count]];

  for (NSDictionary* entry in entries) {
    TTTwitterTweet* tweet = [[TTTwitterTweet alloc] init];

    NSDate* date = [dateFormatter dateFromString:[entry objectForKey:@"created_at"]];
    tweet.created = date;
    tweet.tweetId = [NSNumber numberWithLongLong:
                     [[entry objectForKey:@"id"] longLongValue]];
    tweet.text = [entry objectForKey:@"text"];
    tweet.source = [entry objectForKey:@"source"];

    [tweets addObject:tweet];
    TT_RELEASE_SAFELY(tweet);
  }
  _finished = tweets.count < _resultsPerPage;
  [_tweets addObjectsFromArray: tweets];

  TT_RELEASE_SAFELY(dateFormatter);

  [super requestDidFinishLoad:request];
}


@end

