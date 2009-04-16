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
  [_data release];
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
  [_image release];
  [super dealloc];
}

//////////////////////////////////////////////////////////////////////////////////////////////////
// TTURLResponse

- (NSError*)request:(TTURLRequest*)request processResponse:(NSHTTPURLResponse*)response
            data:(id)data {
  if ([data isKindOfClass:[UIImage class]]) {
    _image = [data retain];
  } else if ([data isKindOfClass:[NSData class]]) {
    UIImage* image = [[TTURLCache sharedCache] imageForURL:request.url fromDisk:NO];
    if (!image) {
      TTLOG(@"CREATE IMAGE FOR %@", request.url);
      image = [UIImage imageWithData:data];
    }
    if (image) {
      if (!request.respondedFromCache) {
//        if (image.size.width * image.size.height > (300*300)) {
//          image = [image transformWidth:300 height:(image.size.height/image.size.width)*300.0
//                         rotate:NO];
//          NSData* data = UIImagePNGRepresentation(image);
//          [[TTURLCache sharedCache] storeData:data forURL:request.url];
//        }
        [[TTURLCache sharedCache] storeImage:image forURL:request.url];
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

