#import "Three20/T3PhotoView.h"
#import "Three20/T3PhotoViewController.h"
#import "Three20/T3ImageView.h"
#import "Three20/T3ActivityLabel.h"
#import "Three20/T3URLCache.h"
#import "Three20/T3PhotoSource.h"

//////////////////////////////////////////////////////////////////////////////////////////////////

static CGFloat kMargin = 10;

//////////////////////////////////////////////////////////////////////////////////////////////////

@implementation T3PhotoView

@synthesize delegate, photo;

- (id)initWithFrame:(CGRect)frame {
  if (self = [super initWithFrame:frame]) {
    delegate = nil;
    photo = nil;
    orientation = 0;
    activityView = nil;
    touchCount = 0;
    isPrimary = NO;
        
    imageView = [[T3ImageView alloc] initWithFrame:frame];
    imageView.delegate = self;
    [self addSubview:imageView];
    
    self.clipsToBounds = YES;
  }
  return self;
}

- (void)dealloc {
  imageView.delegate = nil;
  [photo release];
  [activityView release];
  [imageView release];
  [super dealloc];
}

//////////////////////////////////////////////////////////////////////////////////////////////////

- (CGAffineTransform)getRotationForOrientation:(UIInterfaceOrientation)aOrientation {
  if (aOrientation == UIInterfaceOrientationLandscapeLeft) {
    return CGAffineTransformMakeRotation(4.71238898);
  } else if (aOrientation == UIInterfaceOrientationLandscapeRight) {
    return CGAffineTransformMakeRotation(1.57079633);
  } else {
    return CGAffineTransformIdentity;
  }
}

- (void)layoutPhoto:(UIDeviceOrientation)aOrientation stage:(int)stage {
  if (orientation == UIInterfaceOrientationLandscapeLeft) {
    imageView.transform = CGAffineTransformMakeRotation(4.71238898);
  } else if (orientation == UIInterfaceOrientationLandscapeRight) {
    imageView.transform = CGAffineTransformMakeRotation(1.57079633);
  } else {
    imageView.transform = CGAffineTransformIdentity;
  }

  CGRect screenFrame = [UIScreen mainScreen].bounds;

  CGFloat width, height;
  if (orientation == UIInterfaceOrientationLandscapeLeft
        || orientation == UIInterfaceOrientationLandscapeRight) {
    width = screenFrame.size.height;
    height = screenFrame.size.width;
  } else {
    width = screenFrame.size.width;
    height = screenFrame.size.height;
  }

  if (!photo.size.width) {
    UIImage* image = [[T3URLCache sharedCache] getMediaForURL:photo.smallURL];
    if (image) {
      photo.size = image.size;
    }
  }

  CGFloat photoWidth = 0;
  CGFloat photoHeight = 0;
  if (photo.size.width > photo.size.height) {
    photoWidth = width;
    photoHeight = (photo.size.height/photo.size.width) * width;
    if (photoHeight > height) {
      photoWidth = (photo.size.width/photo.size.height) * height;
      photoHeight = height;
    }
  } else if (photo.size.width && photo.size.height) {
    photoWidth = (photo.size.width/photo.size.height) * height;
    photoHeight = height;
  }

  if (orientation == UIInterfaceOrientationLandscapeLeft) {
    imageView.frame = CGRectMake(0, floor(width/2 - photoWidth/2), photoHeight, photoWidth);
  } else if (orientation == UIInterfaceOrientationLandscapeRight) {
    imageView.frame = CGRectMake(0, floor(width/2 - photoWidth/2), photoHeight, photoWidth);
  } else {
    imageView.frame = CGRectMake(floor(width/2 - photoWidth/2), floor(height/2 - photoHeight/2),
      photoWidth, photoHeight); 
  }
}

- (BOOL)touchHitsSelf:(UITouch*)touch {
  UIView* hitView = [self hitTest:[touch locationInView:self] withEvent:nil];
  return hitView == self;
}

- (BOOL)touchHitsPhoto:(UITouch*)touch {
  if ([self touchHitsSelf:touch]) {
    CGPoint point = [touch locationInView:imageView];
    return point.x > 0 && point.y > 0 && point.x <= imageView.width && point.y <= imageView.height;
  } else {
    return NO;
  }
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// T3ImageViewDelegate

- (void)imageViewLoading:(T3ImageView*)aImageView {
  if (!imageView.image) {
    [self showActivity:@"Loading Photo..."];
  }
}

- (void)imageView:(T3ImageView*)aImageView loaded:(UIImage*)image {
  [self showActivity:nil];

  if (image) {
    if (!photo.size.width) {
      photo.size = image.size;
    }
    [self layout:orientation from:0 stage:0];
  }
}

- (void)imageViewLoadFailed:(T3ImageView*)aImageView {
}

//////////////////////////////////////////////////////////////////////////////////////////////////

- (void)setPhoto:(id<T3Photo>)aPhoto {
  if (aPhoto != photo) {
    [photo release];
    photo = [aPhoto retain];
    
    imageView.url = nil;
  }
}

- (void)layout:(UIInterfaceOrientation)aOrientation from:(UIInterfaceOrientation)fromOrientation
    stage:(int)stage {
  orientation = aOrientation;
  if (photo) {
    [self layoutPhoto:orientation stage:stage];
  }
}

- (BOOL)loadPreview {
  NSString* url = photo.url;
  if (url) {
    UIImage* image = [[T3URLCache sharedCache] getMediaForURL:url fromDisk:NO];
    if (image) {
      imageView.url = url;
      return YES;
    }
  }

  NSString* smallURL = photo.smallURL;
  if (smallURL) {
    UIImage* image = [[T3URLCache sharedCache] getMediaForURL:smallURL fromDisk:NO];
    if (image) {
      imageView.url = smallURL;
      return YES;
    }
  }
  
  NSString* thumbURL = photo.thumbURL;
  if (thumbURL) {
    UIImage* image = [[T3URLCache sharedCache] getMediaForURL:thumbURL fromDisk:NO];
    if (image) {
      imageView.url = thumbURL;
      return YES;
    }
  }
  
  return NO;
}

- (void)loadThumbnail {
  if (photo) {
    isPrimary = NO;
    if (![self loadPreview]) {
      imageView.url = photo.thumbURL;
    }
  }
}

- (void)loadImage {
  if (photo) {
    isPrimary = YES;
    imageView.url = photo.url;
  }
}

- (void)showActivity:(NSString*)text {
  if (text) {
    if (!activityView) {
      activityView = [[T3ActivityLabel alloc] initWithFrame:CGRectZero
        style:T3ActivityLabelStyleBlackBezel];
      activityView.centeredToScreen = NO;
      activityView.userInteractionEnabled = NO;
      [self insertSubview:activityView aboveSubview:imageView];
    }
    activityView.frame = CGRectInset(self.bounds, kMargin, kMargin);
    activityView.label = text;
    activityView.hidden = NO;
  } else if (activityView && !activityView.hidden) {
    activityView.hidden = YES;
  }
}

- (void)photoTouchBegan:(UITouch*)touch {
  ++touchCount;
}

- (void)photoTouchEnded:(UITouch*)touch {
  --touchCount;

  if (touchCount == 0 && touch && touch.tapCount == 1) {
    if ([self touchHitsSelf:touch]) {
      if ([delegate respondsToSelector:@selector(photoViewTapped:)]) {
        [delegate photoViewTapped:self];
      }
    }
  }
}

@end
