//
// Copyright 2009-2011 Facebook
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

#import "PlaygroundViewController.h"

static const  CGFloat   kFramePadding    = 10;
static const  CGFloat   kElementSpacing  = 5;
static const  CGFloat   kGroupSpacing    = 10;

static        NSString* kRequestURLPath  = @"http://farm3.static.flickr.com/2373/2177444005_0d71df1713.jpg";

///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation PlaygroundViewController


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void) loadView {
  [super loadView];

  _scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
  _scrollView.autoresizingMask =
    UIViewAutoresizingFlexibleWidth
    | UIViewAutoresizingFlexibleHeight;

  [self.view addSubview:_scrollView];

  CGFloat yOffset = kFramePadding;

  {
    _requestButton = [[UIButton buttonWithType:UIButtonTypeRoundedRect] retain];
    [_requestButton setTitle: NSLocalizedString(@"TTURLRequest test", @"")
                    forState: UIControlStateNormal];
    [_requestButton addTarget: self
               action: @selector(requestAction)
     forControlEvents: UIControlEventTouchUpInside];
    [_requestButton sizeToFit];

    CGRect frame = _requestButton.frame;
    frame.origin.x = kFramePadding;
    frame.origin.y = yOffset;
    _requestButton.frame = frame;

    [_scrollView addSubview:_requestButton];

    yOffset += frame.size.height;
  }

  {
    _clearCacheButton = [[UIButton buttonWithType:UIButtonTypeRoundedRect] retain];
    [_clearCacheButton setTitle: NSLocalizedString(@"Clear the cache", @"")
                       forState: UIControlStateNormal];
    [_clearCacheButton addTarget: self
                          action: @selector(clearCacheAction)
                forControlEvents: UIControlEventTouchUpInside];
    [_clearCacheButton sizeToFit];

    CGRect frame = _clearCacheButton.frame;
    frame.origin.x = kFramePadding;
    frame.origin.y = yOffset;
    _clearCacheButton.frame = frame;

    [_scrollView addSubview:_clearCacheButton];

    yOffset += frame.size.height;
  }

  [_scrollView setContentSize:CGSizeMake(320, yOffset)];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void) viewDidUnload {
  [super viewDidUnload];

  TT_RELEASE_SAFELY(_imageView);
  TT_RELEASE_SAFELY(_requestButton);
  TT_RELEASE_SAFELY(_clearCacheButton);
  TT_RELEASE_SAFELY(_scrollView);
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void) viewDidAppear:(BOOL)animated {
  [super viewDidAppear:animated];

  [_scrollView flashScrollIndicators];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void) requestAction {
  TTURLRequest* request = [TTURLRequest requestWithURL: kRequestURLPath
                                              delegate: self];

  // TTURLImageResponse is just one of a set of response types you can use.
  // Also available are TTURLDataResponse and TTURLXMLResponse.
  request.response = [[[TTURLImageResponse alloc] init] autorelease];

  [request send];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void) clearCacheAction {
  [[TTURLCache sharedCache] removeAll:YES];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark TTURLRequestDelegate


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)requestDidStartLoad:(TTURLRequest*)request {
  [_requestButton setTitle:@"Loading..." forState:UIControlStateNormal];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)requestDidFinishLoad:(TTURLRequest*)request {
  TTURLImageResponse* imageResponse = (TTURLImageResponse*)request.response;

  if (nil == _imageView) {
    _imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    [_scrollView addSubview:_imageView];
  }
  _imageView.image = imageResponse.image;
  [_imageView sizeToFit];
  _imageView.alpha = 0;

  [UIView beginAnimations:nil context:nil];
  [UIView setAnimationDuration:0.5];

  _requestButton.alpha = 0;
  _clearCacheButton.alpha = 0;
  [_scrollView setContentSize:_imageView.frame.size];
  _imageView.alpha = 1;

  [UIView commitAnimations];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)request:(TTURLRequest*)request didFailLoadWithError:(NSError*)error {
  [_requestButton setTitle:@"Failed to load, try again." forState:UIControlStateNormal];
}


@end
