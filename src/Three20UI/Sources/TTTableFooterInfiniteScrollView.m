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

#import "Three20UI/TTTableFooterInfiniteScrollView.h"

// UI
#import "Three20UI/UIViewAdditions.h"

// Style
#import "Three20Style/TTGlobalStyle.h"
#import "Three20Style/TTDefaultStyleSheet.h"

// Network
#import "Three20Network/TTURLCache.h"

// Core
#import "Three20Core/TTGlobalCoreLocale.h"

#import <QuartzCore/QuartzCore.h>


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation TTTableFooterInfiniteScrollView

@synthesize indicator = _indicator;


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithFrame:(CGRect)frame {
  if ((self = [super initWithFrame:frame])) {
    self.indicator = [[[UIActivityIndicatorView alloc]
                       initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray]
                      autorelease];
    self.indicator.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin |
    UIViewAutoresizingFlexibleRightMargin;

    [self addSubview:self.indicator];
  }
  return self;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)drawRect:(CGRect)rect{
  CGContextRef contextRef = UIGraphicsGetCurrentContext();
  CGContextSetRGBFillColor(contextRef, 1, 1, 1, 1);
  CGContextFillRect(contextRef, rect);
  if (!_loading) {
    CGFloat dotSize = 5.0f;
    CGFloat x = roundf((self.width / 2) - (dotSize / 2));
    CGFloat y = roundf((self.height / 2) - (dotSize / 2));
    CGContextSetRGBFillColor(contextRef, 0.75, 0.75, 0.75, 1.0);
    CGContextFillEllipseInRect(contextRef, CGRectMake(x, y, dotSize, dotSize));
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)layoutSubviews {
  [super layoutSubviews];
  self.indicator.left = roundf((self.width / 2) - (self.indicator.width / 2));
  self.indicator.top = roundf((self.height / 2) - (self.indicator.height / 2));
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setLoading:(BOOL)loading {
  _loading = loading;
  if (_loading) {
    [self.indicator startAnimating];

  } else {
    [self.indicator stopAnimating];
  }
  [self setNeedsDisplay];
}

@end
