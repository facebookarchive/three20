#import "Three20/TTGlobal.h"

///////////////////////////////////////////////////////////////////////////////////////////////////

#define TT_NULL_PHOTO_INDEX NSIntegerMax
#define TT_INFINITE_PHOTO_INDEX NSIntegerMax

@protocol TTPhoto, TTPhotoSourceDelegate;
@class TTURLRequest;

typedef enum {
  TTPhotoVersionNone,
  TTPhotoVersionLarge,
  TTPhotoVersionMedium,
  TTPhotoVersionSmall,
  TTPhotoVersionThumbnail
} TTPhotoVersion;

///////////////////////////////////////////////////////////////////////////////////////////////////

@protocol TTPhotoSource <TTLoadableX>

@property(nonatomic,readonly) NSMutableArray* delegates;

/**
 * The title of this collection of photos.
 */
@property(nonatomic,copy) NSString* title;

/**
 * The total number of photos in the source, independent of the number that have been loaded.
 */
@property(nonatomic,readonly) NSInteger numberOfPhotos;

/**
 * The maximum index of photos that have already been loaded.
 */
@property(nonatomic,readonly) NSInteger maxPhotoIndex;

/**
 *
 */
@property(nonatomic,readonly) BOOL loading;

/**
 *
 */
- (id<TTPhoto>)photoAtIndex:(NSInteger)index;

/**
 * Loads a range of photos asynchronously.
 *
 * @param fromIndex The starting index.
 * @param toIndex The ending index, or -1 to load the remainder of photos.
 */
- (void)loadPhotosFromIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex
        cachePolicy:(TTURLRequestCachePolicy)cachePolicy;

@end

///////////////////////////////////////////////////////////////////////////////////////////////////

@protocol TTPhoto <TTPersistable>

/**
 * The photo source that the photo belongs to.
 */
@property(nonatomic,assign) id<TTPhotoSource> photoSource;

/**
 * The index of the photo within its photo source.
 */
@property(nonatomic) CGSize size;

/**
 * The index of the photo within its photo source.
 */
@property(nonatomic) NSInteger index;

/**
 * The caption of the photo.
 */
@property(nonatomic,copy) NSString* caption;

/**
 * Gets the url of one of the differently sized versions of the photo.
 */
- (NSString*)urlForVersion:(TTPhotoVersion)version;

@end

///////////////////////////////////////////////////////////////////////////////////////////////////

@protocol TTPhotoSourceDelegate <NSObject>

- (void)photoSourceLoading:(id<TTPhotoSource>)photoSource;

- (void)photoSourceLoaded:(id<TTPhotoSource>)photoSource;

- (void)photoSource:(id<TTPhotoSource>)photoSource didFailWithError:(NSError*)error;

- (void)photoSourceCancelled:(id<TTPhotoSource>)photoSource;

@end
