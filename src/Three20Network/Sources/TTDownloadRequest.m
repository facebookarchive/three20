//
//  DownloadRequest.m
//  eReader
//
//  Created by Matej Ornest on 23.8.10.
//  Copyright 2010 Matej Ornest. All rights reserved.
//

#import "TTDownloadRequest.h"

@implementation TTDownloadRequest

@synthesize filePath = _filePath;
@synthesize expectedNumberOfBytes = _expectedNumberOfBytes;

- (void) dealloc {
	
	TT_RELEASE_SAFELY(_filePath);
	
	[super dealloc];
}

@end
