#import "Three20/T3URLCache.h"
#import <CommonCrypto/CommonDigest.h>

//////////////////////////////////////////////////////////////////////////////////////////////////
  
#define SMALL_IMAGE_SIZE (50*50)
#define MEDIUM_IMAGE_SIZE (130*97)
#define LARGE_IMAGE_SIZE (600*400)

static NSString* kCacheDirPathName = @"Three20";

//////////////////////////////////////////////////////////////////////////////////////////////////

@implementation T3URLCache

@synthesize disableDiskCache = _disableDiskCache, disableMediaCache = _disableMediaCache,
  cachePath = _cachePath, maxPixelCount = _maxPixelCount, invalidationAge = _invalidationAge;

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
    _cachePath = [[T3URLCache defaultCachePath] retain];
    _mediaCache = [[NSMutableDictionary alloc] init];
    _mediaSortedList = [[NSMutableArray alloc] init];
    _totalLoading = 0;
    _disableDiskCache = NO;
    _disableMediaCache = NO;
    _invalidationAge = 0;
    _maxPixelCount = (SMALL_IMAGE_SIZE*20) + (MEDIUM_IMAGE_SIZE*12);
    _totalPixelCount = 0;
    
    // Disable the built-in cache to save memory
    NSURLCache* sharedCache = [[NSURLCache alloc] initWithMemoryCapacity:0 diskCapacity:0
      diskPath:nil];
    [NSURLCache setSharedURLCache:sharedCache];
    [sharedCache release];
  }
  return self;
}

- (void)dealloc {
  [_mediaCache release];
  [_mediaSortedList release];
  [_cachePath release];
  [super dealloc];
}

//////////////////////////////////////////////////////////////////////////////////////////////////

- (NSString*)getCachePathForKey:(NSString*)key {
  return [_cachePath stringByAppendingPathComponent:key];
}

- (void)expireImagesFromMemory {
  while (_mediaSortedList.count) {
    NSString* key = [_mediaSortedList objectAtIndex:0];
    UIImage* image = [_mediaCache objectForKey:key];
    // T3LOG(@"EXPIRING %@", key);

    _totalPixelCount -= image.size.width * image.size.height;
    [_mediaCache removeObjectForKey:key];
    [_mediaSortedList removeObjectAtIndex:0];
    
    if (_totalPixelCount <= _maxPixelCount) {
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

//////////////////////////////////////////////////////////////////////////////////////////////////

- (NSString *)keyForURL:(NSString*)url {
  const char* str = [url UTF8String];
  unsigned char result[CC_MD5_DIGEST_LENGTH];
  CC_MD5(str, strlen(str), result);

  return [NSString stringWithFormat:
    @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
    result[0], result[1], result[2], result[3], result[4], result[5], result[6], result[7],
    result[8], result[9], result[10], result[11], result[12], result[13], result[14], result[15]
  ];
}

- (NSString*)getCachePathForURL:(NSString*)url {
  NSString* key = [self keyForURL:url];
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
  NSString* key = [self keyForURL:url];
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
  NSString* key = [self keyForURL:url];
  UIImage* media = [_mediaCache objectForKey:key];
  if (media) {
    return [[media retain] autorelease];
  } else if (fromDisk) {
    NSData* data = [self loadDataFromDisk:url];
    return [self convertDataToMedia:data forType:nil];
  } else {
    return nil;
  }
}

- (id)convertDataToMedia:(NSData*)data forType:(NSString*)mimeType {
  if (!mimeType || [self isImageMimeType:mimeType]) {
    return [UIImage imageWithData:data];
  } else {
    return nil;
  }
}

- (void)storeData:(NSData*)data media:(id)media forURL:(NSString*)url toDisk:(BOOL)toDisk {
  NSString* key = [self keyForURL:url];
  [self storeData:data media:media forKey:key toDisk:toDisk];
}

- (void)storeData:(NSData*)data media:(id)media forKey:(NSString*)key toDisk:(BOOL)toDisk {
  if (!_disableMediaCache && media) {
    if ([media isKindOfClass:[UIImage class]]) {
      UIImage* image = media;
      int pixelCount = image.size.width * image.size.height;
      if (pixelCount < LARGE_IMAGE_SIZE) {
        _totalPixelCount += pixelCount;
        if (_totalPixelCount > _maxPixelCount && _maxPixelCount) {
          [self expireImagesFromMemory];
        }
    
        [_mediaSortedList addObject:key];
        [_mediaCache setObject:image forKey:key];
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

- (NSString*)storeTemporaryData:(NSData*)data media:(id)media toDisk:(BOOL)toDisk {
  static int temporaryURLIncrement = 0;
  
  NSString* url = [NSString stringWithFormat:@"temp:%d", temporaryURLIncrement++];
  [self storeData:data media:media forURL:url toDisk:toDisk];
  return url;
}

- (void)moveDataForURL:(NSString*)oldURL toURL:(NSString*)newURL {
  NSString* oldKey = [self keyForURL:oldURL];
  NSString* newKey = [self keyForURL:newURL];
  id media = [self getMediaForURL:oldKey fromDisk:NO];
  if (media) {
    [_mediaSortedList removeObject:oldKey];
    [_mediaCache removeObjectForKey:oldKey];
    [_mediaSortedList addObject:newKey];
    [_mediaCache setObject:media forKey:newKey];
  }
  NSString* oldPath = [self getCachePathForURL:oldKey];
  NSFileManager* fm = [NSFileManager defaultManager];
  if ([fm fileExistsAtPath:oldPath]) {
    NSString* newPath = [self getCachePathForURL:newKey];
    [fm moveItemAtPath:oldPath toPath:newPath error:nil];
  }
}

- (void)removeURL:(NSString*)url fromDisk:(BOOL)fromDisk {
  NSString*  key = [self keyForURL:url];
  [_mediaSortedList removeObject:key];
  [_mediaCache removeObjectForKey:key];
  
  if (fromDisk) {
    NSString* filePath = [self getCachePathForKey:key];
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
  NSString* key = [self keyForURL:url];
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
  for (NSString* key ; key = [e nextObject]; ) {
    id media = [_mediaCache objectForKey:key];
    if ([media isKindOfClass:[UIImage class]]) {
      UIImage* image = media;
      T3LOG(@"  %f x %f %@", image.size.width, image.size.height, key);
    }
  }  
}

@end
