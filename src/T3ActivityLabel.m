#import "Three20/T3ActivityLabel.h"
#import "Three20/T3BackgroundView.h"

///////////////////////////////////////////////////////////////////////////////////////////////////

static CGFloat kPadding = 15;
static CGFloat kMargin = 9;
static CGFloat kSpacing = 5;
static CGFloat kBezelHeight = 50;
static CGFloat kThinBezelHeight = 35;

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation T3ActivityLabel

@synthesize style = _style, centered = _centered, centeredToScreen = _centeredToScreen;

- (id)initWithFrame:(CGRect)frame style:(T3ActivityLabelStyle)aStyle {
  return [self initWithFrame:frame style:aStyle text:nil];
}

- (id)initWithFrame:(CGRect)frame style:(T3ActivityLabelStyle)aStyle text:(NSString*)text {
  if (self = [super initWithFrame:frame]) {
    _style = aStyle;
    _centered = YES;
    _centeredToScreen = YES;
    
    self.backgroundColor = [UIColor clearColor];
  
    _bezelView = [[T3BackgroundView alloc] initWithFrame:CGRectZero];
    if (_style == T3ActivityLabelStyleBlackBezel || _style == T3ActivityLabelStyleBlackThinBezel) {
      _bezelView.opaque = NO;
      _bezelView.background = T3BackgroundRoundedRect;
      _bezelView.fillColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.7];
      _bezelView.strokeRadius = 10;
    } else if (_style == T3ActivityLabelStyleWhiteBezel) {
      _bezelView.opaque = NO;
      _bezelView.background = T3BackgroundRoundedRect;
      _bezelView.fillColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:1];
      _bezelView.strokeColor = [UIColor colorWithRed:0.7 green:0.7 blue:0.7 alpha:1];
      _bezelView.strokeRadius = 10;
    } else if (_style == T3ActivityLabelStyleWhiteBox) {
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
    _textView.text = text;
    
    if (_style == T3ActivityLabelStyleWhite) {
      _spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:
        UIActivityIndicatorViewStyleWhite];
      _textView.font = [UIFont systemFontOfSize:17];
      _textView.textColor = [UIColor whiteColor];
    } else if (_style == T3ActivityLabelStyleGray
                || _style == T3ActivityLabelStyleWhiteBox
               || _style == T3ActivityLabelStyleWhiteBezel) {
      _spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:
        UIActivityIndicatorViewStyleGray];
      _textView.font = [UIFont systemFontOfSize:17];
      _textView.textColor = [UIColor grayColor];
    } else if (_style == T3ActivityLabelStyleBlackBezel) {
      _spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:
        UIActivityIndicatorViewStyleWhiteLarge];
      _spinner.frame = CGRectMake(0, 0, 24, 24);
      _textView.font = [UIFont boldSystemFontOfSize:17];
      _textView.textColor = [UIColor whiteColor];
      _textView.shadowColor = [UIColor colorWithWhite:0 alpha:0.3];
      _textView.shadowOffset = CGSizeMake(1, 1);
    } else if (_style == T3ActivityLabelStyleBlackThinBezel) {
      _spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:
        UIActivityIndicatorViewStyleWhite];
      _spinner.frame = CGRectMake(0, 0, 20, 20);
      _textView.font = [UIFont boldSystemFontOfSize:15];
      _textView.textColor = [UIColor whiteColor];
      _textView.shadowColor = [UIColor colorWithWhite:0 alpha:0.3];
      _textView.shadowOffset = CGSizeMake(1, 1);
    }
    
    [_bezelView addSubview:_spinner];
    [_bezelView addSubview:_textView];
    [_spinner startAnimating];
  }
  return self;
}

- (void)dealloc {
  [_bezelView release];
  [_spinner release];
  [_textView release];
  [super dealloc];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// UIView

- (void)layoutSubviews {
  [super layoutSubviews];

  CGRect appFrame = [UIScreen mainScreen].applicationFrame;
  CGSize captionSize = [_textView.text sizeWithFont:_textView.font];
  CGFloat contentWidth = _spinner.width + kSpacing + captionSize.width;

  CGFloat bezelWidth, bezelHeight, y;

  if (_style == T3ActivityLabelStyleBlackThinBezel) {
    bezelHeight = kThinBezelHeight;
  } else {
    bezelHeight = kBezelHeight;
  }

  if (!_centered) {
    bezelWidth = self.width - kMargin*2;
    y = -10;
  } else {
    bezelWidth = kPadding + contentWidth + kPadding;
    CGFloat maxBevelWidth = appFrame.size.width - kPadding*2;
    if (bezelWidth > maxBevelWidth) {
      bezelWidth = maxBevelWidth;
      contentWidth = bezelWidth - (kSpacing + _spinner.width);
    }
    
    y = _centeredToScreen
      ? floor(appFrame.size.height/2 - bezelHeight/2) - self.screenY
      : floor(self.height/2 - bezelHeight/2);
  }
  
  CGFloat captionMaxWidth = (bezelWidth - (_spinner.width + kSpacing)) - kPadding*2;
  CGFloat captionWidth = captionSize.width;
  if (captionWidth > captionMaxWidth) {
    captionWidth = captionMaxWidth;
  }
      
  _bezelView.frame = CGRectMake(floor(self.width/2 - bezelWidth/2), y,
    bezelWidth, bezelHeight);
  
  _textView.frame = CGRectMake(floor((bezelWidth/2 - contentWidth/2) + kPadding + _spinner.width/2),
    floor(bezelHeight/2 - captionSize.height/2), captionWidth, captionSize.height);

  _spinner.frame = CGRectMake(_textView.x - (_spinner.width+kSpacing),
    floor(bezelHeight/2 - _spinner.height/2), _spinner.width, _spinner.height);
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
