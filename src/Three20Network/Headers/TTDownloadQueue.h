//
//  TTDownloadQueue.h
//  eReader
//
//  Created by Matej Ornest on 23.8.10.
//  Copyright 2010 - 2011 Matej Ornest. All rights reserved.
//

#import "Three20Network/TTURLRequestQueue.h"

/**
 * Works exactly the same as it's  parent class, except that if TTDownloadRequest
 * is enqueued, it loads it with TTDownloadRequestLoader instead of standard loader,
 * saving dowloaded content to a file rather than storing it in memory.
 *
 * TTDownloadRequest's filePath property can be examined by request delegates
 * to get a content of downloaded file when download is finished.
 *
 * To make a use of this class, you must create an instance and set it as main queue
 * with [TTURLRequestQueue setMainQueue:] at very start of an application 
 * (didFinishApplicationLoading method of application delegate is a good place to do this)
 */
@interface TTDownloadQueue : TTURLRequestQueue {

}

@end
