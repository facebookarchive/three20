#import "Three20/T3PhotoView.h"
#import "Three20/T3ImageView.h"
#import "Three20/T3ActivityLabel.h"
#import "Three20/T3URLCache.h"

//////////////////////////////////////////////////////////////////////////////////////////////////

static const CGFloat kPadding = 20;
static const CGFloat kMarginBottom = 15;
  
static const CGFloat kCaptionWidth = 230;
static const CGFloat kMaxCaptionHeight = 100;

//////////////////////////////////////////////////////////////////////////////////////////////////

@implementation T3PhotoView

@synthesize photo = _photo, extrasHidden = _extrasHidden, captionHidden = _captionHidden;

- (id)initWithFrame:(CGRect)frame {
  if (self = [super initWithFrame:frame]) {
    _photo = nil;
    _statusSpinner = nil;
    _statusLabel = nil;
    _captionLabel = nil;
    _photoVersion = T3PhotoVersionNone;
    _extrasHidden = NO;
    _captionHidden = NO;
    
    self.delegate = self;
    self.clipsToBounds = NO;
  }
  return self;
}

- (void)dealloc {
  [super setDelegate:nil];
  [_photo release];
  [_statusSpinner release];
  [_statusLabel release];
  [_captionLabel release];
  [super dealloc];
}

///////////////////////////////////////////////////////////////////////////////////////////////////

- (BOOL)loadVersion:(T3PhotoVersion)version fromNetwork:(BOOL)fromNetwork {
  NSString* url = [_photo urlForVersion:version];
  if (url) {
    UIImage* image = [[T3URLCache sharedCache] getMediaForURL:url fromDisk:NO];
    if (image || fromNetwork) {
      _photoVersion = version;
      self.url = url;
      return YES;
    }
  }
  return NO;
}

- (void)showCaption:(NSString*)caption {
  if (caption) {
    if (!_captionLabel) {
      _captionLabel = [[UILabel alloc] initWithFrame:CGRectZero];
      _captionLabel.opaque = NO;
      _captionLabel.textColor = [UIColor whiteColor];
      _captionLabel.font = [UIFont boldSystemFontOfSize:13.0];
      _captionLabel.shadowColor = [UIColor colorWithWhite:0 alpha:0.9];
      _captionLabel.shadowOffset = CGSizeMake(1, 1);
      _captionLabel.backgroundColor = [UIColor clearColor];
      _captionLabel.lineBreakMode = UILineBreakModeWordWrap;
      _captionLabel.textAlignment = UITextAlignmentCenter;
      _captionLabel.numberOfLines = 6;
      [self addSubview:_captionLabel];
    }
  }

  _captionLabel.text = caption;
}

//////////////////////////////////////////////////////////////////////////////////////////////////
// UIImageView

- (void)setImage:(UIImage*)image {
  if (image != _defaultImage || !_photo || self.url != [_photo urlForVersion:T3PhotoVersionLarge]) {
    if (image == _defaultImage) {
      self.contentMode = UIViewContentModeCenter;
    } else {
      self.contentMode = UIViewContentModeScaleToFill;
    }
    [super setImage:image];
  }
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// UIView

- (void)layoutSubviews {
  CGRect screenBounds = T3ScreenBounds();
  CGFloat height = self.orientationHeight;
  CGFloat cx = self.bounds.origin.x + self.orientationWidth/2;
  CGFloat cy = self.bounds.origin.y + self.orientationHeight/2;

  BOOL landscape = self.width == self.orientationWidth;
  CGFloat marginBottom = landscape ? TOOLBAR_HEIGHT : 0;
  
  // Since the photo view is constrained to the size of the image, but we want to position
  // the status views relative to the screen, offset by the difference
  CGFloat screenOffset = -floor(screenBounds.size.height/2 - height/2);
  
  // Vertically center in the space between the bottom of the image and the bottom of the screen
  CGFloat imageBottom = screenBounds.size.height/2 + self.defaultImage.size.height/2;
  CGFloat offsetBottom = imageBottom + (screenBounds.size.height - (imageBottom + marginBottom))/2;
  
  _statusLabel.frame = CGRectMake(0, 0, self.width - kPadding, 0);
  [_statusLabel sizeToFit];
  _statusLabel.center = CGPointMake(self.bounds.origin.x + self.bounds.size.width/2,
    screenOffset + self.bounds.origin.y + offsetBottom);

  [_statusSpinner sizeToFit];
  _statusSpinner.center = CGPointMake(self.bounds.origin.x + self.bounds.size.width/2,
    screenOffset + self.bounds.origin.y + offsetBottom);

  CGSize captionSize = [_captionLabel.text sizeWithFont:_captionLabel.font
    constrainedToSize:CGSizeMake(kCaptionWidth, CGFLOAT_MAX)];
  CGFloat captionHeight = captionSize.height > kMaxCaptionHeight
    ? kMaxCaptionHeight : captionSize.height;

  _captionLabel.frame = CGRectMake(
    floor(cx - captionSize.width/2),
    floor(cy + screenBounds.size.height/2 - (captionHeight+kMarginBottom+marginBottom)),
    captionSize.width, captionHeight);
}

//////////////////////////////////////////////////////////////////////////////////////////////////
// UIImageViewDelegate

- (void)imageViewLoading:(T3ImageView*)imageView {
  [self showProgress:0];
}

- (void)imageView:(T3ImageView*)imageView loaded:(UIImage*)image {
  if (!_photo.photoSource.loading) {
    [self showProgress:-1];
    [self showStatus:nil];
  }
  
  if (!_photo.size.width) {
    _photo.size = image.size;
  }
}

- (void)imageView:(T3ImageView*)imageView loadDidFailWithError:(NSError*)error {
  if (self.url == [_photo urlForVersion:T3PhotoVersionLarge]) {
    [self showStatus:NSLocalizedString(@"This photo is not available.", @"")];
  } else {
    [self showProgress:0];
  }
}

//////////////////////////////////////////////////////////////////////////////////////////////////

- (void)setPhoto:(id<T3Photo>)photo {
  if (!photo || photo != _photo) {
    [_photo release];
    _photo = [photo retain];
    _photoVersion = T3PhotoVersionNone;
    
    self.url = nil;
    
    [self showCaption:photo.caption];
  }
  
  if (!_photo || _photo.photoSource.loading) {
    [self showProgress:0];
  } else {
    [self showStatus:nil];
  }
}

- (void)setExtrasHidden:(BOOL)extrasHidden {
  _extrasHidden = extrasHidden;
   _statusSpinner.alpha = _extrasHidden ? 0 : 1;
   _statusLabel.alpha = _extrasHidden ? 0 : 1;
   _captionLabel.alpha = _extrasHidden || _captionHidden ? 0 : 1;
}


- (void)setCaptionHidden:(BOOL)captionHidden {
  _captionHidden = captionHidden;
  _captionLabel.alpha = captionHidden ? 0 : 1;
}

- (BOOL)loadPreview:(BOOL)fromNetwork {
  if (![self loadVersion:T3PhotoVersionLarge fromNetwork:NO]) {
    if (![self loadVersion:T3PhotoVersionSmall fromNetwork:NO]) {
      if (![self loadVersion:T3PhotoVersionThumbnail fromNetwork:fromNetwork]) {
        return NO;
      }
    }
  }
  
  return YES;
}

- (void)loadImage {
  if (_photo) {
    _photoVersion = T3PhotoVersionLarge;
    self.url = [_photo urlForVersion:T3PhotoVersionLarge];
  }
}

- (void)showProgress:(CGFloat)progress {
  if (progress >= 0) {
    if (!_statusSpinner) {
      _statusSpinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:
        UIActivityIndicatorViewStyleWhiteLarge];
      [self addSubview:_statusSpinner];
    }

    [_statusSpinner startAnimating];
    _statusSpinner.hidden = NO;
    [self showStatus:nil];
    [self setNeedsLayout];
    _captionLabel.hidden = YES;
  } else {
    [_statusSpinner stopAnimating];
    _statusSpinner.hidden = YES;
    _captionLabel.hidden = !!_statusLabel.text;
  }
}

- (void)showStatus:(NSString*)text {
  if (text) {
    if (!_statusLabel) {
      _statusLabel = [[UILabel alloc] initWithFrame:CGRectZero];
      _statusLabel.font = [UIFont boldSystemFontOfSize:17];
      _statusLabel.textColor = [UIColor colorWithRed:0.42 green:0.44 blue:0.49 alpha:1];
      _statusLabel.backgroundColor = [UIColor clearColor];
      _statusLabel.shadowColor = [UIColor colorWithWhite:0 alpha:0.7];
      _statusLabel.shadowOffset = CGSizeMake(1, 1);
      _statusLabel.textAlignment = UITextAlignmentCenter;
      _statusLabel.numberOfLines = 0;
      [self addSubview:_statusLabel];
    }
    _statusLabel.hidden = NO;
    [self showProgress:-1];
    [self setNeedsLayout];
    _captionLabel.hidden = YES;
  } else {
    _statusLabel.hidden = YES;
    _captionLabel.hidden = _statusSpinner.isAnimating;
  }

  _statusLabel.text = text;
}

@end
