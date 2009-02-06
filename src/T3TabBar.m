// Copyright 2004-2009 Facebook. All Rights Reserved.

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

@synthesize delegate, selectedTabIndex, tabItems, tabViews, textColor;

- (id)initWithFrame:(CGRect)frame style:(T3TabBarStyle)aStyle {
  if (self = [super initWithFrame:frame]) {
    style = aStyle;
    selectedTabIndex = NSIntegerMax;
    tabItems = nil;
    tabViews = [[NSMutableArray alloc] init];
    trackingTab = nil;
    textColor = [[UIColor blackColor] retain];
    
    if (style == T3TabBarStyleButtons) {
      scrollView = [[UIScrollView alloc] initWithFrame:CGRectZero];
      scrollView.scrollEnabled = NO;
      scrollView.scrollsToTop = NO;
      [self addSubview:scrollView];

      overflowLeft = [[UIImageView alloc] initWithImage:
        [UIImage imageNamed:@"images/overflowLeft.png"]];
      overflowRight.hidden = YES;
      [self addSubview:overflowLeft];
      overflowRight = [[UIImageView alloc] initWithImage:
        [UIImage imageNamed:@"images/overflowRight.png"]];
      overflowRight.hidden = YES;
      [self addSubview:overflowRight];
    } else {
      scrollView = nil;
      overflowLeft = nil;
      overflowRight = nil;
    }
  }
  return self;
}

- (void)dealloc {
  [tabItems release];
  [tabViews release];
  [overflowLeft release];
  [overflowRight release];
  [scrollView release];
  [textColor release];
  [super dealloc];
}

///////////////////////////////////////////////////////////////////////////////////////////////////

- (void)updateOverflow {
  if (scrollView.contentOffset.x < (scrollView.contentSize.width-self.width)) {
    overflowRight.frame = CGRectMake(self.width-overflowRight.width, 2,
      overflowRight.width, overflowRight.height);
    overflowRight.hidden = NO;
  } else {
    overflowRight.hidden = YES;
  }
  if (scrollView.contentOffset.x > 0) {
    overflowLeft.frame = CGRectMake(0, 2, overflowLeft.width, overflowLeft.height);
    overflowLeft.hidden = NO;
  } else {
    overflowLeft.hidden = YES;
  }
}

- (void)layoutTabs {
  CGFloat x = style == T3TabBarStyleButtons ? kTabMargin2 : kTabMargin;

  if (self.contentMode == UIViewContentModeScaleToFill) {
    CGFloat tabWidth = floor((self.width - x*2)/tabViews.count);
    for (int i = 0; i < tabViews.count; ++i) {
      T3TabView* tab = [tabViews objectAtIndex:i];
      tab.frame = CGRectMake(x, 0, tabWidth, self.height);
      x += tab.width;
    }
  } else {
    for (int i = 0; i < tabViews.count; ++i) {
      T3TabView* tab = [tabViews objectAtIndex:i];
      [tab sizeToFit];
      tab.frame = CGRectMake(x, 0, tab.width, self.height);
      x += tab.width;
    }
  }
    
  if (style == T3TabBarStyleButtons) {
    CGPoint contentOffset = scrollView.contentOffset;
    scrollView.frame = self.bounds;
    scrollView.contentSize = CGSizeMake(x + kTabMargin2, self.height);
    scrollView.contentOffset = contentOffset;
  }
}

- (void)tabTouchedUp:(T3TabView*)tab {
  self.selectedTabView = tab;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// UIView

- (void)drawRect:(CGRect)rect {
  if (style == T3TabBarStyleLight) {
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
  } else if (style == T3TabBarStyleButtons) {
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
  if (scrollView) {
    return scrollView.contentOffset;
  } else {
    return CGPointMake(0, 0);
  }
}

- (void)setContentOffset:(CGPoint)offset {
  if (scrollView) {
    scrollView.contentOffset = offset;
  }
}

- (T3TabItem*)selectedTabItem {
  if (selectedTabIndex != NSIntegerMax) {
    return [tabItems objectAtIndex:selectedTabIndex];
  }
  return nil;
}

- (void)setSelectedTabItem:(T3TabItem*)tabItem {
  self.selectedTabIndex = [tabItems indexOfObject:tabItem];
}

- (T3TabView*)selectedTabView {
  if (selectedTabIndex != NSIntegerMax && selectedTabIndex < tabViews.count) {
    return [tabViews objectAtIndex:selectedTabIndex];
  }
  return nil;
}

- (void)setSelectedTabView:(T3TabView*)tab {
  self.selectedTabIndex = [tabViews indexOfObject:tab];
}

- (void)setSelectedTabIndex:(NSInteger)index {
  if (index != selectedTabIndex) {
    if (selectedTabIndex != NSIntegerMax) {
      self.selectedTabView.selected = NO;
    }

    selectedTabIndex = index;

    if (selectedTabIndex != NSIntegerMax) {
      self.selectedTabView.selected = YES;
    }
    
    if ([delegate respondsToSelector:@selector(tabbedBar:tabSelected:)]) {
      [delegate performSelector:@selector(tabbedBar:tabSelected:) withObject:self
        withObject:(id)selectedTabIndex];
    }
  }
}

- (void)setTabItems:(NSArray*)aTabItems {
  [tabItems release];
  tabItems =  [aTabItems retain];
  
  for (int i = 0; i < tabViews.count; ++i) {
    T3TabView* tab = [tabViews objectAtIndex:i];
    [tab removeFromSuperview];
  }
  
  [tabViews removeAllObjects];

  if (selectedTabIndex >= tabViews.count) {
    selectedTabIndex = 0;
  }

  for (int i = 0; i < tabItems.count; ++i) {
    T3TabItem* tabItem = [tabItems objectAtIndex:i];
    T3TabView* tab = [[[T3TabView alloc] initWithItem:tabItem tabBar:self style:style] autorelease];
    [tab addTarget:self action:@selector(tabTouchedUp:) forControlEvents:UIControlEventTouchUpInside];
    if (scrollView) {
      [scrollView addSubview:tab];
    } else {
      [self addSubview:tab];
    }
    [tabViews addObject:tab];
    if (i == selectedTabIndex) {
      tab.selected = YES;
    }
  }
  
  [self layoutTabs];
  
  if (scrollView) {
    [self updateOverflow];
  }
}

- (void)showTabAtIndex:(NSInteger)tabIndex {
  T3TabView* tab = [tabViews objectAtIndex:tabIndex];
  tab.hidden = NO;
}

- (void)hideTabAtIndex:(NSInteger)tabIndex {
  T3TabView* tab = [tabViews objectAtIndex:tabIndex];
  tab.hidden = YES;
}

@end

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation T3TabView

@synthesize tabItem;

- (id)initWithItem:(T3TabItem*)aTabItem tabBar:(T3TabBar*)tabBar style:(T3TabBarStyle)aStyle {
  if (self = [self initWithFrame:CGRectZero]) {
    style = aStyle;
    badgeImage = nil;
    badgeLabel = nil;
    
    tabImage = [[UIImageView alloc] initWithFrame:CGRectZero];
    tabImage.hidden = YES;
    [self addSubview:tabImage];

    iconView = [[T3ImageView alloc] initWithFrame:CGRectZero];
    iconView.contentMode = UIViewContentModeRight;
    iconView.clipsToBounds = YES;
    [self addSubview:iconView];

    titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.contentMode = UIViewContentModeCenter;
    titleLabel.shadowOffset = CGSizeMake(0, -1);
    
    if (style == T3TabBarStyleDark) {
      if (!selectedTabImage) {
        selectedTabImage = [[[UIImage imageNamed:@"images/darkTab.png"]
          stretchableImageWithLeftCapWidth:5 topCapHeight:0] retain];
      }

      tabImage.image = selectedTabImage;

      titleLabel.textAlignment = UITextAlignmentCenter;
      titleLabel.font = [UIFont boldSystemFontOfSize:15];
      titleLabel.textColor = RGBCOLOR(223, 229, 237);
      titleLabel.highlightedTextColor = [UIColor colorWithWhite:0.1 alpha:1];
      titleLabel.shadowColor = [UIColor colorWithWhite:0 alpha:0.6];
    } else if (style == T3TabBarStyleLight) {
      if (!selectedLightImage) {
        selectedLightImage = [[[UIImage imageNamed:@"images/lightTab.png"]
          stretchableImageWithLeftCapWidth:5 topCapHeight:0] retain];
      }

      tabImage.image = selectedLightImage;

      titleLabel.textAlignment = UITextAlignmentCenter;
      titleLabel.font = [UIFont boldSystemFontOfSize:17];
      titleLabel.textColor = tabBar.textColor;
      titleLabel.highlightedTextColor = [UIColor colorWithWhite:0.1 alpha:1];
      titleLabel.shadowColor = [UIColor whiteColor];
    } else if (style == T3TabBarStyleButtons) {
      if (!selectedButtonImage) {
        selectedButtonImage = [[[UIImage imageNamed:@"images/feedButton.png"]
          stretchableImageWithLeftCapWidth:12 topCapHeight:0] retain];
      }

      tabImage.image = selectedButtonImage;

      titleLabel.textAlignment = UITextAlignmentLeft;
      titleLabel.font = [UIFont boldSystemFontOfSize:13];
      titleLabel.textColor = tabBar.textColor;
      titleLabel.highlightedTextColor = [UIColor whiteColor];
      titleLabel.shadowColor = [UIColor whiteColor];
    }
    [self addSubview:titleLabel];

    self.tabItem = aTabItem;
  }
  return self;
}

- (void)dealloc {
  [tabItem release];
  [tabImage release];
  [iconView release];
  [titleLabel release];
  [badgeImage release];
  [badgeLabel release];
  [super dealloc];
}

///////////////////////////////////////////////////////////////////////////////////////////////////

- (void)updateBadgeNumber {
  if (!badgeImage && tabItem.badgeNumber) {
    badgeImage = [[UIImageView alloc] initWithFrame:CGRectZero];
    badgeImage.image = [[UIImage imageNamed:@"images/badge.png"]
      stretchableImageWithLeftCapWidth:12 topCapHeight:15];
    [self addSubview:badgeImage];
    
    badgeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    badgeLabel.backgroundColor = [UIColor clearColor];
    badgeLabel.font = [UIFont boldSystemFontOfSize:14];
    badgeLabel.textColor = [UIColor whiteColor];
    badgeLabel.contentMode = UIViewContentModeCenter;
    badgeLabel.textAlignment = UITextAlignmentCenter;    
    [self addSubview:badgeLabel];
  }
  
  if (tabItem.badgeNumber) {
    badgeLabel.text = [NSString stringWithFormat:@"%d", tabItem.badgeNumber];
    [badgeLabel sizeToFit];
    
    badgeImage.frame = CGRectMake(self.width - (badgeLabel.width + kBadgeHPadding*2), 0,
      badgeLabel.width + 1 + kBadgeHPadding*2, 28);
    badgeLabel.frame = CGRectMake(badgeImage.x, badgeImage.y, badgeImage.width, 22);
    badgeImage.hidden = NO;
    badgeLabel.hidden = NO;
  } else {
    badgeImage.hidden = YES;
    badgeLabel.hidden = YES;
  }
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// UIView

- (void)layoutSubviews {
  [super layoutSubviews];

  tabImage.frame = self.bounds;

  if (style == T3TabBarStyleButtons) {
    CGFloat iconWidth = iconView.url.length ? kIconSize + kIconSpacing : 0;
    iconView.frame = CGRectMake(kPadding2, floor(self.height/2 - kIconSize/2)+2,
      kIconSize, kIconSize);
    titleLabel.frame = CGRectOffset(self.bounds, kPadding2 + iconWidth, 0);
  } else if (style == T3TabBarStyleLight) {
    iconView.frame = CGRectZero;
    titleLabel.frame = CGRectOffset(self.bounds, 0, 2);
  } else if (style == T3TabBarStyleDark) {
    iconView.frame = CGRectZero;
    titleLabel.frame = CGRectOffset(self.bounds, 0, 2);
  }
}

- (void)sizeToFit {
  [titleLabel sizeToFit];
  CGFloat padding = style == T3TabBarStyleButtons ? kPadding2 : kPadding;
  CGFloat iconWidth = iconView.url.length ? kIconSize + kIconSpacing : 0;
  self.frame = CGRectMake(self.x, self.y, titleLabel.width + iconWidth + padding*2, self.height);
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// UIControl

- (void)setSelected:(BOOL)selected {
  [super setSelected:selected];
  tabImage.hidden = !selected;
  titleLabel.highlighted = selected;
  if (style == T3TabBarStyleButtons) {
    if (selected) {
      iconView.contentMode = UIViewContentModeLeft;
      titleLabel.shadowColor = [UIColor colorWithWhite:0 alpha:0.3];
    } else {
      iconView.contentMode = UIViewContentModeRight;
      titleLabel.shadowColor = [UIColor whiteColor];
    }
  } else if (style == T3TabBarStyleLight) {
  } else if (style == T3TabBarStyleDark) {
    if (selected) {
      titleLabel.shadowColor = [UIColor whiteColor];
    } else {
      titleLabel.shadowColor = [UIColor colorWithWhite:0 alpha:0.6];
    }
  }
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// T3TabItemDelegate

- (void)tabItem:(T3TabItem*)item badgeNumberChangedTo:(int)value {
  [self updateBadgeNumber];
}

///////////////////////////////////////////////////////////////////////////////////////////////////

- (void)setTabItem:(T3TabItem*)aTabItem {
  tabItem.delegate = nil;
  [tabItem release];
  tabItem = [aTabItem retain];
  tabItem.delegate = self;
  
  titleLabel.text = tabItem.title;
  iconView.url = tabItem.icon;
  if (tabItem.badgeNumber) {
    [self updateBadgeNumber];
  }
}

@end

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation T3TabItem

@synthesize delegate, title, icon, object, badgeNumber;

- (id)initWithTitle:(NSString*)aTitle {
  if (self = [self init]) {
    self.title = aTitle;
  }
  return self;
}

- (id)init {
  if (self = [super init]) {
    delegate = nil;
    title = nil;
    icon = nil;
    object = nil;
    badgeNumber = 0;
  }
  return self;
}

- (void)dealloc {
  [title release];
  [icon release];
  [object release];
  [super dealloc];
}

- (void)setBadgeNumber:(int)value {
  value = value < 0 ? 0 : value;
  badgeNumber = value;
  if ([delegate respondsToSelector:@selector(tabItem:badgeNumberChangedTo:)]) {
    [delegate performSelector:@selector(tabItem:badgeNumberChangedTo:) withObject:self
      withObject:(id)value];
  }
}

@end
