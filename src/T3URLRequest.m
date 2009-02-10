#import "Three20/T3URLRequest.h"
#import "Three20/T3URLCache.h"

//////////////////////////////////////////////////////////////////////////////////////////////////

@implementation T3URLRequest

@synthesize delegate = _delegate, handler = _handler, handlerDelegate = _handlerDelegate,
  url = _url, httpMethod = _httpMethod, httpBody = _httpBody, contentType = _contentType,
  cachePolicy = _cachePolicy, cacheExpirationAge = _cacheExpirationAge, cacheKey = _cacheKey,
  timestamp = _timestamp, loading = _loading, canBeDelayed = _canBeDelayed, 
  shouldHandleCookies = _shouldHandleCookies, shouldConvertToMedia = _shouldConvertToMedia,
  responseFromCache = _responseFromCache;

+ (T3URLRequest*)requestWithURL:(NSString*)url delegate:(id<T3URLRequestDelegate>)delegate {
  return [[[T3URLRequest alloc] initWithURL:url delegate:delegate] autorelease];
}

- (id)initWithURL:(NSString*)url delegate:(id<T3URLRequestDelegate>)delegate {
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
    _contentType = nil;
    _delegate = nil;
    _handler = nil;
    _handlerDelegate = nil;
    _cachePolicy = T3URLRequestCachePolicyAny;
    _shouldConvertToMedia = NO;
    _cacheExpirationAge = 0;
    _loading = NO;
    _shouldHandleCookies = YES;
    _canBeDelayed = YES;
    _shouldConvertToMedia = NO;
    _responseFromCache = NO;
  }
  return self;
}

- (void)dealloc {
  [_url release];
  [_httpMethod release];
  [_httpBody release];
  [_contentType release];
  [_handler release];
  [super dealloc];
}

- (NSString*)description {
  return [NSString stringWithFormat:@"<T3URLRequest %@>", _url];
}

//////////////////////////////////////////////////////////////////////////////////////////////////

- (BOOL)send {
  return [[T3URLCache sharedCache] sendRequest:self];
}

- (void)cancel {
  [[T3URLCache sharedCache] cancelRequest:self];
}

@end

