#import "Three20/T3Object.h"

///////////////////////////////////////////////////////////////////////////////////////////////////

#define T3_NULL_PHOTO_INDEX NSIntegerMax
#define T3_INFINITE_PHOTO_INDEX NSIntegerMax

@protocol T3Photo;
@class T3URLRequest;

typedef enum {
  T3PhotoVersionNone,
  T3PhotoVersionLarge,
  T3PhotoVersionMedium,
  T3PhotoVersionSmall,
  T3PhotoVersionThumbnail
} T3PhotoVersion;

///////////////////////////////////////////////////////////////////////////////////////////////////

@protocol T3PhotoSource <T3Object>

/**
 *
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
- (id<T3Photo>)photoAtIndex:(NSInteger)index;

/**
 * Loads a range of photos asynchronously.
 *
 * @param fromIndex The starting index.
 * @param toIndex The ending index, or -1 to load the remainder of photos.
 */
- (void)loadPhotos:(T3URLRequest*)request fromIndex:(NSInteger)fromIndex
  toIndex:(NSInteger)toIndex;

@end

///////////////////////////////////////////////////////////////////////////////////////////////////

@protocol T3Photo <T3Object>

/**
 * The photo source that the photo belongs to.
 */
@property(nonatomic,assign) id<T3PhotoSource> photoSource;

/**
 * The index of the photo within its photo source.
 */
@property(nonatomic) CGSize size;

/**
 * The index of the photo within its photo source.
 */
@property(nonatomic) NSInteger index;

/**
 * Gets the url of one of the differently sized versions of the photo.
 */
- (NSString*)urlForVersion:(T3PhotoVersion)version;

@end
