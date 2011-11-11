//
//  TTURLBaseResponse.m
//  Three20Network
//
//  Created by Matěj Ornest on 2.6.11.
//  Copyright 2011 Mineus s.r.o. All rights reserved.
//

#import "TTURLBaseResponse.h"

// Core
#import "Three20Core/TTCorePreprocessorMacros.h"
#import "Three20Core/TTDebug.h"

@implementation TTURLBaseResponse

@synthesize responseHeaders = _allHTTPHeaderFields;

- (void)dealloc {

	TT_RELEASE_SAFELY(_allHTTPHeaderFields);
	
	[super dealloc];
}

- (NSError*)request:(TTURLRequest*)request processResponse:(NSHTTPURLResponse*)response
			   data:(id)data {
	
	/// Save reference to header fields
	TT_RELEASE_SAFELY(_allHTTPHeaderFields);
	
	_allHTTPHeaderFields = [[response allHeaderFields] retain];
	
	return nil;
}

@end
