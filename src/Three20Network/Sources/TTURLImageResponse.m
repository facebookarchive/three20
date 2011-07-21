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

#import "Three20Network/TTURLImageResponse.h"

// Network
#import "Three20Network/TTErrorCodes.h"
#import "Three20Network/TTURLRequest.h"
#import "Three20Network/TTURLCache.h"

// Core
#import "Three20Core/TTDebug.h"


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation TTURLImageResponse

@synthesize image = _image;


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)dealloc {
  TT_RELEASE_SAFELY(_image);

  [super dealloc];
}


//////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark TTURLResponse


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSError*)request:(TTURLRequest*)request processResponse:(NSHTTPURLResponse*)response
            data:(id)data {
  // This response is designed for NSData and UIImage objects, so if we get anything else it's
  // probably a mistake.
  TTDASSERT([data isKindOfClass:[UIImage class]]
            || [data isKindOfClass:[NSData class]]);
  TTDASSERT(nil == _image);

  if ([data isKindOfClass:[UIImage class]]) {
    _image = [data retain];

  } else if ([data isKindOfClass:[NSData class]]) {
    // TODO(jverkoey Feb 10, 2010): This logic doesn't entirely make sense. Why don't we just store
    // the data in the cache if there was a cache miss, and then just retain the image data we
    // downloaded? This needs to be tested in production.
	UIImage* image = nil;
	if(!(request.cachePolicy | TTURLRequestCachePolicyNoCache)) {
      image = [[TTURLCache sharedCache] imageForURL:request.urlPath fromDisk:NO];
  }
    if (nil == image) {
      image = [UIImage imageWithData:data];
    }
    if (nil != image) {
      if (!request.respondedFromCache) {
// XXXjoe Working on option to scale down really large images to a smaller size to save memory
//        if (image.size.width * image.size.height > (300*300)) {
//          image = [image transformWidth:300 height:(image.size.height/image.size.width)*300.0
//                         rotate:NO];
//          NSData* data = UIImagePNGRepresentation(image);
//          [[TTURLCache sharedCache] storeData:data forURL:request.URL];
//        }
        [[TTURLCache sharedCache] storeImage:image forURL:request.urlPath];
      }

      _image = [image retain];

    } else {
      return [NSError errorWithDomain:kTTNetworkErrorDomain
                                 code:kTTNetworkErrorCodeInvalidImage
                             userInfo:nil];
    }
  }

  return nil;
}


@end

