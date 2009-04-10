#import "Three20/TTTabBar.h"
#import "Three20/TTImageView.h"
#import "Three20/TTStyledLabel.h"
#import "Three20/TTDefaultStyleSheet.h"

///////////////////////////////////////////////////////////////////////////////////////////////////

static CGFloat kTabMargin = 10;
static CGFloat kPadding = 10;

//static CGFloat kIconSize = 16;
//static CGFloat kIconSpacing = 3;
//
//static CGFloat kGradient1[] = {RGBA(233, 238, 246, 1), RGBA(229, 235, 243, 1), 1};
//
//static CGFloat kReflectionBottom[] = {RGBA(228, 230, 235, 1)};
//static CGFloat kReflectionBottom2[] = {RGBA(214, 220, 230, 1)};
//
//static CGFloat kTopHighlight[] = {RGBA(247, 249, 252, 1)};
//static CGFloat kTopShadow[] = {RGBA(62, 70, 102, 1)};
//static CGFloat kBottomShadow[] = {RGBA(202, 205, 210, 1)};
//
//static CGFloat kBottomLightShadow[] = {RGBA(207, 213, 225, 1)};
//static CGFloat kBottomHighlight[] = {RGBA(250, 250, 252, 1)};

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation TTTabBar

@synthesize delegate = _delegate, tabItems = _tabItems, tabViews = _tabViews,
            tabStyle = _tabStyle, selectedTabIndex = _selectedTabIndex; 

///////////////////////////////////////////////////////////////////////////////////////////////////
// NSObject

- (id)initWithFrame:(CGRect)frame  {
  if (self = [super initWithFrame:frame]) {
    _selectedTabIndex = NSIntegerMax;
    _overflowLeft = nil;
    _overflowRight = nil;
    _tabItems = nil;
    _tabViews = [[NSMutableArray alloc] init];

    _scrollView = [[UIScrollView alloc] initWithFrame:CGRectZero];
    _scrollView.scrollEnabled = YES;
    _scrollView.scrollsToTop = NO;
    _scrollView.showsVerticalScrollIndicator = NO;
    _scrollView.showsHorizontalScrollIndicator = NO;
    [self addSubview:_scrollView];
    
    self.contentMode = UIViewContentModeLeft;
    self.style = TTSTYLE(tabBar);
    self.tabStyle = @"tab:";
  }
  return self;
}

- (void)dealloc {
  [_tabStyle release];
  [_overflowLeft release];
  [_overflowRight release];
  [_scrollView release];
  [_tabItems release];
  [_tabViews release];
  [super dealloc];
}

///////////////////////////////////////////////////////////////////////////////////////////////////

- (void)updateOverflow {
  if (_scrollView.contentOffset.x < (_scrollView.contentSize.width-self.width)) {
    if (!_overflowRight) {
      _overflowRight = [[TTStyledView alloc] initWithFrame:CGRectZero];
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
      _overflowLeft = [[TTStyledView alloc] initWithFrame:CGRectZero];
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

- (void)layoutTabs {
  CGFloat x = kTabMargin;
  
  if (self.contentMode == UIViewContentModeScaleToFill) {
    CGFloat maxTextWidth = self.width - (kTabMargin*2 + kPadding*2*_tabViews.count);
    CGFloat totalTextWidth = 0;
    CGFloat totalTabWidth = kTabMargin*2;
    CGFloat maxTabWidth = 0;
    for (int i = 0; i < _tabViews.count; ++i) {
      TTTabView* tab = [_tabViews objectAtIndex:i];
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
        TTTabView* tab = [_tabViews objectAtIndex:i];
        CGFloat textWidth = tab.width - kPadding*2;
        tab.frame = CGRectMake(x, 0, ceil(textWidth * shrinkFactor) + kPadding*2 , self.height);
        x += tab.width;
      }
    } else {
      CGFloat averageTabWidth = ceil((self.width - kTabMargin*2)/_tabViews.count);
      if (maxTabWidth > averageTabWidth && self.width - totalTabWidth < kTabMargin) {
        for (int i = 0; i < _tabViews.count; ++i) {
          TTTabView* tab = [_tabViews objectAtIndex:i];
          tab.frame = CGRectMake(x, 0, tab.width, self.height);
          x += tab.width;
        }
      } else {
        for (int i = 0; i < _tabViews.count; ++i) {
          TTTabView* tab = [_tabViews objectAtIndex:i];
          tab.frame = CGRectMake(x, 0, averageTabWidth, self.height);
          x += tab.width;
        }
      }
    }
  } else {
    for (int i = 0; i < _tabViews.count; ++i) {
      TTTabView* tab = [_tabViews objectAtIndex:i];
      [tab sizeToFit];
      tab.frame = CGRectMake(x, 0, tab.width, self.height);
      x += tab.width;
    }
  }
    
  CGPoint contentOffset = _scrollView.contentOffset;
  _scrollView.frame = self.bounds;
  _scrollView.contentSize = CGSizeMake(x + kTabMargin, self.height);
  _scrollView.contentOffset = contentOffset;
}

- (void)tabTouchedUp:(TTTabView*)tab {
  self.selectedTabView = tab;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// UIView

//- (void)drawRect:(CGRect)rect {
//  if (_style == TTTabBarStyleLight) {
//    CGContextRef context = UIGraphicsGetCurrentContext();
//    CGColorSpaceRef space = CGColorSpaceCreateDeviceRGB();
//
//    CGContextSetFillColor(context, kReflectionBottom);
//    CGContextFillRect(context, CGRectMake(rect.origin.x, floor(rect.size.height/2)+3,
//        rect.size.width, floor(rect.size.height/2)-3));
//    
//    CGPoint bottomLine2[] = {rect.origin.x, rect.origin.y+rect.size.height-0.5,
//      rect.origin.x+rect.size.width, rect.origin.y+rect.size.height-0.5};
//    CGPoint bottomLine[] = {rect.origin.x, rect.origin.y+rect.size.height-1.5,
//      rect.origin.x+rect.size.width, rect.origin.y+rect.size.height-1.5};
//
//    CGContextSaveGState(context);
//    CGContextSetStrokeColorSpace(context, space);
//    CGContextSetLineWidth(context, 1.0);
//    CGContextSetStrokeColor(context, kBottomLightShadow);
//    CGContextStrokeLineSegments(context, bottomLine, 2);
//    CGContextSetStrokeColor(context, kBottomHighlight);
//    CGContextStrokeLineSegments(context, bottomLine2, 2);
//    CGContextRestoreGState(context);
//    
//    CGColorSpaceRelease(space);
//  } else if (_style == TTTabBarStyleButtons) {
//    CGContextRef context = UIGraphicsGetCurrentContext();
//    CGColorSpaceRef space = CGColorSpaceCreateDeviceRGB();
//
//    CGFloat locations[] = {0, 1};
//    
//    CGFloat halfHeight = rect.size.height > 10
//      ? floor(rect.size.height/2)+1
//      : rect.size.height;
//    
//    CGGradientRef gradient = CGGradientCreateWithColorComponents(space, kGradient1, locations, 2);
//    CGContextDrawLinearGradient(context, gradient, CGPointMake(0, 0),
//      CGPointMake(0, halfHeight), 0);
//    CGGradientRelease(gradient);
//
//    if (rect.size.height > 10) {
//      CGContextSetFillColor(context, kReflectionBottom2);
//      CGContextFillRect(context, CGRectMake(rect.origin.x, floor(rect.size.height/2)+1,
//          rect.size.width, floor(rect.size.height/2)-1));
//    }
//    
//    CGPoint topLine[] = {rect.origin.x, rect.origin.y+0.5,
//      rect.origin.x+rect.size.width, rect.origin.y+0.5};
//    CGPoint topLine2[] = {rect.origin.x, rect.origin.y+1.5,
//      rect.origin.x+rect.size.width, rect.origin.y+1.5};
//    CGPoint bottomLine[] = {rect.origin.x, rect.origin.y+rect.size.height-0.5,
//      rect.origin.x+rect.size.width, rect.origin.y+rect.size.height-0.5};
//
//    CGContextSaveGState(context);
//    CGContextSetStrokeColorSpace(context, space);
//    CGContextSetLineWidth(context, 1.0);
//    CGContextSetStrokeColor(context, kTopShadow);
//    CGContextStrokeLineSegments(context, topLine, 2);
//    CGContextSetStrokeColor(context, kTopHighlight);
//    CGContextStrokeLineSegments(context, topLine2, 2);
//    CGContextSetStrokeColor(context, kBottomShadow);
//    CGContextStrokeLineSegments(context, bottomLine, 2);
//    CGContextRestoreGState(context);
//    
//    CGColorSpaceRelease(space);
//  }
//}

- (void)layoutSubviews {
  [super layoutSubviews];
  [self updateOverflow];
}

///////////////////////////////////////////////////////////////////////////////////////////////////

- (TTTabItem*)selectedTabItem {
  if (_selectedTabIndex != NSIntegerMax) {
    return [_tabItems objectAtIndex:_selectedTabIndex];
  }
  return nil;
}

- (void)setSelectedTabItem:(TTTabItem*)tabItem {
  self.selectedTabIndex = [_tabItems indexOfObject:tabItem];
}

- (TTTabView*)selectedTabView {
  if (_selectedTabIndex != NSIntegerMax && _selectedTabIndex < _tabViews.count) {
    return [_tabViews objectAtIndex:_selectedTabIndex];
  }
  return nil;
}

- (void)setSelectedTabView:(TTTabView*)tab {
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
    TTTabView* tab = [_tabViews objectAtIndex:i];
    [tab removeFromSuperview];
  }
  
  [_tabViews removeAllObjects];

  if (_selectedTabIndex >= _tabViews.count) {
    _selectedTabIndex = 0;
  }

  for (int i = 0; i < _tabItems.count; ++i) {
    TTTabItem* tabItem = [_tabItems objectAtIndex:i];
    TTTabView* tab = [[[TTTabView alloc] initWithItem:tabItem tabBar:self] autorelease];
    [tab setStylesWithSelector:self.tabStyle];
    [tab addTarget:self action:@selector(tabTouchedUp:) forControlEvents:UIControlEventTouchUpInside];
    if (_scrollView) {
      [_scrollView addSubview:tab];
    } else {
      [_scrollView addSubview:tab];
    }
    [_tabViews addObject:tab];
    if (i == _selectedTabIndex) {
      tab.selected = YES;
    }
  }
  
  [self layoutTabs];
  
  if (_scrollView) {
    [self updateOverflow];
  }
}

- (void)showTabAtIndex:(NSInteger)tabIndex {
  TTTabView* tab = [_tabViews objectAtIndex:tabIndex];
  tab.hidden = NO;
}

- (void)hideTabAtIndex:(NSInteger)tabIndex {
  TTTabView* tab = [_tabViews objectAtIndex:tabIndex];
  tab.hidden = YES;
}

@end

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation TTTabView

@synthesize tabItem = _tabItem;

- (id)initWithItem:(TTTabItem*)tabItem tabBar:(TTTabBar*)tabBar {
  if (self = [self initWithFrame:CGRectZero]) {
    _badge = nil;
        
    self.tabItem = tabItem;
  }
  return self;
}

- (void)dealloc {
  [_tabItem release];
  [_badge release];
  [super dealloc];
}

///////////////////////////////////////////////////////////////////////////////////////////////////

- (void)updateBadgeNumber {
  if (_tabItem.badgeNumber) {
    if (!_badge) {
      _badge = [[TTStyledLabel alloc] initWithFrame:CGRectZero];
      _badge.style = TTSTYLE(badge);
      _badge.backgroundColor = [UIColor clearColor];
      _badge.userInteractionEnabled = NO;
      [self addSubview:_badge];
    }
    _badge.text = [NSString stringWithFormat:@"%d", _tabItem.badgeNumber];
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
  [_title release];
  [_icon release];
  [_object release];
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
