//
//  TTDownloadRequestLoader.m
//  eReader
//
//  Created by Matej Ornest on 23.8.10.
//  Copyright 2010 Matej Ornest. All rights reserved.
//

#import "TTDownloadRequestLoader.h"
#import "TTDownloadRequest.h"

@implementation TTDownloadRequestLoader

///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark TTDownloadRequestLoader private

- (NSString *) temporaryPathForRequest: (TTURLRequest *) request {
	
	/// Get temporary directory path
	NSString *tempDir = NSTemporaryDirectory();
	
	/// Use request's cache key as identifier and append it to tempdir and return the path
	NSString *itemAddr = [NSString stringWithFormat: @"%@.download", request.cacheKey];
	
	return [tempDir stringByAppendingPathComponent: itemAddr];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark NSURLConnectionDelegate

- (void) connection: (NSURLConnection *) connection didReceiveResponse: (NSHTTPURLResponse *) response {
	
	/// Call super to handle the response
	[super connection: connection didReceiveResponse: response];
	
	/// Clear uneeded memory
	TT_RELEASE_SAFELY(_responseData);
	
	/// TODO: If not handled by super implementation, check response status code to see if server
	/// returned OK or error
	
	_bytesLoaded = 0;
	
	TTDownloadRequest *request = (TTDownloadRequest *)[_requests objectAtIndex: 0];
	
	if(request.expectedNumberOfBytes > 0) {
		_contentLength = request.expectedNumberOfBytes;
	}
	else if ([[response allHeaderFields] objectForKey: @"Content-Length"]) {
		NSString *size = [[response allHeaderFields] objectForKey: @"Content-Length"];
		_contentLength = [size integerValue];
	}
	
	/// TODO: Temporary solution to set filename suggested by server; Filename should be present in data returned from server
	id downloadItem = request.userInfo;
	
	if (downloadItem != nil) {
		if([downloadItem respondsToSelector: @selector(setFilename:)]) {
			[downloadItem setFilename: [[response allHeaderFields] objectForKey: @"Content-Location"]];
		}
	}
	
	/// Generate path where to store downloaded file
	_outputFilePath = [[self temporaryPathForRequest: request] retain];
		
	/// Prepare output file handle
	if(![[NSFileManager defaultManager] fileExistsAtPath: _outputFilePath]) {
		/// Create file if it doesn't extist
		[[NSFileManager defaultManager] createFileAtPath: _outputFilePath contents: nil attributes: nil];
	}
	
	/// Open file handle
	_fileHandle = [[NSFileHandle fileHandleForUpdatingAtPath: _outputFilePath] retain];
	
	/// Truncate content's of a file first
	[_fileHandle truncateFileAtOffset: 0];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void) connection: (NSURLConnection *) connection didReceiveData: (NSData *) data {

	if(_fileHandle) {
		
		/// Make sure that we're writing at the end of the file
		[_fileHandle seekToEndOfFile];
		
		/// Write data to a file
		[_fileHandle writeData: data];
		
		/// Flush all in-memory contents to a file
		[_fileHandle synchronizeFile];
		
		_bytesLoaded +=[data length];
	}

	[self dispatchDownloadedBytes: _bytesLoaded ofTotalExpected: _contentLength];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)connectionDidFinishLoading: (NSURLConnection *) connection {
	
	/// Close file handle to flush all in-memory data to the file
	[_fileHandle closeFile];
	
	/// Store file path to request
	TTDownloadRequest *request = (TTDownloadRequest *)[_requests objectAtIndex: 0];
	request.filePath = _outputFilePath;
	
	/// Release local resources
	TT_RELEASE_SAFELY(_fileHandle);
	
	TT_RELEASE_SAFELY(_outputFilePath);
	
	_bytesLoaded = 0;
	
	/// Pass to super to finish the job
	[super connectionDidFinishLoading: connection];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)connection: (NSURLConnection *) connection didFailWithError: (NSError *) error {
	
	/// Close file handle and remove incomplete file
	[_fileHandle closeFile];
	
	if(_outputFilePath != nil) {
		[[NSFileManager defaultManager] removeItemAtPath: _outputFilePath error: nil];
	}
	
	/// Release local resources
	TT_RELEASE_SAFELY(_fileHandle);
	
	TT_RELEASE_SAFELY(_outputFilePath);
	
	_bytesLoaded = 0;
	
	/// Pass to super to finish the job
	[super connection: connection didFailWithError: error];
}

@end
