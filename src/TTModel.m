// Copyright 2004-2009 Facebook. All Rights Reserved.

#import "TTModel.h"
#import "TTURLCache.h"
#import "TTURLRequestQueue.h"

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation TTModel

@synthesize cacheKey = _cacheKey;

///////////////////////////////////////////////////////////////////////////////////////////////////
// NSObject

- (id)init {
  if (self = [super init]) {
    _delegates = nil;
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
  TT_RELEASE_MEMBER(_loadingRequest);
  TT_RELEASE_MEMBER(_delegates);
  TT_RELEASE_MEMBER(_loadedTime);
  TT_RELEASE_MEMBER(_cacheKey);
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

- (NSDate*)loadedTime {
  return _loadedTime;
}

- (BOOL)isLoaded {
  return !!_loadedTime;
}

- (BOOL)isLoading {
  return !!_loadingRequest;
}

- (BOOL)isLoadingMore {
  return _loadingRequest && _isLoadingMore;
}

- (BOOL)isOutdated {
  NSDate* loadedTime = self.loadedTime;
  if (loadedTime) {
    return -[loadedTime timeIntervalSinceNow] > [TTURLCache sharedCache].invalidationAge;
  } else {
    return NO;
  }
}

- (BOOL)isEmpty {
  // Subclasses must implement this, since this class has no idea what content they will have
  return YES;
}

- (void)load:(TTURLRequestCachePolicy)cachePolicy more:(BOOL)more {
}

- (void)invalidate:(BOOL)erase {
  if (_cacheKey) {
    if (erase) {
      [[TTURLCache sharedCache] removeKey:_cacheKey];
    } else {
      [[TTURLCache sharedCache] invalidateKey:_cacheKey];
    }
    TT_RELEASE_MEMBER(_cacheKey);
  }
}

- (void)cancel {
  [_loadingRequest cancel];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// TTURLRequestDelegate

- (void)requestDidStartLoad:(TTURLRequest*)request {
  [_loadingRequest release];
  _loadingRequest = [request retain];
  [_delegates perform:@selector(modelDidStartLoad:) withObject:self];
}

- (void)requestDidFinishLoad:(TTURLRequest*)request {
  if (!self.isLoadingMore) {
    [_loadedTime release];
    _loadedTime = [request.timestamp retain];
    self.cacheKey = request.cacheKey;
  }
  
  TT_RELEASE_MEMBER(_loadingRequest);
  [_delegates perform:@selector(modelDidFinishLoad:) withObject:self];
}

- (void)request:(TTURLRequest*)request didFailLoadWithError:(NSError*)error {
  TT_RELEASE_MEMBER(_loadingRequest);
  [_delegates perform:@selector(model:didFailLoadWithError:) withObject:self
    withObject:error];
}

- (void)requestDidCancelLoad:(TTURLRequest*)request {
  TT_RELEASE_MEMBER(_loadingRequest);
  [_delegates perform:@selector(modelDidCancelLoad:) withObject:self];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// public

- (void)setLoadedTime:(NSDate*)loadedTime {
  [_loadedTime release];
  _loadedTime = [loadedTime retain];
}

@end
