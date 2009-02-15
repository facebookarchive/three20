#import "Three20/T3Global.h"

@class T3URLRequest;

@interface T3URLCache : NSObject {
  NSString* _cachePath;
  NSMutableDictionary* _mediaCache;
  NSMutableArray* _mediaSortedList;
  NSUInteger _totalPixelCount;
  NSUInteger _maxPixelCount;
  NSInteger _totalLoading;
  NSTimeInterval _invalidationAge;
  BOOL _disableDiskCache;
  BOOL _disableMediaCache;
}

/**
 * Disables the disk cache.
 */
@property(nonatomic) BOOL disableDiskCache;

/**
 * Disables the in-memory cache for multimedia objects.
 */
@property(nonatomic) BOOL disableMediaCache;

/**
 * Gets the path to the directory of the disk cache.
 */
@property(nonatomic,copy) NSString* cachePath;

/**
 * The maximum number of pixels to keep in memory for cached images.
 *
 * Setting this to zero will allow an unlimited number of images to be cached.  The default
 * is enough to hold roughly 25 small images.
 */
@property(nonatomic) NSUInteger maxPixelCount;

/**
 * The amount of time to set back the modification timestamp on files when invalidating them.
 */
@property(nonatomic) NSTimeInterval invalidationAge;

/**
 * Gets the shared cache singleton used across the application.
 */
+ (T3URLCache*)sharedCache;

/**
 * Sets the shared cache singleton used across the application.
 */
+ (void)setSharedCache:(T3URLCache*)cache;

/**
 * Gets the path to the default directory of the disk cache.
 */
+ (NSString*)defaultCachePath;

/**
 * Gets the key that would be used to cache a URL response.
 */
- (NSString *)keyForURL:(NSString*)url;

/**
 * Determines if there is a cache entry for a URL.
 */
- (BOOL)hasDataForURL:(NSString*)url;

/**
 * Gets the path in the cache where a URL may be stored.
 */
- (NSString*)getCachePathForURL:(NSString*)url;

/**
 * Gets the data for a URL from the cache if it exists.
 *
 * @return nil if the URL is not cached. 
 */
- (NSData*)getDataForURL:(NSString*)url;

/**
 * Gets the data for a URL from the cache if it exists and is newer than a minimum timestamp.
 *
 * @return nil if hthe URL is not cached or if the cache entry is older than the minimum.
 */
- (NSData*)getDataForURL:(NSString*)url expires:(NSTimeInterval)expirationAge
  timestamp:(NSDate**)timestamp;
- (NSData*)getDataForKey:(NSString*)key expires:(NSTimeInterval)expirationAge
  timestamp:(NSDate**)timestamp;

/**
 * Gets the multimedia object (such as a UIImage) for a URL from the memory cache or disk cache.
 *
 * @return nil if the URL is not cached.
 */
- (id)getMediaForURL:(NSString*)url;

/**
 * Gets the multimedia object for a URL from the memory cache and optionally the disk cache.
 *
 * @return nil if the URL is not cached.
 */
- (id)getMediaForURL:(NSString*)url fromDisk:(BOOL)fromDisk;

/**
 * Converts data to a usable media object, such as a UIImage.
 */ 
- (id)convertDataToMedia:(NSData*)data forType:(NSString*)mimeType;

/**
 * Stores a multimedia object in the memory cache and optionally writes its source data to disk.
 *
 * The data argument is optional if you provide media.  If you omit data then the media will be
 * converted to a file format before being stored on disk.  For example, UIImage objects will be
 * converted to PNGs.  If you happen to have the data that was used to create the image then you
 * should definitely include it here to avoid the cost of encoding the image again.
 */
- (void)storeData:(NSData*)data media:(id)media forURL:(NSString*)url toDisk:(BOOL)toDisk;
- (void)storeData:(NSData*)data media:(id)media forKey:(NSString*)key toDisk:(BOOL)toDisk;

/**
 * Convenient way to create a temporary URL for an image and cache the image with it.
 *
 * @return The temporary URL
 */
- (NSString*)storeTemporaryData:(NSData*)data media:(id)media toDisk:(BOOL)toDisk;

/**
 * Moves the data currently stored under one URL to another URL.
 * 
 * This is handy when you are caching data at a temporary URL while the permanent URL is being
 * retrieved from a server.  Once you know the permanent URL you can use this to move the data.
 */ 
- (void)moveDataForURL:(NSString*)oldURL toURL:(NSString*)newURL;

/**
 * Removes the data for a URL from the memory cache and optionally from the disk cache.
 */
- (void)removeURL:(NSString*)url fromDisk:(BOOL)fromDisk;

/**
 * 
 */
- (void)removeKey:(NSString*)key;

/** 
 * Erases the memory cache and optionally the disk cache.
 */
- (void)removeAll:(BOOL)fromDisk;

/** 
 * Invalidates the file in the disk cache so that its modified timestamp is the current
 * time minus the default cache expiration age.
 *
 * This ensures that the next time the URL is requested from the cache it will be loaded
 * from the network if the default cache expiration age is used.
 */
- (void)invalidateURL:(NSString*)url;

/**
 *
 */
- (void)invalidateKey:(NSString*)key;

/**
 * Invalidates all files in the disk cache according to rules explained in `invalidateURL`.
 */
- (void)invalidateAll;

- (void)logMemoryReport;

@end
