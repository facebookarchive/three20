/**
 * Copyright 2009 Facebook
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

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

- (void)dealloc {
  [super dealloc];
}

@end

//////////////////////////////////////////////////////////////////////////////////////////////////

@implementation TTImageView

@synthesize delegate = _delegate, URL = _URL, image = _image, defaultImage = _defaultImage,
  autoresizesToImage = _autoresizesToImage;

//////////////////////////////////////////////////////////////////////////////////////////////////
// private

- (void)updateLayer {
  TTImageLayer* layer = (TTImageLayer*)self.layer;
  if (self.style) {
    layer.override = nil;
  } else {
    // This is dramatically faster than calling drawRect.  Since we don't have any styles
    // to draw in this case, we can take this shortcut.
    layer.override = self;
  }
  [layer setNeedsDisplay];
}

//////////////////////////////////////////////////////////////////////////////////////////////////
// NSObject

- (id)initWithFrame:(CGRect)frame {
  if (self = [super initWithFrame:frame]) {
    _delegate = nil;
    _request = nil;
    _URL = nil;
    _image = nil;
    _defaultImage = nil;
    _autoresizesToImage = NO;
  }
  return self;
}

- (void)dealloc {
  _delegate = nil;
  [_request cancel];
  TT_RELEASE_SAFELY(_request);
  TT_RELEASE_SAFELY(_URL);
  TT_RELEASE_SAFELY(_image);
  TT_RELEASE_SAFELY(_defaultImage);
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
// TTView

- (void)drawContent:(CGRect)rect {
  if (_image) {
    [_image drawInRect:rect contentMode:self.contentMode];
  } else {
    [_defaultImage drawInRect:rect contentMode:self.contentMode];
  }
}

- (void)setStyle:(TTStyle*)style {
  if (style != _style) {
    [super setStyle:style];
    [self updateLayer];
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
  
  TT_RELEASE_SAFELY(_request);
}

- (void)request:(TTURLRequest*)request didFailLoadWithError:(NSError*)error {
  TT_RELEASE_SAFELY(_request);

  [self imageViewDidFailLoadWithError:error];
  if ([_delegate respondsToSelector:@selector(imageView:didFailLoadWithError:)]) {
    [_delegate imageView:self didFailLoadWithError:error];
  }
}

- (void)requestDidCancelLoad:(TTURLRequest*)request {
  TT_RELEASE_SAFELY(_request);

  [self imageViewDidFailLoadWithError:nil];
  if ([_delegate respondsToSelector:@selector(imageView:didFailLoadWithError:)]) {
    [_delegate imageView:self didFailLoadWithError:nil];
  }
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// TTStyleDelegate

- (void)drawLayer:(TTStyleContext*)context withStyle:(TTStyle*)style {
  if ([style isKindOfClass:[TTContentStyle class]]) {
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSaveGState(ctx);

    CGRect rect = context.frame;
    [context.shape addToPath:rect];
    CGContextClip(ctx);

    [self drawContent:rect];

    CGContextRestoreGState(ctx);
  }
}

//////////////////////////////////////////////////////////////////////////////////////////////////
// public

- (void)setURL:(NSString*)URL {
  if (self.image && _URL && [URL isEqualToString:_URL])
    return;
  
  [self stopLoading];
  [_URL release];
  _URL = [URL retain];
  
  if (!_URL || !_URL.length) {
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

    [self updateLayer];
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
  if (!_request && _URL) {
    UIImage* image = [[TTURLCache sharedCache] imageForURL:_URL];
    if (image) {
      self.image = image;
    } else {
      TTURLRequest* request = [TTURLRequest requestWithURL:_URL delegate:self];
      request.response = [[[TTURLImageResponse alloc] init] autorelease];
      if (_URL && ![request send]) {
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
