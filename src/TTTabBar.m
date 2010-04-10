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

#import "Three20/TTTabBar.h"

#import "Three20/TTTab.h"
#import "Three20/TTTabDelegate.h"

#import "Three20/TTGlobalUI.h"

#import "Three20/TTStyleSheet.h"

///////////////////////////////////////////////////////////////////////////////////////////////////
// global

CGFloat kTabMargin = 10;
static CGFloat kPadding = 10;
const NSInteger kMaxBadgeNumber = 99;

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation TTTabBar

@synthesize delegate = _delegate, tabItems = _tabItems, tabViews = _tabViews,
            tabStyle = _tabStyle, selectedTabIndex = _selectedTabIndex;

///////////////////////////////////////////////////////////////////////////////////////////////////
// private

- (void)addTab:(TTTab*)tab {
  [self addSubview:tab];
}

- (CGSize)layoutTabs {
  CGFloat x = kTabMargin;

  if (self.contentMode == UIViewContentModeScaleToFill) {
    CGFloat maxTextWidth = self.width - (kTabMargin*2 + kPadding*2*_tabViews.count);
    CGFloat totalTextWidth = 0;
    CGFloat totalTabWidth = kTabMargin*2;
    CGFloat maxTabWidth = 0;
    for (int i = 0; i < _tabViews.count; ++i) {
      TTTab* tab = [_tabViews objectAtIndex:i];
      [tab sizeToFit];
      totalTextWidth += tab.width - kPadding*2;
      totalTabWidth += tab.width;
      if (tab.width > maxTabWidth) {
        maxTabWidth = tab.width;
      }
    }

    if (totalTextWidth > maxTextWidth) {
      CGFloat shrinkFactor = maxTextWidth/totalTextWidth;
      for (int i = 0; i < _tabViews.count; ++i) {
        TTTab* tab = [_tabViews objectAtIndex:i];
        CGFloat textWidth = tab.width - kPadding*2;
        tab.frame = CGRectMake(x, 0, ceil(textWidth * shrinkFactor) + kPadding*2 , self.height);
        x += tab.width;
      }
    } else {
      CGFloat averageTabWidth = ceil((self.width - kTabMargin*2)/_tabViews.count);
      if (maxTabWidth > averageTabWidth && self.width - totalTabWidth < kTabMargin) {
        for (int i = 0; i < _tabViews.count; ++i) {
          TTTab* tab = [_tabViews objectAtIndex:i];
          tab.frame = CGRectMake(x, 0, tab.width, self.height);
          x += tab.width;
        }
      } else {
        for (int i = 0; i < _tabViews.count; ++i) {
          TTTab* tab = [_tabViews objectAtIndex:i];
          tab.frame = CGRectMake(x, 0, averageTabWidth, self.height);
          x += tab.width;
        }
      }
    }
  } else {
    for (int i = 0; i < _tabViews.count; ++i) {
      TTTab* tab = [_tabViews objectAtIndex:i];
      [tab sizeToFit];
      tab.frame = CGRectMake(x, 0, tab.width, self.height);
      x += tab.width;
    }
  }

  return CGSizeMake(x, self.height);
}

- (void)tabTouchedUp:(TTTab*)tab {
  self.selectedTabView = tab;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// NSObject

- (id)initWithFrame:(CGRect)frame  {
  if (self = [super initWithFrame:frame]) {
    _selectedTabIndex = NSIntegerMax;
    _tabItems = nil;
    _tabViews = [[NSMutableArray alloc] init];
    _tabStyle = nil;

    self.style = TTSTYLE(tabBar);
    self.tabStyle = @"tab:";
  }
  return self;
}

- (void)dealloc {
  TT_RELEASE_SAFELY(_tabStyle);
  TT_RELEASE_SAFELY(_tabItems);
  TT_RELEASE_SAFELY(_tabViews);
  [super dealloc];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// UIView

- (void)layoutSubviews {
  [super layoutSubviews];
  [self layoutTabs];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// public

- (TTTabItem*)selectedTabItem {
  if (_selectedTabIndex != NSIntegerMax) {
    return [_tabItems objectAtIndex:_selectedTabIndex];
  }
  return nil;
}

- (void)setSelectedTabItem:(TTTabItem*)tabItem {
  self.selectedTabIndex = [_tabItems indexOfObject:tabItem];
}

- (TTTab*)selectedTabView {
  if (_selectedTabIndex != NSIntegerMax && _selectedTabIndex < _tabViews.count) {
    return [_tabViews objectAtIndex:_selectedTabIndex];
  }
  return nil;
}

- (void)setSelectedTabView:(TTTab*)tab {
  self.selectedTabIndex = [_tabViews indexOfObject:tab];
}

- (void)setSelectedTabIndex:(NSInteger)index {
  if (index != _selectedTabIndex) {
    if (_selectedTabIndex != NSIntegerMax) {
      self.selectedTabView.selected = NO;
    }

    _selectedTabIndex = index;

    if (_selectedTabIndex != NSIntegerMax) {
      self.selectedTabView.selected = YES;
    }

    if ([_delegate respondsToSelector:@selector(tabBar:tabSelected:)]) {
      [_delegate tabBar:self tabSelected:_selectedTabIndex];
    }
  }
}

- (void)setTabItems:(NSArray*)tabItems {
  [_tabItems release];
  _tabItems =  [tabItems retain];

  for (int i = 0; i < _tabViews.count; ++i) {
    TTTab* tab = [_tabViews objectAtIndex:i];
    [tab removeFromSuperview];
  }

  [_tabViews removeAllObjects];

  if (_selectedTabIndex >= _tabViews.count) {
    _selectedTabIndex = 0;
  }

  for (int i = 0; i < _tabItems.count; ++i) {
    TTTabItem* tabItem = [_tabItems objectAtIndex:i];
    TTTab* tab = [[[TTTab alloc] initWithItem:tabItem tabBar:self] autorelease];
    [tab setStylesWithSelector:self.tabStyle];
    [tab addTarget:self action:@selector(tabTouchedUp:) forControlEvents:UIControlEventTouchUpInside];
    [self addTab:tab];
    [_tabViews addObject:tab];
    if (i == _selectedTabIndex) {
      tab.selected = YES;
    }
  }

  [self setNeedsLayout];
}

- (void)showTabAtIndex:(NSInteger)tabIndex {
  TTTab* tab = [_tabViews objectAtIndex:tabIndex];
  tab.hidden = NO;
}

- (void)hideTabAtIndex:(NSInteger)tabIndex {
  TTTab* tab = [_tabViews objectAtIndex:tabIndex];
  tab.hidden = YES;
}

@end
