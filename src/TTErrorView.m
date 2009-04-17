#import "Three20/TTErrorView.h"
#import "Three20/TTDefaultStyleSheet.h"

///////////////////////////////////////////////////////////////////////////////////////////////////

static CGFloat kHPadding = 20;
static CGFloat kVPadding = 50;

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation TTErrorView

///////////////////////////////////////////////////////////////////////////////////////////////////
// NSObject

- (id)initWithTitle:(NSString*)title subtitle:(NSString*)subtitle image:(UIImage*)image {
  if (self = [self initWithFrame:CGRectZero]) {
    self.title = title;
    self.subtitle = subtitle;
    self.image = image;
  }
  return self;
}

- (id)initWithFrame:(CGRect)frame {
  if (self = [super initWithFrame:frame]) {
    _imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    _imageView.contentMode = UIViewContentModeCenter;
    [self addSubview:_imageView];

    _titleView = [[UILabel alloc] initWithFrame:CGRectZero];
    _titleView.opaque = NO;
    _titleView.backgroundColor = [UIColor clearColor];
    _titleView.textColor = TTSTYLEVAR(tableErrorTextColor);
    _titleView.font = TTSTYLEVAR(errorTitleFont);
    _titleView.textAlignment = UITextAlignmentCenter;
    [self addSubview:_titleView];
    
    _subtitleView = [[UILabel alloc] initWithFrame:CGRectZero];
    _subtitleView.opaque = NO;
    _subtitleView.backgroundColor = [UIColor clearColor];
    _subtitleView.textColor = TTSTYLEVAR(tableErrorTextColor);
    _subtitleView.font = TTSTYLEVAR(errorSubtitleFont);
    _subtitleView.textAlignment = UITextAlignmentCenter;
    _subtitleView.numberOfLines = 0;
    [self addSubview:_subtitleView];
  }
  return self;
}

- (void)dealloc {
  [_imageView release];
  [_titleView release];
  [_subtitleView release];
  [super dealloc];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// UIView

- (void)layoutSubviews {
  [_subtitleView sizeToFit];
  [_titleView sizeToFit];
  [_imageView sizeToFit];
  
  if (_titleView.text.length) {
    if (_subtitleView.text.length || _imageView.image) {
      _subtitleView.frame = CGRectMake(kHPadding, self.height - kVPadding,
        self.width-kHPadding*2, _subtitleView.height);
      _titleView.frame = CGRectMake(0, _subtitleView.top-kVPadding, self.width, _titleView.height);
    } else {
      _subtitleView.frame = CGRectZero;
      _titleView.frame = CGRectMake(kHPadding, floor(self.height/2 - _titleView.height/2),
        self.width - kHPadding*2, _titleView.height);
    }
  } else {
    _titleView.frame = CGRectZero;
    if (_imageView.image) {
      _subtitleView.frame = CGRectMake(kHPadding, self.height - kVPadding,
        self.width-kHPadding*2, _subtitleView.height);
    } else {
      _subtitleView.frame = CGRectMake(kHPadding, floor(self.height/2 - _subtitleView.height/2),
        self.width-kHPadding*2, _subtitleView.height);
    }
  }

  if (_imageView.image) {
    CGFloat textTop = _titleView.height ? _titleView.top : _subtitleView.top;
    
    _imageView.frame = CGRectMake(self.width/2 - _imageView.width/2,
      textTop/2 - (_imageView.height/2), _imageView.width, _imageView.height);
  } else {
    _imageView.frame = CGRectZero;
  }
}

///////////////////////////////////////////////////////////////////////////////////////////////////

- (NSString*)title {
  return _titleView.text;
}

- (void)setTitle:(NSString*)title {
  _titleView.text = title;
}

- (NSString*)subtitle {
  return _subtitleView.text;
}

- (void)setSubtitle:(NSString*)subtitle {
  _subtitleView.text = subtitle;
}

- (UIImage*)image {
  return _imageView.image;
}

- (void)setImage:(UIImage*)image {
  _imageView.image = image;
}

@end
