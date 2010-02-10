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

#import "Three20/TTGlobalUI.h"

#import "Three20/TTImageView.h"
#import "Three20/TTLabel.h"
#import "Three20/TTLayout.h"
#import "Three20/TTStyleSheet.h"

///////////////////////////////////////////////////////////////////////////////////////////////////
// global

static CGFloat kTabMargin = 10;
static CGFloat kPadding = 10;
static const NSInteger kMaxBadgeNumber = 99;

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

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation TTTabStrip

///////////////////////////////////////////////////////////////////////////////////////////////////
// private

- (void)addTab:(TTTab*)tab {
  [_scrollView addSubview:tab];
}

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

- (CGSize)layoutTabs {
  CGSize size = [super layoutTabs];
  
  CGPoint contentOffset = _scrollView.contentOffset;
  _scrollView.frame = self.bounds;
  _scrollView.contentSize = CGSizeMake(size.width + kTabMargin, self.height);
  _scrollView.contentOffset = contentOffset;
  
  return size;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// NSObject

- (id)initWithFrame:(CGRect)frame  {
  if (self = [super initWithFrame:frame]) {
    _overflowLeft = nil;
    _overflowRight = nil;

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

- (void)dealloc {
  TT_RELEASE_SAFELY(_overflowLeft);
  TT_RELEASE_SAFELY(_overflowRight);
  TT_RELEASE_SAFELY(_scrollView);
  [super dealloc];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// UIView

- (void)layoutSubviews {
  [super layoutSubviews];
  [self updateOverflow];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// TTTabBar

- (void)setTabItems:(NSArray*)tabItems {
  [super setTabItems:tabItems];
  [self updateOverflow];
}

@end

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation TTTabGrid

@synthesize columnCount = _columnCount;

///////////////////////////////////////////////////////////////////////////////////////////////////
// private

- (NSInteger)rowCount {
  return ceil((float)self.tabViews.count / self.columnCount);
}

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
// NSObject

- (id)initWithFrame:(CGRect)frame  {
  if (self = [super initWithFrame:frame]) {
    self.style = TTSTYLE(tabGrid);
    _columnCount = 3;
  }
  return self;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// UIView

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

- (void)setTabItems:(NSArray*)tabItems {
  [super setTabItems:tabItems];
  [self updateTabStyles];
}

@end

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation TTTab

@synthesize tabItem = _tabItem;

- (id)initWithItem:(TTTabItem*)tabItem tabBar:(TTTabBar*)tabBar {
  if (self = [self init]) {
    _badge = nil;
    
    self.tabItem = tabItem;
  }
  return self;
}

- (void)dealloc {
  TT_RELEASE_SAFELY(_tabItem);
  TT_RELEASE_SAFELY(_badge);
  [super dealloc];
}

///////////////////////////////////////////////////////////////////////////////////////////////////

- (void)updateBadgeNumber {
  if (_tabItem.badgeNumber) {
    if (!_badge) {
      _badge = [[TTLabel alloc] init];
      _badge.style = TTSTYLE(badge);
      _badge.backgroundColor = [UIColor clearColor];
      _badge.userInteractionEnabled = NO;
      [self addSubview:_badge];
    }
    if (_tabItem.badgeNumber <= kMaxBadgeNumber) {
      _badge.text = [NSString stringWithFormat:@"%d", _tabItem.badgeNumber];
    } else {
      _badge.text = [NSString stringWithFormat:@"%d+", kMaxBadgeNumber];
    }
    [_badge sizeToFit];
    
    _badge.frame = CGRectMake(self.width - _badge.width-1, 1, _badge.width, _badge.height);
    _badge.hidden = NO;
  } else {
    _badge.hidden = YES;
  }
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// TTTabItemDelegate

- (void)tabItem:(TTTabItem*)item badgeNumberChangedTo:(int)value {
  [self updateBadgeNumber];
}

///////////////////////////////////////////////////////////////////////////////////////////////////

- (void)setTabItem:(TTTabItem*)tabItem {
  if (tabItem != _tabItem) {
    [_tabItem performSelector:@selector(setTabBar:) withObject:nil];
    [_tabItem release];
    _tabItem = [tabItem retain];
    [_tabItem performSelector:@selector(setTabBar:) withObject:self];

    [self setTitle:_tabItem.title forState:UIControlStateNormal];
    [self setImage:_tabItem.icon forState:UIControlStateNormal];

    if (_tabItem.badgeNumber) {
      [self updateBadgeNumber];
    }
  }
}

@end

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation TTTabItem

@synthesize title = _title, icon = _icon, object = _object, badgeNumber = _badgeNumber;

- (id)initWithTitle:(NSString*)title {
  if (self = [self init]) {
    self.title = title;
  }
  return self;
}

- (id)init {
  if (self = [super init]) {
    _title = nil;
    _icon = nil;
    _object = nil;
    _badgeNumber = 0;
    _tabBar = nil;
  }
  return self;
}

- (void)dealloc {
  TT_RELEASE_SAFELY(_title);
  TT_RELEASE_SAFELY(_icon);
  TT_RELEASE_SAFELY(_object);
  [super dealloc];
}

///////////////////////////////////////////////////////////////////////////////////////////////////

- (void)setTabBar:(TTTabBar*)tabBar {
  _tabBar = tabBar;
}

///////////////////////////////////////////////////////////////////////////////////////////////////

- (void)setBadgeNumber:(int)value {
  value = value < 0 ? 0 : value;
  _badgeNumber = value;
  [_tabBar performSelector:@selector(tabItem:badgeNumberChangedTo:) withObject:self
    withObject:(id)value];
}

@end
