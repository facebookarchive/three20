#import "Three20/T3ErrorView.h"

///////////////////////////////////////////////////////////////////////////////////////////////////

static CGFloat kImageSize = 180;
static CGFloat kHPadding = 20;
static CGFloat kVPadding = 50;

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation T3ErrorView

- (id)initWithTitle:(NSString*)title caption:(NSString*)caption image:(UIImage*)image {
  if (self = [self initWithFrame:CGRectZero]) {
    self.title = title;
    self.caption = caption;
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
    
    captionView = [[UILabel alloc] initWithFrame:CGRectZero];
    captionView.opaque = NO;
    captionView.backgroundColor = [UIColor clearColor];
    captionView.textColor = RGBCOLOR(99, 109, 125);
    captionView.font = [UIFont boldSystemFontOfSize:14];
    captionView.textAlignment = UITextAlignmentCenter;
    captionView.numberOfLines = 0;
    [self addSubview:captionView];
  }
  return self;
}

- (void)dealloc {
  [super dealloc];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// UIView

- (void)layoutSubviews {
  [captionView sizeToFit];
  [titleView sizeToFit];
  
  if (titleView.text.length) {
    captionView.frame = CGRectMake(kHPadding, self.height - kVPadding,
      self.width-kHPadding*2, captionView.height);
    titleView.frame = CGRectMake(0, captionView.y-kVPadding, self.width, titleView.height);
  } else {
    captionView.frame = CGRectMake(kHPadding, self.height - kVPadding,
      self.width-kHPadding*2, captionView.height);
    titleView.frame = CGRectZero;
  }

  if (imageView.image) {
    [imageView sizeToFit];
    
    CGFloat textTop = titleView.height ? titleView.y : captionView.y;
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

- (NSString*)caption {
  return captionView.text;
}

- (void)setCaption:(NSString*)caption {
  captionView.text = caption;
}

- (UIImage*)image {
  return imageView.image;
}

- (void)setImage:(UIImage*)image {
  imageView.image = image;
}

@end
