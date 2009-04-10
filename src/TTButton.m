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

- (UIFont*)defaultFont {
  return _font ? _font : TTSTYLEVAR(toolbarButtonFont);
}

- (CGRect)rectForTitle:(NSString*)title forSize:(CGSize)size withFont:(UIFont*)font {
  CGRect rect = CGRectZero;
  if (self.contentHorizontalAlignment == UIControlContentHorizontalAlignmentLeft
      && self.contentVerticalAlignment == UIControlContentVerticalAlignmentTop) {
    rect.size = size;
  } else {
    CGSize textSize = [title sizeWithFont:font];

    if (size.width < textSize.width) {
      size.width = textSize.width;
    }
    
    rect.size = textSize;
    
    if (self.contentHorizontalAlignment == UIControlContentHorizontalAlignmentCenter) {
      rect.origin.x = floor(size.width/2 - textSize.width/2);
    } else if (self.contentHorizontalAlignment == UIControlContentHorizontalAlignmentRight) {
      rect.origin.x = size.width - textSize.width;
    }

    if (self.contentVerticalAlignment == UIControlContentVerticalAlignmentCenter) {
      rect.origin.y = floor(size.height/2 - textSize.height/2);
    } else if (self.contentVerticalAlignment == UIControlContentVerticalAlignmentBottom) {
      rect.origin.y = size.height - textSize.height;
    }
  }
  return rect;
}

- (void)drawTitle:(NSString*)title inRect:(CGRect)rect withFont:(UIFont*)font {
  CGSize size = CGSizeMake(rect.size.width, rect.size.height);
  CGRect titleRect = [self rectForTitle:title forSize:size withFont:font];
  [title drawInRect:CGRectOffset(titleRect, rect.origin.x, rect.origin.y) withFont:font];
}


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
  if (self.highlighted) {
    content = [self contentForState:UIControlStateHighlighted];
  } else if (self.selected) {
    content = [self contentForState:UIControlStateSelected];
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
    if (textStyle) {
      return textStyle.font;
    } else {
      return [self defaultFont];
    }
  }
}

- (UIEdgeInsets)insetsForCurrentStateWithSize:(CGSize)size {
  TTStyle* style = [self styleForCurrentState];
  return [style addToInsets:UIEdgeInsetsZero forSize:size];
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

    if (![style drawRect:rect shape:[TTRectangleShape shape] delegate:self]) {
      NSString* title = [self titleForCurrentState];
      if (title) {
        [self drawTitle:title inRect:rect withFont:[self defaultFont]];
      }
    }
  }
}

- (CGSize)sizeThatFits:(CGSize)size {
  NSString* title = [self titleForCurrentState];
  UIFont* font = [self fontForCurrentState];

  CGRect textRect = [self rectForTitle:title forSize:size withFont:font];
  UIEdgeInsets insets = [self insetsForCurrentStateWithSize:textRect.size];
  
  return CGSizeMake(textRect.size.width + insets.left + insets.right,
                    textRect.size.height + insets.top + insets.bottom);
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

- (void)drawLayer:(CGRect)rect withStyle:(TTStyle*)style shape:(TTShape*)shape {
  NSString* title = [self titleForCurrentState];
  UIEdgeInsets shapeInsets = [shape insetsForSize:rect.size];
  CGRect innerRect = TTRectInset(rect, shapeInsets);
  if (title) {
    if ([style isKindOfClass:[TTTextStyle class]]) {
      TTTextStyle* textStyle = (TTTextStyle*)style;
      UIFont* font = _font ? _font : (textStyle.font ? textStyle.font : [self defaultFont]);
      CGContextRef context = UIGraphicsGetCurrentContext();
      CGContextSaveGState(context);

      if (textStyle.shadowColor) {
        CGSize offset = CGSizeMake(textStyle.shadowOffset.width, -textStyle.shadowOffset.height);
        CGContextSetShadowWithColor(context, offset, 0, textStyle.shadowColor.CGColor);
      }

      if (textStyle.color) {
        [textStyle.color setFill];
      }
      
      [self drawTitle:title inRect:innerRect withFont:font];
      
      CGContextRestoreGState(context);
    } else {
      [self drawTitle:title inRect:innerRect withFont:[self defaultFont]];
    }
  }
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// public

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
