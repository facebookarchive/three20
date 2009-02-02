#import "Three20/T3URLCache.h"
#import "Three20/T3URLRequest.h"
#import <CommonCrypto/CommonDigest.h>

//////////////////////////////////////////////////////////////////////////////////////////////////
  
#define SMALL_IMAGE_SIZE (50*50)
#define MEDIUM_IMAGE_SIZE (130*97)
#define LARGE_IMAGE_SIZE (600*400)

static const NSTimeInterval kFlushDelay = 0.3;
static const NSTimeInterval kTimeout = 300.0;
static const int kLoadMaxRetries = 2;
static const int kMaxConcurrentLoads = 5;
static NSString* kCacheDirPathName = @"Three20";

//////////////////////////////////////////////////////////////////////////////////////////////////

@interface T3RequestLoader : NSObject {
  NSString* url;
  T3URLCache* cache;
  NSMutableArray* requests;
  NSURLConnection* connection;
  NSInteger statusCode;
  NSString* contentType;
  BOOL convertMedia;
  int retriesLeft;
}

@property(nonatomic,readonly) NSString* url;
@property(nonatomic,readonly) NSString* contentType;
@property(nonatomic,readonly) BOOL loading;
@property(nonatomic,readonly) BOOL convertMedia;

- (id)initForRequest:(T3URLRequest*)request cache:(T3URLCache*)cache;

- (void)addRequest:(T3URLRequest*)request;
- (void)removeRequest:(T3URLRequest*)request;

- (void)load;
- (BOOL)cancel:(T3URLRequest*)request;

@end

@implementation T3RequestLoader

@synthesize url, contentType, convertMedia;

- (id)initForRequest:(T3URLRequest*)request cache:(T3URLCache*)aCache {
  if (self = [super init]) {
    url = [request.url copy];
    cache = aCache;
    connection = nil;
    statusCode = 0;
    contentType = nil;
    convertMedia = NO;
    retriesLeft = kLoadMaxRetries;
    requests = [[NSMutableArray alloc] init];
    [self addRequest:request];
  }
  return self;
}
 
- (void)dealloc {
  if (connection) {
    [connection cancel];
    [connection release];
  }
  [url release];
  [contentType release];
  [requests release];
  [super dealloc];
}

//////////////////////////////////////////////////////////////////////////////////////////////////

- (void)connect {
  T3NetworkRequestStarted();

  NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]
                                    cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                    timeoutInterval:kTimeout];
  // XXXjoe Set the User-Agent to something
  connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];  
}

- (void)dispatchData:(NSData*)data media:(id)media {
  for (int i = 0; i < requests.count; ++i) {
    T3URLRequest* request = [requests objectAtIndex:i];
    if ([request.delegate respondsToSelector:@selector(request:loadedData:media:)]) {
      [request.delegate request:request loadedData:data media:media];
    }
  }
}

- (void)dispatchError:(NSError*)error {
  NSEnumerator* e = [requests objectEnumerator];
  for (T3URLRequest* request; request = [e nextObject]; ) {
    if ([request.delegate respondsToSelector:@selector(request:didFailWithError:)]) {
      [request.delegate request:request didFailWithError:error];
    }
  }
}

//////////////////////////////////////////////////////////////////////////////////////////////////
// NSURLConnectionDelegate
 
- (void)connection:(NSURLConnection*)connection didReceiveResponse:(NSHTTPURLResponse*)response {
  statusCode = response.statusCode;
  if (convertMedia) {
    NSDictionary* headers = [response allHeaderFields];
    if (headers) {
      contentType = [[headers objectForKey:@"Content-Type"] retain];
    }
  }
}

- (NSCachedURLResponse *)connection:(NSURLConnection *)aConnection
    willCacheResponse:(NSCachedURLResponse *)cachedResponse {
  if (statusCode == 200) {
    NSData* data = cachedResponse.data;
    [cache performSelector:@selector(loader:loadedData:) withObject:self withObject:data];
  } else {
    T3LOG(@"  FAILED LOADING (%d) %@", statusCode, url);
    NSError* error = [NSError errorWithDomain:NSURLErrorDomain code:statusCode userInfo:nil];
    [cache performSelector:@selector(loader:didFailWithError:) withObject:self withObject:error];
  }
  return nil;
}

-(void)connectionDidFinishLoading:(NSURLConnection *)aConnection {
  T3NetworkRequestStopped();
  [connection release];
  connection = nil;
}

- (void)connection:(NSURLConnection *)aConnection didFailWithError:(NSError *)error {  
  T3LOG(@"  FAILED LOADING %@ FOR %@", url, error);

  T3NetworkRequestStopped();
  
  [connection release];
  connection = nil;
  
  if ([error.domain isEqualToString:NSURLErrorDomain] && error.code == NSURLErrorCannotFindHost
      && retriesLeft) {
    // If there is a network error then we will wait and retry a few times just in case
    // it was just a temporary blip in connectivity
    --retriesLeft;
    [self connect];
  } else {
    [cache performSelector:@selector(loader:didFailWithError:) withObject:self withObject:error];
  }
}

//////////////////////////////////////////////////////////////////////////////////////////////////

- (BOOL)loading {
  return !!connection;
}

- (void)addRequest:(T3URLRequest*)request {
  [requests addObject:request];
  if (request.convertMedia) {
    convertMedia = YES;
  }
}

- (void)removeRequest:(T3URLRequest*)request {
  [requests removeObject:request];
}

- (void)load {
  if (!connection) {
    for (int i = 0; i < requests.count; ++i) {
      T3URLRequest* request = [requests objectAtIndex:i];
      if ([request.delegate respondsToSelector:@selector(requestLoading:)]) {
        [request.delegate requestLoading:request];
      }
    }

    [self connect];
  }
}

- (BOOL)cancel:(T3URLRequest*)request {
  NSUInteger index = [requests indexOfObject:request];
  if (index != NSNotFound) {
    [requests removeObjectAtIndex:index];

    if ([request.delegate respondsToSelector:@selector(requestCancelled:)]) {
      [request.delegate requestCancelled:request];
    }
  }
  if (![requests count]) {
    if (connection) {
      T3NetworkRequestStopped();
      [connection cancel];
    }
    return NO;
  } else {
    return YES;
  }
}
 
@end

//////////////////////////////////////////////////////////////////////////////////////////////////

@implementation T3URLCache

@synthesize disableDiskCache, disableMediaCache, cachePath, paused;

+ (T3URLCache*) sharedCache {
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
    loaders = [[NSMutableDictionary alloc] init];
    loaderQueue = [[NSMutableArray alloc] init];
    mediaCache = [[NSMutableDictionary alloc] init];
    mediaSortedList = [[NSMutableArray alloc] init];
    loaderQueueTimer = nil;
    totalLoading = 0;
    disableDiskCache = NO;
    disableMediaCache = NO;
    paused = NO;
    
    totalPixelCount = 0;
    maxPixelCount = (SMALL_IMAGE_SIZE*20) + (MEDIUM_IMAGE_SIZE*12);
    cachePath = [[T3URLCache defaultCachePath] retain];
    
    // Disable the built-in cache to save memory
    NSURLCache* sharedCache = [[NSURLCache alloc] initWithMemoryCapacity:0 diskCapacity:0
      diskPath:nil];
    [NSURLCache setSharedURLCache:sharedCache];
    [sharedCache release];
  }
  return self;
}

- (void)dealloc {
  [loaders release];
  [loaderQueue release];
  [loaderQueueTimer invalidate];
  [mediaCache release];
  [mediaSortedList release];
  [cachePath release];
  [super dealloc];
}

//////////////////////////////////////////////////////////////////////////////////////////////////

- (NSString *)makeHashKey:(NSString*)input {
  const char* str = [input UTF8String];
  unsigned char result[CC_MD5_DIGEST_LENGTH];
  CC_MD5(str, strlen(str), result);

  return [NSString stringWithFormat:
    @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
    result[0], result[1], result[2], result[3], result[4], result[5], result[6], result[7],
    result[8], result[9], result[10], result[11], result[12], result[13], result[14], result[15]
  ];
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

- (void)writeDataToDisk:(NSData*)imageData withType:(NSString*)type forURL:(NSString*)url {
  NSString* filePath = [self getCachePathForURL:url];
  NSFileManager* fm = [NSFileManager defaultManager];
  [fm createFileAtPath:filePath contents:imageData attributes:nil];
}

- (void)writeImageToDisk:(UIImage*)image forURL:(NSString*)url {
  NSData* imageData = UIImagePNGRepresentation(image);
  [self writeDataToDisk:imageData withType:@"image" forURL:url];
}

- (void)removeFromDisk:(NSString*)url {
  NSString* filePath = [self getCachePathForURL:url];
  NSFileManager* fm = [NSFileManager defaultManager];
  if (filePath && [fm fileExistsAtPath:filePath]) {
    [fm removeItemAtPath:filePath error:nil];
  }
}

- (void)expireImagesFromMemory {
  while (mediaSortedList.count) {
    NSString* url = [mediaSortedList objectAtIndex:0];
    UIImage* image = [mediaCache objectForKey:url];
    T3LOG(@"Expiring %@", url);

    totalPixelCount -= image.size.width * image.size.height;
    [mediaCache removeObjectForKey:url];
    [mediaSortedList removeObjectAtIndex:0];
    
    if (totalPixelCount <= maxPixelCount) {
      break;
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

- (BOOL)loadFromCache:(NSString*)url convertMedia:(BOOL)convertMedia data:(NSData**)data
    media:(id*)media fromDisk:(BOOL)fromDisk {
  if (convertMedia) {
    *media = [self getMediaForURL:url fromDisk:NO];
    if (*media) {
      return YES;
    }
  }
  
  if (fromDisk) {
    *data = [self loadDataFromDisk:url];
    if (*data) {
      if (convertMedia) {
        *media = [self convertDataToMedia:*data forURL:url];
        [self storeData:nil media:*media forURL:url toDisk:NO];
      }
      return YES;
    }
  }
  
  return NO;
}

- (void)executeLoader:(T3RequestLoader*)loader {
  NSData* data = nil;
  id media = nil;
  if ([self loadFromCache:loader.url convertMedia:loader.convertMedia data:&data media:&media
      fromDisk:YES]) {
    [loader dispatchData:data media:media];
    [loaders removeObjectForKey:loader.url];
  } else {
    ++totalLoading;
    [loader load];
  }
}

- (void)loadNextInQueueDelayed {
  if (!loaderQueueTimer) {
    loaderQueueTimer = [NSTimer scheduledTimerWithTimeInterval:kFlushDelay target:self
      selector:@selector(loadNextInQueue) userInfo:nil repeats:NO];
  }
}

- (void)loadNextInQueue {
  loaderQueueTimer = nil;

  for (int i = 0; i < kMaxConcurrentLoads && totalLoading < kMaxConcurrentLoads
      && loaderQueue.count; ++i) {
    T3RequestLoader* loader = [[loaderQueue objectAtIndex:0] retain];
    [loaderQueue removeObjectAtIndex:0];
    [self executeLoader:loader];
    [loader release];
  }

  if (loaderQueue.count) {
    [self loadNextInQueueDelayed];
  }
}

- (void)loadNextInQueueAfterLoader:(T3RequestLoader*)loader {
  --totalLoading;
  [loaders removeObjectForKey:loader.url];
  [self loadNextInQueue];
}

- (void)loader:(T3RequestLoader*)loader didFailWithError:(NSError*)error {
  [loader dispatchError:error];
  [self loadNextInQueueAfterLoader:loader];
}

- (void)loader:(T3RequestLoader*)loader loadedData:(NSData*)data {
  id media = nil;
  if (loader.convertMedia) {
    media = [self convertDataToMedia:data forType:loader.contentType];
    if (!media) {
      return [self loader:loader didFailWithError:nil];
      return;
    }
  }

  [self storeData:data media:media forURL:loader.url toDisk:YES];
  [loader dispatchData:data media:media];

  [self loadNextInQueueAfterLoader:loader];
}

//////////////////////////////////////////////////////////////////////////////////////////////////

- (void)setPaused:(BOOL)isPaused {
  T3LOG(@"PAUSE CACHE %d", isPaused);
  paused = isPaused;
  
  if (!paused) {
    [self loadNextInQueue];
  } else if (loaderQueueTimer) {
    [loaderQueueTimer invalidate];
    loaderQueueTimer = nil;
  }
}

- (BOOL)sendRequest:(T3URLRequest*)request {
  // First, look in the cache if the request allows it
  NSData* data = nil;
  id media = nil;
  if ([self loadFromCache:request.url convertMedia:request.convertMedia data:&data media:&media
        fromDisk:!paused && totalLoading != kMaxConcurrentLoads]) {
    if ([request.delegate respondsToSelector:@selector(request:loadedData:media:)]) {
      [request.delegate request:request loadedData:data media:media];
    }
    return YES;
  }

  if ([request.delegate respondsToSelector:@selector(requestPosted:)]) {
    [request.delegate requestPosted:request];
  }
  
  // Next, see if there is an active loader for the URL and if so join that bandwagon
  T3RequestLoader* loader = [loaders objectForKey:request.url];
  if (loader) {
    [loader addRequest:request];
    return NO;
  }
  
  // Finally, create a new loader and hit the network (unless we are paused)
  loader = [[T3RequestLoader alloc] initForRequest:request cache:self];
  [loaders setObject:loader forKey:request.url];
  if (paused || totalLoading == kMaxConcurrentLoads) {
    [loaderQueue addObject:loader];
  } else {
    ++totalLoading;
    [loader load];
  }
  [loader release];

  return NO;
}

- (void)cancelRequest:(T3URLRequest*)request {
  if (request) {
    T3RequestLoader* loader = [loaders objectForKey:request.url];
    if (loader) {
      [request retain];
      BOOL wasLoading = loader.loading;
      if (![loader cancel:request]) {
        if (wasLoading) {
          --totalLoading;
        }
        [loaders removeObjectForKey:request.url];
        [loaderQueue removeObject:loader];
      }
      [request release];
    }
  }
}

- (NSString*)getCachePathForURL:(NSString*)url {
  NSString* key = [self makeHashKey:url];
  return [cachePath stringByAppendingPathComponent:key];
}

- (BOOL)hasDataForURL:(NSString*)url {
  NSString* filePath = [self getCachePathForURL:url];
  NSFileManager* fm = [NSFileManager defaultManager];
  return [fm fileExistsAtPath:filePath];
}

- (NSData*)getDataForURL:(NSString*)url {
  return [self getDataForURL:url minTime:T3_ALWAYS_USE_CACHE timestamp:nil];
}

- (NSData*)getDataForURL:(NSString*)url minTime:(NSTimeInterval)minTime
    timestamp:(NSDate**)timestamp {
  if (minTime != T3_SKIP_CACHE) {
    NSString* filePath = [self getCachePathForURL:url];
    NSFileManager* fm = [NSFileManager defaultManager];
    if ([fm fileExistsAtPath:filePath]) {
      if (minTime != T3_ALWAYS_USE_CACHE) {
        NSDictionary* attrs = [fm attributesOfItemAtPath:filePath error:nil];
        NSDate* modified = [attrs objectForKey:NSFileModificationDate];
        if ([modified timeIntervalSinceNow] < -minTime) {
          return nil;
        }
        if (timestamp) {
          *timestamp = modified;
        }
      }
      return [NSData dataWithContentsOfFile:filePath];
    }
  }
  return nil;
}

- (id)getMediaForURL:(NSString*)url {
  return [self getMediaForURL:url fromDisk:YES];
}

- (id)getMediaForURL:(NSString*)url fromDisk:(BOOL)fromDisk {
  UIImage* media = [mediaCache objectForKey:url];
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
  if (!disableMediaCache && media) {
    if ([media isKindOfClass:[UIImage class]]) {
      UIImage* image = media;
      int pixelCount = image.size.width * image.size.height;
      if (pixelCount < LARGE_IMAGE_SIZE) {
        totalPixelCount += pixelCount;
        if (totalPixelCount > maxPixelCount) {
          [self expireImagesFromMemory];
        }
    
        T3LOG(@"CACHING IMAGE %@", url);
        [mediaSortedList addObject:url];
        [mediaCache setObject:image forKey:url];
      }
    }
  }
  
  if (toDisk && !disableDiskCache) {
    if ([media isKindOfClass:[UIImage class]]) {
      if (data) {
        [self writeDataToDisk:data withType:@"image" forURL:url];
      } else {
        [self writeImageToDisk:media forURL:url];
      }
    } else if (data) {
      [self writeDataToDisk:data withType:nil forURL:url];
    }
  }
}

- (NSString*)storeDataWithTemporaryURL:(NSData*)data media:(id)media toDisk:(BOOL)toDisk {
  static int temporaryURLIncrement = 0;
  
  NSString* url = [NSString stringWithFormat:@"temp:%d", temporaryURLIncrement++];
  [self storeData:data media:media forURL:url toDisk:toDisk];
  return url;
}

- (void)moveDataForURL:(NSString*)oldURL toURL:(NSString*)newURL {
  id media = [self getMediaForURL:oldURL fromDisk:NO];
  if (media) {
    [mediaSortedList removeObject:oldURL];
    [mediaCache removeObjectForKey:oldURL];
    [mediaSortedList addObject:newURL];
    [mediaCache setObject:media forKey:newURL];
  }
  NSString* oldPath = [self getCachePathForURL:oldURL];
  NSFileManager* fm = [NSFileManager defaultManager];
  if ([fm fileExistsAtPath:oldPath]) {
    NSString* newPath = [self getCachePathForURL:newURL];
    [fm moveItemAtPath:oldPath toPath:newPath error:nil];
  }
}

- (void)removeURL:(NSString*)url fromDisk:(BOOL)fromDisk {
  [mediaSortedList removeObject:url];
  [mediaCache removeObjectForKey:url];
  
  if (fromDisk) {
    [self removeFromDisk:url];
  }
}

- (void)removeAll:(BOOL)fromDisk {
  [mediaCache removeAllObjects];
  [mediaSortedList removeAllObjects];
  totalPixelCount = 0;

  if (fromDisk) {
    NSFileManager* fm = [NSFileManager defaultManager];
    [fm removeItemAtPath:cachePath error:nil];
    [fm createDirectoryAtPath:cachePath attributes:nil];
  }
}

- (void)invalidateURL:(NSString*)url {
  NSString* filePath = [self getCachePathForURL:url];
  NSFileManager* fm = [NSFileManager defaultManager];
  if (filePath && [fm fileExistsAtPath:filePath]) {
    NSDate* invalidDate = [NSDate dateWithTimeIntervalSinceNow:-T3_DEFAULT_CACHE_AGE];
    NSDictionary* attrs = [NSDictionary dictionaryWithObject:invalidDate
      forKey:NSFileModificationDate];

    [fm changeFileAttributes:attrs atPath:filePath];
  }
}

- (void)invalidateAll {
  NSDate* invalidDate = [NSDate dateWithTimeIntervalSinceNow:-T3_DEFAULT_CACHE_AGE];
  NSDictionary* attrs = [NSDictionary dictionaryWithObject:invalidDate
    forKey:NSFileModificationDate];

  NSFileManager* fm = [NSFileManager defaultManager];
  NSDirectoryEnumerator* e = [fm enumeratorAtPath:cachePath];
  for (NSString* fileName; fileName = [e nextObject]; ) {
    NSString* filePath = [cachePath stringByAppendingPathComponent:fileName];
    [fm changeFileAttributes:attrs atPath:filePath];
  }
}

- (void)logMemoryReport {
  T3LOG(@"======= IMAGE CACHE: %d media, %d pixels ========", mediaCache.count, totalPixelCount);
  NSEnumerator* e = [mediaCache keyEnumerator];
  for (NSString* url ; url = [e nextObject]; ) {
    id media = [mediaCache objectForKey:url];
    if ([media isKindOfClass:[UIImage class]]) {
      UIImage* image = media;
      T3LOG(@"  %f x %f %@", image.size.width, image.size.height, url);
    }
  }  
}

@end
