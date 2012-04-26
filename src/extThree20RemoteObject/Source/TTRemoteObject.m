//
// Copyright 2012 RIKSOF
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

#import "TTRemoteObject.h"

@implementation TTRemoteObject

@synthesize documentFormat;

#pragma mark Data Loading

/**
 * Load the data.
 */
-(void)load:(TTURLRequestCachePolicy)cachePolicy cacheExpirationAge:(NSTimeInterval)cacheExpirationAge more:(BOOL)more {
    
    // If we are not loading data, start loading.
    if ( !self.isLoading ) {
        
        // Let other delegates know that we are about to send load request.
        for ( int i = 0; i < [delegates count]; i++ ) {
            id<TTRemoteObjectDelegate> listener = [delegates objectAtIndex:i];
            
            // Does this delegate listen for load requests?
            if ( [listener respondsToSelector:@selector(load:)] ) {
                [listener load:self];
            }
        }
        
        NSString *requestUrl = url;
        
        // If this is a GET method, put the values in the URL.
        if ( [httpMethod isEqualToString:@"GET"] ) {
            NSString *variableSeparator = @"?";
            for ( NSString *key in parameters ) {
                requestUrl = [requestUrl stringByAppendingFormat:@"%@%@=%@",
                              variableSeparator, key,
                CFURLCreateStringByAddingPercentEscapes(NULL,
                    (__bridge CFStringRef)[parameters objectForKey:key],
                    NULL,
                    (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                    kCFStringEncodingUTF8 )];
                variableSeparator = @"&";
            }
        }
        
        // Set up the URL.
        TTURLRequest* request = [TTURLRequest requestWithURL:requestUrl delegate:self];
        
        // Set the HTTP Method.
        request.httpMethod =  httpMethod;
        
        // Set the parameters.
        [request.parameters setDictionary:parameters]; 
        
        // Set the files if this is a POST request.
        if ( [httpMethod isEqualToString:@"POST"] ) {
            for ( int i = 0; i < files.count; i++ ) {
                NSDictionary *file = [files objectAtIndex:i];
                
                [request addFile:[file objectForKey:@"data"]
                        mimeType:[file objectForKey:@"mimeType"]
                        fileName:[file objectForKey:@"name"]
                             key:[file objectForKey:@"key"]];
            }
        }
        
        NSLog(@"RemoteObject - Making request URL: %@, Method: %@", requestUrl, 
              httpMethod);
        NSLog(@"Parameters: %@", parameters);
        NSLog(@"Document Format: %@", ( documentFormat == DOCUMENT_FORMAT_JSON ) ? @"JSON" : @"XML" );
        
        // Set the cache policy.
        request.cachePolicy = cachePolicy;
        request.cacheExpirationAge = cacheExpirationAge;
        
        // Prepare the response object depending on remote document format.
        if ( documentFormat == DOCUMENT_FORMAT_JSON ) {
#ifdef EXT_REMOTE_JSON            
            request.response = [[TTURLJSONResponse alloc] init];
#endif
        } else {
#ifdef EXT_REMOTE_XML
            request.response = [[TTURLXMLResponse alloc] init];
#endif
        }
        
        // Finally send the request.
        [request send];
        
        /**
         * If testing response we can try sending requests synchronously. Uncomment
         * the following two lines and comment the line above.
         */
        //[request sendSynchronously];
        //[self requestDidFinishLoad:request];
    }
}

/**
 * Handle cancel when we have an error.
 */
- (void)requestDidCancelLoad:(TTURLRequest *)request withError:(NSError *)error {
    [super requestDidCancelLoad:request];
    
    // Let other delegates know that last request failed.
    for ( int i = 0; i < [delegates count]; i++ ) {
        id<TTRemoteObjectDelegate> listener = [delegates objectAtIndex:i];
        
        // Does this delegate listen for failed requests?
        if ( [listener respondsToSelector:@selector(remoteObject:didFailLoadWithError:forRequest:)] ) {
            [listener remoteObject:self didFailLoadWithError:error forRequest:request];
        }
    }
}

/**
 * Handle cancels, which we treat as failures. Since no error is reported, we 
 * generate our own.
 */
-(void)requestDidCancelLoad:(TTURLRequest *)request {
    
    // An error to say the load was canceled.
    NSError *error = [NSError errorWithDomain:@"REMOTE_OBJECT_LOAD_CANCELED" code:-1 userInfo:nil];
    
    [self requestDidCancelLoad:request withError:error];
}

/**
 * Handle error.
 */
- (void)request:(TTURLRequest*)request didFailLoadWithError:(NSError*)error {
    [super request:request didFailLoadWithError:error];
    
    // Make sure the response is correct.
    id rootObject = nil;
    
    // Prepare the response object depending on remote document format.
    if ( documentFormat == DOCUMENT_FORMAT_JSON ) {
#ifdef EXT_REMOTE_JSON
        rootObject = ((TTURLJSONResponse *)request.response).rootObject;
#endif
    } else {
#ifdef EXT_REMOTE_XML
        rootObject = ((TTURLXMLResponse *)request.response).rootObject;
#endif
    }
    
    NSLog(@"Error occured on following feed: %@", request);
    NSLog(@"Error: %@", [error localizedDescription]);
    
    // Cancel the request.
    [self requestDidCancelLoad:request withError:error];
}

/**
 * Load data with default cache policy.
 */
-(void)load{
    [self load:TTURLRequestCachePolicyDefault cacheExpirationAge:TT_DEFAULT_CACHE_EXPIRATION_AGE more:NO];
}

/**
 * Handle failures.
 */
-(void)requestDidFinishLoad:(TTURLRequest *)request {
    [super requestDidFinishLoad:request];
    
    // Make sure we inform the delegates.
    // Let other delegates know that we are about to send load request.
    for ( int i = 0; i < [delegates count]; i++ ) {
        id<TTRemoteObjectDelegate> listener = [delegates objectAtIndex:i];
        
        // Does this delegate listen for load requests?
        if ( [listener respondsToSelector:@selector(remoteObject:didFinishLoadForRequest:)] ) {
            [listener remoteObject:self didFinishLoadForRequest:request];
        }
    }
}

#pragma mark Manage Delegates

/**
 * Register a delegate to this object.
 */
-(void)registerDelegate:(id<TTRemoteObjectDelegate>)listener {
    [delegates addObject:listener];
}

/**
 * Remove a delegate from this object.
 */
-(void)removeDelegate:(id<TTRemoteObjectDelegate>)listener {
    [delegates removeObject:listener];
}

#pragma mark Initializations

/**
 * Initialize the object.
 */
-(id)init {
    if (self == [super init]) {
        // Initialize the parameters.
        parameters = [[NSMutableDictionary alloc] init];
        
        // Initialize the delegates.
        delegates = [[NSMutableArray alloc] init];
        
        // Make a copy of the default value mappers, if value mappers
        // is not set.
        if ( valueMapper == nil ) {
            valueMapper = [[TTValueMapper sharedInstance] copy];
        }
        
        // If there is no URL then indicate this object as loaded.
        // As we have loaded it directly.
        _loadedTime = [NSDate dateWithTimeIntervalSinceNow:0];
    }
    
    return self;
}

#pragma TTURLRequestModel Overrides

/**
 * At the moment, there is no need to be outdated.
 */
- (BOOL)isOutdated {
    return NO; 
}

@end
