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

#import "Three20Network/TTURLRequest.h"


// Network
#import "Three20Network/TTGlobalNetwork.h"
#import "Three20Network/TTURLResponse.h"
#import "Three20Network/TTURLRequestQueue.h"

// Core
#import "Three20Core/TTGlobalCore.h"
#import "Three20Core/TTDebug.h"
#import "Three20Core/TTDebugFlags.h"
#import "Three20Core/NSStringAdditions.h"

static NSString* kStringBoundary = @"3i2ndDfv2rTHiSisAbouNdArYfORhtTPEefj3q2f";
const NSTimeInterval TTURLRequestUseDefaultTimeout = -1.0;

///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation TTURLRequest

@synthesize urlPath     = _urlPath;
@synthesize httpMethod  = _httpMethod;
@synthesize httpBody    = _httpBody;
@synthesize parameters  = _parameters;
@synthesize headers     = _headers;

@synthesize contentType           = _contentType;
@synthesize charsetForMultipart   = _charsetForMultipart;

@synthesize response              = _response;

@synthesize cachePolicy           = _cachePolicy;
@synthesize cacheExpirationAge    = _cacheExpirationAge;
@synthesize cacheKey              = _cacheKey;

@synthesize timestamp             = _timestamp;

@synthesize totalBytesLoaded      = _totalBytesLoaded;
@synthesize totalBytesExpected    = _totalBytesExpected;

@synthesize totalBytesDownloaded  = _totalBytesDownloaded;
@synthesize totalContentLength    = _totalContentLength;

@synthesize timeoutInterval       = _timeoutInterval;

@synthesize userInfo              = _userInfo;
@synthesize isLoading             = _isLoading;

@synthesize shouldHandleCookies   = _shouldHandleCookies;
@synthesize respondedFromCache    = _respondedFromCache;
@synthesize filterPasswordLogging = _filterPasswordLogging;
@synthesize multiPartForm         = _multiPartForm;

@synthesize delegates             = _delegates;


///////////////////////////////////////////////////////////////////////////////////////////////////
+ (TTURLRequest*)request {
  return [[[self alloc] init] autorelease];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
+ (TTURLRequest*)requestWithURL:(NSString*)URL delegate:(id /*<TTURLRequestDelegate>*/)delegate {
  return [[[self alloc] initWithURL:URL delegate:delegate] autorelease];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithURL:(NSString*)URL delegate:(id /*<TTURLRequestDelegate>*/)delegate {
	self = [self init];
  if (self) {
    _urlPath = [URL retain];
    if (nil != delegate) {
      [_delegates addObject:delegate];
    }
  }
  return self;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)init {
	self = [super init];
  if (self) {
    _delegates = TTCreateNonRetainingArray();
    _cachePolicy = TTURLRequestCachePolicyDefault;
    _cacheExpirationAge = TT_DEFAULT_CACHE_EXPIRATION_AGE;
    _shouldHandleCookies = YES;
    _charsetForMultipart = NSUTF8StringEncoding;
    _multiPartForm = YES;
    _timeoutInterval = TTURLRequestUseDefaultTimeout;
  }
  return self;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)dealloc {
  TT_RELEASE_SAFELY(_urlPath);
  TT_RELEASE_SAFELY(_httpMethod);
  TT_RELEASE_SAFELY(_response);
  TT_RELEASE_SAFELY(_httpBody);
  TT_RELEASE_SAFELY(_contentType);
  TT_RELEASE_SAFELY(_parameters);
  TT_RELEASE_SAFELY(_headers);
  TT_RELEASE_SAFELY(_cacheKey);
  TT_RELEASE_SAFELY(_userInfo);
  TT_RELEASE_SAFELY(_timestamp);
  TT_RELEASE_SAFELY(_files);
  TT_RELEASE_SAFELY(_delegates);

  [super dealloc];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSString*)description {
  return [NSString stringWithFormat:@"<%@ %@>", [super description], _urlPath];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSString*)generateCacheKey {
  if ([_httpMethod isEqualToString:@"POST"]
      || [_httpMethod isEqualToString:@"PUT"]) {
    NSMutableString* joined = [[[NSMutableString alloc] initWithString:self.urlPath] autorelease];
    NSEnumerator* e = [_parameters keyEnumerator];
    for (id key; key = [e nextObject]; ) {
      [joined appendString:key];
      [joined appendString:@"="];
      NSObject* value = [_parameters valueForKey:key];
      if ([value isKindOfClass:[NSString class]]) {
        [joined appendString:(NSString*)value];
      }
    }

    return [joined md5Hash];

  } else {
    return [self.urlPath md5Hash];
  }
}

//////////////////////////////////////////////////////////////////////////////////////////////////
- (NSData *)generateNonMultipartPostBody {
  NSMutableArray *paramsArray = [NSMutableArray array];
  for (id key in [_parameters keyEnumerator]) {
    NSString *value = [_parameters valueForKey:key];
    if ([key isKindOfClass:[NSString class]] && [value isKindOfClass:[NSString class]]) {
      [paramsArray addObject:[NSString stringWithFormat:@"%@=%@", 
                              key, 
                              [[value stringByReplacingOccurrencesOfString:@" " withString:@"+"] urlEncoded]]];
    }
  }
  NSString *stringBody = [paramsArray componentsJoinedByString:@"&"];
  return [stringBody dataUsingEncoding:NSUTF8StringEncoding];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)appendImageData:(NSData*)data
               withName:(NSString*)name
                 toBody:(NSMutableData*)body {
  NSString *beginLine = [NSString stringWithFormat:@"--%@\r\n", kStringBoundary];
	NSString *endLine = @"\r\n";

  [body appendData:[beginLine dataUsingEncoding:NSUTF8StringEncoding]];
  [body appendData:[[NSString stringWithFormat:
                     @"Content-Disposition: form-data; name=\"%@\"; filename=\"image.jpg\"\r\n",
                     name]
                     dataUsingEncoding:_charsetForMultipart]];
  [body appendData:[[NSString
                      stringWithFormat:@"Content-Length: %d\r\n", data.length]
                     dataUsingEncoding:_charsetForMultipart]];
  [body appendData:[[NSString
                      stringWithString:@"Content-Type: image/jpeg\r\n\r\n"]
                     dataUsingEncoding:_charsetForMultipart]];
  [body appendData:data];
		[body appendData:[endLine dataUsingEncoding:NSUTF8StringEncoding]];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSData*)generatePostBody {

	NSMutableData* body = [NSMutableData data];
  NSString* beginLine = [NSString stringWithFormat:@"--%@\r\n", kStringBoundary];
	NSString *endLine = @"\r\n";
	
  for (id key in [_parameters keyEnumerator]) {
    NSString* value = [_parameters valueForKey:key];
    // Really, this can only be an NSString. We're cheating here.
    if (![value isKindOfClass:[UIImage class]] &&
        ![value isKindOfClass:[NSData class]]) {
      [body appendData:[beginLine dataUsingEncoding:NSUTF8StringEncoding]];
      [body appendData:[[NSString
        stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", key]
          dataUsingEncoding:_charsetForMultipart]];
      [body appendData:[value dataUsingEncoding:_charsetForMultipart]];
		[body appendData:[endLine dataUsingEncoding:NSUTF8StringEncoding]];
    }
  }

  NSString* imageKey = nil;
  for (id key in [_parameters keyEnumerator]) {
    if ([[_parameters objectForKey:key] isKindOfClass:[UIImage class]]) {
      UIImage* image = [_parameters objectForKey:key];
      CGFloat quality = [TTURLRequestQueue mainQueue].imageCompressionQuality;
      NSData* data = UIImageJPEGRepresentation(image, quality);

      [self appendImageData:data withName:key toBody:body];
      imageKey = key;

    } else if ([[_parameters objectForKey:key] isKindOfClass:[NSData class]]) {
      NSData* data = [_parameters objectForKey:key];
      [self appendImageData:data withName:key toBody:body];
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
          dataUsingEncoding:_charsetForMultipart]];
    [body appendData:[[NSString stringWithFormat:@"Content-Length: %d\r\n", data.length]
          dataUsingEncoding:_charsetForMultipart]];
    [body appendData:[[NSString stringWithFormat:@"Content-Type: %@\r\n\r\n", mimeType]
          dataUsingEncoding:_charsetForMultipart]];
    [body appendData:data];
		[body appendData:[endLine dataUsingEncoding:NSUTF8StringEncoding]];
  }

  [body appendData:[[NSString stringWithFormat:@"--%@--\r\n", kStringBoundary]
                   dataUsingEncoding:NSUTF8StringEncoding]];

  // If an image was found, remove it from the dictionary to save memory while we
  // perform the upload
  if (imageKey) {
    [_parameters removeObjectForKey:imageKey];
  }

  TTDCONDITIONLOG(TTDFLAG_URLREQUEST, @"Sending %s", [body bytes]);
  return body;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSMutableDictionary*)parameters {
  if (!_parameters) {
    _parameters = [[NSMutableDictionary alloc] init];
  }
  return _parameters;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSMutableDictionary*)headers {
  if (!_headers) {
    _headers = [[NSMutableDictionary alloc] init];
  }
  return _headers;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSData*)httpBody {
  if (_httpBody) {
    return _httpBody;
  } else if (([[_httpMethod uppercaseString] isEqualToString:@"POST"]
              || [[_httpMethod uppercaseString] isEqualToString:@"PUT"])) {
    if (_multiPartForm) {
      return [self generatePostBody];      
    } else {
      return [self generateNonMultipartPostBody];
    }
  } else {
    return nil;
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSString*)contentType {
  if (_contentType) {
    return _contentType;

  } else if ([_httpMethod isEqualToString:@"POST"]
             || [_httpMethod isEqualToString:@"PUT"]) {
    if (_multiPartForm) {
      return [NSString stringWithFormat:@"multipart/form-data; boundary=%@", kStringBoundary];      
    } else {
      return [NSString stringWithFormat:@"application/x-www-form-urlencoded", kStringBoundary];            
    }
    
  } else {
    return nil;
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSString*)cacheKey {
  if (!_cacheKey) {
    _cacheKey = [[self generateCacheKey] retain];
  }
  return _cacheKey;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setValue:(NSString*)value forHTTPHeaderField:(NSString*)field {
  if (!_headers) {
    _headers = [[NSMutableDictionary alloc] init];
  }
  [_headers setObject:value forKey:field];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)addFile:(NSData*)data mimeType:(NSString*)mimeType fileName:(NSString*)fileName {
  if (!_files) {
    _files = [[NSMutableArray alloc] init];
  }

  [_files addObject:data];
  [_files addObject:mimeType];
  [_files addObject:fileName];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)send {
  if (_parameters) {
    // Don't log passwords. Save now, restore after logging
    NSString* password = [_parameters objectForKey:@"password"];
    if (_filterPasswordLogging && password) {
      [_parameters setObject:@"[FILTERED]" forKey:@"password"];
    }

    TTDCONDITIONLOG(TTDFLAG_URLREQUEST, @"SEND %@ %@", self.urlPath, self.parameters);

    if (password) {
      [_parameters setObject:password forKey:@"password"];
    }
  }
  return [[TTURLRequestQueue mainQueue] sendRequest:self];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)sendSynchronously {
  return [[TTURLRequestQueue mainQueue] sendSynchronousRequest:self];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)cancel {
  [[TTURLRequestQueue mainQueue] cancelRequest:self];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSURLRequest*)createNSURLRequest {
  return [[TTURLRequestQueue mainQueue] createNSURLRequest:self URL:nil];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Properties


///////////////////////////////////////////////////////////////////////////////////////////////////
/**
 * Deprecated
 */
- (void)setURL:(NSString*)urlPath {
  NSString* aUrlPath = [urlPath copy];
  [_urlPath release];
  _urlPath = aUrlPath;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
/**
 * Deprecated
 */
- (NSString*)URL {
  return _urlPath;
}

@end
