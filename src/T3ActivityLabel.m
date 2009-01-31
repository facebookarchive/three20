#import "Three20/T3ActivityLabel.h"
#import "Three20/T3PaintedView.h"

///////////////////////////////////////////////////////////////////////////////////////////////////

static CGFloat kPadding = 15;
static CGFloat kMargin = 9;
static CGFloat kSpacing = 5;
static CGFloat kBezelHeight = 50;
static CGFloat kThinBezelHeight = 35;

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation T3ActivityLabel

@synthesize style, centered, centeredToScreen;

- (id)initWithFrame:(CGRect)frame style:(T3ActivityLabelStyle)aStyle {
  if (self = [super initWithFrame:frame]) {
    style = aStyle;
    centered = YES;
    centeredToScreen = YES;
    
    self.backgroundColor = [UIColor clearColor];
  
    _bezelView = [[T3PaintedView alloc] initWithFrame:CGRectZero];
    if (style == T3ActivityLabelStyleBlackBezel || style == T3ActivityLabelStyleBlackThinBezel) {
      _bezelView.opaque = NO;
      _bezelView.background = T3BackgroundRoundedRect;
      _bezelView.fillColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.7];
      _bezelView.strokeRadius = 10;
    } else if (style == T3ActivityLabelStyleWhiteBezel) {
      _bezelView.opaque = NO;
      _bezelView.background = T3BackgroundRoundedRect;
      _bezelView.fillColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:1];
      _bezelView.strokeColor = [UIColor colorWithRed:0.7 green:0.7 blue:0.7 alpha:1];
      _bezelView.strokeRadius = 10;
    } else if (style == T3ActivityLabelStyleWhiteBox) {
      _bezelView.backgroundColor = [UIColor whiteColor];
      self.backgroundColor = [UIColor whiteColor];
    } else {
      _bezelView.backgroundColor = [UIColor clearColor];
    }
    [self addSubview:_bezelView];
    
    _textView = [[UILabel alloc] initWithFrame:
      CGRectMake(frame.size.height+5,0,frame.size.width,frame.size.height)];
    _textView.backgroundColor = [UIColor clearColor];
    _textView.opaque = NO;
    _textView.lineBreakMode = UILineBreakModeTailTruncation;
    
    if (style == T3ActivityLabelStyleWhite) {
      spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:
        UIActivityIndicatorViewStyleWhite];
      _textView.font = [UIFont systemFontOfSize:17];
      _textView.textColor = [UIColor whiteColor];
    } else if (style == T3ActivityLabelStyleGray
                || style == T3ActivityLabelStyleWhiteBox
               || style == T3ActivityLabelStyleWhiteBezel) {
      spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:
        UIActivityIndicatorViewStyleGray];
      _textView.font = [UIFont systemFontOfSize:17];
      _textView.textColor = [UIColor grayColor];
    } else if (style == T3ActivityLabelStyleBlackBezel) {
      spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:
        UIActivityIndicatorViewStyleWhiteLarge];
      spinner.frame = CGRectMake(0, 0, 24, 24);
      _textView.font = [UIFont boldSystemFontOfSize:17];
      _textView.textColor = [UIColor whiteColor];
      _textView.shadowColor = [UIColor colorWithWhite:0 alpha:0.3];
      _textView.shadowOffset = CGSizeMake(1, 1);
    } else if (style == T3ActivityLabelStyleBlackThinBezel) {
      spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:
        UIActivityIndicatorViewStyleWhite];
      spinner.frame = CGRectMake(0, 0, 20, 20);
      _textView.font = [UIFont boldSystemFontOfSize:15];
      _textView.textColor = [UIColor whiteColor];
      _textView.shadowColor = [UIColor colorWithWhite:0 alpha:0.3];
      _textView.shadowOffset = CGSizeMake(1, 1);
    }
    
    [_bezelView addSubview:spinner];
    [_bezelView addSubview:_textView];
    [spinner startAnimating];
  }
  return self;
}

- (void)dealloc {
  [_bezelView release];
  [spinner release];
  [_textView release];
  [super dealloc];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// UIView

- (void)layoutSubviews {
  [super layoutSubviews];

  CGRect appFrame = [UIScreen mainScreen].applicationFrame;
  CGSize captionSize = [_textView.text sizeWithFont:_textView.font];
  CGFloat contentWidth = spinner.width + kSpacing + captionSize.width;

  CGFloat bezelWidth, bezelHeight, y;

  if (style == T3ActivityLabelStyleBlackThinBezel) {
    bezelHeight = kThinBezelHeight;
  } else {
    bezelHeight = kBezelHeight;
  }

  if (!centered) {
    bezelWidth = self.width - kMargin*2;
    y = -10;
  } else {
    bezelWidth = kPadding + contentWidth + kPadding;
    CGFloat maxBevelWidth = appFrame.size.width - kPadding*2;
    if (bezelWidth > maxBevelWidth) {
      bezelWidth = maxBevelWidth;
      contentWidth = bezelWidth - (kSpacing + spinner.width);
    }
    
    y = centeredToScreen
      ? floor(appFrame.size.height/2 - bezelHeight/2) - self.screenY
      : floor(self.height/2 - bezelHeight/2);
  }
  
  CGFloat captionMaxWidth = (bezelWidth - (spinner.width + kSpacing)) - kPadding*2;
  CGFloat captionWidth = captionSize.width;
  if (captionWidth > captionMaxWidth) {
    captionWidth = captionMaxWidth;
  }
      
  _bezelView.frame = CGRectMake(floor(self.width/2 - bezelWidth/2), y,
    bezelWidth, bezelHeight);
  
  _textView.frame = CGRectMake(floor((bezelWidth/2 - contentWidth/2) + kPadding + spinner.width/2),
    floor(bezelHeight/2 - captionSize.height/2), captionWidth, captionSize.height);

  spinner.frame = CGRectMake(_textView.x - (spinner.width+kSpacing),
    floor(bezelHeight/2 - spinner.height/2), spinner.width, spinner.height);
}

///////////////////////////////////////////////////////////////////////////////////////////////////

- (NSString*)text {
  return _textView.text;
}

- (void)setText:(NSString*)text {
  _textView.text = text;
  [self setNeedsLayout];
}

@end
