#import "Three20/T3TabBar.h"
#import "Three20/T3ImageView.h"

///////////////////////////////////////////////////////////////////////////////////////////////////

static CGFloat kTabMargin = 8;
static CGFloat kPadding = 11;

static CGFloat kTabMargin2 = 10;
static CGFloat kPadding2 = 10;

static CGFloat kIconSize = 16;
static CGFloat kIconSpacing = 3;

static CGFloat kBadgeHPadding = 8;

static UIImage* selectedTabImage = nil;
static UIImage* selectedLightImage = nil;
static UIImage* selectedButtonImage = nil;

static CGFloat kGradient1[] = {RGBA(233, 238, 246, 1), RGBA(229, 235, 243, 1), 1};

static CGFloat kReflectionBottom[] = {RGBA(228, 230, 235, 1)};
static CGFloat kReflectionBottom2[] = {RGBA(214, 220, 230, 1)};

static CGFloat kTopHighlight[] = {RGBA(247, 249, 252, 1)};
static CGFloat kTopShadow[] = {RGBA(62, 70, 102, 1)};
static CGFloat kBottomShadow[] = {RGBA(202, 205, 210, 1)};

static CGFloat kBottomLightShadow[] = {RGBA(207, 213, 225, 1)};
static CGFloat kBottomHighlight[] = {RGBA(250, 250, 252, 1)};

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation T3TabBar

@synthesize delegate = _delegate, selectedTabIndex = _selectedTabIndex, tabItems = _tabItems,
  tabViews = _tabViews, textColor = _textColor;

- (id)initWithFrame:(CGRect)frame style:(T3TabBarStyle)style {
  if (self = [super initWithFrame:frame]) {
    _style = style;
    _selectedTabIndex = NSIntegerMax;
    _tabItems = nil;
    _tabViews = [[NSMutableArray alloc] init];
    _trackingTab = nil;
    _textColor = [[UIColor blackColor] retain];
    
    if (_style == T3TabBarStyleButtons) {
      _scrollView = [[UIScrollView alloc] initWithFrame:CGRectZero];
      _scrollView.scrollEnabled = NO;
      _scrollView.scrollsToTop = NO;
      [self addSubview:_scrollView];

      _overflowLeft = [[UIImageView alloc] initWithImage:
        [UIImage imageNamed:@"images/overflowLeft.png"]];
      _overflowRight.hidden = YES;
      [self addSubview:_overflowLeft];
      _overflowRight = [[UIImageView alloc] initWithImage:
        [UIImage imageNamed:@"images/overflowRight.png"]];
      _overflowRight.hidden = YES;
      [self addSubview:_overflowRight];
    } else {
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
  [_textColor release];
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
  CGFloat x = _style == T3TabBarStyleButtons ? kTabMargin2 : kTabMargin;

  if (self.contentMode == UIViewContentModeScaleToFill) {
    CGFloat tabWidth = floor((self.width - x*2)/_tabViews.count);
    for (int i = 0; i < _tabViews.count; ++i) {
      T3TabView* tab = [_tabViews objectAtIndex:i];
      tab.frame = CGRectMake(x, 0, tabWidth, self.height);
      x += tab.width;
    }
  } else {
    for (int i = 0; i < _tabViews.count; ++i) {
      T3TabView* tab = [_tabViews objectAtIndex:i];
      [tab sizeToFit];
      tab.frame = CGRectMake(x, 0, tab.width, self.height);
      x += tab.width;
    }
  }
    
  if (_style == T3TabBarStyleButtons) {
    CGPoint contentOffset = _scrollView.contentOffset;
    _scrollView.frame = self.bounds;
    _scrollView.contentSize = CGSizeMake(x + kTabMargin2, self.height);
    _scrollView.contentOffset = contentOffset;
  }
}

- (void)tabTouchedUp:(T3TabView*)tab {
  self.selectedTabView = tab;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// UIView

- (void)drawRect:(CGRect)rect {
  if (_style == T3TabBarStyleLight) {
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
  } else if (_style == T3TabBarStyleButtons) {
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

- (T3TabItem*)selectedTabItem {
  if (_selectedTabIndex != NSIntegerMax) {
    return [_tabItems objectAtIndex:_selectedTabIndex];
  }
  return nil;
}

- (void)setSelectedTabItem:(T3TabItem*)tabItem {
  self.selectedTabIndex = [_tabItems indexOfObject:tabItem];
}

- (T3TabView*)selectedTabView {
  if (_selectedTabIndex != NSIntegerMax && _selectedTabIndex < _tabViews.count) {
    return [_tabViews objectAtIndex:_selectedTabIndex];
  }
  return nil;
}

- (void)setSelectedTabView:(T3TabView*)tab {
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
    T3TabView* tab = [_tabViews objectAtIndex:i];
    [tab removeFromSuperview];
  }
  
  [_tabViews removeAllObjects];

  if (_selectedTabIndex >= _tabViews.count) {
    _selectedTabIndex = 0;
  }

  for (int i = 0; i < _tabItems.count; ++i) {
    T3TabItem* tabItem = [_tabItems objectAtIndex:i];
    T3TabView* tab = [[[T3TabView alloc] initWithItem:tabItem tabBar:self style:_style] autorelease];
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
  T3TabView* tab = [_tabViews objectAtIndex:tabIndex];
  tab.hidden = NO;
}

- (void)hideTabAtIndex:(NSInteger)tabIndex {
  T3TabView* tab = [_tabViews objectAtIndex:tabIndex];
  tab.hidden = YES;
}

@end

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation T3TabView

@synthesize tabItem = _tabItem;

- (id)initWithItem:(T3TabItem*)tabItem tabBar:(T3TabBar*)tabBar style:(T3TabBarStyle)style {
  if (self = [self initWithFrame:CGRectZero]) {
    _style = style;
    _badgeImage = nil;
    _badgeLabel = nil;
    
    _tabImage = [[UIImageView alloc] initWithFrame:CGRectZero];
    _tabImage.hidden = YES;
    [self addSubview:_tabImage];

    _iconView = [[T3ImageView alloc] initWithFrame:CGRectZero];
    _iconView.contentMode = UIViewContentModeRight;
    _iconView.clipsToBounds = YES;
    [self addSubview:_iconView];

    _titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _titleLabel.backgroundColor = [UIColor clearColor];
    _titleLabel.contentMode = UIViewContentModeCenter;
    _titleLabel.shadowOffset = CGSizeMake(0, -1);
    
    if (_style == T3TabBarStyleDark) {
      if (!selectedTabImage) {
        selectedTabImage = [[[UIImage imageNamed:@"images/darkTab.png"]
          stretchableImageWithLeftCapWidth:5 topCapHeight:0] retain];
      }

      _tabImage.image = selectedTabImage;

      _titleLabel.textAlignment = UITextAlignmentCenter;
      _titleLabel.font = [UIFont boldSystemFontOfSize:15];
      _titleLabel.textColor = RGBCOLOR(223, 229, 237);
      _titleLabel.highlightedTextColor = [UIColor colorWithWhite:0.1 alpha:1];
      _titleLabel.shadowColor = [UIColor colorWithWhite:0 alpha:0.6];
    } else if (_style == T3TabBarStyleLight) {
      if (!selectedLightImage) {
        selectedLightImage = [[[UIImage imageNamed:@"images/lightTab.png"]
          stretchableImageWithLeftCapWidth:5 topCapHeight:0] retain];
      }

      _tabImage.image = selectedLightImage;

      _titleLabel.textAlignment = UITextAlignmentCenter;
      _titleLabel.font = [UIFont boldSystemFontOfSize:17];
      _titleLabel.textColor = tabBar.textColor;
      _titleLabel.highlightedTextColor = [UIColor colorWithWhite:0.1 alpha:1];
      _titleLabel.shadowColor = [UIColor whiteColor];
    } else if (_style == T3TabBarStyleButtons) {
      if (!selectedButtonImage) {
        selectedButtonImage = [[[UIImage imageNamed:@"images/feedButton.png"]
          stretchableImageWithLeftCapWidth:12 topCapHeight:0] retain];
      }

      _tabImage.image = selectedButtonImage;

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
    _badgeImage.image = [[UIImage imageNamed:@"images/badge.png"]
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
    _badgeLabel.frame = CGRectMake(_badgeImage.x, _badgeImage.y, _badgeImage.width, 22);
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

  if (_style == T3TabBarStyleButtons) {
    CGFloat iconWidth = _iconView.url.length ? kIconSize + kIconSpacing : 0;
    _iconView.frame = CGRectMake(kPadding2, floor(self.height/2 - kIconSize/2)+2,
      kIconSize, kIconSize);
    _titleLabel.frame = CGRectOffset(self.bounds, kPadding2 + iconWidth, 0);
  } else if (_style == T3TabBarStyleLight) {
    _iconView.frame = CGRectZero;
    _titleLabel.frame = CGRectOffset(self.bounds, 0, 2);
  } else if (_style == T3TabBarStyleDark) {
    _iconView.frame = CGRectZero;
    _titleLabel.frame = CGRectOffset(self.bounds, 0, 2);
  }
}

- (void)sizeToFit {
  [_titleLabel sizeToFit];
  CGFloat padding = _style == T3TabBarStyleButtons ? kPadding2 : kPadding;
  CGFloat iconWidth = _iconView.url.length ? kIconSize + kIconSpacing : 0;
  self.frame = CGRectMake(self.x, self.y, _titleLabel.width + iconWidth + padding*2, self.height);
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// UIControl

- (void)setSelected:(BOOL)selected {
  [super setSelected:selected];
  _tabImage.hidden = !selected;
  _titleLabel.highlighted = selected;
  if (_style == T3TabBarStyleButtons) {
    if (selected) {
      _iconView.contentMode = UIViewContentModeLeft;
      _titleLabel.shadowColor = [UIColor colorWithWhite:0 alpha:0.3];
    } else {
      _iconView.contentMode = UIViewContentModeRight;
      _titleLabel.shadowColor = [UIColor whiteColor];
    }
  } else if (_style == T3TabBarStyleLight) {
  } else if (_style == T3TabBarStyleDark) {
    if (selected) {
      _titleLabel.shadowColor = [UIColor whiteColor];
    } else {
      _titleLabel.shadowColor = [UIColor colorWithWhite:0 alpha:0.6];
    }
  }
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// T3TabItemDelegate

- (void)tabItem:(T3TabItem*)item badgeNumberChangedTo:(int)value {
  [self updateBadgeNumber];
}

///////////////////////////////////////////////////////////////////////////////////////////////////

- (void)setTabItem:(T3TabItem*)tabItem {
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

@implementation T3TabItem

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

- (void)setTabBar:(T3TabBar*)tabBar {
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
