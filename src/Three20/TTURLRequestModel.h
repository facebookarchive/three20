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

#import "Three20/TTModel.h"
#import "Three20/TTURLRequestDelegate.h"

/**
 * An implementation of TTModel which is built to work with TTURLRequests.
 *
 * If you use a TTURLRequestModel as the delegate of your TTURLRequests, it will automatically
 * manage many of the TTModel properties based on the state of your requests.
 */
@interface TTURLRequestModel : TTModel <TTURLRequestDelegate> {
  TTURLRequest* _loadingRequest;
  NSDate*       _loadedTime;
  NSString*     _cacheKey;
  BOOL          _isLoadingMore;
  BOOL          _hasNoMore;
}

@property (nonatomic, retain) NSDate*   loadedTime;
@property (nonatomic, copy)   NSString* cacheKey;
@property (nonatomic)         BOOL      hasNoMore;

/**
 * Resets the model to its original state before any data was loaded.
 */
- (void)reset;

@end

