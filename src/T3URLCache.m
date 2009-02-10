#import "Three20/T3URLCache.h"
#import "Three20/T3URLRequest.h"
#import <CommonCrypto/CommonDigest.h>

//////////////////////////////////////////////////////////////////////////////////////////////////
  
#define SMALL_IMAGE_SIZE (50*50)
#define MEDIUM_IMAGE_SIZE (130*97)
#define LARGE_IMAGE_SIZE (600*400)

static const NSTimeInterval kFlushDelay = 0.3;
static const NSTimeInterval kTimeout = 300.0;
static const NSInteger kLoadMaxRetries = 2;
static const NSInteger kMaxConcurrentLoads = 5;
static NSUInteger kMaxContentLength = 150000;

static NSString* kCacheDirPathName = @"Three20";
static NSString* kSafariUserAgent = @"Mozilla/5.0 (iPhone; U; CPU iPhone OS 2_2 like Mac OS X;\
 en-us) AppleWebKit/525.181 (KHTML, like Gecko) Version/3.1.1 Mobile/5H11 Safari/525.20";

//////////////////////////////////////////////////////////////////////////////////////////////////

@interface T3RequestLoader : NSObject {
  NSString* _url;
  NSString* _cacheKey;
  T3URLCache* _cache;
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

- (id)initForRequest:(T3URLRequest*)request cache:(T3URLCache*)cache;

- (void)addRequest:(T3URLRequest*)request;
- (void)removeRequest:(T3URLRequest*)request;

- (void)load;
- (BOOL)cancel:(T3URLRequest*)request;

@end

@implementation T3RequestLoader

@synthesize url = _url, requests = _requests, contentType = _contentType, cacheKey = _cacheKey,
  cachePolicy = _cachePolicy, cacheExpirationAge = _cacheExpirationAge,
  shouldConvertToMedia = _shouldConvertToMedia;

- (id)initForRequest:(T3URLRequest*)request cache:(T3URLCache*)cache {
  if (self = [super init]) {
    _url = [request.url copy];
    _cacheKey = [request.cacheKey copy];
    _cachePolicy = request.cachePolicy;
    _cacheExpirationAge = request.cacheExpirationAge;
    _cache = cache;
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
  [urlRequest setValue:_cache.userAgent forHTTPHeaderField:@"User-Agent"];

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
  if (contentLength > _cache.maxContentLength && _cache.maxContentLength) {
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
    [_cache performSelector:@selector(loader:loadedData:) withObject:self withObject:_responseData];
  } else {
    T3LOG(@"  FAILED LOADING (%d) %@", _statusCode, _url);
    NSError* error = [NSError errorWithDomain:NSURLErrorDomain code:_statusCode userInfo:nil];
    [_cache performSelector:@selector(loader:didFailWithError:) withObject:self withObject:error];
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
    [_cache performSelector:@selector(loader:didFailWithError:) withObject:self withObject:error];
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
    for (int i = 0; i < _requests.count; ++i) {
      T3URLRequest* request = [_requests objectAtIndex:i];
      if ([request.handler respondsToSelector:@selector(requestLoading:)]) {
        [request.handler requestLoading:request];
      }
      if ([request.delegate respondsToSelector:@selector(requestLoading:)]) {
        [request.delegate requestLoading:request];
      }
    }

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
    [_cache performSelector:@selector(loaderDidCancel:wasLoading:) withObject:self
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

@implementation T3URLCache

@synthesize disableDiskCache = _disableDiskCache, disableMediaCache = _disableMediaCache,
  cachePath = _cachePath, userAgent = _userAgent, 
  maxContentLength = _maxContentLength, maxPixelCount = _maxPixelCount,
  invalidationAge = _invalidationAge, paused = _paused;

+ (T3URLCache*)sharedCache {
  static T3URLCache* sharedCache = nil;
  if (!sharedCache) {
    sharedCache = [[T3URLCache alloc] init];
  }
  return sharedCache;
}

+ (NSString*)defaultCachePath {
  NSArray* paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
  NSString* cachesPath = [paths objectAtIndex:0];
  NSString* cachePath = [cachesPath stringByAppendingPathComponent:kCacheDirPathName];
  NSFileManager* fm = [NSFileManager defaultManager];
  if (![fm fileExistsAtPath:cachesPath]) {
    [fm createDirectoryAtPath:cachesPath attributes:nil];
  }
  if (![fm fileExistsAtPath:cachePath]) {
    [fm createDirectoryAtPath:cachePath attributes:nil];
  }
  return cachePath;
}

//////////////////////////////////////////////////////////////////////////////////////////////////

- (id)init {
  if (self == [super init]) {
    _loaders = [[NSMutableDictionary alloc] init];
    _loaderQueue = [[NSMutableArray alloc] init];
    _mediaCache = [[NSMutableDictionary alloc] init];
    _mediaSortedList = [[NSMutableArray alloc] init];
    _loaderQueueTimer = nil;
    _userAgent = [kSafariUserAgent copy];
    _totalLoading = 0;
    _disableDiskCache = NO;
    _disableMediaCache = NO;
    _maxContentLength = kMaxContentLength;
    _maxPixelCount = (SMALL_IMAGE_SIZE*20) + (MEDIUM_IMAGE_SIZE*12);
    _invalidationAge = 0;
    _paused = NO;
    
    _totalPixelCount = 0;
    _cachePath = [[T3URLCache defaultCachePath] retain];
    
    // Disable the built-in cache to save memory
    NSURLCache* sharedCache = [[NSURLCache alloc] initWithMemoryCapacity:0 diskCapacity:0
      diskPath:nil];
    [NSURLCache setSharedURLCache:sharedCache];
    [sharedCache release];
  }
  return self;
}

- (void)dealloc {
  [_loaders release];
  [_loaderQueue release];
  [_loaderQueueTimer invalidate];
  [_userAgent release];
  [_mediaCache release];
  [_mediaSortedList release];
  [_cachePath release];
  [super dealloc];
}

//////////////////////////////////////////////////////////////////////////////////////////////////

- (NSString *)generateCacheKey:(NSString*)url {
  const char* str = [url UTF8String];
  unsigned char result[CC_MD5_DIGEST_LENGTH];
  CC_MD5(str, strlen(str), result);

  return [NSString stringWithFormat:
    @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
    result[0], result[1], result[2], result[3], result[4], result[5], result[6], result[7],
    result[8], result[9], result[10], result[11], result[12], result[13], result[14], result[15]
  ];
}

- (NSString*)getCachePathForKey:(NSString*)key {
  return [_cachePath stringByAppendingPathComponent:key];
}

- (void)expireImagesFromMemory {
  while (_mediaSortedList.count) {
    NSString* url = [_mediaSortedList objectAtIndex:0];
    UIImage* image = [_mediaCache objectForKey:url];
    T3LOG(@"EXPIRING %@", url);

    _totalPixelCount -= image.size.width * image.size.height;
    [_mediaCache removeObjectForKey:url];
    [_mediaSortedList removeObjectAtIndex:0];
    
    if (_totalPixelCount <= _maxPixelCount) {
      break;
    }
  }
}

- (NSData*)loadDataFromDisk:(NSString*)url {
  NSString* filePath = [self getCachePathForURL:url];
  NSFileManager* fm = [NSFileManager defaultManager];
  if ([fm fileExistsAtPath:filePath]) {
    return [[[NSData alloc] initWithContentsOfFile:filePath] autorelease];
  } else {
    return nil;
  }
}

- (void)writeDataToDisk:(NSData*)imageData withType:(NSString*)type forKey:(NSString*)key {
  NSString* filePath = [self getCachePathForKey:key];
  NSFileManager* fm = [NSFileManager defaultManager];
  [fm createFileAtPath:filePath contents:imageData attributes:nil];
}

- (void)writeImageToDisk:(UIImage*)image forKey:(NSString*)key {
  NSData* imageData = UIImagePNGRepresentation(image);
  [self writeDataToDisk:imageData withType:@"image" forKey:key];
}

- (void)storeData:(NSData*)data media:(id)media forURL:(NSString*)url key:(NSString*)key
    toDisk:(BOOL)toDisk {
  if (!_disableMediaCache && media) {
    if ([media isKindOfClass:[UIImage class]]) {
      UIImage* image = media;
      int pixelCount = image.size.width * image.size.height;
      if (pixelCount < LARGE_IMAGE_SIZE) {
        _totalPixelCount += pixelCount;
        if (_totalPixelCount > _maxPixelCount && _maxPixelCount) {
          [self expireImagesFromMemory];
        }
    
        // T3LOG(@"CACHING IMAGE %@", url);
        [_mediaSortedList addObject:url];
        [_mediaCache setObject:image forKey:url];
      }
    }
  }
  
  if (toDisk && !_disableDiskCache) {
    if ([media isKindOfClass:[UIImage class]]) {
      if (data) {
        [self writeDataToDisk:data withType:@"image" forKey:key];
      } else {
        [self writeImageToDisk:media forKey:key];
      }
    } else if (data) {
      [self writeDataToDisk:data withType:nil forKey:key];
    }
  }
}

- (BOOL)isImageMimeType:(NSString*)mimeType {
  static  NSDictionary* imageMimeTypes = nil;
  if (!imageMimeTypes) {
    imageMimeTypes = [[NSDictionary dictionaryWithObjectsAndKeys:
      [NSNull null], @"image/jpeg",
      [NSNull null], @"image/jpg",
      [NSNull null], @"image/gif",
      [NSNull null], @"image/png",
      [NSNull null], @"image/bmp",
      [NSNull null], @"image/tiff",
      [NSNull null], @"image/ico",
      [NSNull null], @"image/cur",
      [NSNull null], @"image/xbm",
      nil] retain];
  }
  
  return !![imageMimeTypes objectForKey:mimeType];
}

- (id)convertDataToMedia:(NSData*)data forType:(NSString*)mimeType {
  if ([self isImageMimeType:mimeType]) {
    return [UIImage imageWithData:data];
  } else {
    return nil;
  }
}

- (id)convertDataToMedia:(NSData*)data forURL:(NSString*)url {
  // XXXjoe For now images are the only media type we know
  UIImage* image = [UIImage imageWithData:data];
  return image;
}

- (BOOL)loadFromCache:(NSString*)url cacheKey:(NSString*)cacheKey
    expires:(NSTimeInterval)expirationAge shouldConvertToMedia:(BOOL)shouldConvertToMedia
    fromDisk:(BOOL)fromDisk data:(NSData**)data media:(id*)media timestamp:(NSDate**)timestamp {
  if (shouldConvertToMedia) {
    *media = [self getMediaForURL:url fromDisk:NO];
    if (*media) {
      return YES;
    }
  }
  
  if (fromDisk) {
    *data = [self getDataForKey:cacheKey expires:expirationAge timestamp:timestamp];
    if (*data) {
      if (shouldConvertToMedia) {
        *media = [self convertDataToMedia:*data forURL:url];
        [self storeData:nil media:*media forURL:url toDisk:NO];
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
    BOOL delayed = (_paused && request.canBeDelayed) || _totalLoading == kMaxConcurrentLoads;
    
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
      media = [self convertDataToMedia:data forType:loader.contentType];
      if (!media) {
        return [self loader:loader didFailWithError:nil];
      }
    }

    if (!(loader.cachePolicy & T3URLRequestCachePolicyNoCache)) {
      [self storeData:data media:media forURL:loader.url key:loader.cacheKey toDisk:YES];
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
    request.cacheKey = [self generateCacheKey:request.url];
  }
  
  if ([request.handler respondsToSelector:@selector(requestPosted:)]) {
    [request.handler requestPosted:request];
  }
  
  if ([request.delegate respondsToSelector:@selector(requestPosted:)]) {
    [request.delegate requestPosted:request];
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
  loader = [[T3RequestLoader alloc] initForRequest:request cache:self];
  [_loaders setObject:loader forKey:request.cacheKey];
  if ((_paused && request.canBeDelayed) || _totalLoading == kMaxConcurrentLoads) {
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

- (NSString*)getCachePathForURL:(NSString*)url {
  NSString* key = [self generateCacheKey:url];
  return [self getCachePathForKey:key];
}

- (BOOL)hasDataForURL:(NSString*)url {
  NSString* filePath = [self getCachePathForURL:url];
  NSFileManager* fm = [NSFileManager defaultManager];
  return [fm fileExistsAtPath:filePath];
}

- (NSData*)getDataForURL:(NSString*)url {
  return [self getDataForURL:url expires:0 timestamp:nil];
}

- (NSData*)getDataForURL:(NSString*)url expires:(NSTimeInterval)expirationAge
    timestamp:(NSDate**)timestamp {
  NSString* key = [self generateCacheKey:url];
  return [self getDataForKey:key expires:expirationAge timestamp:timestamp];
}

- (NSData*)getDataForKey:(NSString*)key expires:(NSTimeInterval)expirationAge
    timestamp:(NSDate**)timestamp {
  NSString* filePath = [self getCachePathForKey:key];
  NSFileManager* fm = [NSFileManager defaultManager];
  if ([fm fileExistsAtPath:filePath]) {
    NSDictionary* attrs = [fm attributesOfItemAtPath:filePath error:nil];
    NSDate* modified = [attrs objectForKey:NSFileModificationDate];
    if (expirationAge && [modified timeIntervalSinceNow] < -expirationAge) {
      return nil;
    }
    if (timestamp) {
      *timestamp = modified;
    }

    return [NSData dataWithContentsOfFile:filePath];
  }

  return nil;
}

- (id)getMediaForURL:(NSString*)url {
  return [self getMediaForURL:url fromDisk:YES];
}

- (id)getMediaForURL:(NSString*)url fromDisk:(BOOL)fromDisk {
  UIImage* media = [_mediaCache objectForKey:url];
  if (media) {
    return [[media retain] autorelease];
  } else if (fromDisk) {
    NSData* data = [self loadDataFromDisk:url];
    return [self convertDataToMedia:data forURL:url];
  } else {
    return nil;
  }
}

- (void)storeData:(NSData*)data media:(id)media forURL:(NSString*)url toDisk:(BOOL)toDisk {
  NSString* key = [self generateCacheKey:url];
  [self storeData:data media:media forURL:url key:key toDisk:toDisk];
}

- (NSString*)storeTemporaryData:(NSData*)data media:(id)media toDisk:(BOOL)toDisk {
  static int temporaryURLIncrement = 0;
  
  NSString* url = [NSString stringWithFormat:@"temp:%d", temporaryURLIncrement++];
  [self storeData:data media:media forURL:url toDisk:toDisk];
  return url;
}

- (void)moveDataForURL:(NSString*)oldURL toURL:(NSString*)newURL {
  id media = [self getMediaForURL:oldURL fromDisk:NO];
  if (media) {
    [_mediaSortedList removeObject:oldURL];
    [_mediaCache removeObjectForKey:oldURL];
    [_mediaSortedList addObject:newURL];
    [_mediaCache setObject:media forKey:newURL];
  }
  NSString* oldPath = [self getCachePathForURL:oldURL];
  NSFileManager* fm = [NSFileManager defaultManager];
  if ([fm fileExistsAtPath:oldPath]) {
    NSString* newPath = [self getCachePathForURL:newURL];
    [fm moveItemAtPath:oldPath toPath:newPath error:nil];
  }
}

- (void)removeURL:(NSString*)url fromDisk:(BOOL)fromDisk {
  [_mediaSortedList removeObject:url];
  [_mediaCache removeObjectForKey:url];
  
  if (fromDisk) {
    NSString* filePath = [self getCachePathForURL:url];
    NSFileManager* fm = [NSFileManager defaultManager];
    if (filePath && [fm fileExistsAtPath:filePath]) {
      [fm removeItemAtPath:filePath error:nil];
    }
  }
}

- (void)removeKey:(NSString*)key {
  NSString* filePath = [self getCachePathForKey:key];
  NSFileManager* fm = [NSFileManager defaultManager];
  if (filePath && [fm fileExistsAtPath:filePath]) {
    [fm removeItemAtPath:filePath error:nil];
  }
}

- (void)removeAll:(BOOL)fromDisk {
  [_mediaCache removeAllObjects];
  [_mediaSortedList removeAllObjects];
  _totalPixelCount = 0;

  if (fromDisk) {
    NSFileManager* fm = [NSFileManager defaultManager];
    [fm removeItemAtPath:_cachePath error:nil];
    [fm createDirectoryAtPath:_cachePath attributes:nil];
  }
}

- (void)invalidateURL:(NSString*)url {
  NSString* key = [self generateCacheKey:url];
  return [self invalidateKey:key];
}

- (void)invalidateKey:(NSString*)key {
  NSString* filePath = [self getCachePathForKey:key];
  NSFileManager* fm = [NSFileManager defaultManager];
  if (filePath && [fm fileExistsAtPath:filePath]) {
    NSDate* invalidDate = [NSDate dateWithTimeIntervalSinceNow:-_invalidationAge];
    NSDictionary* attrs = [NSDictionary dictionaryWithObject:invalidDate
      forKey:NSFileModificationDate];

    [fm changeFileAttributes:attrs atPath:filePath];
  }
}

- (void)invalidateAll {
  NSDate* invalidDate = [NSDate dateWithTimeIntervalSinceNow:-_invalidationAge];
  NSDictionary* attrs = [NSDictionary dictionaryWithObject:invalidDate
    forKey:NSFileModificationDate];

  NSFileManager* fm = [NSFileManager defaultManager];
  NSDirectoryEnumerator* e = [fm enumeratorAtPath:_cachePath];
  for (NSString* fileName; fileName = [e nextObject]; ) {
    NSString* filePath = [_cachePath stringByAppendingPathComponent:fileName];
    [fm changeFileAttributes:attrs atPath:filePath];
  }
}

- (void)logMemoryReport {
  T3LOG(@"======= IMAGE CACHE: %d media, %d pixels ========", _mediaCache.count, _totalPixelCount);
  NSEnumerator* e = [_mediaCache keyEnumerator];
  for (NSString* url ; url = [e nextObject]; ) {
    id media = [_mediaCache objectForKey:url];
    if ([media isKindOfClass:[UIImage class]]) {
      UIImage* image = media;
      T3LOG(@"  %f x %f %@", image.size.width, image.size.height, url);
    }
  }  
}

@end
