#import "Three20/TTErrorView.h"

///////////////////////////////////////////////////////////////////////////////////////////////////

static CGFloat kImageSize = 180;
static CGFloat kHPadding = 20;
static CGFloat kVPadding = 50;

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation TTErrorView

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
    _titleView.textColor = RGBCOLOR(99, 109, 125);
    _titleView.font = [UIFont boldSystemFontOfSize:18];
    _titleView.textAlignment = UITextAlignmentCenter;
    [self addSubview:_titleView];
    
    _subtitleView = [[UILabel alloc] initWithFrame:CGRectZero];
    _subtitleView.opaque = NO;
    _subtitleView.backgroundColor = [UIColor clearColor];
    _subtitleView.textColor = RGBCOLOR(99, 109, 125);
    _subtitleView.font = [UIFont boldSystemFontOfSize:14];
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
  
  if (_titleView.text.length) {
    _subtitleView.frame = CGRectMake(kHPadding, self.height - kVPadding,
      self.width-kHPadding*2, _subtitleView.height);
    _titleView.frame = CGRectMake(0, _subtitleView.top-kVPadding, self.width, _titleView.height);
  } else {
    _subtitleView.frame = CGRectMake(kHPadding, self.height - kVPadding,
      self.width-kHPadding*2, _subtitleView.height);
    _titleView.frame = CGRectZero;
  }

  if (_imageView.image) {
    [_imageView sizeToFit];
    
    CGFloat textTop = _titleView.height ? _titleView.top : _subtitleView.top;
    _imageView.frame = CGRectMake(self.width/2 - kImageSize/2, textTop - (kImageSize + kVPadding),
      kImageSize, kImageSize);
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
