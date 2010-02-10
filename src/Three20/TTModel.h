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

#import "Three20/TTURLRequest.h"
#import "Three20/TTURLRequestDelegate.h"

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
 * Indicates that the model is of date and should be reloaded as soon as possible.
 */
-(BOOL)isOutdated;

/**
 * Loads the model.
 */
- (void)load:(TTURLRequestCachePolicy)cachePolicy more:(BOOL)more;

/**
 * Cancels a load that is in progress.
 */
- (void)cancel;

/**
 * Invalidates data stored in the cache or optionally erases it.
 */
- (void)invalidate:(BOOL)erase;

@end

///////////////////////////////////////////////////////////////////////////////////////////////////

@protocol TTModelDelegate <NSObject>

@optional

/**
 *
 */
- (void)modelDidStartLoad:(id<TTModel>)model;

/**
 *
 */
- (void)modelDidFinishLoad:(id<TTModel>)model;

/**
 *
 */
- (void)model:(id<TTModel>)model didFailLoadWithError:(NSError*)error;

/**
 *
 */
- (void)modelDidCancelLoad:(id<TTModel>)model;

/**
 * Informs the delegate that the model has changed in some fundamental way.
 *
 * The change is not described specifically, so the delegate must assume that the entire
 * contents of the model may have changed, and react almost as if it was given a new model.
 */
- (void)modelDidChange:(id<TTModel>)model;

/**
 *
 */
- (void)model:(id<TTModel>)model didUpdateObject:(id)object atIndexPath:(NSIndexPath*)indexPath;

/**
 *
 */
- (void)model:(id<TTModel>)model didInsertObject:(id)object atIndexPath:(NSIndexPath*)indexPath;

/**
 *
 */
- (void)model:(id<TTModel>)model didDeleteObject:(id)object atIndexPath:(NSIndexPath*)indexPath;

/**
 * Informs the delegate that the model is about to begin a multi-stage update.
 *
 * Models should use this method to condense multiple updates into a single visible update.
 * This avoids having the view update multiple times for each change.  Instead, the user will
 * only see the end result of all of your changes when you call modelDidEndUpdates.
 */
- (void)modelDidBeginUpdates:(id<TTModel>)model;

/**
 * Informs the delegate that the model has completed a multi-stage update.
 *
 * The exact nature of the change is not specified, so the receiver should investigate the
 * new state of the model by examining its properties.
 */
- (void)modelDidEndUpdates:(id<TTModel>)model;

@end

///////////////////////////////////////////////////////////////////////////////////////////////////

/**
 * A default implementation of TTModel does nothing other than appear to be loaded.
 */
@interface TTModel : NSObject <TTModel> {
  NSMutableArray* _delegates;
}

/**
 * Notifies delegates that the model started to load.
 */
- (void)didStartLoad;

/**
 * Notifies delegates that the model finished loading
 */
- (void)didFinishLoad;

/**
 * Notifies delegates that the model failed to load.
 */
- (void)didFailLoadWithError:(NSError*)error;

/**
 * Notifies delegates that the model canceled its load.
 */
- (void)didCancelLoad;

/**
 * Notifies delegates that the model has begun making multiple updates.
 */
- (void)beginUpdates;

/**
 * Notifies delegates that the model has completed its updates.
 */
- (void)endUpdates;

/**
 * Notifies delegates that an object was updated.
 */
- (void)didUpdateObject:(id)object atIndexPath:(NSIndexPath*)indexPath;

/**
 * Notifies delegates that an object was inserted.
 */
- (void)didInsertObject:(id)object atIndexPath:(NSIndexPath*)indexPath;

/**
 * Notifies delegates that an object was deleted.
 */
- (void)didDeleteObject:(id)object atIndexPath:(NSIndexPath*)indexPath;

/**
 * Notifies delegates that the model changed in some fundamental way.
 */
- (void)didChange;

@end

///////////////////////////////////////////////////////////////////////////////////////////////////

/**
 * An implementation of TTModel which is built to work with TTURLRequests.
 *
 * If you use a TTURLRequestModel as the delegate of your TTURLRequests, it will automatically
 * manage many of the TTModel properties based on the state of your requests.
 */
@interface TTURLRequestModel : TTModel <TTURLRequestDelegate> {
  TTURLRequest* _loadingRequest;
  NSDate* _loadedTime;
  NSString* _cacheKey;
  BOOL _isLoadingMore;
  BOOL _hasNoMore;
}

@property(nonatomic,retain) NSDate* loadedTime;
@property(nonatomic,copy) NSString* cacheKey;
@property(nonatomic) BOOL hasNoMore;

/**
 * Resets the model to its original state before any data was loaded.
 */
- (void)reset;

@end

