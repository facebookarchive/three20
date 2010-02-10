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

#import "Three20/TTRequestLoader.h"

#import "Three20/TTURLRequest.h"
#import "Three20/TTURLRequestDelegate.h"
#import "Three20/TTURLRequestQueue.h"
#import "Three20/TTURLResponse.h"

#import "Three20/TTCorePreprocessorMacros.h"
#import "Three20/TTDebug.h"
#import "Three20/TTDebugFlags.h"
#import "Three20/TTGlobalCore.h"

static const NSInteger kLoadMaxRetries = 2;


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation TTRequestLoader

@synthesize URL                 = _URL;
@synthesize requests            = _requests;
@synthesize cacheKey            = _cacheKey;
@synthesize cachePolicy         = _cachePolicy;
@synthesize cacheExpirationAge  = _cacheExpirationAge;


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initForRequest:(TTURLRequest*)request queue:(TTURLRequestQueue*)queue {
  if (self = [super init]) {
    _URL = [request.URL copy];
    _queue = queue;
    _cacheKey = [request.cacheKey retain];
    _cachePolicy = request.cachePolicy;
    _cacheExpirationAge = request.cacheExpirationAge;
    _requests = [[NSMutableArray alloc] init];
    _connection = nil;
    _retriesLeft = kLoadMaxRetries;
    _response = nil;
    _responseData = nil;
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
  TT_RELEASE_SAFELY(_URL);
  TT_RELEASE_SAFELY(_cacheKey);
  TT_RELEASE_SAFELY(_requests); 
  [super dealloc];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)connectToURL:(NSURL*)URL {
  TTDCONDITIONLOG(TTDFLAG_URLREQUEST, @"Connecting to %@", _URL);
  TTNetworkRequestStarted();
  
  TTURLRequest* request = _requests.count == 1 ? [_requests objectAtIndex:0] : nil;
  NSURLRequest *URLRequest = [_queue createNSURLRequest:request URL:URL];
  
  _connection = [[NSURLConnection alloc] initWithRequest:URLRequest delegate:self];
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
//////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark NSURLConnectionDelegate


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)connection:(NSURLConnection*)connection didReceiveResponse:(NSHTTPURLResponse*)response {
  _response = [response retain];
  NSDictionary* headers = [response allHeaderFields];
  int contentLength = [[headers objectForKey:@"Content-Length"] intValue];
  
  TTDASSERT(0 == _queue.maxContentLength || contentLength <=_queue.maxContentLength);
  if (contentLength > _queue.maxContentLength && _queue.maxContentLength) {
    TTDCONDITIONLOG(TTDFLAG_URLREQUEST, @"MAX CONTENT LENGTH EXCEEDED (%d) %@", contentLength, _URL);
    [self cancel];
  }
  
  _responseData = [[NSMutableData alloc] initWithCapacity:contentLength];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)connection:(NSURLConnection*)connection didReceiveData:(NSData*)data {
  [_responseData appendData:data];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSCachedURLResponse *)connection:(NSURLConnection *)connection
                  willCacheResponse:(NSCachedURLResponse *)cachedResponse {
  return nil;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)connection:(NSURLConnection *)connection didSendBodyData:(NSInteger)bytesWritten
 totalBytesWritten:(NSInteger)totalBytesWritten
totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite {
  [self dispatchLoadedBytes:totalBytesWritten expected:totalBytesExpectedToWrite];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
  TTNetworkRequestStopped();
  
  if (_response.statusCode == 200) {
    [_queue performSelector:@selector(loader:didLoadResponse:data:) withObject:self
                 withObject:_response withObject:_responseData];
  } else {
    TTDCONDITIONLOG(TTDFLAG_URLREQUEST, @"  FAILED LOADING (%d) %@", _response.statusCode, _URL);
    NSError* error = [NSError errorWithDomain:NSURLErrorDomain code:_response.statusCode
                                     userInfo:nil];
    [_queue performSelector:@selector(loader:didFailLoadWithError:) withObject:self
                 withObject:error];
  }
  
  TT_RELEASE_SAFELY(_responseData);
  TT_RELEASE_SAFELY(_connection);
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)connection:(NSURLConnection *)connection
didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge{
  TTDCONDITIONLOG(TTDFLAG_URLREQUEST, @"  RECEIVED AUTH CHALLENGE LOADING %@ ", _URL);
  [_queue performSelector: @selector(loader:didReceiveAuthenticationChallenge:)
               withObject: self
               withObject: challenge];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {  
  TTDCONDITIONLOG(TTDFLAG_URLREQUEST, @"  FAILED LOADING %@ FOR %@", _URL, error);
  
  TTNetworkRequestStopped();
  
  TT_RELEASE_SAFELY(_responseData);
  TT_RELEASE_SAFELY(_connection);
  
  if ([error.domain isEqualToString:NSURLErrorDomain] && error.code == NSURLErrorCannotFindHost
      && _retriesLeft) {
    // If there is a network error then we will wait and retry a few times just in case
    // it was just a temporary blip in connectivity
    --_retriesLeft;
    [self load:[NSURL URLWithString:_URL]];
  } else {
    [_queue performSelector:@selector(loader:didFailLoadWithError:) withObject:self
                 withObject:error];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)isLoading {
  return !!_connection;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)addRequest:(TTURLRequest*)request {
  [_requests addObject:request];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)removeRequest:(TTURLRequest*)request {
  [_requests removeObject:request];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)load:(NSURL*)URL {
  if (!_connection) {
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
    
    [_queue performSelector:@selector(loader:didFailLoadWithError:) withObject:self
                 withObject:error];
  } else {
    [self connection:nil didReceiveResponse:(NSHTTPURLResponse*)response];
    [self connection:nil didReceiveData:data];
    
    [self connectionDidFinishLoading:nil];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)cancel:(TTURLRequest*)request {
  NSUInteger index = [_requests indexOfObject:request];
  if (index != NSNotFound) {
    request.isLoading = NO;
    
    for (id<TTURLRequestDelegate> delegate in request.delegates) {
      if ([delegate respondsToSelector:@selector(requestDidCancelLoad:)]) {
        [delegate requestDidCancelLoad:request];
      }
    }
    
    [_requests removeObjectAtIndex:index];
  }
  if (![_requests count]) {
    [_queue performSelector:@selector(loaderDidCancel:wasLoading:) withObject:self
                 withObject:(id)!!_connection];
    if (_connection) {
      TTNetworkRequestStopped();
      [_connection cancel];
      TT_RELEASE_SAFELY(_connection);
    }
    return NO;
  } else {
    return YES;
  }
}

@end
