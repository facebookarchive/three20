#import "Three20/TTTabBar.h"
#import "Three20/TTImageView.h"
#import "Three20/TTDefaultStyleSheet.h"

///////////////////////////////////////////////////////////////////////////////////////////////////

static CGFloat kTabMargin = 8;
static CGFloat kPadding = 11;

static CGFloat kTabMargin2 = 10;
static CGFloat kPadding2 = 10;

static CGFloat kIconSize = 16;
static CGFloat kIconSpacing = 3;

static CGFloat kBadgeHPadding = 8;

static CGFloat kGradient1[] = {RGBA(233, 238, 246, 1), RGBA(229, 235, 243, 1), 1};

static CGFloat kReflectionBottom[] = {RGBA(228, 230, 235, 1)};
static CGFloat kReflectionBottom2[] = {RGBA(214, 220, 230, 1)};

static CGFloat kTopHighlight[] = {RGBA(247, 249, 252, 1)};
static CGFloat kTopShadow[] = {RGBA(62, 70, 102, 1)};
static CGFloat kBottomShadow[] = {RGBA(202, 205, 210, 1)};

static CGFloat kBottomLightShadow[] = {RGBA(207, 213, 225, 1)};
static CGFloat kBottomHighlight[] = {RGBA(250, 250, 252, 1)};

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation TTTabBar

@synthesize delegate = _delegate, selectedTabIndex = _selectedTabIndex, tabItems = _tabItems,
  tabViews = _tabViews, textColor = _textColor, tintColor = _tintColor, tabImage = _tabImage;

- (id)initWithFrame:(CGRect)frame style:(TTTabBarStyle)style {
  if (self = [super initWithFrame:frame]) {
    _style = style;
    _selectedTabIndex = NSIntegerMax;
    _tabItems = nil;
    _tabViews = [[NSMutableArray alloc] init];
    self.textColor = TTSTYLEVAR(linkTextColor);
    _tintColor = nil;
    
    self.contentMode = UIViewContentModeLeft;
    
    if (_style == TTTabBarStyleButtons) {
      self.tabImage = [[UIImage imageNamed:@"Three20.bundle/images/tabButton.png"]
        stretchableImageWithLeftCapWidth:12 topCapHeight:0];
            
      _scrollView = [[UIScrollView alloc] initWithFrame:CGRectZero];
      _scrollView.scrollEnabled = YES;
      _scrollView.scrollsToTop = NO;
      _scrollView.showsVerticalScrollIndicator = NO;
      _scrollView.showsHorizontalScrollIndicator = NO;
      [self addSubview:_scrollView];

      _overflowLeft = [[UIImageView alloc] initWithImage:
        [UIImage imageNamed:@"Three20.bundle/images/overflowLeft.png"]];
      _overflowRight.hidden = YES;
      [self addSubview:_overflowLeft];
      _overflowRight = [[UIImageView alloc] initWithImage:
        [UIImage imageNamed:@"Three20.bundle/images/overflowRight.png"]];
      _overflowRight.hidden = YES;
      [self addSubview:_overflowRight];
    } else {
      if (_style == TTTabBarStyleLight) {
        self.tabImage = [[UIImage imageNamed:@"Three20.bundle/images/lightTab.png"]
          stretchableImageWithLeftCapWidth:5 topCapHeight:0];

        self.backgroundColor = RGBCOLOR(237, 239, 244);
      } else if (_style == TTTabBarStyleDark) {
        self.tabImage = [[UIImage imageNamed:@"Three20.bundle/images/darkTab.png"]
                  stretchableImageWithLeftCapWidth:5 topCapHeight:0];

        self.backgroundColor = RGBCOLOR(110, 132, 162);
      }
      _scrollView = nil;
      _overflowLeft = nil;
      _overflowRight = nil;
    }
  }
  return self;
}

- (void)dealloc {
  [_tabItems release];
  [_tabViews release];
  [_overflowLeft release];
  [_overflowRight release];
  [_scrollView release];
  [_tabImage release];
  [_textColor release];
  [_tintColor release];
  [super dealloc];
}

///////////////////////////////////////////////////////////////////////////////////////////////////

- (void)updateOverflow {
  if (_scrollView.contentOffset.x < (_scrollView.contentSize.width-self.width)) {
    _overflowRight.frame = CGRectMake(self.width-_overflowRight.width, 2,
      _overflowRight.width, _overflowRight.height);
    _overflowRight.hidden = NO;
  } else {
    _overflowRight.hidden = YES;
  }
  if (_scrollView.contentOffset.x > 0) {
    _overflowLeft.frame = CGRectMake(0, 2, _overflowLeft.width, _overflowLeft.height);
    _overflowLeft.hidden = NO;
  } else {
    _overflowLeft.hidden = YES;
  }
}

- (void)layoutTabs {
  CGFloat margin = _style == TTTabBarStyleButtons ? kTabMargin2 : kTabMargin;
  CGFloat padding = _style == TTTabBarStyleButtons ? kPadding2 : kPadding;
  CGFloat x = margin;

  if (self.contentMode == UIViewContentModeScaleToFill) {
    CGFloat maxTextWidth = self.width - (margin*2 + padding*2*_tabViews.count);
    CGFloat totalTextWidth = 0;
    CGFloat totalTabWidth = margin*2;
    CGFloat maxTabWidth = 0;
    for (int i = 0; i < _tabViews.count; ++i) {
      TTTabView* tab = [_tabViews objectAtIndex:i];
      [tab sizeToFit];
      totalTextWidth += tab.width - padding*2;
      totalTabWidth += tab.width;
      if (tab.width > maxTabWidth) {
        maxTabWidth = tab.width;
      }
    }

    if (totalTextWidth > maxTextWidth) {
      CGFloat shrinkFactor = maxTextWidth/totalTextWidth;
      for (int i = 0; i < _tabViews.count; ++i) {
        TTTabView* tab = [_tabViews objectAtIndex:i];
        CGFloat textWidth = tab.width - padding*2;
        tab.frame = CGRectMake(x, 0, ceil(textWidth * shrinkFactor) + padding*2 , self.height);
        x += tab.width;
      }
    } else {
      CGFloat averageTabWidth = ceil((self.width - margin*2)/_tabViews.count);
      if (maxTabWidth > averageTabWidth && self.width - totalTabWidth < margin) {
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
    
  if (_style == TTTabBarStyleButtons) {
    CGPoint contentOffset = _scrollView.contentOffset;
    _scrollView.frame = self.bounds;
    _scrollView.contentSize = CGSizeMake(x + kTabMargin2, self.height);
    _scrollView.contentOffset = contentOffset;
  }
}

- (void)tabTouchedUp:(TTTabView*)tab {
  self.selectedTabView = tab;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// UIView

- (void)drawRect:(CGRect)rect {
  if (_style == TTTabBarStyleLight) {
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGColorSpaceRef space = CGColorSpaceCreateDeviceRGB();

    CGContextSetFillColor(context, kReflectionBottom);
    CGContextFillRect(context, CGRectMake(rect.origin.x, floor(rect.size.height/2)+3,
        rect.size.width, floor(rect.size.height/2)-3));
    
    CGPoint bottomLine2[] = {rect.origin.x, rect.origin.y+rect.size.height-0.5,
      rect.origin.x+rect.size.width, rect.origin.y+rect.size.height-0.5};
    CGPoint bottomLine[] = {rect.origin.x, rect.origin.y+rect.size.height-1.5,
      rect.origin.x+rect.size.width, rect.origin.y+rect.size.height-1.5};

    CGContextSaveGState(context);
    CGContextSetStrokeColorSpace(context, space);
    CGContextSetLineWidth(context, 1.0);
    CGContextSetStrokeColor(context, kBottomLightShadow);
    CGContextStrokeLineSegments(context, bottomLine, 2);
    CGContextSetStrokeColor(context, kBottomHighlight);
    CGContextStrokeLineSegments(context, bottomLine2, 2);
    CGContextRestoreGState(context);
    
    CGColorSpaceRelease(space);
  } else if (_style == TTTabBarStyleButtons) {
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGColorSpaceRef space = CGColorSpaceCreateDeviceRGB();

    CGFloat locations[] = {0, 1};
    
    CGFloat halfHeight = rect.size.height > 10
      ? floor(rect.size.height/2)+1
      : rect.size.height;
    
    CGGradientRef gradient = CGGradientCreateWithColorComponents(space, kGradient1, locations, 2);
    CGContextDrawLinearGradient(context, gradient, CGPointMake(0, 0),
      CGPointMake(0, halfHeight), 0);
    CGGradientRelease(gradient);

    if (rect.size.height > 10) {
      CGContextSetFillColor(context, kReflectionBottom2);
      CGContextFillRect(context, CGRectMake(rect.origin.x, floor(rect.size.height/2)+1,
          rect.size.width, floor(rect.size.height/2)-1));
    }
    
    CGPoint topLine[] = {rect.origin.x, rect.origin.y+0.5,
      rect.origin.x+rect.size.width, rect.origin.y+0.5};
    CGPoint topLine2[] = {rect.origin.x, rect.origin.y+1.5,
      rect.origin.x+rect.size.width, rect.origin.y+1.5};
    CGPoint bottomLine[] = {rect.origin.x, rect.origin.y+rect.size.height-0.5,
      rect.origin.x+rect.size.width, rect.origin.y+rect.size.height-0.5};

    CGContextSaveGState(context);
    CGContextSetStrokeColorSpace(context, space);
    CGContextSetLineWidth(context, 1.0);
    CGContextSetStrokeColor(context, kTopShadow);
    CGContextStrokeLineSegments(context, topLine, 2);
    CGContextSetStrokeColor(context, kTopHighlight);
    CGContextStrokeLineSegments(context, topLine2, 2);
    CGContextSetStrokeColor(context, kBottomShadow);
    CGContextStrokeLineSegments(context, bottomLine, 2);
    CGContextRestoreGState(context);
    
    CGColorSpaceRelease(space);
  }
}

- (void)layoutSubviews {
  [super layoutSubviews];
  [self updateOverflow];
}

///////////////////////////////////////////////////////////////////////////////////////////////////

- (CGPoint)contentOffset {
  if (_scrollView) {
    return _scrollView.contentOffset;
  } else {
    return CGPointMake(0, 0);
  }
}

- (void)setContentOffset:(CGPoint)offset {
  if (_scrollView) {
    _scrollView.contentOffset = offset;
  }
}

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
    TTTabView* tab = [[[TTTabView alloc] initWithItem:tabItem tabBar:self style:_style] autorelease];
    [tab addTarget:self action:@selector(tabTouchedUp:) forControlEvents:UIControlEventTouchUpInside];
    if (_scrollView) {
      [_scrollView addSubview:tab];
    } else {
      [self addSubview:tab];
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

- (id)initWithItem:(TTTabItem*)tabItem tabBar:(TTTabBar*)tabBar style:(TTTabBarStyle)style {
  if (self = [self initWithFrame:CGRectZero]) {
    _style = style;
    _badgeImage = nil;
    _badgeLabel = nil;
    
    _tabImage = [[UIImageView alloc] initWithFrame:CGRectZero];
    _tabImage.hidden = YES;
    [self addSubview:_tabImage];

    _iconView = [[TTImageView alloc] initWithFrame:CGRectZero];
    _iconView.contentMode = UIViewContentModeRight;
    _iconView.clipsToBounds = YES;
    [self addSubview:_iconView];

    _titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _titleLabel.backgroundColor = [UIColor clearColor];
    _titleLabel.contentMode = UIViewContentModeCenter;
    _titleLabel.shadowOffset = CGSizeMake(0, -1);
    _titleLabel.adjustsFontSizeToFitWidth = YES;
    _titleLabel.minimumFontSize = 8;
    _tabImage.image = tabBar.tabImage;
    
    if (_style == TTTabBarStyleDark) {

      _titleLabel.textAlignment = UITextAlignmentCenter;
      _titleLabel.font = [UIFont boldSystemFontOfSize:15];
      _titleLabel.textColor = RGBCOLOR(223, 229, 237);
      _titleLabel.highlightedTextColor = [UIColor colorWithWhite:0.1 alpha:1];
      _titleLabel.shadowColor = [UIColor colorWithWhite:0 alpha:0.4];
      _titleLabel.adjustsFontSizeToFitWidth = YES;
      _titleLabel.minimumFontSize = 9;
    } else if (_style == TTTabBarStyleLight) {
      _titleLabel.textAlignment = UITextAlignmentCenter;
      _titleLabel.font = [UIFont boldSystemFontOfSize:17];
      _titleLabel.textColor = tabBar.textColor;
      _titleLabel.highlightedTextColor = [UIColor colorWithWhite:0.1 alpha:1];
      _titleLabel.shadowColor = [UIColor whiteColor];
      _titleLabel.adjustsFontSizeToFitWidth = YES;
      _titleLabel.minimumFontSize = 9;
    } else if (_style == TTTabBarStyleButtons) {
      _titleLabel.textAlignment = UITextAlignmentLeft;
      _titleLabel.font = [UIFont boldSystemFontOfSize:13];
      _titleLabel.textColor = tabBar.textColor;
      _titleLabel.highlightedTextColor = [UIColor whiteColor];
      _titleLabel.shadowColor = [UIColor whiteColor];
    }
    [self addSubview:_titleLabel];

    self.tabItem = tabItem;
  }
  return self;
}

- (void)dealloc {
  [_tabItem release];
  [_tabImage release];
  [_iconView release];
  [_titleLabel release];
  [_badgeImage release];
  [_badgeLabel release];
  [super dealloc];
}

///////////////////////////////////////////////////////////////////////////////////////////////////

- (void)updateBadgeNumber {
  if (!_badgeImage && _tabItem.badgeNumber) {
    _badgeImage = [[UIImageView alloc] initWithFrame:CGRectZero];
    _badgeImage.image = [[UIImage imageNamed:@"Three20.bundle/images/badge.png"]
      stretchableImageWithLeftCapWidth:12 topCapHeight:15];
    [self addSubview:_badgeImage];
    
    _badgeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _badgeLabel.backgroundColor = [UIColor clearColor];
    _badgeLabel.font = [UIFont boldSystemFontOfSize:14];
    _badgeLabel.textColor = [UIColor whiteColor];
    _badgeLabel.contentMode = UIViewContentModeCenter;
    _badgeLabel.textAlignment = UITextAlignmentCenter;    
    [self addSubview:_badgeLabel];
  }
  
  if (_tabItem.badgeNumber) {
    _badgeLabel.text = [NSString stringWithFormat:@"%d", _tabItem.badgeNumber];
    [_badgeLabel sizeToFit];
    
    _badgeImage.frame = CGRectMake(self.width - (_badgeLabel.width + kBadgeHPadding*2), 0,
      _badgeLabel.width + 1 + kBadgeHPadding*2, 28);
    _badgeLabel.frame = CGRectMake(_badgeImage.left, _badgeImage.top, _badgeImage.width, 22);
    _badgeImage.hidden = NO;
    _badgeLabel.hidden = NO;
  } else {
    _badgeImage.hidden = YES;
    _badgeLabel.hidden = YES;
  }
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// UIView

- (void)layoutSubviews {
  [super layoutSubviews];

  _tabImage.frame = self.bounds;

  CGSize titleSize = [_titleLabel.text sizeWithFont:_titleLabel.font];
  
  CGFloat textWidth = self.width;
  CGFloat textLeft = 0;
  if (titleSize.width > self.width) {
    textLeft = 4;
    textWidth -= 8;
  }
  
  if (_style == TTTabBarStyleButtons) {
    CGFloat iconWidth = _iconView.url.length ? kIconSize + kIconSpacing : 0;
    _iconView.frame = CGRectMake(kPadding2, floor(self.height/2 - kIconSize/2)+2,
      kIconSize, kIconSize);
    _titleLabel.frame = CGRectOffset(self.bounds, kPadding2 + iconWidth, 0);
  } else if (_style == TTTabBarStyleLight) {
    _iconView.frame = CGRectZero;
    _titleLabel.frame = CGRectMake(textLeft, self.bounds.origin.y + 2,
      textWidth, self.height);
  } else if (_style == TTTabBarStyleDark) {
    _iconView.frame = CGRectZero;
    _titleLabel.frame = CGRectMake(textLeft, self.bounds.origin.y + 2,
      textWidth, self.height);
  }
}

- (CGSize)sizeThatFits:(CGSize)size {
  CGSize titleSize = [_titleLabel sizeThatFits:size];
  CGFloat padding = _style == TTTabBarStyleButtons ? kPadding2 : kPadding;
  CGFloat iconWidth = _iconView.url.length ? kIconSize + kIconSpacing : 0;
  
  return CGSizeMake(iconWidth + titleSize.width + padding*2, size.height);
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// UIControl

- (void)setSelected:(BOOL)selected {
  [super setSelected:selected];
  _tabImage.hidden = !selected;
  _titleLabel.highlighted = selected;
  if (_style == TTTabBarStyleButtons) {
    if (selected) {
      _iconView.contentMode = UIViewContentModeLeft;
      _titleLabel.shadowColor = [UIColor colorWithWhite:0 alpha:0.3];
    } else {
      _iconView.contentMode = UIViewContentModeRight;
      _titleLabel.shadowColor = [UIColor whiteColor];
    }
  } else if (_style == TTTabBarStyleLight) {
  } else if (_style == TTTabBarStyleDark) {
    if (selected) {
      _titleLabel.shadowColor = [UIColor whiteColor];
    } else {
      _titleLabel.shadowColor = [UIColor colorWithWhite:0 alpha:0.6];
    }
  }
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// TTTabItemDelegate

- (void)tabItem:(TTTabItem*)item badgeNumberChangedTo:(int)value {
  [self updateBadgeNumber];
}

///////////////////////////////////////////////////////////////////////////////////////////////////

- (void)setTabItem:(TTTabItem*)tabItem {
  [_tabItem performSelector:@selector(setTabBar:) withObject:nil];
  [_tabItem release];
  _tabItem = [tabItem retain];
  [_tabItem performSelector:@selector(setTabBar:) withObject:self];
  
  _titleLabel.text = _tabItem.title;
  _iconView.url = _tabItem.icon;
  if (_tabItem.badgeNumber) {
    [self updateBadgeNumber];
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
