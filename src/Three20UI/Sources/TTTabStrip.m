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

#import "Three20UI/TTTabStrip.h"

// UI
#import "Three20UI/TTTab.h"
#import "Three20UI/UIViewAdditions.h"

// UI (private)
#import "Three20UI/private/TTTabBarInternal.h"

// Style
#import "Three20Style/TTGlobalStyle.h"
#import "Three20Style/TTStyleSheet.h"

// Core
#import "Three20Core/TTCorePreprocessorMacros.h"


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation TTTabStrip


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithFrame:(CGRect)frame  {
  if (self = [super initWithFrame:frame]) {
    _scrollView = [[UIScrollView alloc] init];
    _scrollView.scrollEnabled = YES;
    _scrollView.scrollsToTop = NO;
    _scrollView.showsVerticalScrollIndicator = NO;
    _scrollView.showsHorizontalScrollIndicator = NO;
    [self addSubview:_scrollView];

    self.style = TTSTYLE(tabStrip);
    self.tabStyle = @"tabRound:";
  }

  return self;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)dealloc {
  TT_RELEASE_SAFELY(_overflowLeft);
  TT_RELEASE_SAFELY(_overflowRight);
  TT_RELEASE_SAFELY(_scrollView);

  [super dealloc];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Private


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)addTab:(TTTab*)tab {
  [_scrollView addSubview:tab];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)updateOverflow {
  if (_scrollView.contentOffset.x < (_scrollView.contentSize.width-self.width)) {
    if (!_overflowRight) {
      _overflowRight = [[TTView alloc] init];
      _overflowRight.style = TTSTYLE(tabOverflowRight);
      _overflowRight.userInteractionEnabled = NO;
      _overflowRight.backgroundColor = [UIColor clearColor];
      [_overflowRight sizeToFit];
      [self addSubview:_overflowRight];
    }

    _overflowRight.left = self.width-_overflowRight.width;
    _overflowRight.hidden = NO;
  } else {
    _overflowRight.hidden = YES;
  }
  if (_scrollView.contentOffset.x > 0) {
    if (!_overflowLeft) {
      _overflowLeft = [[TTView alloc] init];
      _overflowLeft.style = TTSTYLE(tabOverflowLeft);
      _overflowLeft.userInteractionEnabled = NO;
      _overflowLeft.backgroundColor = [UIColor clearColor];
      [_overflowLeft sizeToFit];
      [self addSubview:_overflowLeft];
    }

    _overflowLeft.hidden = NO;
  } else {
    _overflowLeft.hidden = YES;
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (CGSize)layoutTabs {
  CGSize size = [super layoutTabs];

  CGPoint contentOffset = _scrollView.contentOffset;
  _scrollView.frame = self.bounds;
  _scrollView.contentSize = CGSizeMake(size.width + kTabMargin, self.height);
  _scrollView.contentOffset = contentOffset;

  return size;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark UIView


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)layoutSubviews {
  [super layoutSubviews];
  [self updateOverflow];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark TTTabBar


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setTabItems:(NSArray*)tabItems {
  [super setTabItems:tabItems];
  [self updateOverflow];
}


@end

