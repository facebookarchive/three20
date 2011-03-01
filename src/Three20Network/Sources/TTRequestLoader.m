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

#import "Three20Network/private/TTRequestLoader.h"

// Network
#import "Three20Network/TTGlobalNetwork.h"
#import "Three20Network/TTURLRequest.h"
#import "Three20Network/TTURLRequestDelegate.h"
#import "Three20Network/TTURLRequestQueue.h"
#import "Three20Network/TTURLResponse.h"

// Network (private)
#import "Three20Network/private/TTURLRequestQueueInternal.h"

// Core
#import "Three20Core/NSObjectAdditions.h"
#import "Three20Core/TTDebug.h"
#import "Three20Core/TTDebugFlags.h"

static const NSInteger kLoadMaxRetries = 2;


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation TTRequestLoader

@synthesize urlPath             = _urlPath;
@synthesize requests            = _requests;
@synthesize cacheKey            = _cacheKey;
@synthesize cachePolicy         = _cachePolicy;
@synthesize cacheExpirationAge  = _cacheExpirationAge;


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initForRequest:(TTURLRequest*)request queue:(TTURLRequestQueue*)queue {
  if (self = [super init]) {
    _urlPath            = [request.urlPath copy];
    _queue              = queue;
    _cacheKey           = [request.cacheKey retain];
    _cachePolicy        = request.cachePolicy;
    _cacheExpirationAge = request.cacheExpirationAge;
    _requests           = [[NSMutableArray alloc] init];
    _retriesLeft        = kLoadMaxRetries;

    [self addRequest:request];
  }
  return self;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)dealloc {
  [_connection cancel];
  TT_RELEASE_SAFELY(_connection);
  TT_RELEASE_SAFELY(_response);
  TT_RELEASE_SAFELY(_responseData);
  TT_RELEASE_SAFELY(_urlPath);
  TT_RELEASE_SAFELY(_cacheKey);
  TT_RELEASE_SAFELY(_requests);
  [super dealloc];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Private


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)connectToURL:(NSURL*)URL {
  TTDCONDITIONLOG(TTDFLAG_URLREQUEST, @"Connecting to %@", _urlPath);
  TTNetworkRequestStarted();

  TTURLRequest* request = _requests.count == 1 ? [_requests objectAtIndex:0] : nil;
  NSURLRequest* URLRequest = [_queue createNSURLRequest:request URL:URL];

  _connection = [[NSURLConnection alloc] initWithRequest:URLRequest delegate:self];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)dispatchLoadedBytes:(NSInteger)bytesLoaded expected:(NSInteger)bytesExpected {
  for (TTURLRequest* request in [[_requests copy] autorelease]) {
    request.totalBytesLoaded = bytesLoaded;
    request.totalBytesExpected = bytesExpected;

    for (id<TTURLRequestDelegate> delegate in request.delegates) {
      if ([delegate respondsToSelector:@selector(requestDidUploadData:)]) {
        [delegate requestDidUploadData:request];
      }
    }
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Public


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)addRequest:(TTURLRequest*)request {
  // TODO (jverkoey April 27, 2010): Look into the repercussions of adding a request with
  // different properties.
  //TTDASSERT([_urlPath isEqualToString:request.urlPath]);
  //TTDASSERT(_cacheKey == request.cacheKey);
  //TTDASSERT(_cachePolicy == request.cachePolicy);
  //TTDASSERT(_cacheExpirationAge == request.cacheExpirationAge);

  [_requests addObject:request];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)removeRequest:(TTURLRequest*)request {
  [_requests removeObject:request];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)load:(NSURL*)URL {
  if (nil == _connection) {
    [self connectToURL:URL];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)loadSynchronously:(NSURL*)URL {
  // This method simulates an asynchronous network connection. If your delegate isn't being called
  // correctly, this would be the place to start tracing for errors.
  TTNetworkRequestStarted();

  TTURLRequest* request = _requests.count == 1 ? [_requests objectAtIndex:0] : nil;
  NSURLRequest* URLRequest = [_queue createNSURLRequest:request URL:URL];

  NSHTTPURLResponse* response = nil;
  NSError* error = nil;
  NSData* data = [NSURLConnection
                  sendSynchronousRequest: URLRequest
                  returningResponse: &response
                  error: &error];

  if (nil != error) {
    TTNetworkRequestStopped();

    TT_RELEASE_SAFELY(_responseData);
    TT_RELEASE_SAFELY(_connection);

    [_queue loader:self didFailLoadWithError:error];

  } else {
    [self connection:nil didReceiveResponse:(NSHTTPURLResponse*)response];
    [self connection:nil didReceiveData:data];

    [self connectionDidFinishLoading:nil];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)cancel:(TTURLRequest*)request {
  NSUInteger requestIndex = [_requests indexOfObject:request];
  if (requestIndex != NSNotFound) {
    request.isLoading = NO;

    for (id<TTURLRequestDelegate> delegate in request.delegates) {
      if ([delegate respondsToSelector:@selector(requestDidCancelLoad:)]) {
        [delegate requestDidCancelLoad:request];
      }
    }

    [_requests removeObjectAtIndex:requestIndex];
  }

  if (![_requests count]) {
    [_queue loaderDidCancel:self wasLoading:!!_connection];
    if (nil != _connection) {
      TTNetworkRequestStopped();
      [_connection cancel];
      TT_RELEASE_SAFELY(_connection);
    }
    return NO;

  } else {
    return YES;
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSError*)processResponse:(NSHTTPURLResponse*)response data:(id)data {
  for (TTURLRequest* request in _requests) {
    NSError* error = [request.response request:request processResponse:response data:data];
    if (error) {
      return error;
    }
  }
  return nil;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)dispatchError:(NSError*)error {
  for (TTURLRequest* request in [[_requests copy] autorelease]) {
    request.isLoading = NO;

    for (id<TTURLRequestDelegate> delegate in request.delegates) {
      if ([delegate respondsToSelector:@selector(request:didFailLoadWithError:)]) {
        [delegate request:request didFailLoadWithError:error];
      }
    }
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)dispatchLoaded:(NSDate*)timestamp {
  for (TTURLRequest* request in [[_requests copy] autorelease]) {
    request.timestamp = timestamp;
    request.isLoading = NO;

    for (id<TTURLRequestDelegate> delegate in request.delegates) {
      if ([delegate respondsToSelector:@selector(requestDidFinishLoad:)]) {
        [delegate requestDidFinishLoad:request];
      }
    }
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)dispatchAuthenticationChallenge:(NSURLAuthenticationChallenge*)challenge {
  for (TTURLRequest* request in [[_requests copy] autorelease]) {

    for (id<TTURLRequestDelegate> delegate in request.delegates) {
      if ([delegate respondsToSelector:@selector(request:didReceiveAuthenticationChallenge:)]) {
        [delegate request:request didReceiveAuthenticationChallenge:challenge];
      }
    }
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)cancel {
  NSArray* requestsToCancel = [_requests copy];
  for (id request in requestsToCancel) {
    [self cancel:request];
  }
  [requestsToCancel release];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark NSURLConnectionDelegate


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)connection:(NSURLConnection*)connection didReceiveResponse:(NSHTTPURLResponse*)response {
  _response = [response retain];
  NSDictionary* headers = [response allHeaderFields];
  int contentLength = [[headers objectForKey:@"Content-Length"] intValue];

  // If you hit this assertion it's because a massive file is about to be downloaded.
  // If you're sure you want to do this, add the following line to your app delegate startup
  // method. Setting the max content length to zero allows anything to go through. If you just
  // want to raise the limit, set it to any positive byte size.
  // [[TTURLRequestQueue mainQueue] setMaxContentLength:0]
  TTDASSERT(0 == _queue.maxContentLength || contentLength <=_queue.maxContentLength);

  if (contentLength > _queue.maxContentLength && _queue.maxContentLength) {
    TTDCONDITIONLOG(TTDFLAG_URLREQUEST, @"MAX CONTENT LENGTH EXCEEDED (%d) %@",
                    contentLength, _urlPath);
    [self cancel];
  }

  _responseData = [[NSMutableData alloc] initWithCapacity:contentLength];

    for (TTURLRequest* request in [[_requests copy] autorelease]) {
        request.totalContentLength = contentLength;
    }

}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)connection:(NSURLConnection*)connection didReceiveData:(NSData*)data {
  [_responseData appendData:data];
    for (TTURLRequest* request in [[_requests copy] autorelease]) {
        request.totalBytesDownloaded += [data length];
    }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSCachedURLResponse *)connection: (NSURLConnection *)connection
                  willCacheResponse: (NSCachedURLResponse *)cachedResponse {
  return nil;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)           connection: (NSURLConnection *)connection
              didSendBodyData: (NSInteger)bytesWritten
            totalBytesWritten: (NSInteger)totalBytesWritten
    totalBytesExpectedToWrite: (NSInteger)totalBytesExpectedToWrite {
  [self dispatchLoadedBytes:totalBytesWritten expected:totalBytesExpectedToWrite];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
  TTNetworkRequestStopped();

  TTDCONDITIONLOG(TTDFLAG_ETAGS, @"Response status code: %d", _response.statusCode);

  // We need to accept valid HTTP status codes, not only 200.
  if (_response.statusCode >= 200 && _response.statusCode < 300) {
    [_queue loader:self didLoadResponse:_response data:_responseData];

  } else if (_response.statusCode == 304) {
    [_queue loader:self didLoadUnmodifiedResponse:_response];

  } else {
    TTDCONDITIONLOG(TTDFLAG_URLREQUEST, @"  FAILED LOADING (%d) %@",
                    _response.statusCode, _urlPath);
    NSError* error = [NSError errorWithDomain:NSURLErrorDomain code:_response.statusCode
                                     userInfo:nil];
    [_queue loader:self didFailLoadWithError:error];
  }

  TT_RELEASE_SAFELY(_responseData);
  TT_RELEASE_SAFELY(_connection);
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)connection:(NSURLConnection *)connection
didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge{
  TTDCONDITIONLOG(TTDFLAG_URLREQUEST, @"  RECEIVED AUTH CHALLENGE LOADING %@ ", _urlPath);
  [_queue loader:self didReceiveAuthenticationChallenge:challenge];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
  TTDCONDITIONLOG(TTDFLAG_URLREQUEST, @"  FAILED LOADING %@ FOR %@", _urlPath, error);

  TTNetworkRequestStopped();

  TT_RELEASE_SAFELY(_responseData);
  TT_RELEASE_SAFELY(_connection);

  if ([error.domain isEqualToString:NSURLErrorDomain] && error.code == NSURLErrorCannotFindHost
      && _retriesLeft) {
    // If there is a network error then we will wait and retry a few times in case
    // it was just a temporary blip in connectivity.
    --_retriesLeft;
    [self load:[NSURL URLWithString:_urlPath]];

  } else {
    [_queue loader:self didFailLoadWithError:error];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Accessors


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)isLoading {
  return !!_connection;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
/**
 * Deprecated
 */
- (NSString*)URL {
  return _urlPath;
}


@end
