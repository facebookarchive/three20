//
// Copyright 2009-2011 Facebook
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//    http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

#import "Three20UI/TTPhotoView.h"

// UI
#import "Three20UI/TTPhoto.h"
#import "Three20UI/TTPhotoSource.h"
#import "Three20UI/TTLabel.h"
#import "Three20UI/UIViewAdditions.h"

// UI (private)
#import "Three20UI/private/TTImageViewInternal.h"

// UINavigator
#import "Three20UINavigator/TTGlobalNavigatorMetrics.h"

// UICommon
#import "Three20UICommon/TTGlobalUICommon.h"

// Style
#import "Three20Style/TTGlobalStyle.h"
#import "Three20Style/TTStyleSheet.h"

// Network
#import "Three20Network/TTURLCache.h"
#import "Three20Network/TTURLRequestQueue.h"

// Core
#import "Three20Core/TTCorePreprocessorMacros.h"
#import "Three20Core/TTGlobalCoreLocale.h"


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation TTPhotoView

@synthesize photo         = _photo;
@synthesize captionStyle  = _captionStyle;
@synthesize hidesExtras   = _hidesExtras;
@synthesize hidesCaption  = _hidesCaption;


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];
  if (self) {
    _photoVersion = TTPhotoVersionNone;
    self.clipsToBounds = NO;
  }

  return self;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)dealloc {
  [[TTURLRequestQueue mainQueue] cancelRequestsWithDelegate:self];
  [super setDelegate:nil];
  TT_RELEASE_SAFELY(_photo);
  TT_RELEASE_SAFELY(_captionLabel);
  TT_RELEASE_SAFELY(_captionStyle);
  TT_RELEASE_SAFELY(_statusSpinner);
  TT_RELEASE_SAFELY(_statusLabel);

  [super dealloc];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Private


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)loadVersion:(TTPhotoVersion)version fromNetwork:(BOOL)fromNetwork {
  NSString* URL = [_photo URLForVersion:version];
  if (URL) {
    UIImage* image = [[TTURLCache sharedCache] imageForURL:URL];
    if (image || fromNetwork) {
      _photoVersion = version;
      self.urlPath = URL;
      return YES;
    }
  }

  return NO;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)showCaption:(NSString*)caption {
  if (caption) {
    if (!_captionLabel) {
      _captionLabel = [[TTLabel alloc] init];
      _captionLabel.opaque = NO;
      _captionLabel.style = _captionStyle ? _captionStyle : TTSTYLE(photoCaption);
      _captionLabel.alpha = _hidesCaption ? 0 : 1;
      [self addSubview:_captionLabel];
    }
  }

  _captionLabel.text = caption;
  [self setNeedsLayout];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark UIImageView


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setImage:(UIImage*)image {
  if (image != _defaultImage
      || !_photo
      || self.urlPath != [_photo URLForVersion:TTPhotoVersionLarge]) {
    if (image == _defaultImage) {
      self.contentMode = UIViewContentModeCenter;

    } else {
      self.contentMode = UIViewContentModeScaleAspectFill;
    }

    [super setImage:image];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)imageViewDidStartLoad {
  [self showProgress:0];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
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


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)imageViewDidFailLoadWithError:(NSError*)error {
  [self showProgress:0];
  if (error) {
    [self showStatus:TTDescriptionForError(error)];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark UIView


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)layoutSubviews {
  CGRect screenBounds = TTScreenBounds();
  CGFloat width = self.width;
  CGFloat height = self.height;
  CGFloat cx = self.bounds.origin.x + width/2;
  CGFloat cy = self.bounds.origin.y + height/2;
  CGFloat marginRight = 0, marginLeft = 0, marginBottom = TTToolbarHeight();

  // Since the photo view is constrained to the size of the image, but we want to position
  // the status views relative to the screen, offset by the difference
  CGFloat screenOffset = -floor(screenBounds.size.height/2 - height/2);

  // Vertically center in the space between the bottom of the image and the bottom of the screen
  CGFloat imageBottom = screenBounds.size.height/2 + self.defaultImage.size.height/2;
  CGFloat textWidth = screenBounds.size.width - (marginLeft+marginRight);

  if (_statusLabel.text.length) {
    CGSize statusSize = [_statusLabel sizeThatFits:CGSizeMake(textWidth, 0)];
    _statusLabel.frame =
        CGRectMake(marginLeft + (cx - screenBounds.size.width/2),
                   cy + floor(screenBounds.size.height/2 - (statusSize.height+marginBottom)),
                   textWidth, statusSize.height);

  } else {
    _statusLabel.frame = CGRectZero;
  }

  if (_captionLabel.text.length) {
    CGSize captionSize = [_captionLabel sizeThatFits:CGSizeMake(textWidth, 0)];
    _captionLabel.frame = CGRectMake(marginLeft + (cx - screenBounds.size.width/2),
                                     cy + floor(screenBounds.size.height/2
                                                - (captionSize.height+marginBottom)),
                                     textWidth, captionSize.height);

  } else {
    _captionLabel.frame = CGRectZero;
  }

  CGFloat spinnerTop = _captionLabel.height
    ? _captionLabel.top - floor(_statusSpinner.height + _statusSpinner.height/2)
    : screenOffset + imageBottom + floor(_statusSpinner.height/2);

  _statusSpinner.frame =
    CGRectMake(self.bounds.origin.x + floor(self.bounds.size.width/2 - _statusSpinner.width/2),
               spinnerTop, _statusSpinner.width, _statusSpinner.height);

}


///////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Public


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setPhoto:(id<TTPhoto>)photo {
  if (!photo || photo != _photo) {
    [_photo release];
    _photo = [photo retain];
    _photoVersion = TTPhotoVersionNone;

    self.urlPath = nil;

    [self showCaption:photo.caption];
  }

  if (!_photo || _photo.photoSource.isLoading) {
    [self showProgress:0];

  } else {
    [self showStatus:nil];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setHidesExtras:(BOOL)hidesExtras {
  if (!hidesExtras) {
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:TT_FAST_TRANSITION_DURATION];
  }
  _hidesExtras = hidesExtras;
  _statusSpinner.alpha = _hidesExtras ? 0 : 1;
  _statusLabel.alpha = _hidesExtras ? 0 : 1;
  _captionLabel.alpha = _hidesExtras || _hidesCaption ? 0 : 1;
  if (!hidesExtras) {
    [UIView commitAnimations];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setHidesCaption:(BOOL)hidesCaption {
  _hidesCaption = hidesCaption;
  _captionLabel.alpha = hidesCaption ? 0 : 1;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)loadPreview:(BOOL)fromNetwork {
	BOOL keepTrying = YES;
	// Trying to load the large image first causes scrolling to stall something
	// fierce when using local images on older iPhones since the large image
	// *always* starts to load in time for this first call to succeed. So we
	// skip straight to attempting to load the small version unless we're loading
	// off the network.
	if (fromNetwork) {
		keepTrying = [self loadVersion:TTPhotoVersionLarge fromNetwork:NO];
	}
	if (keepTrying) {
    if (![self loadVersion:TTPhotoVersionSmall fromNetwork:NO]) {
      if (![self loadVersion:TTPhotoVersionThumbnail fromNetwork:fromNetwork]) {
        return NO;
      }
    }
  }

  return YES;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)loadImage {
  if (_photo) {
    _photoVersion = TTPhotoVersionLarge;
    self.urlPath = [_photo URLForVersion:TTPhotoVersionLarge];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
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


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)showStatus:(NSString*)text {
  if (text) {
    if (!_statusLabel) {
      _statusLabel = [[TTLabel alloc] init];
      _statusLabel.style = TTSTYLE(photoStatusLabel);
      _statusLabel.opaque = NO;
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
