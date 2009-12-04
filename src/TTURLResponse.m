/**
 * Copyright 2009 Facebook
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#import "Three20/TTURLResponse.h"
#import "Three20/TTURLRequest.h"
#import "Three20/TTURLCache.h"

//////////////////////////////////////////////////////////////////////////////////////////////////

@implementation TTURLDataResponse

@synthesize data = _data;

- (id)init {
  if (self = [super init]) {
    _data = nil;
  }
  return self;
}

- (void)dealloc {
  TT_RELEASE_SAFELY(_data);
  [super dealloc];
}

//////////////////////////////////////////////////////////////////////////////////////////////////
// TTURLResponse

- (NSError*)request:(TTURLRequest*)request processResponse:(NSHTTPURLResponse*)response
            data:(id)data {
  if ([data isKindOfClass:[NSData class]]) {
    _data = [data retain];
  }
  return nil;
}

@end

//////////////////////////////////////////////////////////////////////////////////////////////////

@implementation TTURLImageResponse

@synthesize image = _image;

- (id)init {
  if (self = [super init]) {
    _image = nil;
  }
  return self;
}

- (void)dealloc {
  TT_RELEASE_SAFELY(_image);
  [super dealloc];
}

//////////////////////////////////////////////////////////////////////////////////////////////////
// TTURLResponse

- (NSError*)request:(TTURLRequest*)request processResponse:(NSHTTPURLResponse*)response
            data:(id)data {
  if ([data isKindOfClass:[UIImage class]]) {
    _image = [data retain];
  } else if ([data isKindOfClass:[NSData class]]) {
    UIImage* image = [[TTURLCache sharedCache] imageForURL:request.URL fromDisk:NO];
    if (!image) {
      image = [UIImage imageWithData:data];
    }
    if (image) {
      if (!request.respondedFromCache) {
// XXXjoe Working on option to scale down really large images to a smaller size to save memory      
//        if (image.size.width * image.size.height > (300*300)) {
//          image = [image transformWidth:300 height:(image.size.height/image.size.width)*300.0
//                         rotate:NO];
//          NSData* data = UIImagePNGRepresentation(image);
//          [[TTURLCache sharedCache] storeData:data forURL:request.URL];
//        }
        [[TTURLCache sharedCache] storeImage:image forURL:request.URL];
      }
      _image = [image retain];
    } else {
      return [NSError errorWithDomain:TT_ERROR_DOMAIN code:TT_EC_INVALID_IMAGE
                      userInfo:nil];
    }
  }
  return nil;
}

@end

