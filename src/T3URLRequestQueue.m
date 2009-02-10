#import "Three20/T3URLRequestQueue.h"
#import "Three20/T3URLCache.h"
#import "Three20/T3URLRequest.h"

//////////////////////////////////////////////////////////////////////////////////////////////////
  
static const NSTimeInterval kFlushDelay = 0.3;
static const NSTimeInterval kTimeout = 300.0;
static const NSInteger kLoadMaxRetries = 2;
static const NSInteger kMaxConcurrentLoads = 5;
static NSUInteger kDefaultMaxContentLength = 150000;

static NSString* kSafariUserAgent = @"Mozilla/5.0 (iPhone; U; CPU iPhone OS 2_2 like Mac OS X;\
 en-us) AppleWebKit/525.181 (KHTML, like Gecko) Version/3.1.1 Mobile/5H11 Safari/525.20";

//////////////////////////////////////////////////////////////////////////////////////////////////

@interface T3RequestLoader : NSObject {
  NSString* _url;
  NSString* _cacheKey;
  T3URLRequestQueue* _queue;
  T3URLRequestCachePolicy _cachePolicy;
  NSMutableArray* _requests;
  NSURLConnection* _connection;
  NSMutableData* _responseData;
  NSInteger _statusCode;
  NSString* _contentType;
  NSTimeInterval _cacheExpirationAge;
  BOOL _shouldConvertToMedia;
  int _retriesLeft;
}

@property(nonatomic,readonly) NSArray* requests;
@property(nonatomic,readonly) NSString* url;
@property(nonatomic,readonly) NSString* cacheKey;
@property(nonatomic,readonly) NSString* contentType;
@property(nonatomic,readonly) T3URLRequestCachePolicy cachePolicy;
@property(nonatomic,readonly) NSTimeInterval cacheExpirationAge;
@property(nonatomic,readonly) BOOL loading;
@property(nonatomic,readonly) BOOL shouldConvertToMedia;

- (id)initForRequest:(T3URLRequest*)request queue:(T3URLRequestQueue*)queue;

- (void)addRequest:(T3URLRequest*)request;
- (void)removeRequest:(T3URLRequest*)request;

- (void)load;
- (BOOL)cancel:(T3URLRequest*)request;

@end

@implementation T3RequestLoader

@synthesize url = _url, requests = _requests, contentType = _contentType, cacheKey = _cacheKey,
  cachePolicy = _cachePolicy, cacheExpirationAge = _cacheExpirationAge,
  shouldConvertToMedia = _shouldConvertToMedia;

- (id)initForRequest:(T3URLRequest*)request queue:(T3URLRequestQueue*)queue {
  if (self = [super init]) {
    _url = [request.url copy];
    _cacheKey = [request.cacheKey copy];
    _cachePolicy = request.cachePolicy;
    _cacheExpirationAge = request.cacheExpirationAge;
    _queue = queue;
    _connection = nil;
    _statusCode = 0;
    _contentType = nil;
    _shouldConvertToMedia = NO;
    _retriesLeft = kLoadMaxRetries;
    _responseData = nil;
    _requests = [[NSMutableArray alloc] init];
    [self addRequest:request];
  }
  return self;
}
 
- (void)dealloc {
  [_connection cancel];
  [_connection release];
  [_responseData release];
  [_url release];
  [_cacheKey release];
  [_contentType release];
  [_requests release];  
  [super dealloc];
}

//////////////////////////////////////////////////////////////////////////////////////////////////

- (void)connect {
  T3NetworkRequestStarted();

  NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:_url]
                                    cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                    timeoutInterval:kTimeout];
  [urlRequest setValue:_queue.userAgent forHTTPHeaderField:@"User-Agent"];

  if (_requests.count == 1) {
    T3URLRequest* request = [_requests objectAtIndex:0];
    [urlRequest setHTTPShouldHandleCookies:request.shouldHandleCookies];
    
    NSString* method = request.httpMethod;
    if (method) {
      [urlRequest setHTTPMethod:method];
    }
    
    NSString* contentType = request.contentType;
    if (contentType) {
      [urlRequest setValue:contentType forHTTPHeaderField:@"Content-Type"];
    }
    
    NSData* body = request.httpBody;
    if (body) {
      [urlRequest setHTTPBody:body];
    }
  }
  
  _connection = [[NSURLConnection alloc] initWithRequest:urlRequest delegate:self];
}

- (void)cancel {
  NSArray* requestsToCancel = [_requests copy];
  for (id request in requestsToCancel) {
    [self cancel:request];
  }
  [requestsToCancel release];
}

- (NSError*)validateData:(NSData*)data {
  for (T3URLRequest* request in _requests) {
    NSError* error = [request.handler request:request validateData:data];
    if (error) {
      return error;
    }
  }
  return nil;
}

- (void)dispatchData:(NSData*)data media:(id)media timestamp:(NSDate*)timestamp {
  for (T3URLRequest* request in [[_requests copy] autorelease]) {
    request.timestamp = timestamp;
    request.loading = NO;

    if ([request.handler respondsToSelector:@selector(request:loadedData:media:)]) {
      [request.handler request:request loadedData:data media:media];
    }
    
    if ([request.delegate respondsToSelector:@selector(request:loadedData:media:)]) {
      [request.delegate request:request loadedData:data media:media];
    }
  }
}

- (void)dispatchError:(NSError*)error {
  for (T3URLRequest* request in [[_requests copy] autorelease]) {
    request.loading = NO;

    if ([request.handler respondsToSelector:@selector(request:didFailWithError:)]) {
      [request.handler request:request didFailWithError:error];
    }

    if ([request.delegate respondsToSelector:@selector(request:didFailWithError:)]) {
      [request.delegate request:request didFailWithError:error];
    }
  }
}

//////////////////////////////////////////////////////////////////////////////////////////////////
// NSURLConnectionDelegate
 
- (void)connection:(NSURLConnection*)connection didReceiveResponse:(NSHTTPURLResponse*)response {
  _statusCode = response.statusCode;
  NSDictionary* headers = [response allHeaderFields];
  int contentLength = [[headers objectForKey:@"Content-Length"] intValue];
  if (contentLength > _queue.maxContentLength && _queue.maxContentLength) {
    [self cancel];
  }

  if (_shouldConvertToMedia) {
    NSDictionary* headers = [response allHeaderFields];
    if (headers) {
      _contentType = [[headers objectForKey:@"Content-Type"] retain];
    }
  }

  _responseData = [[NSMutableData alloc] initWithCapacity:contentLength];
}

-(void)connection:(NSURLConnection*)connection didReceiveData:(NSData*)data {
  [_responseData appendData:data];
}

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection
    willCacheResponse:(NSCachedURLResponse *)cachedResponse {
  return nil;
}

-(void)connectionDidFinishLoading:(NSURLConnection *)connection {
  T3NetworkRequestStopped();

  //T3LOG(@"Loaded: %s", _responseData.bytes);

  if (_statusCode == 200) {
    [_queue performSelector:@selector(loader:loadedData:) withObject:self withObject:_responseData];
  } else {
    T3LOG(@"  FAILED LOADING (%d) %@", _statusCode, _url);
    NSError* error = [NSError errorWithDomain:NSURLErrorDomain code:_statusCode userInfo:nil];
    [_queue performSelector:@selector(loader:didFailWithError:) withObject:self withObject:error];
  }

  [_responseData release];
  _responseData = nil;
  [_connection release];
  _connection = nil;
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {  
  T3LOG(@"  FAILED LOADING %@ FOR %@", _url, error);

  T3NetworkRequestStopped();
  
  [_responseData release];
  _responseData = nil;
  [_connection release];
  _connection = nil;
  
  if ([error.domain isEqualToString:NSURLErrorDomain] && error.code == NSURLErrorCannotFindHost
      && _retriesLeft) {
    // If there is a network error then we will wait and retry a few times just in case
    // it was just a temporary blip in connectivity
    --_retriesLeft;
    [self connect];
  } else {
    [_queue performSelector:@selector(loader:didFailWithError:) withObject:self withObject:error];
  }
}

//////////////////////////////////////////////////////////////////////////////////////////////////

- (BOOL)loading {
  return !!_connection;
}

- (void)addRequest:(T3URLRequest*)request {
  [_requests addObject:request];
  if (request.shouldConvertToMedia) {
    _shouldConvertToMedia = YES;
  }
}

- (void)removeRequest:(T3URLRequest*)request {
  [_requests removeObject:request];
}

- (void)load {
  if (!_connection) {
    [self connect];
  }
}

- (BOOL)cancel:(T3URLRequest*)request {
  NSUInteger index = [_requests indexOfObject:request];
  if (index != NSNotFound) {
    [_requests removeObjectAtIndex:index];
    
    request.loading = NO;

    if ([request.handler respondsToSelector:@selector(requestCancelled:)]) {
      [request.handler requestCancelled:request];
    }    
    if ([request.delegate respondsToSelector:@selector(requestCancelled:)]) {
      [request.delegate requestCancelled:request];
    }
  }
  if (![_requests count]) {
    [_queue performSelector:@selector(loaderDidCancel:wasLoading:) withObject:self
      withObject:(id)!!_connection];
    if (_connection) {
      T3NetworkRequestStopped();
      [_connection cancel];
      _connection = nil;
    }
    return NO;
  } else {
    return YES;
  }
}
 
@end

//////////////////////////////////////////////////////////////////////////////////////////////////

@implementation T3URLRequestQueue

@synthesize maxContentLength = _maxContentLength, userAgent = _userAgent, paused = _paused;

+ (T3URLRequestQueue*)mainQueue {
  static T3URLRequestQueue* mainQueue = nil;
  if (!mainQueue) {
    mainQueue = [[T3URLRequestQueue alloc] init];
  }
  return mainQueue;
}

//////////////////////////////////////////////////////////////////////////////////////////////////

- (id)init {
  if (self == [super init]) {
    _loaders = [[NSMutableDictionary alloc] init];
    _loaderQueue = [[NSMutableArray alloc] init];
    _loaderQueueTimer = nil;
    _totalLoading = 0;
    _maxContentLength = kDefaultMaxContentLength;
    _userAgent = [kSafariUserAgent copy];
    _paused = NO;
  }
  return self;
}

- (void)dealloc {
  [_loaders release];
  [_loaderQueue release];
  [_loaderQueueTimer invalidate];
  [_userAgent release];
  [super dealloc];
}

//////////////////////////////////////////////////////////////////////////////////////////////////

- (BOOL)loadFromCache:(NSString*)url cacheKey:(NSString*)cacheKey
    expires:(NSTimeInterval)expirationAge shouldConvertToMedia:(BOOL)shouldConvertToMedia
    fromDisk:(BOOL)fromDisk data:(NSData**)data media:(id*)media timestamp:(NSDate**)timestamp {
  if (shouldConvertToMedia) {
    *media = [[T3URLCache sharedCache] getMediaForURL:url fromDisk:NO];
    if (*media) {
      return YES;
    }
  }
  
  if (fromDisk) {
    *data = [[T3URLCache sharedCache] getDataForKey:cacheKey expires:expirationAge
      timestamp:timestamp];
    if (*data) {
      if (shouldConvertToMedia) {
        *media = [[T3URLCache sharedCache] convertDataToMedia:*data forType:nil];
        [[T3URLCache sharedCache] storeData:nil media:*media forKey:cacheKey toDisk:NO];
      }

      return YES;
    }
  }
  
  return NO;
}

- (BOOL)loadRequestFromCache:(T3URLRequest*)request {
  if (request.cachePolicy & (T3URLRequestCachePolicyDisk|T3URLRequestCachePolicyMemory)) {
    NSData* data = nil;
    id media = nil;
    NSDate* timestamp = nil;
    BOOL delayed = _paused || _totalLoading == kMaxConcurrentLoads;
    
    if ([self loadFromCache:request.url cacheKey:request.cacheKey
        expires:request.cacheExpirationAge
        shouldConvertToMedia:request.shouldConvertToMedia
        fromDisk:!delayed && request.cachePolicy & T3URLRequestCachePolicyDisk
        data:&data media:&media timestamp:&timestamp]) {

      NSError* error = [request.handler request:request validateData:data];
      if (error) {
        if ([request.handler respondsToSelector:@selector(request:didFailWithError:)]) {
          [request.handler request:request didFailWithError:error];
        }

        if ([request.delegate respondsToSelector:@selector(request:didFailWithError:)]) {
          [request.delegate request:request didFailWithError:error];
        }
      } else {
        request.responseFromCache = YES;
        request.timestamp = timestamp;
        request.loading = NO;

        if ([request.handler respondsToSelector:@selector(request:loadedData:media:)]) {
          [request.handler request:request loadedData:data media:media];
        }
        
        if ([request.delegate respondsToSelector:@selector(request:loadedData:media:)]) {
          [request.delegate request:request loadedData:data media:media];
        }
      }
      
      return YES;
    }
  }
  
  return NO;
}

- (void)executeLoader:(T3RequestLoader*)loader {
  NSData* data = nil;
  id media = nil;
  NSDate* timestamp = nil;
  BOOL canUseCache = loader.cachePolicy
    & (T3URLRequestCachePolicyDisk|T3URLRequestCachePolicyMemory);
  
  if (canUseCache && [self loadFromCache:loader.url cacheKey:loader.cacheKey
      expires:loader.cacheExpirationAge shouldConvertToMedia:loader.shouldConvertToMedia
      fromDisk:loader.cachePolicy & T3URLRequestCachePolicyDisk
      data:&data media:&media timestamp:&timestamp]) {
    NSError* error = [loader validateData:data];
    if (error) {
      [loader dispatchError:error];
    } else {
      [loader dispatchData:data media:media timestamp:timestamp];
    }
    
    [_loaders removeObjectForKey:loader.cacheKey];
  } else {
    ++_totalLoading;
    [loader load];
  }
}

- (void)loadNextInQueueDelayed {
  if (!_loaderQueueTimer) {
    _loaderQueueTimer = [NSTimer scheduledTimerWithTimeInterval:kFlushDelay target:self
      selector:@selector(loadNextInQueue) userInfo:nil repeats:NO];
  }
}

- (void)loadNextInQueue {
  _loaderQueueTimer = nil;

  for (int i = 0; i < kMaxConcurrentLoads && _totalLoading < kMaxConcurrentLoads
      && _loaderQueue.count; ++i) {
    T3RequestLoader* loader = [[_loaderQueue objectAtIndex:0] retain];
    [_loaderQueue removeObjectAtIndex:0];
    [self executeLoader:loader];
    [loader release];
  }

  if (_loaderQueue.count) {
    [self loadNextInQueueDelayed];
  }
}

- (void)loadNextInQueueAfterLoader:(T3RequestLoader*)loader {
  --_totalLoading;
  [_loaders removeObjectForKey:loader.cacheKey];
  [self loadNextInQueue];
}

- (void)loader:(T3RequestLoader*)loader didFailWithError:(NSError*)error {
  [loader dispatchError:error];
  [self loadNextInQueueAfterLoader:loader];
}

- (void)loader:(T3RequestLoader*)loader loadedData:(NSData*)data {
  NSError* error = [loader validateData:data];
  if (error) {
    [loader dispatchError:error];
  } else {
    id media = nil;
    if (loader.shouldConvertToMedia) {
      media = [[T3URLCache sharedCache] convertDataToMedia:data forType:loader.contentType];
      if (!media) {
        return [self loader:loader didFailWithError:nil];
      }
    }

    if (!(loader.cachePolicy & T3URLRequestCachePolicyNoCache)) {
      [[T3URLCache sharedCache] storeData:data media:media forKey:loader.cacheKey toDisk:YES];
    }
    [loader dispatchData:data media:media timestamp:[NSDate date]];
  }

  [self loadNextInQueueAfterLoader:loader];
}

- (void)loaderDidCancel:(T3RequestLoader*)loader wasLoading:(BOOL)wasLoading {
  if (wasLoading) {
    [self loadNextInQueueAfterLoader:loader];
  } else {
    [_loaders removeObjectForKey:loader.cacheKey];
  }
}

//////////////////////////////////////////////////////////////////////////////////////////////////

- (void)setPaused:(BOOL)isPaused {
  // T3LOG(@"PAUSE CACHE %d", isPaused);
  _paused = isPaused;
  
  if (!_paused) {
    [self loadNextInQueue];
  } else if (_loaderQueueTimer) {
    [_loaderQueueTimer invalidate];
    _loaderQueueTimer = nil;
  }
}

- (BOOL)sendRequest:(T3URLRequest*)request {
  if (!request.cacheKey) {
    request.cacheKey = [[T3URLCache sharedCache] keyForURL:request.url];
  }
  
  if ([request.handler respondsToSelector:@selector(requestLoading:)]) {
    [request.handler requestLoading:request];
  }
  
  if ([request.delegate respondsToSelector:@selector(requestLoading:)]) {
    [request.delegate requestLoading:request];
  }
  
  if ([self loadRequestFromCache:request]) {
    return YES;
  }

  request.loading = YES;
  
  T3RequestLoader* loader = nil;
  if (![request.httpMethod isEqualToString:@"POST"]) {
    // Next, see if there is an active loader for the URL and if so join that bandwagon
    loader = [_loaders objectForKey:request.cacheKey];
    if (loader) {
      [loader addRequest:request];
      return NO;
    }
  }
  
  // Finally, create a new loader and hit the network (unless we are paused)
  loader = [[T3RequestLoader alloc] initForRequest:request queue:self];
  [_loaders setObject:loader forKey:request.cacheKey];
  if (_paused || _totalLoading == kMaxConcurrentLoads) {
    [_loaderQueue addObject:loader];
  } else {
    ++_totalLoading;
    [loader load];
  }
  [loader release];

  return NO;
}

- (void)cancelRequest:(T3URLRequest*)request {
  if (request) {
    T3RequestLoader* loader = [_loaders objectForKey:request.cacheKey];
    if (loader) {
      if (![loader cancel:request]) {
        [_loaderQueue removeObject:loader];
      }
    }
  }
}

- (void)cancelRequestsWithDelegate:(id)delegate {
  NSMutableArray* requestsToCancel = nil;
  
  for (T3RequestLoader* loader in [_loaders objectEnumerator]) {
    for (T3URLRequest* request in loader.requests) {
      if (request.delegate == delegate || request.handler == delegate
          || request.handlerDelegate == delegate) {
        if (!requestsToCancel) {
          requestsToCancel = [NSMutableArray array];
        }
        [requestsToCancel addObject:request];
      }
    }
  }
  
  for (T3URLRequest* request in requestsToCancel) {
    [self cancelRequest:request];
  }  
}

- (void)cancelAllRequests {
  for (T3RequestLoader* loader in [[[_loaders copy] autorelease] objectEnumerator]) {
    [loader cancel];
  }
}

@end
