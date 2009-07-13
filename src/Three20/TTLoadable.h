#import "Three20/TTGlobal.h"

/**
 * TTLoadable describes the state of an object that can be loaded from a remote source.
 *
 * By implementing this protocol, you can communicate to the user the state of network
 * activity in an object.
 */
@protocol TTLoadable <NSObject>

/** 
 * An array of objects that conform to the TTLoadableDelegate protocol.
 */
@property(nonatomic,readonly) NSMutableArray* delegates;

/**
 * The time that the data was loaded.
 */
@property(nonatomic,readonly) NSDate* loadedTime;

/**
 * Indicates that the data has been loaded.
 */

@property(nonatomic,readonly) BOOL isLoaded;

/**
 * Indicates that the data is in the process of loading.
 */
@property(nonatomic,readonly) BOOL isLoading;

/**
 * Indicates that the data is in the process of loading additional data.
 */
@property(nonatomic,readonly) BOOL isLoadingMore;

/**
 * Indicates that the data is of date and should be refreshed as soon as possible.
 */
@property(nonatomic,readonly) BOOL isOutdated;

/**
 * Indicates that the data set contains no objects.
 */
@property(nonatomic,readonly) BOOL isEmpty;

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

@protocol TTLoadableDelegate <NSObject>

@optional

- (void)loadableDidStartLoad:(id<TTLoadable>)loadable;

- (void)loadableDidFinishLoad:(id<TTLoadable>)loadable;

- (void)loadable:(id<TTLoadable>)loadable didFailLoadWithError:(NSError*)error;

- (void)loadableDidCancelLoad:(id<TTLoadable>)loadable;

@end
