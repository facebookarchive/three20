/**
 * Copyright 2009 Facebook
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#import "Three20/TTYouTubeView.h"

///////////////////////////////////////////////////////////////////////////////////////////////////

static CGFloat kDefaultWidth = 140;
static CGFloat kDefaultHeight = 105;

static NSString* kEmbedHTML = @"\
<html>\
<head>\
<meta name=\"viewport\" content=\"initial-scale=1.0, user-scalable=no, width=%0.0f\"/>\
</head>\
<body style=\"background:#fff;margin-top:0px;margin-left:0px\">\
<div><object width=\"%0.0f\" height=\"%0.0f\">\
<param name=\"movie\" value=\"%@\"></param><param name=\"wmode\"\
value=\"transparent\"></param>\
<embed id=\"yt\" src=\"%@\" type=\"application/x-shockwave-flash\"\
wmode=\"transparent\" width=\"%0.0f\" height=\"%0.0f\"></embed>\
</object></div>\
</body>\
</html>";

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation TTYouTubeView

@synthesize URL = _URL;

- (id)initWithURL:(NSString*)URL {
  if (self = [self initWithFrame:CGRectMake(0, 0, kDefaultWidth, kDefaultHeight)]) {
    self.URL = URL;
  }
  return self;
}

- (void)dealloc {
  TT_RELEASE_SAFELY(_URL);
  [super dealloc];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// UIView

- (void)layoutSubviews {
  [self stringByEvaluatingJavaScriptFromString:
    [NSString stringWithFormat:@"yt.width = %0.0f; yt.height = %0.0f", self.width, self.height]];
}

///////////////////////////////////////////////////////////////////////////////////////////////////

- (void)setURL:(NSString*)URL {
  [_URL release];
  _URL = [URL copy];

  if (_URL) {
    NSString* html = [NSString stringWithFormat:kEmbedHTML, self.width, self.width,
                               self.height, _URL, _URL, self.width, self.height];
    [self loadHTMLString:html baseURL:nil];
  } else {
    [self loadHTMLString:@"&nbsp;" baseURL:nil];
  }
}


@end
