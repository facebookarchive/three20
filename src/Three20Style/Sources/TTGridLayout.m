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

#import "Three20Style/TTGridLayout.h"


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation TTGridLayout

@synthesize columnCount = _columnCount;
@synthesize padding     = _padding;
@synthesize spacing     = _spacing;


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)init {
  if (self = [super init]) {
    _columnCount = 1;
  }

  return self;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Public


///////////////////////////////////////////////////////////////////////////////////////////////////
- (CGSize)layoutSubviews:(NSArray*)subviews forView:(UIView*)view {
  CGFloat innerWidth = (view.frame.size.width - _padding*2);
  CGFloat width = ceil(innerWidth / _columnCount);
  CGFloat rowHeight = 0;

  CGFloat x = _padding, y = _padding;
  CGFloat maxX = 0, lastHeight = 0;
  NSInteger column = 0;
  for (UIView* subview in subviews) {
    if (column % _columnCount == 0) {
      x = _padding;
      y += rowHeight + _spacing;
    }
    CGSize size = [subview sizeThatFits:CGSizeMake(width, 0)];
    rowHeight = size.height;
    subview.frame = CGRectMake(x, y, width, size.height);
    x += subview.frame.size.width + _spacing;
    if (x > maxX) {
      maxX = x;
    }
    lastHeight = subview.frame.size.height;
    ++column;
  }

  return CGSizeMake(maxX+_padding, y+lastHeight+_padding);
}


@end
