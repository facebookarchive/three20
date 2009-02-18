#import "Three20/TTSearchBar.h"
#import "Three20/TTSearchTextField.h"
#import "Three20/TTBackgroundView.h"
#import "Three20/TTAppearance.h"

///////////////////////////////////////////////////////////////////////////////////////////////////

static const CGFloat kMarginX = 5;
static const CGFloat kMarginY = 5;

static const CGFloat kPaddingX = 10;
static const CGFloat kPaddingY = 10;

static const CGFloat kIndexViewMargin = 4;

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation TTSearchBar

@synthesize tintColor = _tintColor;

- (id)initWithFrame:(CGRect)frame {
  if (self = [super initWithFrame:frame]) {
    _boxView = [[TTBackgroundView alloc] initWithFrame:CGRectZero];
    _boxView.backgroundColor = [UIColor clearColor];
    _boxView.style = TTDrawRoundInnerShadow;
    _boxView.contentMode = UIViewContentModeRedraw;
    [self addSubview:_boxView];
    
    _searchField = [[TTSearchTextField alloc] initWithFrame:CGRectZero];
    _searchField.placeholder = NSLocalizedString(@"Search", @"");
        
    UIImageView* iconView = [[[UIImageView alloc] initWithImage:
      [UIImage imageNamed:@"ttimages/searchIcon.png"]] autorelease];
    [iconView sizeToFit];
    iconView.contentMode = UIViewContentModeLeft;
    iconView.frame = CGRectInset(iconView.frame, -floor(kMarginX/2), 0);
    _searchField.leftView = iconView;
    _searchField.leftViewMode = UITextFieldViewModeAlways;

    [_searchField addTarget:self action:@selector(textFieldDidBeginEditing)
      forControlEvents:UIControlEventEditingDidBegin];
    [_searchField addTarget:self action:@selector(textFieldDidEndEditing)
      forControlEvents:UIControlEventEditingDidEnd];
    
    [self addSubview:_searchField];

    self.contentMode = UIViewContentModeRedraw;
    self.tintColor = [TTAppearance appearance].barTintColor;
  }
  return self;
}

- (void)dealloc {
  [_searchField release];
  [_boxView release];
  [_tintColor release];
  [super dealloc];
}

///////////////////////////////////////////////////////////////////////////////////////////////////

- (CGFloat)indexViewWidth {
  UITableView* tableView = (UITableView*)[self firstParentOfClass:[UITableView class]];
  if (tableView) {
    UIView* indexView = tableView.indexView;
    if (indexView) {
      return indexView.width;
    }
  }
  return 0;
}

- (void)showIndexView:(BOOL)show {
  UITableView* tableView = (UITableView*)[self firstParentOfClass:[UITableView class]];
  if (tableView) {
    UIView* indexView = tableView.indexView;
    if (indexView) {
      [UIView beginAnimations:nil context:nil];
      [UIView setAnimationDuration:TT_TRANSITION_DURATION];
      
      if (show) {
        CGRect frame = indexView.frame;
        frame.origin.x = self.width - (indexView.width + kIndexViewMargin);
        indexView.frame = frame;
      } else {
        indexView.frame = CGRectOffset(indexView.frame, indexView.width + kIndexViewMargin, 0);
      }
      indexView.alpha = show ? 1 : 0;
      
      CGRect searchFrame = _searchField.frame;
      searchFrame.size.width += show ? -self.indexViewWidth : self.indexViewWidth;
      _searchField.frame = searchFrame;

      CGRect boxFrame = _boxView.frame;
      boxFrame.size.width += show ? -self.indexViewWidth : self.indexViewWidth;
      _boxView.frame = boxFrame;
      
      [UIView commitAnimations];
    }
  }
}

- (void)scrollToTop {
  UIScrollView* scrollView = (UIScrollView*)[self firstParentOfClass:[UIScrollView class]];
  if (scrollView) {
    CGPoint offset = scrollView.contentOffset;
    if (offset.y != self.top) {
      [scrollView setContentOffset:CGPointMake(offset.x, self.top) animated:YES];
    }
  }
}

- (void)textFieldDidBeginEditing {
  [self scrollToTop];
  [self showIndexView:NO];
}

- (void)textFieldDidEndEditing {
  [self showIndexView:YES];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// UIView

- (void)drawRect:(CGRect)rect {
  UIColor* fill[] = {_tintColor};
  [[TTAppearance appearance] draw:TTDrawReflection rect:rect
    fill:fill fillCount:1 stroke:nil radius:0];
}

- (void)layoutSubviews {
  CGFloat indexViewWidth = [_searchField isEditing] ? 0 : self.indexViewWidth;

  CGRect boxRect = CGRectInset(self.bounds, kMarginX, kMarginY);
  boxRect.size.width -= indexViewWidth;
  _boxView.frame = boxRect;
  
  _searchField.frame = CGRectMake(kMarginX+kPaddingX, 0,
    self.width - (kMarginX*2+kPaddingX+indexViewWidth), self.height);
}

- (CGSize)sizeThatFits:(CGSize)size {
  CGSize fontSize = [@"M" sizeWithFont:self.font];
  return CGSizeMake(size.width, fontSize.height+kPaddingY*2);
}

///////////////////////////////////////////////////////////////////////////////////////////////////

- (id<UITextFieldDelegate>)delegate {
  return _searchField.delegate;
}

- (void)setDelegate:(id<UITextFieldDelegate>)delegate {
  _searchField.delegate = delegate;
}

- (id<TTTableViewDataSource>)dataSource {
  return _searchField.dataSource;
}

- (void)setDataSource:(id<TTTableViewDataSource>)dataSource {
  _searchField.dataSource = dataSource;
}

- (BOOL)editing {
  return _searchField.editing;
}

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

- (BOOL)searchesAutomatically {
  return _searchField.searchesAutomatically;
}

- (void)setSearchesAutomatically:(BOOL)searchesAutomatically {
  _searchField.searchesAutomatically = searchesAutomatically;
}

- (NSString*)text {
  return _searchField.text;
}

- (void)setText:(NSString*)text {
  _searchField.text = text;
}

- (UITableView*)tableView {
  return _searchField.tableView;
}

- (UIFont*)font {
  return _searchField.font;
}

- (void)setFont:(UIFont*)font {
  _searchField.font = font;
}

- (void)setTintColor:(UIColor*)tintColor {
  if (tintColor != _tintColor) {
    [_tintColor release];
    _tintColor = [tintColor retain];
    
    _boxView.strokeColor = [_tintColor transformHue:1 saturation:1 value:0.9];
  }
}

@end

