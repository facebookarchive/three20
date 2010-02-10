//
// Copyright 2009-2010 Facebook
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

#import "Three20/TTButton.h"

#import "Three20/TTGlobalCore.h"
#import "Three20/TTGlobalUI.h"

#import "Three20/TTDefaultStyleSheet.h"

#import "Three20/TTURLRequest.h"
#import "Three20/TTURLRequestDelegate.h"
#import "Three20/TTURLImageResponse.h"

#import "Three20/TTURLCache.h"

///////////////////////////////////////////////////////////////////////////////////////////////////
// global

static const CGFloat kHPadding = 8;
static const CGFloat kVPadding = 7;

///////////////////////////////////////////////////////////////////////////////////////////////////

@interface TTButtonContent : NSObject <TTURLRequestDelegate> {
  TTButton* _button;
  NSString* _title;
  NSString* _imageURL;
  UIImage* _image;
  TTStyle* _style;
  TTURLRequest* _request;
}

@property(nonatomic,copy) NSString* title;
@property(nonatomic,copy) NSString* imageURL;
@property(nonatomic,retain) UIImage* image;
@property(nonatomic,retain) TTStyle* style;

- (id)initWithButton:(TTButton*)button;

- (void)reload;
- (void)stopLoading;

@end

@implementation TTButtonContent

@synthesize title = _title, imageURL = _imageURL, image = _image, style = _style;

//////////////////////////////////////////////////////////////////////////////////////////////////
// NSObject

- (id)initWithButton:(TTButton*)button {
  if (self = [super init]) {
    _button = button;
    _title = nil;
    _imageURL = nil;
    _image = nil;
    _request = nil;
    _style = nil;
  }
  return self;
}

- (void)dealloc {
  [_request cancel];
  TT_RELEASE_SAFELY(_request);
  TT_RELEASE_SAFELY(_title);
  TT_RELEASE_SAFELY(_imageURL);
  TT_RELEASE_SAFELY(_image);
  TT_RELEASE_SAFELY(_style);
  [super dealloc];
}

//////////////////////////////////////////////////////////////////////////////////////////////////
// TTURLRequestDelegate

- (void)requestDidStartLoad:(TTURLRequest*)request {
  [_request release];
  _request = [request retain];
}

- (void)requestDidFinishLoad:(TTURLRequest*)request {
  TTURLImageResponse* response = request.response;
  self.image = response.image;
  [_button setNeedsDisplay];
  
  TT_RELEASE_SAFELY(_request);
}

- (void)request:(TTURLRequest*)request didFailLoadWithError:(NSError*)error {
  TT_RELEASE_SAFELY(_request);
}

- (void)requestDidCancelLoad:(TTURLRequest*)request {
  TT_RELEASE_SAFELY(_request);
}

//////////////////////////////////////////////////////////////////////////////////////////////////
// public

- (void)setImageURL:(NSString*)URL {
  if (self.image && _imageURL && [URL isEqualToString:_imageURL])
    return;
  
  [self stopLoading];
  [_imageURL release];
  _imageURL = [URL retain];
  
  if (_imageURL.length) {
    [self reload];
  } else {
    self.image = nil;
    [_button setNeedsDisplay];
  }
}

- (void)reload {
  if (!_request && _imageURL) {
    UIImage* image = [[TTURLCache sharedCache] imageForURL:_imageURL];
    if (image) {
      self.image = image;
      [_button setNeedsDisplay];
    } else {
      TTURLRequest* request = [TTURLRequest requestWithURL:_imageURL delegate:self];
      request.response = [[[TTURLImageResponse alloc] init] autorelease];
      [request send];
    }
  }
}

- (void)stopLoading {
  [_request cancel];
}

@end

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation TTButton

@synthesize font = _font, isVertical = _isVertical;

///////////////////////////////////////////////////////////////////////////////////////////////////
// class public

+ (TTButton*)buttonWithStyle:(NSString*)selector {
  TTButton* button = [[[TTButton alloc] init] autorelease];
  [button setStylesWithSelector:selector];
  return button;
}

+ (TTButton*)buttonWithStyle:(NSString*)selector title:(NSString*)title {
  TTButton* button = [[[TTButton alloc] init] autorelease];
  [button setTitle:title forState:UIControlStateNormal];
  [button setStylesWithSelector:selector];
  return button;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// private

- (id)keyForState:(UIControlState)state {
  static NSString* normal = @"normal";
  static NSString* highlighted = @"highlighted";
  static NSString* selected = @"selected";
  static NSString* disabled = @"disabled";
  if (state & UIControlStateHighlighted) {
    return highlighted;
  } else if (state & UIControlStateSelected) {
    return selected;
  } else if (state & UIControlStateDisabled) {
    return disabled;
  } else {
    return normal;
  }
}

- (TTButtonContent*)contentForState:(UIControlState)state {
  if (!_content) {
    _content = [[NSMutableDictionary alloc] init];
  }
  
  id key = [self keyForState:state];
  TTButtonContent* content = [_content objectForKey:key];
  if (!content) {
    content = [[[TTButtonContent alloc] initWithButton:self] autorelease];
    [_content setObject:content forKey:key];
  }
  
  return content;
}

- (TTButtonContent*)contentForCurrentState {
  TTButtonContent* content = nil;
  if (self.selected) {
    content = [self contentForState:UIControlStateSelected];
  } else if (self.highlighted) {
    content = [self contentForState:UIControlStateHighlighted];
  } else if (!self.enabled) {
    content = [self contentForState:UIControlStateDisabled];
  }

  return content ? content : [self contentForState:UIControlStateNormal];
}

- (NSString*)titleForCurrentState {
  TTButtonContent* content = [self contentForCurrentState];
  return content.title ? content.title : [self contentForState:UIControlStateNormal].title;
}

- (UIImage*)imageForCurrentState {
  TTButtonContent* content = [self contentForCurrentState];
  return content.image ? content.image : [self contentForState:UIControlStateNormal].image;
}

- (TTStyle*)styleForCurrentState {
  TTButtonContent* content = [self contentForCurrentState];
  return content.style ? content.style : [self contentForState:UIControlStateNormal].style;
}

- (UIFont*)fontForCurrentState {
  if (_font) {
    return _font;
  } else {
    TTStyle* style = [self styleForCurrentState];
    TTTextStyle* textStyle = (TTTextStyle*)[style firstStyleOfClass:[TTTextStyle class]];
    if (textStyle.font) {
      return textStyle.font;
    } else {
      return self.font;
    }
  }
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// NSObject

- (id)initWithFrame:(CGRect)frame {
  if (self = [super initWithFrame:frame]) {
    _content = nil;
    _font = nil;
    _isVertical = NO;
    
    self.backgroundColor = [UIColor clearColor];
    self.contentMode = UIViewContentModeRedraw;
  }
  return self;
}

- (void)dealloc {
  TT_RELEASE_SAFELY(_content);
  TT_RELEASE_SAFELY(_font);
  [super dealloc];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// UIView

- (void)drawRect:(CGRect)rect {
  TTStyle* style = [self styleForCurrentState];
  if (style) {
    CGRect textFrame = self.bounds;

    TTStyleContext* context = [[[TTStyleContext alloc] init] autorelease];
    context.delegate = self;
    
    TTPartStyle* imageStyle = [style styleForPart:@"image"];
    TTBoxStyle* imageBoxStyle = nil;
    CGSize imageSize = CGSizeZero;
    if (imageStyle) {
      imageBoxStyle = [imageStyle.style firstStyleOfClass:[TTBoxStyle class]];
      imageSize = [imageStyle.style addToSize:CGSizeZero context:context];
      if (_isVertical) {
        CGFloat height = imageSize.height + imageBoxStyle.margin.top + imageBoxStyle.margin.bottom;
        textFrame.origin.y += height;
        textFrame.size.height -= height;
      } else {
        textFrame.origin.x += imageSize.width + imageBoxStyle.margin.right;
        textFrame.size.width -= imageSize.width + imageBoxStyle.margin.right;
      }
    }
    
    context.delegate = self;
    context.frame = self.bounds;
    context.contentFrame = textFrame;
    context.font = [self fontForCurrentState];
    
    [style draw:context];

    if (imageStyle) {
      CGRect frame = context.contentFrame;
      if (_isVertical) {
        frame = self.bounds;
        frame.origin.x += imageBoxStyle.margin.left;
        frame.origin.y += imageBoxStyle.margin.top;
      } else {
        frame.size = imageSize;
        frame.origin.x += imageBoxStyle.margin.left;
        frame.origin.y += imageBoxStyle.margin.top;
      }

      context.frame = frame;
      context.contentFrame = context.frame;
      context.shape = nil;
      
      [imageStyle drawPart:context];
    }
  }
}

- (CGSize)sizeThatFits:(CGSize)size {
  TTStyleContext* context = [[[TTStyleContext alloc] init] autorelease];
  context.delegate = self;
  context.font = [self fontForCurrentState];

  TTStyle* style = [self styleForCurrentState];
  if (style) {
    return [style addToSize:CGSizeZero context:context];
  } else {
    return size;
  }
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// UIControl

- (void)setHighlighted:(BOOL)highlighted {
  [super setHighlighted:highlighted];
  [self setNeedsDisplay];
}

- (void)setSelected:(BOOL)selected {
  [super setSelected:selected];
  [self setNeedsDisplay];
}

- (void)setEnabled:(BOOL)enabled {
  [super setEnabled:enabled];
  [self setNeedsDisplay];
}

//////////////////////////////////////////////////////////////////////////////////////////////////
// UIAccessibility

- (BOOL)isAccessibilityElement {
  return YES;
}

- (NSString *)accessibilityLabel {
  return [self titleForCurrentState];
}

- (UIAccessibilityTraits)accessibilityTraits {
  return [super accessibilityTraits] | UIAccessibilityTraitButton;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// TTStyleDelegate

- (NSString*)textForLayerWithStyle:(TTStyle*)style {
  return [self titleForCurrentState];
}

- (UIImage*)imageForLayerWithStyle:(TTStyle*)style {
  return [self imageForCurrentState];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// public

- (UIFont*)font {
  if (!_font) {
    _font = [TTSTYLEVAR(buttonFont) retain];
  }
  return _font;
}

- (void)setFont:(UIFont*)font {
  if (font != _font) {
    [_font release];
    _font = [font retain];
    [self setNeedsDisplay];
  }
}

- (NSString*)titleForState:(UIControlState)state {
  return [self contentForState:state].title;
}

- (void)setTitle:(NSString*)title forState:(UIControlState)state {
  TTButtonContent* content = [self contentForState:state];
  content.title = title;
  [self setNeedsDisplay];
}

- (NSString*)imageForState:(UIControlState)state {
  return [self contentForState:state].imageURL;
}

- (void)setImage:(NSString*)imageURL forState:(UIControlState)state {
  TTButtonContent* content = [self contentForState:state];
  content.imageURL = imageURL;
  [self setNeedsDisplay];
}

- (TTStyle*)styleForState:(UIControlState)state {
  return [self contentForState:state].style;
}

- (void)setStyle:(TTStyle*)style forState:(UIControlState)state {
  TTButtonContent* content = [self contentForState:state];
  content.style = style;
  [self setNeedsDisplay];
}

- (void)setStylesWithSelector:(NSString*)selector {
  TTStyleSheet* ss = [TTStyleSheet globalStyleSheet];
  
  TTStyle* normalStyle = [ss styleWithSelector:selector forState:UIControlStateNormal];
  [self setStyle:normalStyle forState:UIControlStateNormal];

  TTStyle* highlightedStyle = [ss styleWithSelector:selector forState:UIControlStateHighlighted];
  [self setStyle:highlightedStyle forState:UIControlStateHighlighted];

  TTStyle* selectedStyle = [ss styleWithSelector:selector forState:UIControlStateSelected];
  [self setStyle:selectedStyle forState:UIControlStateSelected];

  TTStyle* disabledStyle = [ss styleWithSelector:selector forState:UIControlStateDisabled];
  [self setStyle:disabledStyle forState:UIControlStateDisabled];
}

- (void)suspendLoadingImages:(BOOL)suspended {
  TTButtonContent* content = [self contentForCurrentState];
  if (suspended) {
    [content stopLoading];
  } else if (!content.image) {
    [content reload];
  }
}

- (CGRect)rectForImage {
  TTStyle* style = [self styleForCurrentState];
  if (style) {
    TTStyleContext* context = [[[TTStyleContext alloc] init] autorelease];
    context.delegate = self;
    
    TTPartStyle* imagePartStyle = [style styleForPart:@"image"];
    if (imagePartStyle) {
      TTImageStyle* imageStyle = [imagePartStyle.style firstStyleOfClass:[TTImageStyle class]];
      TTBoxStyle* imageBoxStyle = [imagePartStyle.style firstStyleOfClass:[TTBoxStyle class]];
      CGSize imageSize = [imagePartStyle.style addToSize:CGSizeZero context:context];

      CGRect frame = context.contentFrame;
      if (_isVertical) {
        frame = self.bounds;
        frame.origin.x += imageBoxStyle.margin.left;
        frame.origin.y += imageBoxStyle.margin.top;
      } else {
        frame.size = imageSize;
        frame.origin.x += imageBoxStyle.margin.left;
        frame.origin.y += imageBoxStyle.margin.top;
      }

      UIImage* image = [self imageForCurrentState];
      return [image convertRect:frame withContentMode:imageStyle.contentMode];
    }
  }

  return CGRectZero;
}

@end
