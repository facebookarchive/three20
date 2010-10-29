//
//  TTDownloadRequestLoader.h
//  eReader
//
//  Created by Matej Ornest on 23.8.10.
//  Copyright 2010 Matej Ornest. All rights reserved.
//

#import "Three20Network/TTRequestLoader.h"

/**
 * Loads request, storing received data to file instead of memory
 */
@interface TTDownloadRequestLoader : TTRequestLoader {

	NSString *_outputFilePath;
	
	NSFileHandle *_fileHandle;
	
	NSUInteger _bytesLoaded;
}

@end
