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

#import "Three20Network/TTGlobalNetwork.h"

// Core
#import "Three20Core/TTDebug.h"

#import <UIKit/UIKit.h>
#import <pthread.h>

static int              gNetworkTaskCount = 0;
static pthread_mutex_t  gMutex = PTHREAD_MUTEX_INITIALIZER;


///////////////////////////////////////////////////////////////////////////////////////////////////
void TTNetworkRequestStarted() {
  pthread_mutex_lock(&gMutex);

  if (0 == gNetworkTaskCount) {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
  }
  gNetworkTaskCount++;

  pthread_mutex_unlock(&gMutex);
}


///////////////////////////////////////////////////////////////////////////////////////////////////
void TTNetworkRequestStopped() {
  pthread_mutex_lock(&gMutex);

  --gNetworkTaskCount;
  // If this asserts, you don't have enough stop requests to match your start requests.
  TTDASSERT(gNetworkTaskCount >= 0);
  gNetworkTaskCount = MAX(0, gNetworkTaskCount);

  if (gNetworkTaskCount == 0) {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
  }

  pthread_mutex_unlock(&gMutex);
}
