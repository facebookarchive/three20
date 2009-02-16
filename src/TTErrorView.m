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
    imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    imageView.contentMode = UIViewContentModeCenter;
    [self addSubview:imageView];

    titleView = [[UILabel alloc] initWithFrame:CGRectZero];
    titleView.opaque = NO;
    titleView.backgroundColor = [UIColor clearColor];
    titleView.textColor = RGBCOLOR(99, 109, 125);
    titleView.font = [UIFont boldSystemFontOfSize:18];
    titleView.textAlignment = UITextAlignmentCenter;
    [self addSubview:titleView];
    
    subtitleView = [[UILabel alloc] initWithFrame:CGRectZero];
    subtitleView.opaque = NO;
    subtitleView.backgroundColor = [UIColor clearColor];
    subtitleView.textColor = RGBCOLOR(99, 109, 125);
    subtitleView.font = [UIFont boldSystemFontOfSize:14];
    subtitleView.textAlignment = UITextAlignmentCenter;
    subtitleView.numberOfLines = 0;
    [self addSubview:subtitleView];
  }
  return self;
}

- (void)dealloc {
  [super dealloc];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// UIView

- (void)layoutSubviews {
  [subtitleView sizeToFit];
  [titleView sizeToFit];
  
  if (titleView.text.length) {
    subtitleView.frame = CGRectMake(kHPadding, self.height - kVPadding,
      self.width-kHPadding*2, subtitleView.height);
    titleView.frame = CGRectMake(0, subtitleView.y-kVPadding, self.width, titleView.height);
  } else {
    subtitleView.frame = CGRectMake(kHPadding, self.height - kVPadding,
      self.width-kHPadding*2, subtitleView.height);
    titleView.frame = CGRectZero;
  }

  if (imageView.image) {
    [imageView sizeToFit];
    
    CGFloat textTop = titleView.height ? titleView.y : subtitleView.y;
    imageView.frame = CGRectMake(self.width/2 - kImageSize/2, textTop - (kImageSize + kVPadding),
      kImageSize, kImageSize);
  } else {
    imageView.frame = CGRectZero;
  }
}

///////////////////////////////////////////////////////////////////////////////////////////////////

- (NSString*)title {
  return titleView.text;
}

- (void)setTitle:(NSString*)title {
  titleView.text = title;
}

- (NSString*)subtitle {
  return subtitleView.text;
}

- (void)setSubtitle:(NSString*)subtitle {
  subtitleView.text = subtitle;
}

- (UIImage*)image {
  return imageView.image;
}

- (void)setImage:(UIImage*)image {
  imageView.image = image;
}

@end
