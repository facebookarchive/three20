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

#import "Three20UI/TTPageControl.h"

// UI
#import "Three20UI/UIViewAdditions.h"

// Style
#import "Three20Style/TTStyleContext.h"
#import "Three20Style/TTStyleSheet.h"
#import "Three20Style/TTBoxStyle.h"

// Core
#import "Three20Core/TTDebug.h"
#import "Three20Core/TTCorePreprocessorMacros.h"


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation TTPageControl

@synthesize numberOfPages       = _numberOfPages;
@synthesize currentPage         = _currentPage;
@synthesize dotStyle            = _dotStyle;
@synthesize hidesForSinglePage  = _hidesForSinglePage;


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithFrame:(CGRect)frame {
  if (self = [super initWithFrame:frame]) {
    self.backgroundColor = [UIColor clearColor];
    self.dotStyle = @"pageDot:";
    self.hidesForSinglePage = NO;
    self.contentMode = UIViewContentModeRedraw;
  }

  return self;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)dealloc {
  TT_RELEASE_SAFELY(_dotStyle);
  TT_RELEASE_SAFELY(_normalDotStyle);
  TT_RELEASE_SAFELY(_currentDotStyle);

  [super dealloc];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Properties


///////////////////////////////////////////////////////////////////////////////////////////////////
- (TTStyle*)normalDotStyle {
  if (!_normalDotStyle) {
    _normalDotStyle = [[[TTStyleSheet globalStyleSheet] styleWithSelector:_dotStyle
                                                        forState:UIControlStateNormal] retain];
  }
  return _normalDotStyle;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (TTStyle*)currentDotStyle {
  if (!_currentDotStyle) {
    _currentDotStyle = [[[TTStyleSheet globalStyleSheet] styleWithSelector:_dotStyle
                                                         forState:UIControlStateSelected] retain];
  }
  return _currentDotStyle;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark UIView


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)drawRect:(CGRect)rect {
  if(_numberOfPages <= 1 && _hidesForSinglePage) {
    return;
  }

  TTStyleContext* context = [[[TTStyleContext alloc] init] autorelease];
  TTBoxStyle* boxStyle = [self.normalDotStyle firstStyleOfClass:[TTBoxStyle class]];

  CGSize dotSize = [self.normalDotStyle addToSize:CGSizeZero context:context];

  CGFloat dotWidth = dotSize.width + boxStyle.margin.left + boxStyle.margin.right;
  CGFloat totalWidth = (dotWidth * _numberOfPages) - (boxStyle.margin.left + boxStyle.margin.right);
  CGRect contentRect = CGRectMake(round(self.width/2 - totalWidth/2),
                                  round(self.height/2 - dotSize.height/2),
                                  dotSize.width, dotSize.height);

  for (NSInteger i = 0; i < _numberOfPages; ++i) {
    contentRect.origin.x += boxStyle.margin.left;

    context.frame = contentRect;
    context.contentFrame = contentRect;

    if (i == _currentPage) {
      [self.currentDotStyle draw:context];
    } else {
      [self.normalDotStyle draw:context];
    }
    contentRect.origin.x += dotSize.width + boxStyle.margin.right;
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (CGSize)sizeThatFits:(CGSize)size {
  TTStyleContext* context = [[[TTStyleContext alloc] init] autorelease];
  CGSize dotSize = [self.normalDotStyle addToSize:CGSizeZero context:context];

  CGFloat margin = 0;
  TTBoxStyle* boxStyle = [self.normalDotStyle firstStyleOfClass:[TTBoxStyle class]];
  if (boxStyle) {
    margin = boxStyle.margin.right + boxStyle.margin.left;
  }

  return CGSizeMake((dotSize.width * _numberOfPages) + (margin * (_numberOfPages-1)),
                    dotSize.height);
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark UIControl


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
  if (self.touchInside) {
    CGPoint point = [touch locationInView:self];

    if (point.x < self.width / 2) {
      self.currentPage = self.currentPage - 1;

    } else {
      self.currentPage = self.currentPage + 1;
    }

    [self sendActionsForControlEvents:UIControlEventValueChanged];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Public


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setNumberOfPages:(NSInteger)numberOfPages {
  if (numberOfPages != _numberOfPages) {
    TTDASSERT(numberOfPages >= 0);

    _numberOfPages = MAX(0, numberOfPages);
    [self setNeedsDisplay];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setCurrentPage:(NSInteger)currentPage {
  if (currentPage != _currentPage) {
    _currentPage = MAX(0, MIN(_numberOfPages - 1,currentPage));
    [self setNeedsDisplay];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setDotStyle:(NSString*)dotStyle {
  if (![dotStyle isEqualToString:_dotStyle]) {
    [_dotStyle release];
    _dotStyle = [dotStyle copy];
    TT_RELEASE_SAFELY(_normalDotStyle);
    TT_RELEASE_SAFELY(_currentDotStyle);
  }
}


@end
