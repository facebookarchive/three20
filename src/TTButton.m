#include "Three20/TTButton.h"
#include "Three20/TTShape.h"
#include "Three20/TTDefaultStyleSheet.h"
#include "Three20/TTURLRequest.h"
#include "Three20/TTURLResponse.h"
#include "Three20/TTURLCache.h"

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
  [_request release];
  [_title release];
  [_imageURL release];
  [_image release];
  [_style release];
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
  
  [_request release];
  _request = nil;
}

- (void)request:(TTURLRequest*)request didFailLoadWithError:(NSError*)error {
  [_request release];
  _request = nil;
}

- (void)requestDidCancelLoad:(TTURLRequest*)request {
  [_request release];
  _request = nil;
}

//////////////////////////////////////////////////////////////////////////////////////////////////
// public

- (void)setImageURL:(NSString*)url {
  if (self.image && _imageURL && [url isEqualToString:_imageURL])
    return;
  
  [self stopLoading];
  [_imageURL release];
  _imageURL = [url retain];
  
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

@synthesize font = _font;

///////////////////////////////////////////////////////////////////////////////////////////////////
// class public

+ (TTButton*)buttonWithStyle:(NSString*)selector title:(NSString*)title {
  TTButton* button = [[[TTButton alloc] initWithFrame:CGRectZero] autorelease];
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
    
    self.backgroundColor = [UIColor clearColor];
  }
  return self;
}

- (void)dealloc {
  [_content release];
  [_font release];
  [super dealloc];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// UIView

- (void)drawRect:(CGRect)rect {
  TTStyle* style = [self styleForCurrentState];
  if (style) {
    UIImage* image = [self imageForCurrentState];
    [image drawInRect:rect radius:0 contentMode:UIViewContentModeScaleAspectFill];

    TTStyleContext* context = [[[TTStyleContext alloc] init] autorelease];
    context.delegate = self;
    context.frame = rect;
    context.contentFrame = rect;
    context.font = [self fontForCurrentState];

    [style draw:context];
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

///////////////////////////////////////////////////////////////////////////////////////////////////
// TTStyleDelegate

- (NSString*)textForLayerWithStyle:(TTStyle*)style {
  return [self titleForCurrentState];
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
}

- (NSString*)imageForState:(UIControlState)state {
  return [self contentForState:state].imageURL;
}

- (void)setImage:(NSString*)imageURL forState:(UIControlState)state {
  TTButtonContent* content = [self contentForState:state];
  content.imageURL = imageURL;
}

- (TTStyle*)styleForState:(UIControlState)state {
  return [self contentForState:state].style;
}

- (void)setStyle:(TTStyle*)style forState:(UIControlState)state {
  TTButtonContent* content = [self contentForState:state];
  content.style = style;
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

@end
