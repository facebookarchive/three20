//
// Copyright 2009-2011 Facebook
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

#import "Three20Network/TTURLRequestModel.h"

// Network
#import "Three20Network/TTURLRequest.h"
#import "Three20Network/TTURLRequestQueue.h"
#import "Three20Network/TTURLCache.h"

// Core
#import "Three20Core/TTCorePreprocessorMacros.h"


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation TTURLRequestModel

@synthesize loadedTime  = _loadedTime;
@synthesize cacheKey    = _cacheKey;
@synthesize hasNoMore   = _hasNoMore;


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)dealloc {
  [[TTURLRequestQueue mainQueue] cancelRequestsWithDelegate:self];
  [_loadingRequest cancel];

  TT_RELEASE_SAFELY(_loadingRequest);
  TT_RELEASE_SAFELY(_loadedTime);
  TT_RELEASE_SAFELY(_cacheKey);

  [super dealloc];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)reset {
  TT_RELEASE_SAFELY(_cacheKey);
  TT_RELEASE_SAFELY(_loadedTime);
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark TTModel


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)isLoaded {
  return !!_loadedTime;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)isLoading {
  return !!_loadingRequest;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)isLoadingMore {
  return _isLoadingMore;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)isOutdated {
  if (nil == _cacheKey) {
    return nil != _loadedTime;

  } else {
    NSDate* loadedTime = self.loadedTime;

    if (nil != loadedTime) {
      return -[loadedTime timeIntervalSinceNow] > [TTURLCache sharedCache].invalidationAge;

    } else {
      return NO;
    }
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)cancel {
  [_loadingRequest cancel];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)invalidate:(BOOL)erase {
  if (nil != _cacheKey) {
    if (erase) {
      [[TTURLCache sharedCache] removeKey:_cacheKey];

    } else {
      [[TTURLCache sharedCache] invalidateKey:_cacheKey];
    }

    TT_RELEASE_SAFELY(_cacheKey);
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark TTURLRequestDelegate


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)requestDidStartLoad:(TTURLRequest*)request {
  [_loadingRequest release];
  _loadingRequest = [request retain];
  [self didStartLoad];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)requestDidFinishLoad:(TTURLRequest*)request {
  if (!self.isLoadingMore) {
    [_loadedTime release];
    _loadedTime = [request.timestamp retain];
    self.cacheKey = request.cacheKey;
  }

  TT_RELEASE_SAFELY(_loadingRequest);
  [self didFinishLoad];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)request:(TTURLRequest*)request didFailLoadWithError:(NSError*)error {
  TT_RELEASE_SAFELY(_loadingRequest);
  [self didFailLoadWithError:error];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)requestDidCancelLoad:(TTURLRequest*)request {
  TT_RELEASE_SAFELY(_loadingRequest);
  [self didCancelLoad];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (float)downloadProgress {
  if ([self isLoading]) {
    if (!_loadingRequest.totalContentLength) {
      return 0;
    }
    return (float)_loadingRequest.totalBytesDownloaded / (float)_loadingRequest.totalContentLength;
  }
  return 0.0f;
}

@end
