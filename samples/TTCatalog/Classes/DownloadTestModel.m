#import "DownloadTestModel.h"
#import <Three20/Three20.h>

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation DownloadTestModel

@synthesize downloadUrl = _downloadUrl;

///////////////////////////////////////////////////////////////////////////////////////////////////
// initiation

- (id)init {
  if (self = [super init]) {
  }
  return self;
}

- (void)dealloc {
  TT_RELEASE_SAFELY(_downloadUrl);
  [super dealloc];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// TTURLRequestModel 

- (void)load:(TTURLRequestCachePolicy)cachePolicy more:(BOOL)more {
  TTURLRequest *request = [[[TTURLRequest alloc] initWithURL: _downloadUrl delegate: self] autorelease];
  [request setResponse: [[[TTURLDataResponse alloc] init] autorelease]];
  [request setCachePolicy: cachePolicy];
  [request send];
} 

@end
