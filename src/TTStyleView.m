#import "Three20/TTStyleView.h"
#import "Three20/TTURLCache.h"
#import "Three20/TTURLRequest.h"
#import "Three20/TTURLResponse.h"

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation TTStyleView

@synthesize delegate = _delegate, style = _style, fillColor = _fillColor, fillColor2 = _fillColor2,
  borderColor = _borderColor, borderWidth = _borderWidth, borderRadius = _borderRadius,
  backgroundInset = _backgroundInset, backgroundImageURL = _backgroundImageURL,
  backgroundImage = _backgroundImage, backgroundImageDefault = _backgroundImageDefault;

///////////////////////////////////////////////////////////////////////////////////////////////////
// private

- (CGRect)backgroundBounds {
  CGRect frame = self.frame;
  return CGRectMake(_backgroundInset.left, _backgroundInset.top,
    frame.size.width - (_backgroundInset.left + _backgroundInset.right),
    frame.size.height - (_backgroundInset.top + _backgroundInset.bottom));
}

- (void)drawBackground:(CGRect)rect {
  if (_style) {
    if (_fillColor2 && _fillColor) {
      UIColor* fillColors[] = {_fillColor, _fillColor2};
      [[TTAppearance appearance] draw:_style rect:rect fill:fillColors fillCount:2
        stroke:nil thickness:_borderWidth radius:_borderRadius];
    } else if (_fillColor) {
      [[TTAppearance appearance] draw:_style rect:rect fill:&_fillColor fillCount:1
        stroke:nil thickness:_borderWidth radius:_borderRadius];
    } else if (_style != TTStyleFill) {
      [[TTAppearance appearance] draw:_style rect:rect fill:nil fillCount:0
        stroke:nil thickness:_borderWidth radius:_borderRadius];
    }
  }
}

- (void)drawImage:(CGRect)rect {
  if (_backgroundImage) {
    if (_borderRadius) {
      [_backgroundImage drawInRect:rect radius:_borderRadius];
    } else {
      [_backgroundImage drawInRect:rect];
    }
  } else if (_backgroundImageDefault) {
    if (_borderRadius) {
      [_backgroundImageDefault drawInRect:rect radius:_borderRadius];
    } else {
      [_backgroundImageDefault drawInRect:rect];
    }
  }
}

- (void)drawForeground:(CGRect)rect {
  if (_style) {
    if (_borderColor) {
      [[TTAppearance appearance] draw:_style rect:rect fill:nil fillCount:0
        stroke:_borderColor thickness:_borderWidth radius:_borderRadius];
    }
  }
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// NSObject

- (id)initWithFrame:(CGRect)frame {
  if (self = [super initWithFrame:frame]) {
    _delegate = nil;
    _imageRequest = nil;
    _style = TTStyleFill;
    _fillColor = nil;
    _fillColor2 = nil;
    _borderColor = nil;
    _borderWidth = 1;
    _borderRadius = 0;
    _backgroundInset = UIEdgeInsetsZero;
    _backgroundImageURL = nil;
    _backgroundImage = nil;
    _backgroundImageDefault = nil;

    self.contentMode = UIViewContentModeRedraw;
  }
  return self;
}

- (void)dealloc {
  _delegate = nil;
  [_imageRequest cancel];
  [_imageRequest release];
  [_fillColor release];
  [_fillColor2 release];
  [_borderColor release];
  [_backgroundImageURL release];
  [_backgroundImage release];
  [_backgroundImageDefault release];
  [super dealloc];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// UIView

- (void)drawRect:(CGRect)rect {
  CGRect bounds = self.backgroundBounds;
  [self drawBackground:bounds];
  [self drawImage:rect];
  [self drawForeground:bounds];
}

//////////////////////////////////////////////////////////////////////////////////////////////////
// TTURLRequestDelegate

- (void)requestDidStartLoad:(TTURLRequest*)request {
  _imageRequest = [request retain];
  
  if ([_delegate respondsToSelector:@selector(styleViewDidStartLoad:)]) {
    [_delegate styleViewDidStartLoad:self];
  }
}

- (void)requestDidFinishLoad:(TTURLRequest*)request {
  TTURLImageResponse* response = request.response;
  self.backgroundImage = response.image;
  
  [_imageRequest release];
  _imageRequest = nil;
}

- (void)request:(TTURLRequest*)request didFailLoadWithError:(NSError*)error {
  [_imageRequest release];
  _imageRequest = nil;

  if ([_delegate respondsToSelector:@selector(styleView:didFailLoadWithError:)]) {
    [_delegate styleView:self didFailLoadWithError:error];
  }
}

- (void)requestDidCancelLoad:(TTURLRequest*)request {
  [_imageRequest release];
  _imageRequest = nil;

  if ([_delegate respondsToSelector:@selector(styleView:didFailLoadWithError:)]) {
    [_delegate styleView:self didFailLoadWithError:nil];
  }
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// public

- (void)setFillColor:(UIColor*)color {
  [_fillColor release];
  _fillColor = [color retain];
  
  [self setNeedsDisplay];
}

- (void)setBackgroundImageURL:(NSString*)url {
  if (self.backgroundImage && _backgroundImageURL && [url isEqualToString:_backgroundImageURL])
    return;
  
  [self stopLoadingImages];
  [_backgroundImageURL release];
  _backgroundImageURL = [url retain];
  
  if (!_backgroundImageURL || !_backgroundImageURL.length) {
    if (self.backgroundImage != _backgroundImageDefault) {
      self.backgroundImage = _backgroundImageDefault;
    }
  } else {
    [self reloadImages];
  }
}


- (void)setBackgroundImage:(UIImage*)image {
  if (image != _backgroundImage) {
    [_backgroundImage release];
    _backgroundImage = [image retain];
  }
  
  if (!_backgroundImageDefault || image != _backgroundImageDefault) {
    if ([_delegate respondsToSelector:@selector(styleView:didLoadImage:)]) {
      [_delegate styleView:self didLoadImage:image];
    }
  }
  
  [self setNeedsDisplay];
}

- (BOOL)isLoading {
  return !!_imageRequest;
}

- (BOOL)isLoaded {
  return self.backgroundImage && self.backgroundImage != _backgroundImageDefault;
}

- (void)reloadImages {
  if (_imageRequest)
    return;
  
  UIImage* image = [[TTURLCache sharedCache] imageForURL:_backgroundImageURL];
  if (image) {
    self.backgroundImage = image;
  } else {
    TTURLRequest* request = [TTURLRequest requestWithURL:_backgroundImageURL delegate:self];
    request.response = [[[TTURLImageResponse alloc] init] autorelease];
    if (_backgroundImageURL && ![request send]) {
      // Put the default image in place while waiting for the request to load
      if (_backgroundImageDefault && self.backgroundImage != _backgroundImageDefault) {
        self.backgroundImage = _backgroundImageDefault;
      }
    }
  }
}

- (void)stopLoadingImages {
  [_imageRequest cancel];
}


@end
