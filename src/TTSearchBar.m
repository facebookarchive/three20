#import "Three20/TTSearchBar.h"
#import "Three20/TTSearchTextField.h"
#import "Three20/TTAppearance.h"

///////////////////////////////////////////////////////////////////////////////////////////////////

static const CGFloat kMarginX = 5;
static const CGFloat kMarginY = 5;

static const CGFloat kPaddingX = 10;
static const CGFloat kPaddingY = 0;

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation TTSearchBar

@synthesize searchSource = _searchSource, tintColor = _tintColor;

- (id)initWithFrame:(CGRect)frame {
  if (self = [super initWithFrame:frame]) {
    self.tintColor = RGBCOLOR(109, 132, 162);
//    self.tintColor = [UIColor colorWithRed:0.23046875 green:0.34765625 blue:0.59375 alpha:1.0];
    
    _searchField = [[TTSearchTextField alloc] initWithFrame:CGRectMake(0, 0, 320, 40)];
    _searchField.placeholder = NSLocalizedString(@"Search", @"");
    
    UIImageView* iconView = [[[UIImageView alloc] initWithImage:
      [UIImage imageNamed:@"ttimages/searchIcon.png"]] autorelease];
    [iconView sizeToFit];
    iconView.contentMode = UIViewContentModeLeft;
    iconView.frame = CGRectInset(iconView.frame, -2, 0);
    _searchField.leftView = iconView;
    _searchField.leftViewMode = UITextFieldViewModeAlways;
    
    [self addSubview:_searchField];
  }
  return self;
}

- (void)dealloc {
  [_tintColor release];
  [super dealloc];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// UIView

- (void)drawRect:(CGRect)rect {
  UIColor* ligherTint = [_tintColor transformHue:1 saturation:0.4 value:1.2];
  UIColor* barFill[] = {ligherTint, _tintColor, _tintColor};

  [[TTAppearance appearance] drawBackground:TTBackgroundRoundedRect rect:rect
    fill:barFill fillCount:3 stroke:nil radius:0];

  UIColor* highlight = RGBACOLOR(255, 255, 255, 0.4);

  [[TTAppearance appearance] drawBackground:TTBackgroundStrokeTop rect:CGRectInset(rect, 0, 1)
    fill:nil fillCount:0 stroke:highlight radius:0];

  UIColor* textFill[] = {RGBACOLOR(255, 255, 255, 1)};
  UIColor* textStroke = [_tintColor transformHue:1 saturation:1 value:0.9];

  [[TTAppearance appearance] drawBackground:TTBackgroundRoundedRect
    rect:CGRectInset(rect, kMarginX, kMarginY)
    fill:textFill fillCount:1 stroke:textStroke radius:TT_RADIUS_ROUNDED];
}

- (void)layoutSubviews {
  _searchField.frame = CGRectMake(kMarginX+kPaddingX, 0,
    self.width - (kMarginX+kPaddingX+kMarginX), self.height);
}

- (CGSize)sizeThatFits:(CGSize)size {
  return CGSizeMake(size.width, 41);
}

///////////////////////////////////////////////////////////////////////////////////////////////////

- (BOOL)showsDoneButton {
  return _searchField.showsDoneButton;
}

- (void)setShowsDoneButton:(BOOL)showsDoneButton {
  _searchField.showsDoneButton = showsDoneButton;
}

- (BOOL)showsDarkScreen {
  return _searchField.showsDarkScreen;
}

- (void)setShowsDarkScreen:(BOOL)showsDarkScreen {
  _searchField.showsDarkScreen = showsDarkScreen;
}

- (id<TTSearchSource>)searchSource {
  return _searchField.searchSource;
}

- (void)setSearchSource:(id<TTSearchSource>)searchSource {
  _searchField.searchSource = searchSource;
}

@end
