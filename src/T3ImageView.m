#import "Three20/T3ImageView.h"

@implementation T3ImageView

@synthesize delegate, url, defaultImage, loading, autoresizesToImage;

- (id)initWithFrame:(CGRect)frame {
  if (self = [super initWithFrame:frame]) {
    delegate = nil;
    request = nil;
    url = nil;
    defaultImage = nil;
    autoresizesToImage = NO;
  }
  return self;
}

- (void)dealloc {
  delegate = nil;
  self.url = nil;
  [request release];
  [defaultImage release];
  [super dealloc];
}

//////////////////////////////////////////////////////////////////////////////////////////////////
// UIImageView

- (void)setImage:(UIImage*)image {
  [super setImage:image];

  CGRect frame = self.frame;
  if (autoresizesToImage) {
    self.frame = CGRectMake(frame.origin.x, frame.origin.y, image.size.width, image.size.height);
  } else {
    if (!frame.size.width && !frame.size.height) {
      self.frame = CGRectMake(frame.origin.x, frame.origin.y, image.size.width, image.size.height);
    } else if (frame.size.width && !frame.size.height) {
      self.frame = CGRectMake(frame.origin.x, frame.origin.y,
        frame.size.width, floor((image.size.height/image.size.width) * frame.size.width));
    } else if (frame.size.height && !frame.size.width) {
      self.frame = CGRectMake(frame.origin.x, frame.origin.y,
        floor((image.size.width/image.size.height) * frame.size.height), frame.size.height);
    }
  }

  [delegate imageView:self loaded:image];
}

//////////////////////////////////////////////////////////////////////////////////////////////////
// T3URLRequestDelegate

- (void)request:(T3URLRequest*)aRequest loadedData:(NSData*)data media:(id)media
    forURL:(NSString*)url {
  [request release];
  request = nil;

  if ([media isKindOfClass:[UIImage class]]) {
    self.image = (UIImage*)media;

    if ([delegate respondsToSelector:@selector(imageViewLoaded:)]) {
      [delegate imageViewLoaded:self];
    }
  } else {
    if ([delegate respondsToSelector:@selector(imageView:loadFailedWithError:)]) {
      [delegate imageView:self loadFailedWithError:nil];
    }
  }
}

- (void)request:(T3URLRequest*)aRequest loadingURL:(NSString*)url didFailWithError:(NSError*)error {
  [request release];
  request = nil;

  if ([delegate respondsToSelector:@selector(imageView:loadFailedWithError:)]) {
    [delegate imageView:self loadFailedWithError:error];
  }
}

- (void)request:(T3URLRequest*)aRequest cancelledLoadingURL:(NSString*)url {
  [request release];
  request = nil;

  if ([delegate respondsToSelector:@selector(imageView:loadFailedWithError:)]) {
    [delegate imageView:self loadFailedWithError:nil];
  }
}

//////////////////////////////////////////////////////////////////////////////////////////////////

- (void)setUrl:(NSString*)theURL {
  if (self.image && [theURL isEqualToString:url])
    return;
  
  [self stopLoading];
  [url release];
  url = [theURL retain];
  
  if (!url || !url.length) {
    if (self.image != defaultImage) {
      self.image = defaultImage;
    }
  } else {
    [self reload];
  }
}

- (BOOL)loading {
  return !!request;
}

- (void)reload {
  if (request)
    return;
  
  request = [[T3URLRequest alloc] initWithURL:url delegate:self];
  request.convertMedia = YES;
  
  if (url && ![request send]) {
    // Put the default image in place while waiting for the request to load
    if (defaultImage && self.image != defaultImage) {
      self.image = defaultImage;
    }

    if ([delegate respondsToSelector:@selector(imageViewLoading:)]) {
      [delegate imageViewLoading:self];
    }
  }
}

- (void)stopLoading {
  [request cancel];
}

@end
