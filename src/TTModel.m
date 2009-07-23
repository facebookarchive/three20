// Copyright 2004-2009 Facebook. All Rights Reserved.

#import "TTModel.h"
#import "TTURLCache.h"
#import "TTURLRequestQueue.h"

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation TTModel

///////////////////////////////////////////////////////////////////////////////////////////////////
// NSObject

- (id)init {
  if (self = [super init]) {
    _delegates = nil;
  }
  return self;
}

- (void)dealloc {
  TT_RELEASE_SAFELY(_delegates);
  [super dealloc];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// TTModel

- (NSMutableArray*)delegates {
  if (!_delegates) {
    _delegates = TTCreateNonRetainingArray();
  }
  return _delegates;
}

- (BOOL)isLoaded {
  return YES;
}

- (BOOL)isLoading {
  return NO;
}

- (BOOL)isLoadingMore {
  return NO;
}

- (BOOL)isOutdated {
  return NO;
}

- (void)load:(TTURLRequestCachePolicy)cachePolicy more:(BOOL)more {
}

- (void)cancel {
}

- (void)invalidate:(BOOL)erase {
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// public

- (void)didStartLoad {
  [_delegates perform:@selector(modelDidStartLoad:) withObject:self];
}

- (void)didFinishLoad {
  [_delegates perform:@selector(modelDidFinishLoad:) withObject:self];
}

- (void)didFailLoadWithError:(NSError*)error {
  [_delegates perform:@selector(model:didFailLoadWithError:) withObject:self
    withObject:error];
}

- (void)didCancelLoad {
  [_delegates perform:@selector(modelDidCancelLoad:) withObject:self];
}

- (void)beginUpdates {
  [_delegates perform:@selector(modelDidBeginUpdates:) withObject:self];
}

- (void)endUpdates {
  [_delegates perform:@selector(modelDidEndUpdates:) withObject:self];
}

- (void)didUpdateObject:(id)object atIndexPath:(NSIndexPath*)indexPath {
  [_delegates perform:@selector(model:didUpdateObject:atIndexPath:) withObject:self
              withObject:object withObject:indexPath];
}

- (void)didInsertObject:(id)object atIndexPath:(NSIndexPath*)indexPath {
  [_delegates perform:@selector(model:didInsertObject:atIndexPath:) withObject:self
              withObject:object withObject:indexPath];
}

- (void)didDeleteObject:(id)object atIndexPath:(NSIndexPath*)indexPath {
  [_delegates perform:@selector(model:didDeleteObject:atIndexPath:) withObject:self
              withObject:object withObject:indexPath];
}

- (void)didChange {
  [_delegates perform:@selector(modelDidChange:) withObject:self];
}
@end

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation TTURLRequestModel

@synthesize loadedTime = _loadedTime, cacheKey = _cacheKey, hasNoMore = _hasNoMore;

///////////////////////////////////////////////////////////////////////////////////////////////////
// NSObject

- (id)init {
  if (self = [super init]) {
    _loadingRequest = nil;
    _isLoadingMore = NO;
    _loadedTime = nil;
    _cacheKey = nil;
  }
  return self;
}

- (void)dealloc {
  [[TTURLRequestQueue mainQueue] cancelRequestsWithDelegate:self];
  [_loadingRequest cancel];
  TT_RELEASE_SAFELY(_loadingRequest);
  TT_RELEASE_SAFELY(_loadedTime);
  TT_RELEASE_SAFELY(_cacheKey);
  [super dealloc];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// TTModel

- (BOOL)isLoaded {
  return !!_loadedTime;
}

- (BOOL)isLoading {
  return !!_loadingRequest;
}

- (BOOL)isLoadingMore {
  return _isLoadingMore;
}

- (BOOL)isOutdated {
  if (!_cacheKey && _loadedTime) {
    return YES;
  } else if (!_cacheKey) {
    return NO;
  } else {
    NSDate* loadedTime = self.loadedTime;
    if (loadedTime) {
      return -[loadedTime timeIntervalSinceNow] > [TTURLCache sharedCache].invalidationAge;
    } else {
      return NO;
    }
  }
}

- (void)cancel {
  [_loadingRequest cancel];
}

- (void)invalidate:(BOOL)erase {
  if (_cacheKey) {
    if (erase) {
      [[TTURLCache sharedCache] removeKey:_cacheKey];
    } else {
      [[TTURLCache sharedCache] invalidateKey:_cacheKey];
    }
    TT_RELEASE_SAFELY(_cacheKey);
  }
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// TTURLRequestDelegate

- (void)requestDidStartLoad:(TTURLRequest*)request {
  [_loadingRequest release];
  _loadingRequest = [request retain];
  [self didStartLoad];
}

- (void)requestDidFinishLoad:(TTURLRequest*)request {
  if (!self.isLoadingMore) {
    [_loadedTime release];
    _loadedTime = [request.timestamp retain];
    self.cacheKey = request.cacheKey;
  }
  
  TT_RELEASE_SAFELY(_loadingRequest);
  [self didFinishLoad];
}

- (void)request:(TTURLRequest*)request didFailLoadWithError:(NSError*)error {
  TT_RELEASE_SAFELY(_loadingRequest);
  [self didFailLoadWithError:error];
}

- (void)requestDidCancelLoad:(TTURLRequest*)request {
  TT_RELEASE_SAFELY(_loadingRequest);
  [self didCancelLoad];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// public

- (void)reset {
  TT_RELEASE_SAFELY(_cacheKey);
  TT_RELEASE_SAFELY(_loadedTime);
}

@end

