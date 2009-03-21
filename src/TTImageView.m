#import "Three20/TTImageView.h"
#import "Three20/TTURLResponse.h"

//////////////////////////////////////////////////////////////////////////////////////////////////

@implementation TTImageView

@synthesize delegate = _delegate, url = _url, defaultImage = _defaultImage,
  autoresizesToImage = _autoresizesToImage;

- (id)initWithFrame:(CGRect)frame {
  if (self = [super initWithFrame:frame]) {
    _delegate = nil;
    _request = nil;
    _url = nil;
    _defaultImage = nil;
    _autoresizesToImage = NO;
  }
  return self;
}

- (void)dealloc {
  _delegate = nil;
  [_request cancel];
  [_request release];
  [_url release];
  [_defaultImage release];
  [super dealloc];
}

//////////////////////////////////////////////////////////////////////////////////////////////////
// UIImageView

- (void)setImage:(UIImage*)image {
  [super setImage:image];

  CGRect frame = self.frame;
  if (_autoresizesToImage) {
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

  if (!_defaultImage || image != _defaultImage) {
    [self imageViewDidLoadImage:image];
    if ([_delegate respondsToSelector:@selector(imageView:didLoadImage:)]) {
      [_delegate imageView:self didLoadImage:image];
    }
  }
}

//////////////////////////////////////////////////////////////////////////////////////////////////
// TTURLRequestDelegate

- (void)requestDidStartLoad:(TTURLRequest*)request {
  _request = [request retain];
  
  [self imageViewDidStartLoad];
  if ([_delegate respondsToSelector:@selector(imageViewDidStartLoad:)]) {
    [_delegate imageViewDidStartLoad:self];
  }
}

- (void)requestDidFinishLoad:(TTURLRequest*)request {
  TTURLImageResponse* response = request.response;
  self.image = response.image;
  
  [_request release];
  _request = nil;
}

- (void)request:(TTURLRequest*)request didFailLoadWithError:(NSError*)error {
  [_request release];
  _request = nil;

  [self imageViewDidFailLoadWithError:error];
  if ([_delegate respondsToSelector:@selector(imageView:didFailLoadWithError:)]) {
    [_delegate imageView:self didFailLoadWithError:error];
  }
}

- (void)requestDidCancelLoad:(TTURLRequest*)request {
  [_request release];
  _request = nil;

  [self imageViewDidFailLoadWithError:nil];
  if ([_delegate respondsToSelector:@selector(imageView:didFailLoadWithError:)]) {
    [_delegate imageView:self didFailLoadWithError:nil];
  }
}

//////////////////////////////////////////////////////////////////////////////////////////////////
// public

- (void)setUrl:(NSString*)url {
  if (self.image && _url && [url isEqualToString:_url])
    return;
  
  [self stopLoading];
  [_url release];
  _url = [url retain];
  
  if (!_url || !_url.length) {
    if (self.image != _defaultImage) {
      self.image = _defaultImage;
    }
  } else {
    [self reload];
  }
}

- (BOOL)isLoading {
  return !!_request;
}

- (BOOL)isLoaded {
  return self.image && self.image != _defaultImage;
}

- (void)reload {
  if (_request)
    return;
  
  TTURLRequest* request = [TTURLRequest requestWithURL:_url delegate:self];
  request.response = [[[TTURLImageResponse alloc] init] autorelease];
  if (_url && ![request send]) {
    // Put the default image in place while waiting for the request to load
    if (_defaultImage && self.image != _defaultImage) {
      self.image = _defaultImage;
    }
  }
}

- (void)stopLoading {
  [_request cancel];
}

- (void)imageViewDidStartLoad {
}

- (void)imageViewDidLoadImage:(UIImage*)image {
}

- (void)imageViewDidFailLoadWithError:(NSError*)error {
}

@end
