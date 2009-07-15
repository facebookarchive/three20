#import "Three20/TTURLRequest.h"

/**
 * TTModel describes the state of an object that can be loaded from a remote source.
 *
 * By implementing this protocol, you can communicate to the user the state of network
 * activity in an object.
 */
@protocol TTModel <NSObject>

/** 
 * An array of objects that conform to the TTModelDelegate protocol.
 */
- (NSMutableArray*)delegates;

/**
 * The time that the data was loaded.
 */
- (NSDate*)loadedTime;

/**
 * Indicates that the data has been loaded.
 */

- (BOOL)isLoaded;

/**
 * Indicates that the data is in the process of loading.
 */
- (BOOL)isLoading;

/**
 * Indicates that the data is in the process of loading additional data.
 */
- (BOOL)isLoadingMore;

/**
 * Indicates that the data is of date and should be refreshed as soon as possible.
 */
-(BOOL)isOutdated;

/**
 * Indicates that the data set contains no objects.
 */
- (BOOL)isEmpty;

/**
 * Loads the model.
 */
- (void)load:(TTURLRequestCachePolicy)cachePolicy more:(BOOL)more;

/**
 * Invalidates data stored in the cache or optionally erases it.
 */
- (void)invalidate:(BOOL)erase;

/**
 * Cancels a load that is in progress.
 */
- (void)cancel;

@end

///////////////////////////////////////////////////////////////////////////////////////////////////

@protocol TTModelDelegate <NSObject>

@optional

- (void)modelDidStartLoad:(id<TTModel>)model;

- (void)modelDidFinishLoad:(id<TTModel>)model;

- (void)model:(id<TTModel>)model didFailLoadWithError:(NSError*)error;

- (void)modelDidCancelLoad:(id<TTModel>)model;

@end

///////////////////////////////////////////////////////////////////////////////////////////////////

@interface TTModel : NSObject <TTModel, TTURLRequestDelegate> {
  NSMutableArray* _delegates;
  TTURLRequest* _loadingRequest;
  BOOL _isLoadingMore;
  NSDate* _loadedTime;
  NSString* _cacheKey;
}

@property(nonatomic,copy) NSString* cacheKey;

- (void)setLoadedTime:(NSDate*)timestamp;

@end
