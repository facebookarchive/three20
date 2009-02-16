#import "Three20/TTURLRequest.h"
#import "Three20/TTURLRequestQueue.h"
#import <CommonCrypto/CommonDigest.h>

//////////////////////////////////////////////////////////////////////////////////////////////////

static NSString* kStringBoundary = @"3i2ndDfv2rTHiSisAbouNdArYfORhtTPEefj3q2f";

//////////////////////////////////////////////////////////////////////////////////////////////////

@implementation TTURLRequest

@synthesize delegate = _delegate, handler = _handler, handlerDelegate = _handlerDelegate,
  url = _url, httpMethod = _httpMethod, httpBody = _httpBody, params = _params,
  contentType = _contentType, cachePolicy = _cachePolicy, cacheExpirationAge = _cacheExpirationAge,
  cacheKey = _cacheKey, timestamp = _timestamp, loading = _loading,
  shouldHandleCookies = _shouldHandleCookies, shouldConvertToMedia = _shouldConvertToMedia,
  responseFromCache = _responseFromCache;

+ (TTURLRequest*)request {
  return [[[TTURLRequest alloc] init] autorelease];
}

+ (TTURLRequest*)requestWithURL:(NSString*)url delegate:(id<TTURLRequestDelegate>)delegate {
  return [[[TTURLRequest alloc] initWithURL:url delegate:delegate] autorelease];
}

- (id)initWithURL:(NSString*)url delegate:(id<TTURLRequestDelegate>)delegate {
  if (self = [self init]) {
    _url = [url retain];
    _delegate = delegate;
  }
  return self;
}

- (id)init {
  if (self = [super init]) {
    _url = nil;
    _httpMethod = nil;
    _httpBody = nil;
    _params = nil;
    _contentType = nil;
    _delegate = nil;
    _handler = nil;
    _handlerDelegate = nil;
    _cachePolicy = TTURLRequestCachePolicyAny;
    _shouldConvertToMedia = NO;
    _cacheExpirationAge = 0;
    _loading = NO;
    _shouldHandleCookies = YES;
    _shouldConvertToMedia = NO;
    _responseFromCache = NO;
  }
  return self;
}

- (void)dealloc {
  [_url release];
  [_httpMethod release];
  [_httpBody release];
  [_params release];
  [_contentType release];
  [_handler release];
  [super dealloc];
}

- (NSString*)description {
  return [NSString stringWithFormat:@"<TTURLRequest %@>", _url];
}

//////////////////////////////////////////////////////////////////////////////////////////////////

- (NSString *)md5HexDigest:(NSString*)input {
  const char* str = [input UTF8String];
  unsigned char result[CC_MD5_DIGEST_LENGTH];
  CC_MD5(str, strlen(str), result);

  return [NSString stringWithFormat:
    @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
    result[0], result[1], result[2], result[3], result[4], result[5], result[6], result[7],
    result[8], result[9], result[10], result[11], result[12], result[13], result[14], result[15]
  ];
}

- (NSString*)generateCacheKey {
  if ([_httpMethod isEqualToString:@"POST"]) {
    NSMutableString* joined = [[[NSMutableString alloc] initWithString:self.url] autorelease]; 
    NSEnumerator* e = [_params keyEnumerator];
    for (id key; key = [e nextObject]; ) {
      [joined appendString:key];
      [joined appendString:@"="];
      NSObject* value = [_params valueForKey:key];
      if ([value isKindOfClass:[NSString class]]) {
        [joined appendString:(NSString*)value];
      }
    }

    return [self md5HexDigest:joined];
  } else {
    return [self md5HexDigest:self.url];
  }
}

- (NSData*)generatePostBody {
  NSMutableData *body = [NSMutableData data];
  NSString *endLine = [NSString stringWithFormat:@"\r\n--%@\r\n", kStringBoundary];

  [body appendData:[[NSString stringWithFormat:@"--%@\r\n", kStringBoundary]
    dataUsingEncoding:NSUTF8StringEncoding]];
  
  for (id key in [_params keyEnumerator]) {
    if (![[_params objectForKey:key] isKindOfClass:[UIImage class]]) {
      [body appendData:[[NSString
        stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", key]
          dataUsingEncoding:NSUTF8StringEncoding]];
      [body appendData:[[_params valueForKey:key] dataUsingEncoding:NSUTF8StringEncoding]];
      [body appendData:[endLine dataUsingEncoding:NSUTF8StringEncoding]];        
    }
  }

  [body appendData:[endLine dataUsingEncoding:NSUTF8StringEncoding]];
  
  //TTLOG(@"Sending %s", [body bytes]);
  return body;
}

//////////////////////////////////////////////////////////////////////////////////////////////////

- (NSData*)httpBody {
  if (_httpBody) {
    return _httpBody;
  } else if ([_httpMethod isEqualToString:@"POST"]) {
    return [self generatePostBody];
  } else {
    return nil;
  }
}

- (NSString*)contentType {
  if (_contentType) {
    return _contentType;
  } else if ([_httpMethod isEqualToString:@"POST"]) {
    return [NSString stringWithFormat:@"multipart/form-data; boundary=%@", kStringBoundary];
  } else {
    return nil;
  }
}

- (NSString*)cacheKey {
  if (!_cacheKey) {
    _cacheKey = [[self generateCacheKey] retain];
  }
  return _cacheKey;
}

- (BOOL)send {
  return [[TTURLRequestQueue mainQueue] sendRequest:self];
}

- (void)cancel {
  [[TTURLRequestQueue mainQueue] cancelRequest:self];
}

@end

