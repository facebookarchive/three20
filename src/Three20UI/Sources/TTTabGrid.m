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

#import "Three20UI/TTTabGrid.h"

// UI
#import "Three20UI/TTButton.h"
#import "Three20UI/UIViewAdditions.h"

// Style
#import "Three20Style/TTGlobalStyle.h"
#import "Three20Style/TTStyleSheet.h"
#import "Three20Style/TTGridLayout.h"

// Core
#import "Three20Core/TTCorePreprocessorMacros.h"


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation TTTabGrid

@synthesize columnCount = _columnCount;


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithFrame:(CGRect)frame  {
	self = [super initWithFrame:frame];
  if (self) {
    self.style = TTSTYLE(tabGrid);
    _columnCount = 3;
  }
  return self;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Private


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSInteger)rowCount {
  return ceil((float)self.tabViews.count / self.columnCount);
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)updateTabStyles {
  CGFloat columnCount = [self columnCount];
  int rowCount = [self rowCount];
  int cellCount = rowCount * columnCount;

  if (self.tabViews.count > columnCount) {
    int column = 0;
    for (TTTab* tab in self.tabViews) {
      if (column == 0) {
        [tab setStylesWithSelector:@"tabGridTabTopLeft:"];

      } else if (column == columnCount-1) {
        [tab setStylesWithSelector:@"tabGridTabTopRight:"];

      } else if (column == cellCount - columnCount) {
        [tab setStylesWithSelector:@"tabGridTabBottomLeft:"];

      } else if (column == cellCount - 1) {
        [tab setStylesWithSelector:@"tabGridTabBottomRight:"];

      } else {
        [tab setStylesWithSelector:@"tabGridTabCenter:"];
      }
      ++column;
    }

  } else {
    int column = 0;
    for (TTTab* tab in self.tabViews) {
      if (column == 0) {
        [tab setStylesWithSelector:@"tabGridTabLeft:"];

      } else if (column == columnCount-1) {
        [tab setStylesWithSelector:@"tabGridTabRight:"];

      } else {
        [tab setStylesWithSelector:@"tabGridTabCenter:"];
      }
      ++column;
    }
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (CGSize)layoutTabs {
  if (self.width && self.height) {
    TTGridLayout* layout = [[[TTGridLayout alloc] init] autorelease];
    layout.padding = 1;
    layout.columnCount = [self columnCount];
    return [layout layoutSubviews:self.tabViews forView:self];

  } else {
    return self.frame.size;
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark UIView


///////////////////////////////////////////////////////////////////////////////////////////////////
- (CGSize)sizeThatFits:(CGSize)size {
  CGSize styleSize = [super sizeThatFits:size];
  for (TTTab* tab in self.tabViews) {
    CGSize tabSize = [tab sizeThatFits:CGSizeZero];
    NSInteger rowCount = [self rowCount];
    return CGSizeMake(size.width,
                      rowCount ? tabSize.height * [self rowCount] + styleSize.height : 0);
  }
  return size;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setTabItems:(NSArray*)tabItems {
  [super setTabItems:tabItems];
  [self updateTabStyles];
}


@end
