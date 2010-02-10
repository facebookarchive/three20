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

#import "Three20/TTURLCache.h"

#import "Three20/TTGlobalCore.h"
#import "Three20/TTGlobalCorePaths.h"
#import "Three20/TTGlobalNetwork.h"
#import "Three20/TTDebugFlags.h"

#import <CommonCrypto/CommonDigest.h>
#import <QuartzCore/QuartzCore.h>

//////////////////////////////////////////////////////////////////////////////////////////////////
  
#define TT_LARGE_IMAGE_SIZE (600*400)

static NSString* kDefaultCacheName = @"Three20";

static TTURLCache* gSharedCache = nil;
static NSMutableDictionary* gNamedCaches = nil;

//////////////////////////////////////////////////////////////////////////////////////////////////

@implementation TTURLCache

@synthesize disableDiskCache = _disableDiskCache, disableImageCache = _disableImageCache,
  cachePath = _cachePath, maxPixelCount = _maxPixelCount, invalidationAge = _invalidationAge;

//////////////////////////////////////////////////////////////////////////////////////////////////
// class public


+ (TTURLCache*)cacheWithName:(NSString*)name {
  if (!gNamedCaches) {
    gNamedCaches = [[NSMutableDictionary alloc] init];
  }
  TTURLCache* cache = [gNamedCaches objectForKey:name];
  if (!cache) {
    cache = [[[TTURLCache alloc] initWithName:name] autorelease];
    [gNamedCaches setObject:cache forKey:name];
  }
  return cache;
}

+ (TTURLCache*)sharedCache {
  if (!gSharedCache) {
    gSharedCache = [[TTURLCache alloc] init];
  }
  return gSharedCache;
}

+ (void)setSharedCache:(TTURLCache*)cache {
  if (gSharedCache != cache) {
    [gSharedCache release];
    gSharedCache = [cache retain];
  }
}

+ (NSString*)cachePathWithName:(NSString*)name {
  NSArray* paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
  NSString* cachesPath = [paths objectAtIndex:0];
  NSString* cachePath = [cachesPath stringByAppendingPathComponent:name];
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
// private

- (void)expireImagesFromMemory {
  while (_imageSortedList.count) {
    NSString* key = [_imageSortedList objectAtIndex:0];
    UIImage* image = [_imageCache objectForKey:key];
    TTDCONDITIONLOG(TTDFLAG_URLCACHE, @"EXPIRING %@", key);

    _totalPixelCount -= image.size.width * image.size.height;
    [_imageCache removeObjectForKey:key];
    [_imageSortedList removeObjectAtIndex:0];
    
    if (_totalPixelCount <= _maxPixelCount) {
      break;
    }
  }
}

- (void)storeImage:(UIImage*)image forURL:(NSString*)URL force:(BOOL)force {
  if (image && (force || !_disableImageCache)) {
    int pixelCount = image.size.width * image.size.height;
    if (force || pixelCount < TT_LARGE_IMAGE_SIZE) {
      _totalPixelCount += pixelCount;
      if (_totalPixelCount > _maxPixelCount && _maxPixelCount) {
        [self expireImagesFromMemory];
      }

      if (!_imageCache) {
        _imageCache = [[NSMutableDictionary alloc] init];
      }
      if (!_imageSortedList) {
        _imageSortedList = [[NSMutableArray alloc] init];
      }

      [_imageSortedList addObject:URL];
      [_imageCache setObject:image forKey:URL];
    }
  }
}

- (UIImage*)loadImageFromBundle:(NSString*)URL {
  NSString* path = TTPathForBundleResource([URL substringFromIndex:9]);
  NSData* data = [NSData dataWithContentsOfFile:path];
  return [UIImage imageWithData:data];
}

- (UIImage*)loadImageFromDocuments:(NSString*)URL {
  NSString* path = TTPathForDocumentsResource([URL substringFromIndex:12]);
  NSData* data = [NSData dataWithContentsOfFile:path];
  return [UIImage imageWithData:data];
}

- (NSString*)createTemporaryURL {
  static int temporaryURLIncrement = 0;
  return [NSString stringWithFormat:@"temp:%d", temporaryURLIncrement++];
}

- (NSString*)createUniqueTemporaryURL {
  NSFileManager* fm = [NSFileManager defaultManager];
  NSString* tempURL = nil;
  NSString* newPath = nil;
  do {
    tempURL = [self createTemporaryURL];
    newPath = [self cachePathForURL:tempURL];
  } while ([fm fileExistsAtPath:newPath]);
  return tempURL;
}

//////////////////////////////////////////////////////////////////////////////////////////////////
// NSObject

- (id)initWithName:(NSString*)name {
  if (self == [super init]) {
    _name = [name copy];
    _cachePath = [[TTURLCache cachePathWithName:name] retain];
    _imageCache = nil;
    _imageSortedList = nil;
    _totalLoading = 0;
    _disableDiskCache = NO;
    _disableImageCache = NO;
    _invalidationAge = TT_DEFAULT_CACHE_INVALIDATION_AGE;
    _maxPixelCount = 0;
    _totalPixelCount = 0;
    
    // XXXjoe Disabling the built-in cache may save memory but it also makes UIWebView slow
    // NSURLCache* sharedCache = [[NSURLCache alloc] initWithMemoryCapacity:0 diskCapacity:0
    // diskPath:nil];
    // [NSURLCache setSharedURLCache:sharedCache];
    // [sharedCache release];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                          selector:@selector(didReceiveMemoryWarning:)
                                          name:UIApplicationDidReceiveMemoryWarningNotification  
                                          object:nil];  
  }
  return self;
}

- (id)init {
  return [self initWithName:kDefaultCacheName];
}

- (void)dealloc {
  [[NSNotificationCenter defaultCenter] removeObserver:self
                                        name:UIApplicationDidReceiveMemoryWarningNotification  
                                        object:nil];  
  TT_RELEASE_SAFELY(_name);
  TT_RELEASE_SAFELY(_imageCache);
  TT_RELEASE_SAFELY(_imageSortedList);
  TT_RELEASE_SAFELY(_cachePath);
  [super dealloc];
}

//////////////////////////////////////////////////////////////////////////////////////////////////
// NSNotifications

- (void)didReceiveMemoryWarning:(void*)object {
  // Empty the memory cache when memory is low
  [self removeAll:NO];
}

//////////////////////////////////////////////////////////////////////////////////////////////////
// public

- (NSString *)keyForURL:(NSString*)URL {
  const char* str = [URL UTF8String];
  unsigned char result[CC_MD5_DIGEST_LENGTH];
  CC_MD5(str, strlen(str), result);

  return [NSString stringWithFormat:
    @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
    result[0], result[1], result[2], result[3], result[4], result[5], result[6], result[7],
    result[8], result[9], result[10], result[11], result[12], result[13], result[14], result[15]
  ];
}

- (NSString*)cachePathForURL:(NSString*)URL {
  NSString* key = [self keyForURL:URL];
  return [self cachePathForKey:key];
}

- (NSString*)cachePathForKey:(NSString*)key {
  return [_cachePath stringByAppendingPathComponent:key];
}

- (BOOL)hasDataForURL:(NSString*)URL {
  NSString* filePath = [self cachePathForURL:URL];
  NSFileManager* fm = [NSFileManager defaultManager];
  return [fm fileExistsAtPath:filePath];
}

- (NSData*)dataForURL:(NSString*)URL {
  return [self dataForURL:URL expires:TT_CACHE_EXPIRATION_AGE_NEVER timestamp:nil];
}

- (NSData*)dataForURL:(NSString*)URL expires:(NSTimeInterval)expirationAge
    timestamp:(NSDate**)timestamp {
  NSString* key = [self keyForURL:URL];
  return [self dataForKey:key expires:expirationAge timestamp:timestamp];
}

- (NSData*)dataForKey:(NSString*)key expires:(NSTimeInterval)expirationAge
    timestamp:(NSDate**)timestamp {
  NSString* filePath = [self cachePathForKey:key];
  NSFileManager* fm = [NSFileManager defaultManager];
  if ([fm fileExistsAtPath:filePath]) {
    NSDictionary* attrs = [fm attributesOfItemAtPath:filePath error:nil];
    NSDate* modified = [attrs objectForKey:NSFileModificationDate];
    if ([modified timeIntervalSinceNow] < -expirationAge) {
      return nil;
    }
    if (timestamp) {
      *timestamp = modified;
    }

    return [NSData dataWithContentsOfFile:filePath];
  }

  return nil;
}

- (id)imageForURL:(NSString*)URL {
  return [self imageForURL:URL fromDisk:YES];
}

- (id)imageForURL:(NSString*)URL fromDisk:(BOOL)fromDisk {
  UIImage* image = [_imageCache objectForKey:URL];
  if (!image && fromDisk) {
    if (TTIsBundleURL(URL)) {
      image = [self loadImageFromBundle:URL];
      [self storeImage:image forURL:URL];
    } else if (TTIsDocumentsURL(URL)) {
      image = [self loadImageFromDocuments:URL];
      [self storeImage:image forURL:URL];
    }
  }
  return image;
}

- (void)storeData:(NSData*)data forURL:(NSString*)URL {
  NSString* key = [self keyForURL:URL];
  [self storeData:data forKey:key];
}

- (void)storeData:(NSData*)data forKey:(NSString*)key {
  if (!_disableDiskCache) {
    NSString* filePath = [self cachePathForKey:key];
    NSFileManager* fm = [NSFileManager defaultManager];
    [fm createFileAtPath:filePath contents:data attributes:nil];
  }
}

- (void)storeImage:(UIImage*)image forURL:(NSString*)URL {
  [self storeImage:image forURL:URL force:NO];
}
  
- (NSString*)storeTemporaryData:(NSData*)data {
  NSString* URL = [self createUniqueTemporaryURL];
  [self storeData:data forURL:URL];
  return URL;
}

- (NSString*)storeTemporaryFile:(NSURL*)fileURL {
  if ([fileURL isFileURL]) {
    NSString* filePath = [fileURL path];
    NSFileManager* fm = [NSFileManager defaultManager];
    if ([fm fileExistsAtPath:filePath]) {
      NSString* tempURL = nil;
      NSString* newPath = nil;
      do {
        tempURL = [self createTemporaryURL];
        newPath = [self cachePathForURL:tempURL];
      } while ([fm fileExistsAtPath:newPath]);

      if ([fm moveItemAtPath:filePath toPath:newPath error:nil]) {
        return tempURL;
      }
    }
  }
  return nil;
}

- (NSString*)storeTemporaryImage:(UIImage*)image toDisk:(BOOL)toDisk {
  NSString* URL = [self createUniqueTemporaryURL];
  [self storeImage:image forURL:URL force:YES];
  
  NSData* data = UIImagePNGRepresentation(image);
  [self storeData:data forURL:URL];
  return URL;
}

- (void)moveDataForURL:(NSString*)oldURL toURL:(NSString*)newURL {
  NSString* oldKey = [self keyForURL:oldURL];
  NSString* newKey = [self keyForURL:newURL];
  id image = [self imageForURL:oldKey];
  if (image) {
    [_imageSortedList removeObject:oldKey];
    [_imageCache removeObjectForKey:oldKey];
    [_imageSortedList addObject:newKey];
    [_imageCache setObject:image forKey:newKey];
  }
  NSString* oldPath = [self cachePathForKey:oldKey];
  NSFileManager* fm = [NSFileManager defaultManager];
  if ([fm fileExistsAtPath:oldPath]) {
    NSString* newPath = [self cachePathForKey:newKey];
    [fm moveItemAtPath:oldPath toPath:newPath error:nil];
  }
}

- (void)moveDataFromPath:(NSString*)path toURL:(NSString*)newURL {
  NSString* newKey = [self keyForURL:newURL];
  NSFileManager* fm = [NSFileManager defaultManager];
  if ([fm fileExistsAtPath:path]) {
    NSString* newPath = [self cachePathForKey:newKey];
    [fm moveItemAtPath:path toPath:newPath error:nil];
  }
}

- (NSString*)moveDataFromPathToTemporaryURL:(NSString*)path {
  NSString* tempURL = [self createUniqueTemporaryURL];
  [self moveDataFromPath:path toURL:tempURL];
  return tempURL;
}

- (void)removeURL:(NSString*)URL fromDisk:(BOOL)fromDisk {
  NSString*  key = [self keyForURL:URL];
  [_imageSortedList removeObject:key];
  [_imageCache removeObjectForKey:key];
  
  if (fromDisk) {
    NSString* filePath = [self cachePathForKey:key];
    NSFileManager* fm = [NSFileManager defaultManager];
    if (filePath && [fm fileExistsAtPath:filePath]) {
      [fm removeItemAtPath:filePath error:nil];
    }
  }
}

- (void)removeKey:(NSString*)key {
  NSString* filePath = [self cachePathForKey:key];
  NSFileManager* fm = [NSFileManager defaultManager];
  if (filePath && [fm fileExistsAtPath:filePath]) {
    [fm removeItemAtPath:filePath error:nil];
  }
}

- (void)removeAll:(BOOL)fromDisk {
  [_imageCache removeAllObjects];
  [_imageSortedList removeAllObjects];
  _totalPixelCount = 0;

  if (fromDisk) {
    NSFileManager* fm = [NSFileManager defaultManager];
    [fm removeItemAtPath:_cachePath error:nil];
    [fm createDirectoryAtPath:_cachePath attributes:nil];
  }
}

- (void)invalidateURL:(NSString*)URL {
  NSString* key = [self keyForURL:URL];
  return [self invalidateKey:key];
}

- (void)invalidateKey:(NSString*)key {
  NSString* filePath = [self cachePathForKey:key];
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

- (void)logMemoryUsage {
#if TTLOGLEVEL_INFO <= TTMAXLOGLEVEL
  TTDCONDITIONLOG(TTDFLAG_URLCACHE, @"======= IMAGE CACHE: %d images, %d pixels ========", _imageCache.count, _totalPixelCount);
  NSEnumerator* e = [_imageCache keyEnumerator];
  for (NSString* key ; key = [e nextObject]; ) {
    UIImage* image = [_imageCache objectForKey:key];
    TTDCONDITIONLOG(TTDFLAG_URLCACHE, @"  %f x %f %@", image.size.width, image.size.height, key);
  }
#endif
}

@end
