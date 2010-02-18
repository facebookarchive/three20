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

#import "Three20/TTURLRequestQueue.h"

#import "Three20/TTGlobalCore.h"
#import "Three20/TTGlobalCorePaths.h"
#import "Three20/TTDebugFlags.h"

#import "Three20/TTURLRequest.h"
#import "Three20/TTURLRequestDelegate.h"
#import "Three20/TTUserInfo.h"
#import "Three20/TTURLResponse.h"
#import "Three20/TTURLCache.h"

#import "Three20/TTRequestLoader.h"
  
static const NSTimeInterval kFlushDelay = 0.3;
static const NSTimeInterval kTimeout = 300.0;
static const NSInteger kMaxConcurrentLoads = 5;
static NSUInteger kDefaultMaxContentLength = 150000;

static NSString* kSafariUserAgent = @"Mozilla/5.0 (iPhone; U; CPU iPhone OS 2_2 like Mac OS X;\
 en-us) AppleWebKit/525.181 (KHTML, like Gecko) Version/3.1.1 Mobile/5H11 Safari/525.20";

static TTURLRequestQueue* gMainQueue = nil;


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation TTURLRequestQueue

@synthesize maxContentLength        = _maxContentLength;
@synthesize userAgent               = _userAgent;
@synthesize suspended               = _suspended;
@synthesize imageCompressionQuality = _imageCompressionQuality;


///////////////////////////////////////////////////////////////////////////////////////////////////
+ (TTURLRequestQueue*)mainQueue {
  if (!gMainQueue) {
    gMainQueue = [[TTURLRequestQueue alloc] init];
  }
  return gMainQueue;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
+ (void)setMainQueue:(TTURLRequestQueue*)queue {
  if (gMainQueue != queue) {
    [gMainQueue release];
    gMainQueue = [queue retain];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)init {
  if (self == [super init]) {
    _loaders = [[NSMutableDictionary alloc] init];
    _loaderQueue = [[NSMutableArray alloc] init];
    _loaderQueueTimer = nil;
    _totalLoading = 0;
    _maxContentLength = kDefaultMaxContentLength;
    _imageCompressionQuality = 0.75;
    _userAgent = [kSafariUserAgent copy];
    _suspended = NO;
  }
  return self;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)dealloc {
  [_loaderQueueTimer invalidate];
  TT_RELEASE_SAFELY(_loaders);
  TT_RELEASE_SAFELY(_loaderQueue);
  TT_RELEASE_SAFELY(_userAgent);
  [super dealloc];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSData*)loadFromBundle:(NSString*)URL error:(NSError**)error {
  NSString* path = TTPathForBundleResource([URL substringFromIndex:9]);
  NSFileManager* fm = [NSFileManager defaultManager];
  if ([fm fileExistsAtPath:path]) {
    return [NSData dataWithContentsOfFile:path];
  } else if (error) {
    *error = [NSError errorWithDomain:NSCocoaErrorDomain
                      code:NSFileReadNoSuchFileError userInfo:nil];
  }
  return nil;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSData*)loadFromDocuments:(NSString*)URL error:(NSError**)error {
  NSString* path = TTPathForDocumentsResource([URL substringFromIndex:12]);
  NSFileManager* fm = [NSFileManager defaultManager];
  if ([fm fileExistsAtPath:path]) {
    return [NSData dataWithContentsOfFile:path];
  } else if (error) {
    *error = [NSError errorWithDomain:NSCocoaErrorDomain
                      code:NSFileReadNoSuchFileError userInfo:nil];
  }
  return nil;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)loadFromCache:(NSString*)URL cacheKey:(NSString*)cacheKey
    expires:(NSTimeInterval)expirationAge fromDisk:(BOOL)fromDisk data:(id*)data
    error:(NSError**)error timestamp:(NSDate**)timestamp {
  UIImage* image = [[TTURLCache sharedCache] imageForURL:URL fromDisk:fromDisk];
  if (image) {
    *data = image;
    return YES;    
  } else if (fromDisk) {
    if (TTIsBundleURL(URL)) {
      *data = [self loadFromBundle:URL error:error];
      return YES;
    } else if (TTIsDocumentsURL(URL)) {
      *data = [self loadFromDocuments:URL error:error];
      return YES;
    } else {
      *data = [[TTURLCache sharedCache] dataForKey:cacheKey expires:expirationAge
                                        timestamp:timestamp];
      if (*data) {
        return YES;
      }
    }
  }
  
  return NO;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)loadRequestFromCache:(TTURLRequest*)request {
  if (!request.cacheKey) {
    request.cacheKey = [[TTURLCache sharedCache] keyForURL:request.URL];
  }

  if (request.cachePolicy & (TTURLRequestCachePolicyDisk|TTURLRequestCachePolicyMemory)) {
    id data = nil;
    NSDate* timestamp = nil;
    NSError* error = nil;
    
    if ([self loadFromCache:request.URL cacheKey:request.cacheKey
              expires:request.cacheExpirationAge
              fromDisk:!_suspended && request.cachePolicy & TTURLRequestCachePolicyDisk
              data:&data error:&error timestamp:&timestamp]) {
      request.isLoading = NO;

      if (!error) {
        error = [request.response request:request processResponse:nil data:data];
      }
      
      if (error) {
        for (id<TTURLRequestDelegate> delegate in request.delegates) {
          if ([delegate respondsToSelector:@selector(request:didFailLoadWithError:)]) {
            [delegate request:request didFailLoadWithError:error];
          }
        }
      } else {
        request.timestamp = timestamp ? timestamp : [NSDate date];
        request.respondedFromCache = YES;

        for (id<TTURLRequestDelegate> delegate in request.delegates) {
          if ([delegate respondsToSelector:@selector(requestDidFinishLoad:)]) {
            [delegate requestDidFinishLoad:request];
          }
        }
      }
      
      return YES;
    }
  }
  
  return NO;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)executeLoader:(TTRequestLoader*)loader {
  id data = nil;
  NSDate* timestamp = nil;
  NSError* error = nil;
  
  if ((loader.cachePolicy & (TTURLRequestCachePolicyDisk|TTURLRequestCachePolicyMemory))
      && [self loadFromCache:loader.URL cacheKey:loader.cacheKey
               expires:loader.cacheExpirationAge
               fromDisk:loader.cachePolicy & TTURLRequestCachePolicyDisk
               data:&data error:&error timestamp:&timestamp]) {
    [_loaders removeObjectForKey:loader.cacheKey];

    if (!error) {
      error = [loader processResponse:nil data:data];
    }
    if (error) {
      [loader dispatchError:error];
    } else {
      [loader dispatchLoaded:timestamp];
    }
  } else {
    ++_totalLoading;
    [loader load:[NSURL URLWithString:loader.URL]];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)loadNextInQueueDelayed {
  if (!_loaderQueueTimer) {
    _loaderQueueTimer = [NSTimer scheduledTimerWithTimeInterval:kFlushDelay target:self
      selector:@selector(loadNextInQueue) userInfo:nil repeats:NO];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)loadNextInQueue {
  _loaderQueueTimer = nil;

  for (int i = 0;
       i < kMaxConcurrentLoads && _totalLoading < kMaxConcurrentLoads
       && _loaderQueue.count;
       ++i) {
    TTRequestLoader* loader = [[_loaderQueue objectAtIndex:0] retain];
    [_loaderQueue removeObjectAtIndex:0];
    [self executeLoader:loader];
    [loader release];
  }

  if (_loaderQueue.count && !_suspended) {
    [self loadNextInQueueDelayed];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)removeLoader:(TTRequestLoader*)loader {
  --_totalLoading;
  [_loaders removeObjectForKey:loader.cacheKey];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)loader:(TTRequestLoader*)loader didLoadResponse:(NSHTTPURLResponse*)response data:(id)data {
  [loader retain];
  [self removeLoader:loader];
  
  NSError* error = [loader processResponse:response data:data];
  if (error) {
    [loader dispatchError:error];
  } else {
    if (!(loader.cachePolicy & TTURLRequestCachePolicyNoCache)) {
      [[TTURLCache sharedCache] storeData:data forKey:loader.cacheKey];
    }
    [loader dispatchLoaded:[NSDate date]];
  }
  [loader release];

  [self loadNextInQueue];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
-(void)loader:(TTRequestLoader*)loader didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *) challenge{
  TTDCONDITIONLOG(TTDFLAG_URLREQUEST, @"CHALLENGE: %@", challenge);
  [loader dispatchAuthenticationChallenge:challenge];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)loader:(TTRequestLoader*)loader didFailLoadWithError:(NSError*)error {
  TTDCONDITIONLOG(TTDFLAG_URLREQUEST, @"ERROR: %@", error);
  [self removeLoader:loader];
  [loader dispatchError:error];
  [self loadNextInQueue];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)loaderDidCancel:(TTRequestLoader*)loader wasLoading:(BOOL)wasLoading {
  if (wasLoading) {
    [self removeLoader:loader];
    [self loadNextInQueue];
  } else {
    [_loaders removeObjectForKey:loader.cacheKey];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setSuspended:(BOOL)isSuspended {
  TTDCONDITIONLOG(TTDFLAG_URLREQUEST, @"SUSPEND LOADING %d", isSuspended);
  _suspended = isSuspended;
  
  if (!_suspended) {
    [self loadNextInQueue];
  } else if (_loaderQueueTimer) {
    [_loaderQueueTimer invalidate];
    _loaderQueueTimer = nil;
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)sendRequest:(TTURLRequest*)request {
  if ([self loadRequestFromCache:request]) {
    return YES;
  }

  for (id<TTURLRequestDelegate> delegate in request.delegates) {
    if ([delegate respondsToSelector:@selector(requestDidStartLoad:)]) {
      [delegate requestDidStartLoad:request];
    }
  }
  
  if (!request.URL.length) {
    NSError* error = [NSError errorWithDomain:NSURLErrorDomain code:NSURLErrorBadURL userInfo:nil];
    for (id<TTURLRequestDelegate> delegate in request.delegates) {
      if ([delegate respondsToSelector:@selector(request:didFailLoadWithError:)]) {
        [delegate request:request didFailLoadWithError:error];
      }
    }
    return NO;
  }

  request.isLoading = YES;
  
  TTRequestLoader* loader = nil;

  // If we're not POSTing or PUTting data, let's see if we can jump on an existing request.
  if (![request.httpMethod isEqualToString:@"POST"]
      && ![request.httpMethod isEqualToString:@"PUT"]) {
    // Next, see if there is an active loader for the URL and if so join that bandwagon.
    loader = [_loaders objectForKey:request.cacheKey];
    if (loader) {
      [loader addRequest:request];
      return NO;
    }
  }

  // Finally, create a new loader and hit the network (unless we are suspended)
  loader = [[TTRequestLoader alloc] initForRequest:request queue:self];
  [_loaders setObject:loader forKey:request.cacheKey];
  if (_suspended || _totalLoading == kMaxConcurrentLoads) {
    [_loaderQueue addObject:loader];
  } else {
    ++_totalLoading;
    [loader load:[NSURL URLWithString:request.URL]];
  }
  [loader release];
  
  return NO;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)sendSynchronousRequest:(TTURLRequest*)request {
  if ([self loadRequestFromCache:request]) {
    return YES;
  }

  for (id<TTURLRequestDelegate> delegate in request.delegates) {
    if ([delegate respondsToSelector:@selector(requestDidStartLoad:)]) {
      [delegate requestDidStartLoad:request];
    }
  }

  if (!request.URL.length) {
    NSError* error = [NSError errorWithDomain:NSURLErrorDomain code:NSURLErrorBadURL userInfo:nil];
    for (id<TTURLRequestDelegate> delegate in request.delegates) {
      if ([delegate respondsToSelector:@selector(request:didFailLoadWithError:)]) {
        [delegate request:request didFailLoadWithError:error];
      }
    }
    return NO;
  }

  request.isLoading = YES;

  // Finally, create a new loader and hit the network (unless we are suspended)
  TTRequestLoader* loader = [[TTRequestLoader alloc] initForRequest:request queue:self];

  // Should be decremented eventually by loadSynchronously
  ++_totalLoading;

  [loader loadSynchronously:[NSURL URLWithString:request.URL]];
  TT_RELEASE_SAFELY(loader);

  return NO;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)cancelRequest:(TTURLRequest*)request {
  if (request) {
    TTRequestLoader* loader = [_loaders objectForKey:request.cacheKey];
    if (loader) {
      [loader retain];
      if (![loader cancel:request]) {
        [_loaderQueue removeObject:loader];
      }
      [loader release];
    }
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)cancelRequestsWithDelegate:(id)delegate {
  NSMutableArray* requestsToCancel = nil;
  
  for (TTRequestLoader* loader in [_loaders objectEnumerator]) {
    for (TTURLRequest* request in loader.requests) {
      for (id<TTURLRequestDelegate> requestDelegate in request.delegates) {
        if (delegate == requestDelegate) {
          if (!requestsToCancel) {
            requestsToCancel = [NSMutableArray array];
          }
          [requestsToCancel addObject:request];
          break;
        }
      }

      if ([request.userInfo isKindOfClass:[TTUserInfo class]]) {
        TTUserInfo* userInfo = request.userInfo;
        if (userInfo.weakRef && userInfo.weakRef == delegate) {
          if (!requestsToCancel) {
            requestsToCancel = [NSMutableArray array];
          }
          [requestsToCancel addObject:request];
        }
      }
    }
  }
  
  for (TTURLRequest* request in requestsToCancel) {
    [self cancelRequest:request];
  }  
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)cancelAllRequests {
  for (TTRequestLoader* loader in [[[_loaders copy] autorelease] objectEnumerator]) {
    [loader cancel];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSURLRequest*)createNSURLRequest:(TTURLRequest*)request URL:(NSURL*)URL {
  if (!URL) {
    URL = [NSURL URLWithString:request.URL];
  }
  
  NSMutableURLRequest* URLRequest = [NSMutableURLRequest requestWithURL:URL
                                    cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                    timeoutInterval:kTimeout];
  [URLRequest setValue:self.userAgent forHTTPHeaderField:@"User-Agent"];

  if (request) {
    [URLRequest setHTTPShouldHandleCookies:request.shouldHandleCookies];
    
    NSString* method = request.httpMethod;
    if (method) {
      [URLRequest setHTTPMethod:method];
    }
    
    NSString* contentType = request.contentType;
    if (contentType) {
      [URLRequest setValue:contentType forHTTPHeaderField:@"Content-Type"];
    }
    
    NSData* body = request.httpBody;
    if (body) {
      [URLRequest setHTTPBody:body];
    }

    NSDictionary* headers = request.headers;
    for (NSString *key in [headers keyEnumerator]) {
      [URLRequest setValue:[headers objectForKey:key] forHTTPHeaderField:key];
    }
  }
  
  return URLRequest;
}


@end
