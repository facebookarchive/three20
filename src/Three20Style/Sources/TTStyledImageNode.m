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

#import "Three20Style/TTStyledImageNode.h"

// Network
#import "Three20Network/TTURLCache.h"

// Core
#import "Three20Core/TTCorePreprocessorMacros.h"


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation TTStyledImageNode

@synthesize URL           = _URL;
@synthesize image         = _image;
@synthesize defaultImage  = _defaultImage;
@synthesize width         = _width;
@synthesize height        = _height;


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithURL:(NSString*)URL {
  if (self = [super initWithText:nil next:nil]) {
    self.URL = URL;
  }

  return self;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)init {
  if (self = [self initWithURL:nil]) {
  }

  return self;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)dealloc {
  TT_RELEASE_SAFELY(_URL);
  TT_RELEASE_SAFELY(_image);
  TT_RELEASE_SAFELY(_defaultImage);

  [super dealloc];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSString*)description {
  return [NSString stringWithFormat:@"(%@)", _URL];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark TTStyledNode


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSString*)outerHTML {
  NSString* html = [NSString stringWithFormat:@"<img src=\"%@\"/>", _URL];
  if (_nextSibling) {
    return [NSString stringWithFormat:@"%@%@", html, _nextSibling.outerHTML];

  } else {
    return html;
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Public


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setURL:(NSString*)URL {
  if (nil == _URL || ![URL isEqualToString:_URL]) {
    [_URL release];
    _URL = [URL retain];

    if (nil != _URL) {
      self.image = [[TTURLCache sharedCache] imageForURL:_URL];

    } else {
      self.image = nil;
    }
  }
}


@end
