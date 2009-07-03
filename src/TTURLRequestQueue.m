#import "Three20/TTURLRequestQueue.h"
#import "Three20/TTURLRequest.h"
#import "Three20/TTURLResponse.h"
#import "Three20/TTURLCache.h"

//////////////////////////////////////////////////////////////////////////////////////////////////
  
static const NSTimeInterval kFlushDelay = 0.3;
static const NSTimeInterval kTimeout = 300.0;
static const NSInteger kLoadMaxRetries = 2;
static const NSInteger kMaxConcurrentLoads = 5;
static NSUInteger kDefaultMaxContentLength = 150000;

static NSString* kSafariUserAgent = @"Mozilla/5.0 (iPhone; U; CPU iPhone OS 2_2 like Mac OS X;\
 en-us) AppleWebKit/525.181 (KHTML, like Gecko) Version/3.1.1 Mobile/5H11 Safari/525.20";

static TTURLRequestQueue* gMainQueue = nil;

//////////////////////////////////////////////////////////////////////////////////////////////////

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
- (BOOL)cancel:(TTURLRequest*)request;

@end

@implementation TTRequestLoader

@synthesize URL = _URL, requests = _requests, cacheKey = _cacheKey,
  cachePolicy = _cachePolicy, cacheExpirationAge = _cacheExpirationAge;

- (id)initForRequest:(TTURLRequest*)request queue:(TTURLRequestQueue*)queue {
  if (self = [super init]) {
    _URL = [request.URL copy];
    _queue = queue;
    _cacheKey = [request.cacheKey retain];
    _cachePolicy = request.cachePolicy;
    _cacheExpirationAge = request.cacheExpirationAge;
    _requests = [[NSMutableArray alloc] init];
    _connection = nil;
    _retriesLeft = kLoadMaxRetries;
    _response = nil;
    _responseData = nil;
    [self addRequest:request];
  }
  return self;
}
 
- (void)dealloc {
  [_connection cancel];
  [_connection release];
  [_response release];
  [_responseData release];
  [_URL release];
  [_cacheKey release];
  [_requests release]; 
  [super dealloc];
}

//////////////////////////////////////////////////////////////////////////////////////////////////

- (void)connectToURL:(NSURL*)URL {
  TTLOG(@"Connecting to %@", _URL);
  TTNetworkRequestStarted();

  TTURLRequest* request = _requests.count == 1 ? [_requests objectAtIndex:0] : nil;
  NSURLRequest *URLRequest = [_queue createNSURLRequest:request URL:URL];

  _connection = [[NSURLConnection alloc] initWithRequest:URLRequest delegate:self];
}

- (void)cancel {
  NSArray* requestsToCancel = [_requests copy];
  for (id request in requestsToCancel) {
    [self cancel:request];
  }
  [requestsToCancel release];
}

- (NSError*)processResponse:(NSHTTPURLResponse*)response data:(id)data {
  for (TTURLRequest* request in _requests) {
    NSError* error = [request.response request:request processResponse:response data:data];
    if (error) {
      return error;
    }
  }
  return nil;
}

- (void)dispatchLoaded:(NSDate*)timestamp {
  for (TTURLRequest* request in [[_requests copy] autorelease]) {
    request.timestamp = timestamp;
    request.isLoading = NO;

    for (id<TTURLRequestDelegate> delegate in request.delegates) {
      if ([delegate respondsToSelector:@selector(requestDidFinishLoad:)]) {
        [delegate requestDidFinishLoad:request];
      }
    }
  }
}

- (void)dispatchError:(NSError*)error {
  for (TTURLRequest* request in [[_requests copy] autorelease]) {
    request.isLoading = NO;

    for (id<TTURLRequestDelegate> delegate in request.delegates) {
      if ([delegate respondsToSelector:@selector(request:didFailLoadWithError:)]) {
        [delegate request:request didFailLoadWithError:error];
      }
    }
  }
}

//////////////////////////////////////////////////////////////////////////////////////////////////
// NSURLConnectionDelegate
 
- (void)connection:(NSURLConnection*)connection didReceiveResponse:(NSHTTPURLResponse*)response {
  _response = [response retain];
  NSDictionary* headers = [response allHeaderFields];
  int contentLength = [[headers objectForKey:@"Content-Length"] intValue];
  if (contentLength > _queue.maxContentLength && _queue.maxContentLength) {
    TTLOG(@"MAX CONTENT LENGTH EXCEEDED (%d) %@", contentLength, _URL);
    [self cancel];
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

- (void)connection:(NSURLConnection *)connection didSendBodyData:(NSInteger)bytesWritten
        totalBytesWritten:(NSInteger)totalBytesWritten
        totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite {
}
 
-(void)connectionDidFinishLoading:(NSURLConnection *)connection {
  TTNetworkRequestStopped();

  if (_response.statusCode == 200) {
    [_queue performSelector:@selector(loader:didLoadResponse:data:) withObject:self
      withObject:_response withObject:_responseData];
  } else {
    TTLOG(@"  FAILED LOADING (%d) %@", _response.statusCode, _URL);
    NSError* error = [NSError errorWithDomain:NSURLErrorDomain code:_response.statusCode
      userInfo:nil];
    [_queue performSelector:@selector(loader:didFailLoadWithError:) withObject:self
      withObject:error];
  }

  [_responseData release];
  _responseData = nil;
  [_connection release];
  _connection = nil;
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {  
  TTLOG(@"  FAILED LOADING %@ FOR %@", _URL, error);

  TTNetworkRequestStopped();
  
  [_responseData release];
  _responseData = nil;
  [_connection release];
  _connection = nil;
  
  if ([error.domain isEqualToString:NSURLErrorDomain] && error.code == NSURLErrorCannotFindHost
      && _retriesLeft) {
    // If there is a network error then we will wait and retry a few times just in case
    // it was just a temporary blip in connectivity
    --_retriesLeft;
    [self load:[NSURL URLWithString:_URL]];
  } else {
    [_queue performSelector:@selector(loader:didFailLoadWithError:) withObject:self
            withObject:error];
  }
}

//////////////////////////////////////////////////////////////////////////////////////////////////

- (BOOL)isLoading {
  return !!_connection;
}

- (void)addRequest:(TTURLRequest*)request {
  [_requests addObject:request];
}

- (void)removeRequest:(TTURLRequest*)request {
  [_requests removeObject:request];
}

- (void)load:(NSURL*)URL {
  if (!_connection) {
    [self connectToURL:URL];
  }
}

- (BOOL)cancel:(TTURLRequest*)request {
  NSUInteger index = [_requests indexOfObject:request];
  if (index != NSNotFound) {
    request.isLoading = NO;

    for (id<TTURLRequestDelegate> delegate in request.delegates) {
      if ([delegate respondsToSelector:@selector(requestDidCancelLoad:)]) {
        [delegate requestDidCancelLoad:request];
      }
    }

    [_requests removeObjectAtIndex:index];
  }
  if (![_requests count]) {
    [_queue performSelector:@selector(loaderDidCancel:wasLoading:) withObject:self
            withObject:(id)!!_connection];
    if (_connection) {
      TTNetworkRequestStopped();
      [_connection cancel];
      [_connection release];
      _connection = nil;
    }
    return NO;
  } else {
    return YES;
  }
}
 
@end

//////////////////////////////////////////////////////////////////////////////////////////////////

@implementation TTURLRequestQueue

@synthesize maxContentLength = _maxContentLength, userAgent = _userAgent, suspended = _suspended,
  imageCompressionQuality = _imageCompressionQuality;

+ (TTURLRequestQueue*)mainQueue {
  if (!gMainQueue) {
    gMainQueue = [[TTURLRequestQueue alloc] init];
  }
  return gMainQueue;
}

+ (void)setMainQueue:(TTURLRequestQueue*)queue {
  if (gMainQueue != queue) {
    [gMainQueue release];
    gMainQueue = [queue retain];
  }
}

//////////////////////////////////////////////////////////////////////////////////////////////////

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

- (void)dealloc {
  [_loaders release];
  [_loaderQueue release];
  [_loaderQueueTimer invalidate];
  [_userAgent release];
  [super dealloc];
}

//////////////////////////////////////////////////////////////////////////////////////////////////

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
        request.timestamp = timestamp;
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

- (void)loadNextInQueueDelayed {
  if (!_loaderQueueTimer) {
    _loaderQueueTimer = [NSTimer scheduledTimerWithTimeInterval:kFlushDelay target:self
      selector:@selector(loadNextInQueue) userInfo:nil repeats:NO];
  }
}

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

- (void)removeLoader:(TTRequestLoader*)loader {
  --_totalLoading;
  [_loaders removeObjectForKey:loader.cacheKey];
}

- (void)loader:(TTRequestLoader*)loader didLoadResponse:(NSHTTPURLResponse*)response
    data:(id)data {
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

  [self loadNextInQueue];
}

- (void)loader:(TTRequestLoader*)loader didFailLoadWithError:(NSError*)error {
  TTLOG(@"ERROR: %@", error);
  [self removeLoader:loader];
  [loader dispatchError:error];
  [self loadNextInQueue];
}

- (void)loaderDidCancel:(TTRequestLoader*)loader wasLoading:(BOOL)wasLoading {
  if (wasLoading) {
    [self removeLoader:loader];
    [self loadNextInQueue];
  } else {
    [_loaders removeObjectForKey:loader.cacheKey];
  }
}

//////////////////////////////////////////////////////////////////////////////////////////////////

- (void)setSuspended:(BOOL)isSuspended {
  // TTLOG(@"SUSPEND LOADING %d", isSuspended);
  _suspended = isSuspended;
  
  if (!_suspended) {
    [self loadNextInQueue];
  } else if (_loaderQueueTimer) {
    [_loaderQueueTimer invalidate];
    _loaderQueueTimer = nil;
  }
}

- (BOOL)sendRequest:(TTURLRequest*)request {
  for (id<TTURLRequestDelegate> delegate in request.delegates) {
    if ([delegate respondsToSelector:@selector(requestDidStartLoad:)]) {
      [delegate requestDidStartLoad:request];
    }
  }
  
  if ([self loadRequestFromCache:request]) {
    return YES;
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
  if (![request.httpMethod isEqualToString:@"POST"]) {
    // Next, see if there is an active loader for the URL and if so join that bandwagon
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
        if (userInfo.weak && userInfo.weak == delegate) {
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

- (void)cancelAllRequests {
  for (TTRequestLoader* loader in [[[_loaders copy] autorelease] objectEnumerator]) {
    [loader cancel];
  }
}

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
  }
  
  return URLRequest;
}

@end
