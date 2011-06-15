//
//  TTDownloadQueue.m
//  eReader
//
//  Created by Matej Ornest on 23.8.10.
//  Copyright 2010 Matej Ornest. All rights reserved.
//

#import "TTDownloadQueue.h"
#import "TTDownloadRequestLoader.h"
#import "TTDownloadRequest.h"

static const NSInteger kMaxConcurrentLoads = 3;

@implementation TTDownloadQueue

- (BOOL) sendRequest: (TTURLRequest *) request {
	
	if(![request isKindOfClass: [TTDownloadRequest class]]) {
		
		/// Pass to parent class implementation to handle the request
		return [super sendRequest: request];
	}
	
	/// Inform delegates that request did start loading
	for (id<TTURLRequestDelegate> delegate in request.delegates) {
		if ([delegate respondsToSelector:@selector(requestDidStartLoad:)]) {
			[delegate requestDidStartLoad:request];
		}
	}
	
	// If the url is empty, fail.
	if (!request.urlPath.length) {
		NSError* error = [NSError errorWithDomain:NSURLErrorDomain code:NSURLErrorBadURL userInfo:nil];
		for (id<TTURLRequestDelegate> delegate in request.delegates) {
			if ([delegate respondsToSelector:@selector(request:didFailLoadWithError:)]) {
				[delegate request:request didFailLoadWithError:error];
			}
		}
		return NO;
	}
	
	request.isLoading = YES;
	
	/// Load request with DownloadLoader
	TTDownloadRequestLoader *loader = nil;
	
	// Finally, create a new loader and hit the network (unless we are suspended)
	loader = [[TTDownloadRequestLoader alloc] initForRequest: request queue: self];
	
	[_loaders setObject: loader forKey: request.cacheKey];
	
	if(_suspended || _totalLoading == kMaxConcurrentLoads) {
		[_loaderQueue addObject: loader];
	}
	else {
		++_totalLoading;
		[loader load: [NSURL URLWithString: request.urlPath]];
	}
	
	[loader release];
	
	return NO;
}


@end
