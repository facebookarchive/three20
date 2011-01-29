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

///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@interface TTTwitterSearchFeedModel : TTURLRequestModel {
  NSString* _searchQuery;

  NSMutableArray*  _tweets;

  NSUInteger _page;             // page of search request
  NSUInteger _resultsPerPage;   // results per page, once the initial query is made
                                // this value shouldn't be changed
  BOOL _finished;
}

@property (nonatomic, copy)     NSString*       searchQuery;
@property (nonatomic, readonly) NSMutableArray* tweets;
@property (nonatomic, assign)   NSUInteger      resultsPerPage;
@property (nonatomic, readonly) BOOL            finished;

- (id)initWithSearchQuery:(NSString*)searchQuery;

@end
