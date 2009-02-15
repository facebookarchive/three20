#import "Three20/T3MenuViewCell.h"
#import "Three20/T3Appearance.h"

///////////////////////////////////////////////////////////////////////////////////////////////////

static CGFloat kPaddingX = 8;
static CGFloat kPaddingY = 3;
static CGFloat kMaxWidth = 250;

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation T3MenuViewCell

@synthesize object = _object, selected = _selected;

- (id)initWithFrame:(CGRect)frame {
	if (self = [super initWithFrame:frame]) {
    _object = nil;
    _selected = NO;
    
    _labelView = [[UILabel alloc] initWithFrame:CGRectZero];
    _labelView.opaque = NO;
    _labelView.backgroundColor = [UIColor clearColor];
    _labelView.textColor = [UIColor blackColor];
    _labelView.highlightedTextColor = [UIColor whiteColor];
    _labelView.lineBreakMode = UILineBreakModeTailTruncation;
    [self addSubview:_labelView];

    self.backgroundColor = [UIColor clearColor];
	}
	return self;
}

- (void)dealloc {
  [_object release];
  [_labelView release];
	[super dealloc];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// UIView

- (void)drawRect:(CGRect)rect {
  if (_selected) {
    UIColor* fill[] = {RGBACOLOR(79, 144, 255, 1), RGBACOLOR(49, 90, 255, 1)};
    UIColor* stroke = RGBACOLOR(53, 94, 255, 1);

    [[T3Appearance appearance] drawBackground:T3BackgroundRoundedRect rect:CGRectInset(rect, 1, 1)
      fill:fill fillCount:2 stroke:stroke radius:T3_RADIUS_ROUNDED];
  } else {
    UIColor* fill[] = {RGBACOLOR(221, 231, 248, 1), RGBACOLOR(188, 206, 241, 1)};
    UIColor* stroke = RGBACOLOR(121, 133, 217, 1);

    [[T3Appearance appearance] drawBackground:T3BackgroundRoundedRect rect:CGRectInset(rect, 1, 1)
      fill:fill fillCount:2 stroke:stroke radius:T3_RADIUS_ROUNDED];
  }
}

- (void)layoutSubviews {
  _labelView.frame = CGRectMake(kPaddingX, kPaddingY,
    self.frame.size.width-kPaddingX*2, self.frame.size.height-kPaddingY*2);
}

- (CGSize)sizeThatFits:(CGSize)size {
  CGSize labelSize = [_labelView.text sizeWithFont:_labelView.font];
  CGFloat width = labelSize.width + kPaddingX*2;
  return CGSizeMake(width > kMaxWidth ? kMaxWidth : width, labelSize.height + kPaddingY*2);
}

///////////////////////////////////////////////////////////////////////////////////////////////////

- (NSString*)label {
  return _labelView.text;
}

- (void)setLabel:(NSString*)label {
  _labelView.text = label;
}

- (UIFont*)font {
  return _labelView.font;
}

- (void)setFont:(UIFont*)font {
  _labelView.font = font;
}

- (void)setSelected:(BOOL)selected {
  _selected = selected;
  
  _labelView.highlighted = selected;
  [self setNeedsDisplay];
}

@end
