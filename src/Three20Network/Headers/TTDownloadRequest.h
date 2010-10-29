//
//  DownloadRequest.h
//  eReader
//
//  Created by Matej Ornest on 23.8.10.
//  Copyright 2010 Matej Ornest. All rights reserved.
//

#import "Three20Network/TTURLRequest.h"

@interface TTDownloadRequest : TTURLRequest {

	/// Path where downloaded file has been stored;
	/// This is set by request loader, do not manipulate directly!!!
	NSString *_filePath;
	
	/// Expected number of bytes overrides Content-Length header
	NSInteger _expectedNumberOfBytes;
}

@property (nonatomic, copy) NSString *filePath;
@property (nonatomic, assign) NSInteger expectedNumberOfBytes;

@end
