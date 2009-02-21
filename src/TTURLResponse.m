#import "Three20/TTURLResponse.h"
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
    data:(NSData*)data {
  _data = [data retain];
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
    data:(NSData*)data {
  UIImage* image = [UIImage imageWithData:data];
  if (image) {
    if (!request.respondedFromCache) {
      [[TTURLCache sharedCache] storeImage:image forKey:request.cacheKey];
    }
    _image = [image retain];
    return nil;
  } else {
    return [NSError errorWithDomain:TT_ERROR_DOMAIN code:TT_EC_INVALID_IMAGE
      userInfo:nil];
  }
}

@end

