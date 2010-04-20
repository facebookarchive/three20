//
// Copyright 2009-2010 Facebook
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

#import "Three20/TTButtonContent.h"

// Network
#import "Three20/TTURLImageResponse.h"
#import "Three20/TTURLCache.h"
#import "Three20/TTURLRequest.h"

// Core
#import "Three20/TTCorePreprocessorMacros.h"


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation TTButtonContent

@synthesize title     = _title;
@synthesize imageURL  = _imageURL;
@synthesize image     = _image;
@synthesize style     = _style;


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithButton:(TTButton*)button {
  if (self = [super init]) {
    _button = button;
  }
  return self;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)dealloc {
  [_request cancel];
  TT_RELEASE_SAFELY(_request);
  TT_RELEASE_SAFELY(_title);
  TT_RELEASE_SAFELY(_imageURL);
  TT_RELEASE_SAFELY(_image);
  TT_RELEASE_SAFELY(_style);

  [super dealloc];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark TTURLRequestDelegate


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)requestDidStartLoad:(TTURLRequest*)request {
  [_request release];
  _request = [request retain];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)requestDidFinishLoad:(TTURLRequest*)request {
  TTURLImageResponse* response = request.response;
  self.image = response.image;
  [_button setNeedsDisplay];

  TT_RELEASE_SAFELY(_request);
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)request:(TTURLRequest*)request didFailLoadWithError:(NSError*)error {
  TT_RELEASE_SAFELY(_request);
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)requestDidCancelLoad:(TTURLRequest*)request {
  TT_RELEASE_SAFELY(_request);
}


///////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Public


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setImageURL:(NSString*)URL {
  if (self.image && _imageURL && [URL isEqualToString:_imageURL])
    return;

  [self stopLoading];
  [_imageURL release];
  _imageURL = [URL retain];

  if (_imageURL.length) {
    [self reload];

  } else {
    self.image = nil;
    [_button setNeedsDisplay];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)reload {
  if (!_request && _imageURL) {
    UIImage* image = [[TTURLCache sharedCache] imageForURL:_imageURL];
    if (image) {
      self.image = image;
      [_button setNeedsDisplay];
    } else {
      TTURLRequest* request = [TTURLRequest requestWithURL:_imageURL delegate:self];
      request.response = [[[TTURLImageResponse alloc] init] autorelease];
      [request send];
    }
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)stopLoading {
  [_request cancel];
}


@end

