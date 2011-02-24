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

#import "Three20Style/TTFlowLayout.h"


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation TTFlowLayout

@synthesize padding = _padding;
@synthesize spacing = _spacing;


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Public


///////////////////////////////////////////////////////////////////////////////////////////////////
- (CGSize)layoutSubviews:(NSArray*)subviews forView:(UIView*)view {
  CGFloat x = _padding, y = _padding;
  CGFloat maxX = 0, rowHeight = 0;
  CGFloat maxWidth = view.frame.size.width - _padding*2;
  for (UIView* subview in subviews) {
    if (x > _padding && x + subview.frame.size.width > maxWidth) {
      x = _padding;
      y += rowHeight + _spacing;
      rowHeight = 0;
    }
    subview.frame = CGRectMake(x, y, subview.frame.size.width, subview.frame.size.height);
    x += subview.frame.size.width + _spacing;
    if (x > maxX) {
      maxX = x;
    }
    if (subview.frame.size.height > rowHeight) {
      rowHeight = subview.frame.size.height;
    }
  }

  return CGSizeMake(maxX+_padding, y+rowHeight+_padding);
}


@end
