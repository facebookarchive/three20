#import "Three20/TTImageView.h"
#import "Three20/TTURLCache.h"
#import "Three20/TTURLResponse.h"
#import "Three20/TTShape.h"
#import "QuartzCore/CALayer.h"

//////////////////////////////////////////////////////////////////////////////////////////////////

@interface TTImageLayer : CALayer {
  TTImageView* _override;
}

@property(nonatomic,assign) TTImageView* override;

@end

@implementation TTImageLayer

@synthesize override = _override;

- (id)init {
  if (self = [super init]) {
    _override = NO;
  }
  return self;
}

- (void)display {
  if (_override) {
    self.contents = (id)_override.image.CGImage;
  } else {
    return [super display];
  }
}

@end

//////////////////////////////////////////////////////////////////////////////////////////////////

@implementation TTImageView

@synthesize delegate = _delegate, url = _url, image = _image, defaultImage = _defaultImage,
  autoresizesToImage = _autoresizesToImage;

//////////////////////////////////////////////////////////////////////////////////////////////////
// NSObject

- (id)initWithFrame:(CGRect)frame {
  if (self = [super initWithFrame:frame]) {
    _delegate = nil;
    _request = nil;
    _url = nil;
    _image = nil;
    _defaultImage = nil;
    _autoresizesToImage = NO;
    self.opaque = YES;
  }
  return self;
}

- (void)dealloc {
  _delegate = nil;
  [_request cancel];
  [_request release];
  [_url release];
  [_image release];
  [_defaultImage release];
  [super dealloc];
}

//////////////////////////////////////////////////////////////////////////////////////////////////
// UIView

+ (Class)layerClass {
  return [TTImageLayer class];
}

- (void)drawRect:(CGRect)rect {
  if (self.style) {
    [super drawRect:rect];
  }
}

//////////////////////////////////////////////////////////////////////////////////////////////////
// TTStyledView

- (void)drawContent:(CGRect)rect {
  if (_image) {
    [_image drawInRect:rect contentMode:self.contentMode];
  } else {
    [_defaultImage drawInRect:rect contentMode:self.contentMode];
  }
}

//////////////////////////////////////////////////////////////////////////////////////////////////
// TTURLRequestDelegate

- (void)requestDidStartLoad:(TTURLRequest*)request {
  [_request release];
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

///////////////////////////////////////////////////////////////////////////////////////////////////
// TTStyleDelegate

- (void)drawLayer:(CGRect)rect withStyle:(TTStyle*)style shape:(TTShape*)shape {
  if ([style isKindOfClass:[TTContentStyle class]]) {
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);

    [shape addToPath:rect];
    CGContextClip(context);

    [self drawContent:rect];

    CGContextRestoreGState(context);
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

- (void)setImage:(UIImage*)image {
  if (image != _image) {
    [_image release];
    _image = [image retain];

    TTImageLayer* layer = (TTImageLayer*)self.layer;
    if (self.style) {
      layer.override = nil;
      [self setNeedsDisplay];
    } else {
      // This is dramatically faster than calling drawRect.  Since we don't have any styles
      // to draw in this case, we can take this shortcut.
      layer.override = self;
      [layer setNeedsDisplay];
    }
    
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
}

- (BOOL)isLoading {
  return !!_request;
}

- (BOOL)isLoaded {
  return self.image && self.image != _defaultImage;
}

- (void)reload {
  if (!_request && _url) {
    UIImage* image = [[TTURLCache sharedCache] imageForURL:_url];
    if (image) {
      self.image = image;
    } else {
      TTURLRequest* request = [TTURLRequest requestWithURL:_url delegate:self];
      request.response = [[[TTURLImageResponse alloc] init] autorelease];
      if (_url && ![request send]) {
        // Put the default image in place while waiting for the request to load
        if (_defaultImage && self.image != _defaultImage) {
          self.image = _defaultImage;
        }
      }
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
