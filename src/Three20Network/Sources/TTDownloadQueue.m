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
