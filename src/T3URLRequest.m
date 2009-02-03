#import "Three20/T3URLRequest.h"
#import "Three20/T3URLCache.h"

//////////////////////////////////////////////////////////////////////////////////////////////////

@implementation T3URLRequest

@synthesize url, delegate, minTime, convertMedia;

+ (T3URLRequest*)requestWithURL:(NSString*)url delegate:(id<T3URLRequestDelegate>)aDelegate {
  return [[[T3URLRequest alloc] initWithURL:url delegate:aDelegate] autorelease];
}

- (id)initWithURL:(NSString*)aURL delegate:(id<T3URLRequestDelegate>)aDelegate {
  if (self = [super init]) {
    url = [aURL retain];
    delegate = aDelegate;
    convertMedia = NO;
    minTime = T3_DEFAULT_CACHE_AGE;
  }
  return self;
}

- (void)dealloc {
  [url release];
  [super dealloc];
}

- (BOOL)send {
  return [[T3URLCache sharedCache] sendRequest:self];
}

- (void)cancel {
  [[T3URLCache sharedCache] cancelRequest:self];
}

@end

