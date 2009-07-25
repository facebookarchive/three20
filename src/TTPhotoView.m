#import "Three20/TTPhotoView.h"
#import "Three20/TTDefaultStyleSheet.h"
#import "Three20/TTImageView.h"
#import "Three20/TTActivityLabel.h"
#import "Three20/TTURLCache.h"
#import "Three20/TTURLRequestQueue.h"

//////////////////////////////////////////////////////////////////////////////////////////////////

static const CGFloat kPadding = 20;
static const CGFloat kCaptionMargin = 20;
  
static const CGFloat kMaxCaptionHeight = 100;

//////////////////////////////////////////////////////////////////////////////////////////////////

@implementation TTPhotoView

@synthesize photo = _photo, hidesExtras = _hidesExtras, hidesCaption = _hidesCaption;

///////////////////////////////////////////////////////////////////////////////////////////////////
// private

- (BOOL)loadVersion:(TTPhotoVersion)version fromNetwork:(BOOL)fromNetwork {
  NSString* URL = [_photo URLForVersion:version];
  if (URL) {
    UIImage* image = [[TTURLCache sharedCache] imageForURL:URL];
    if (image || fromNetwork) {
      _photoVersion = version;
      self.URL = URL;
      return YES;
    }
  }
  return NO;
}

- (void)showCaption:(NSString*)caption {
  if (caption) {
    if (!_captionLabel) {
      _captionLabel = [[UILabel alloc] init];
      _captionLabel.textColor = TTSTYLEVAR(photoCaptionTextColor);
      _captionLabel.font = TTSTYLEVAR(photoCaptionFont);
      _captionLabel.shadowColor = [UIColor colorWithWhite:0 alpha:0.9];
      _captionLabel.shadowOffset = CGSizeMake(1, 1);
      _captionLabel.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
      _captionLabel.lineBreakMode = UILineBreakModeTailTruncation;
      _captionLabel.textAlignment = UITextAlignmentCenter;
      _captionLabel.numberOfLines = 6;
      _captionLabel.alpha = _hidesCaption ? 0 : 1;
      [self addSubview:_captionLabel];
    }
  }

  _captionLabel.text = caption;
  [self setNeedsLayout];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// NSObject

- (id)initWithFrame:(CGRect)frame {
  if (self = [super initWithFrame:frame]) {
    _photo = nil;
    _statusSpinner = nil;
    _statusLabel = nil;
    _captionLabel = nil;
    _photoVersion = TTPhotoVersionNone;
    _hidesExtras = NO;
    _hidesCaption = NO;
    
    self.clipsToBounds = NO;
  }
  return self;
}

- (void)dealloc {
  [[TTURLRequestQueue mainQueue] cancelRequestsWithDelegate:self];
  [super setDelegate:nil];
  TT_RELEASE_SAFELY(_photo);
  TT_RELEASE_SAFELY(_statusSpinner);
  TT_RELEASE_SAFELY(_statusLabel);
  TT_RELEASE_SAFELY(_captionLabel);
  [super dealloc];
}

//////////////////////////////////////////////////////////////////////////////////////////////////
// UIImageView

- (void)setImage:(UIImage*)image {
  if (image != _defaultImage || !_photo || self.URL != [_photo URLForVersion:TTPhotoVersionLarge]) {
    if (image == _defaultImage) {
      self.contentMode = UIViewContentModeCenter;
    } else {
      self.contentMode = UIViewContentModeScaleAspectFill;
    }
    [super setImage:image];
  }
}

- (void)imageViewDidStartLoad {
  [self showProgress:0];
}

- (void)imageViewDidLoadImage:(UIImage*)image {
  if (!_photo.photoSource.isLoading) {
    [self showProgress:-1];
    [self showStatus:nil];
  }
  
  if (!_photo.size.width) {
    _photo.size = image.size;
    [self.superview setNeedsLayout];
  }
}

- (void)imageViewDidFailLoadWithError:(NSError*)error {
  [self showProgress:0];
  [self showStatus:TTDescriptionForError(error)];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// UIView

- (void)layoutSubviews {
  CGRect screenBounds = TTScreenBounds();
  CGFloat width = self.orientationWidth;
  CGFloat height = self.orientationHeight;
  CGFloat cx = self.bounds.origin.x + width/2;
  CGFloat cy = self.bounds.origin.y + height/2;

  BOOL portrait = self.width == width;
  CGFloat marginRight = portrait ? 0 : TT_CHROME_HEIGHT;
  CGFloat marginLeft = portrait ? 0 : TT_ROW_HEIGHT;
  CGFloat marginBottom = portrait ? TT_ROW_HEIGHT : 0;
  
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

  CGFloat captionWidth = screenBounds.size.width - (marginLeft+marginRight);
  CGSize captionSize = [_captionLabel.text sizeWithFont:_captionLabel.font
                                           constrainedToSize:CGSizeMake(captionWidth, CGFLOAT_MAX)];
  if (captionSize.height) {
    CGFloat captionHeight = (captionSize.height > kMaxCaptionHeight
                            ? kMaxCaptionHeight : captionSize.height) + kCaptionMargin;
    _captionLabel.frame = CGRectMake(marginLeft + (cx - screenBounds.size.width/2), 
      cy + floor(screenBounds.size.height/2 - (captionHeight+marginBottom)),
      captionWidth, captionHeight);
  } else {
    _captionLabel.frame = CGRectZero;
  }
}

//////////////////////////////////////////////////////////////////////////////////////////////////
// public

- (void)setPhoto:(id<TTPhoto>)photo {
  if (!photo || photo != _photo) {
    [_photo release];
    _photo = [photo retain];
    _photoVersion = TTPhotoVersionNone;
    
    self.URL = nil;
    
    [self showCaption:photo.caption];
  }
  
  if (!_photo || _photo.photoSource.isLoading) {
    [self showProgress:0];
  } else {
    [self showStatus:nil];
  }
}

- (void)setHidesExtras:(BOOL)hidesExtras {
  _hidesExtras = hidesExtras;
   _statusSpinner.alpha = _hidesExtras ? 0 : 1;
   _statusLabel.alpha = _hidesExtras ? 0 : 1;
   _captionLabel.alpha = _hidesExtras || _hidesCaption ? 0 : 1;
}

- (void)setHidesCaption:(BOOL)hidesCaption {
  _hidesCaption = hidesCaption;
  _captionLabel.alpha = hidesCaption ? 0 : 1;
}

- (BOOL)loadPreview:(BOOL)fromNetwork {
  if (![self loadVersion:TTPhotoVersionLarge fromNetwork:NO]) {
    if (![self loadVersion:TTPhotoVersionSmall fromNetwork:NO]) {
      if (![self loadVersion:TTPhotoVersionThumbnail fromNetwork:fromNetwork]) {
        return NO;
      }
    }
  }
  
  return YES;
}

- (void)loadImage {
  if (_photo) {
    _photoVersion = TTPhotoVersionLarge;
    self.URL = [_photo URLForVersion:TTPhotoVersionLarge];
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
  } else {
    [_statusSpinner stopAnimating];
    _statusSpinner.hidden = YES;
    _captionLabel.hidden = !!_statusLabel.text.length;
  }
}

- (void)showStatus:(NSString*)text {
  if (text) {
    if (!_statusLabel) {
      _statusLabel = [[UILabel alloc] init];
      _statusLabel.font = TTSTYLEVAR(tableFont);
      _statusLabel.textColor = TTSTYLEVAR(tableErrorTextColor);
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
    _captionLabel.hidden = NO;
  }

  _statusLabel.text = text;
}

@end
