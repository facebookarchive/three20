#import "Three20/TTActivityLabel.h"
#import "Three20/TTView.h"
#import "Three20/TTDefaultStyleSheet.h"
#import "Three20/TTButton.h"

///////////////////////////////////////////////////////////////////////////////////////////////////

static CGFloat kPadding = 15;
static CGFloat kMargin = 9;
static CGFloat kSpacing = 5;
static CGFloat kBezelHeight = 50;
static CGFloat kThinBezelHeight = 35;

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation TTActivityLabel

@synthesize delegate = _delegate, style = _style, centered = _centered,
            centeredToScreen = _centeredToScreen, showsStopButton = _showsStopButton;

///////////////////////////////////////////////////////////////////////////////////////////////////
// private

- (void)touchedStopButton {
  if ([_delegate respondsToSelector:@selector(activityLabelDidStop:)]) {
    [_delegate activityLabelDidStop:self];
  }
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// NSObject

- (id)initWithFrame:(CGRect)frame style:(TTActivityLabelStyle)style {
  return [self initWithFrame:frame style:style text:nil];
}

- (id)initWithFrame:(CGRect)frame style:(TTActivityLabelStyle)style text:(NSString*)text {
  if (self = [super initWithFrame:frame]) {
    _style = style;
    _delegate = nil;
    _stopButton = nil;
    _centered = YES;
    _centeredToScreen = YES;
    _showsStopButton = NO;
    
    self.backgroundColor = [UIColor clearColor];
  
    _bezelView = [[TTView alloc] initWithFrame:CGRectZero];
    if (_style == TTActivityLabelStyleBlackBezel || _style == TTActivityLabelStyleBlackThinBezel) {
      _bezelView.opaque = NO;
      _bezelView.style = TTSTYLE(blackBezel);
    } else if (_style == TTActivityLabelStyleWhiteBezel) {
      _bezelView.opaque = NO;
      _bezelView.style = TTSTYLE(whiteBezel);
    } else if (_style == TTActivityLabelStyleWhiteBox) {
      _bezelView.backgroundColor = [UIColor whiteColor];
      self.backgroundColor = [UIColor whiteColor];
    } else if (_style == TTActivityLabelStyleBlackBox) {
      _bezelView.backgroundColor = [UIColor clearColor];
      self.backgroundColor = [UIColor colorWithWhite:0 alpha:0.8];
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
    
    if (_style == TTActivityLabelStyleWhite) {
      _spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:
        UIActivityIndicatorViewStyleWhite];
      _textView.font = TTSTYLEVAR(activityLabelFont);
      _textView.textColor = [UIColor whiteColor];
    } else if (_style == TTActivityLabelStyleGray
                || _style == TTActivityLabelStyleWhiteBox
               || _style == TTActivityLabelStyleWhiteBezel) {
      _spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:
        UIActivityIndicatorViewStyleGray];
      _textView.font = TTSTYLEVAR(activityLabelFont);
      _textView.textColor = TTSTYLEVAR(tableActivityTextColor);
    } else if (_style == TTActivityLabelStyleBlackBezel || _style == TTActivityLabelStyleBlackBox) {
      _spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:
        UIActivityIndicatorViewStyleWhiteLarge];
      _spinner.frame = CGRectMake(0, 0, 24, 24);
      _textView.font = TTSTYLEVAR(activityLabelFont);
      _textView.textColor = [UIColor whiteColor];
      _textView.shadowColor = [UIColor colorWithWhite:0 alpha:0.3];
      _textView.shadowOffset = CGSizeMake(1, 1);
    } else if (_style == TTActivityLabelStyleBlackThinBezel) {
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
  [_stopButton release];
  [super dealloc];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// UIView

- (void)layoutSubviews {
  [super layoutSubviews];

  CGSize textSize = [_textView.text sizeWithFont:_textView.font];

  CGFloat spinnerSize = _spinner.height;
  if (spinnerSize + kPadding > self.height) {
    spinnerSize = textSize.height;
  }

  CGFloat contentWidth = spinnerSize + kSpacing + textSize.width;
  if (_stopButton) {
    [_stopButton sizeToFit];
    _stopButton.height = 30;
    contentWidth += _stopButton.width + kSpacing;
  }
  
  CGFloat bezelWidth, bezelHeight, y;

  if (_style == TTActivityLabelStyleBlackThinBezel) {
    bezelHeight = kThinBezelHeight;
  } else {
    bezelHeight = kBezelHeight;
  }

  if (!_centered) {
    bezelWidth = self.width - kMargin*2;
    y = -10;
  } else {
    bezelWidth = kPadding + contentWidth + kPadding;

    CGRect appFrame = [UIScreen mainScreen].applicationFrame;
    CGFloat maxBevelWidth = appFrame.size.width - kPadding*2;
    if (bezelWidth > maxBevelWidth) {
      bezelWidth = maxBevelWidth;
      contentWidth = bezelWidth - (kSpacing + spinnerSize);
    }
    
    y = _centeredToScreen
      ? floor(appFrame.size.height/2 - bezelHeight/2) - self.screenY
      : floor(self.height/2 - bezelHeight/2);
  }
  
  CGFloat textMaxWidth = (bezelWidth - (spinnerSize + kSpacing)) - kPadding*2;
  CGFloat textWidth = textSize.width;
  if (textWidth > textMaxWidth) {
    textWidth = textMaxWidth;
  }
      
  _bezelView.frame = CGRectMake(floor(self.width/2 - bezelWidth/2), y,
    bezelWidth, bezelHeight);
  
  _textView.frame = CGRectMake(floor((bezelWidth/2 - contentWidth/2) + kPadding + spinnerSize/2),
    floor(bezelHeight/2 - textSize.height/2), textWidth, textSize.height);

  _spinner.frame = CGRectMake(_textView.left - (spinnerSize+kSpacing),
    floor(bezelHeight/2 - spinnerSize/2), spinnerSize, spinnerSize);

  _stopButton.frame = CGRectMake(_textView.right + kSpacing*2,
    floor(bezelHeight/2 - _stopButton.height/2), _stopButton.width, _stopButton.height);
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// public

- (NSString*)text {
  return _textView.text;
}

- (void)setText:(NSString*)text {
  _textView.text = text;
  [self setNeedsLayout];
}

- (UIFont*)font {
  return _textView.font;
}

- (void)setFont:(UIFont*)font {
  _textView.font = font;
  [self setNeedsLayout];
}

- (void)setShowsStopButton:(BOOL)showsStopButton {
  if (showsStopButton != _showsStopButton) {
    _showsStopButton = showsStopButton;
    
    if (_showsStopButton) {
      _stopButton = [[TTButton buttonWithStyle:@"blackToolbarButton:"
                               title:TTLocalizedString(@"Stop", @"")] retain];
      [_stopButton addTarget:self action:@selector(touchedStopButton)
                   forControlEvents:UIControlEventTouchUpInside];
      [_bezelView addSubview:_stopButton];
    } else {
      [_stopButton removeFromSuperview];
      [_stopButton release];
      _stopButton = nil;
    }
  }
}

@end
