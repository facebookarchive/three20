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

#import "Three20/TTGlobalNetwork.h"

@class TTURLRequestQueue;
@class TTURLRequest;


@interface TTRequestLoader : NSObject {
  NSString* _URL;
  TTURLRequestQueue* _queue;
  NSString* _cacheKey;
  TTURLRequestCachePolicy _cachePolicy;
  NSTimeInterval _cacheExpirationAge;
  NSMutableArray* _requests;
  NSURLConnection* _connection;
  NSHTTPURLResponse* _response;
  NSMutableData* _responseData;
  int _retriesLeft;
}

@property(nonatomic,readonly) NSArray* requests;
@property(nonatomic,readonly) NSString* URL;
@property(nonatomic,readonly) NSString* cacheKey;
@property(nonatomic,readonly) TTURLRequestCachePolicy cachePolicy;
@property(nonatomic,readonly) NSTimeInterval cacheExpirationAge;
@property(nonatomic,readonly) BOOL isLoading;

- (id)initForRequest:(TTURLRequest*)request queue:(TTURLRequestQueue*)queue;

- (void)addRequest:(TTURLRequest*)request;
- (void)removeRequest:(TTURLRequest*)request;

- (void)load:(NSURL*)URL;
- (void)loadSynchronously:(NSURL*)URL;
- (BOOL)cancel:(TTURLRequest*)request;

- (NSError*)processResponse:(NSHTTPURLResponse*)response data:(id)data;
- (void)dispatchError:(NSError*)error;
- (void)dispatchLoaded:(NSDate*)timestamp;
- (void)dispatchAuthenticationChallenge:(NSURLAuthenticationChallenge*)challenge;
- (void)cancel;

@end
