#import "Three20/TTURLRequest.h"
#import "Three20/TTURLResponse.h"
#import "Three20/TTURLRequestQueue.h"
#import <CommonCrypto/CommonDigest.h>

//////////////////////////////////////////////////////////////////////////////////////////////////

static NSString* kStringBoundary = @"3i2ndDfv2rTHiSisAbouNdArYfORhtTPEefj3q2f";

//////////////////////////////////////////////////////////////////////////////////////////////////

@implementation TTURLRequest

@synthesize delegates = _delegates, URL = _URL, response = _response, httpMethod = _httpMethod,
  httpBody = _httpBody, parameters = _parameters, contentType = _contentType,
  cachePolicy = _cachePolicy, cacheExpirationAge = _cacheExpirationAge, cacheKey = _cacheKey,
  timestamp = _timestamp, userInfo = _userInfo, isLoading = _isLoading,
  shouldHandleCookies = _shouldHandleCookies, totalBytesLoaded = _totalBytesLoaded,
  totalBytesExpected = _totalBytesExpected, respondedFromCache = _respondedFromCache,
  headers = _headers;

+ (TTURLRequest*)request {
  return [[[TTURLRequest alloc] init] autorelease];
}

+ (TTURLRequest*)requestWithURL:(NSString*)URL delegate:(id<TTURLRequestDelegate>)delegate {
  return [[[TTURLRequest alloc] initWithURL:URL delegate:delegate] autorelease];
}

- (id)initWithURL:(NSString*)URL delegate:(id<TTURLRequestDelegate>)delegate {
  if (self = [self init]) {
    _URL = [URL retain];
    if (delegate) {
      [_delegates addObject:delegate];
    }
  }
  return self;
}

- (id)init {
  if (self = [super init]) {
    _URL = nil;
    _httpMethod = nil;
    _httpBody = nil;
    _headers = nil;
    _parameters = nil;
    _contentType = nil;
    _delegates = TTCreateNonRetainingArray();
    _files = nil;
    _response = nil;
    _cachePolicy = TTURLRequestCachePolicyDefault;
    _cacheExpirationAge = 0;
    _timestamp = nil;
    _cacheKey = nil;
    _userInfo = nil;
    _isLoading = NO;
    _shouldHandleCookies = YES;
    _totalBytesLoaded = 0;
    _totalBytesExpected = 0;
    _respondedFromCache = NO;
  }
  return self;
}

- (void)dealloc {
  TT_RELEASE_SAFELY(_URL);
  TT_RELEASE_SAFELY(_httpMethod);
  TT_RELEASE_SAFELY(_httpBody);
  TT_RELEASE_SAFELY(_headers);
  TT_RELEASE_SAFELY(_parameters);
  TT_RELEASE_SAFELY(_contentType);
  TT_RELEASE_SAFELY(_delegates);
  TT_RELEASE_SAFELY(_files);
  TT_RELEASE_SAFELY(_response);
  TT_RELEASE_SAFELY(_timestamp);
  TT_RELEASE_SAFELY(_cacheKey);
  TT_RELEASE_SAFELY(_userInfo);
  [super dealloc];
}

- (NSString*)description {
  return [NSString stringWithFormat:@"<TTURLRequest %@>", _URL];
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
    NSMutableString* joined = [[[NSMutableString alloc] initWithString:self.URL] autorelease]; 
    NSEnumerator* e = [_parameters keyEnumerator];
    for (id key; key = [e nextObject]; ) {
      [joined appendString:key];
      [joined appendString:@"="];
      NSObject* value = [_parameters valueForKey:key];
      if ([value isKindOfClass:[NSString class]]) {
        [joined appendString:(NSString*)value];
      }
    }

    return [self md5HexDigest:joined];
  } else {
    return [self md5HexDigest:self.URL];
  }
}

- (NSData*)generatePostBody {
  NSMutableData *body = [NSMutableData data];
  NSString *beginLine = [NSString stringWithFormat:@"\r\n--%@\r\n", kStringBoundary];

  [body appendData:[[NSString stringWithFormat:@"--%@\r\n", kStringBoundary]
    dataUsingEncoding:NSUTF8StringEncoding]];
  
  for (id key in [_parameters keyEnumerator]) {
    NSString* value = [_parameters valueForKey:key];
    if (![value isKindOfClass:[UIImage class]]) {
      [body appendData:[beginLine dataUsingEncoding:NSUTF8StringEncoding]];        
      [body appendData:[[NSString
        stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", key]
          dataUsingEncoding:NSUTF8StringEncoding]];
      [body appendData:[value dataUsingEncoding:NSUTF8StringEncoding]];
    }
  }

  NSString* imageKey = nil;
  for (id key in [_parameters keyEnumerator]) {
    if ([[_parameters objectForKey:key] isKindOfClass:[UIImage class]]) {
      UIImage* image = [_parameters objectForKey:key];
      CGFloat quality = [TTURLRequestQueue mainQueue].imageCompressionQuality;
      NSData* data = UIImageJPEGRepresentation(image, quality);
      
      [body appendData:[beginLine dataUsingEncoding:NSUTF8StringEncoding]];
      [body appendData:[[NSString stringWithFormat:
                       @"Content-Disposition: form-data; name=\"%@\"; filename=\"image.jpg\"\r\n",
                       key]
          dataUsingEncoding:NSUTF8StringEncoding]];
      [body appendData:[[NSString
        stringWithFormat:@"Content-Length: %d\r\n", data.length]
          dataUsingEncoding:NSUTF8StringEncoding]];  
      [body appendData:[[NSString
        stringWithString:@"Content-Type: image/jpeg\r\n\r\n"]
          dataUsingEncoding:NSUTF8StringEncoding]];  
      [body appendData:data];
      imageKey = key;
    }
  }
  
  for (NSInteger i = 0; i < _files.count; i += 3) {
    NSData* data = [_files objectAtIndex:i];
    NSString* mimeType = [_files objectAtIndex:i+1];
    NSString* fileName = [_files objectAtIndex:i+2];
      
    [body appendData:[beginLine dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:
                       @"Content-Disposition: form-data; name=\"%@\"; filename=\"%@\"\r\n",
                       fileName, fileName]
          dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"Content-Length: %d\r\n", data.length]
          dataUsingEncoding:NSUTF8StringEncoding]];  
    [body appendData:[[NSString stringWithFormat:@"Content-Type: %@\r\n\r\n", mimeType]
          dataUsingEncoding:NSUTF8StringEncoding]];  
    [body appendData:data];
  }

  [body appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n", kStringBoundary]
                   dataUsingEncoding:NSUTF8StringEncoding]];

  // If an image was found, remove it from the dictionary to save memory while we
  // perform the upload
  if (imageKey) {
    [_parameters removeObjectForKey:imageKey];
  }

  //TTLOG(@"Sending %s", [body bytes]);
  return body;
}

//////////////////////////////////////////////////////////////////////////////////////////////////

- (NSMutableDictionary*)parameters {
  if (!_parameters) {
    _parameters = [[NSMutableDictionary alloc] init];
  }
  return _parameters;
}

- (NSData*)httpBody {
  if (_httpBody) {
    return _httpBody;
  } else if ([[_httpMethod uppercaseString] isEqualToString:@"POST"]) {
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

- (void)setValue:(NSString *)value forHTTPHeaderField:(NSString *)field {
  if (!_headers) {
    _headers = [[NSMutableDictionary alloc] init];
  }
  [_headers setObject:value forKey:field];
}

- (void)addFile:(NSData*)data mimeType:(NSString*)mimeType fileName:(NSString*)fileName {
  if (!_files) {
    _files = [[NSMutableArray alloc] init];
  }
  
  [_files addObject:data];
  [_files addObject:mimeType];
  [_files addObject:fileName];
}

- (BOOL)send {
  if (_parameters) {
    TTLOG(@"SEND %@ %@", self.URL, self.parameters);
  }
  return [[TTURLRequestQueue mainQueue] sendRequest:self];
}

- (void)cancel {
  [[TTURLRequestQueue mainQueue] cancelRequest:self];
}

- (NSURLRequest*)createNSURLRequest {
  return [[TTURLRequestQueue mainQueue] createNSURLRequest:self URL:nil];
}

@end

//////////////////////////////////////////////////////////////////////////////////////////////////

@implementation TTUserInfo

@synthesize topic = _topic, strong = _strong, weak = _weak;

//////////////////////////////////////////////////////////////////////////////////////////////////
// class public

+ (id)topic:(NSString*)topic strong:(id)strong weak:(id)weak {
  return [[[TTUserInfo alloc] initWithTopic:topic strong:strong weak:weak] autorelease];
}

+ (id)topic:(NSString*)topic {
  return [[[TTUserInfo alloc] initWithTopic:topic strong:nil weak:nil] autorelease];
}

+ (id)weak:(id)weak {
  return [[[TTUserInfo alloc] initWithTopic:nil strong:nil weak:weak] autorelease];
}

//////////////////////////////////////////////////////////////////////////////////////////////////
// NSObject

- (id)initWithTopic:(NSString*)topic strong:(id)strong weak:(id)weak {
  if (self = [super init]) {
    self.topic = topic;
    self.strong = strong;
    self.weak = weak;
  }
  return self;
}

- (void)dealloc {
  TT_RELEASE_SAFELY(_topic);
  TT_RELEASE_SAFELY(_strong);
  [super dealloc];
}

@end
