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

#import "Three20UI/TTButton.h"

// UI (private)
#import "Three20UI/private/TTButtonContent.h"

// UI
#import "Three20UI/TTImageViewDelegate.h"

// Style
#import "Three20Style/TTGlobalStyle.h"
#import "Three20Style/TTDefaultStyleSheet.h"
#import "Three20Style/TTStyleContext.h"
#import "Three20Style/TTTextStyle.h"
#import "Three20Style/TTPartStyle.h"
#import "Three20Style/TTBoxStyle.h"
#import "Three20Style/TTImageStyle.h"
#import "Three20Style/UIImageAdditions.h"

// Core
#import "Three20Core/TTCorePreprocessorMacros.h"

static const CGFloat kHPadding = 8;
static const CGFloat kVPadding = 7;


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation TTButton

@synthesize font        = _font;
@synthesize isVertical  = _isVertical;
@synthesize imageDelegate = _imageDelegate;


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];
  if (self) {
    self.backgroundColor = [UIColor clearColor];
    self.contentMode = UIViewContentModeRedraw;
  }
  return self;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)dealloc {
  TT_RELEASE_SAFELY(_content);
  TT_RELEASE_SAFELY(_font);
  self.imageDelegate = nil;

  [super dealloc];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Public


///////////////////////////////////////////////////////////////////////////////////////////////////
+ (TTButton*)buttonWithStyle:(NSString*)selector {
  TTButton* button = [[[self alloc] init] autorelease];
  [button setStylesWithSelector:selector];
  return button;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
+ (TTButton*)buttonWithStyle:(NSString*)selector title:(NSString*)title {
  TTButton* button = [[[self alloc] init] autorelease];
  [button setTitle:title forState:UIControlStateNormal];
  [button setStylesWithSelector:selector];
  return button;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Private


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)keyForState:(UIControlState)state {
  static NSString* normalKey = @"normal";
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
    return normalKey;
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
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


///////////////////////////////////////////////////////////////////////////////////////////////////
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


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSString*)titleForCurrentState {
  TTButtonContent* content = [self contentForCurrentState];
  return content.title ? content.title : [self contentForState:UIControlStateNormal].title;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (UIImage*)imageForCurrentState {
  TTButtonContent* content = [self contentForCurrentState];
  return content.image ? content.image : [self contentForState:UIControlStateNormal].image;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (TTStyle*)styleForCurrentState {
  TTButtonContent* content = [self contentForCurrentState];
  return content.style ? content.style : [self contentForState:UIControlStateNormal].style;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
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
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark UIView


///////////////////////////////////////////////////////////////////////////////////////////////////
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


///////////////////////////////////////////////////////////////////////////////////////////////////
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
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark UIControl


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setHighlighted:(BOOL)highlighted {
  [super setHighlighted:highlighted];
  [self setNeedsDisplay];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setSelected:(BOOL)selected {
  [super setSelected:selected];
  [self setNeedsDisplay];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setEnabled:(BOOL)enabled {
  [super setEnabled:enabled];
  [self setNeedsDisplay];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark UIAccessibility


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)isAccessibilityElement {
  return YES;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSString *)accessibilityLabel {
  return [self titleForCurrentState];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (UIAccessibilityTraits)accessibilityTraits {
  return [super accessibilityTraits] | UIAccessibilityTraitButton;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark TTStyleDelegate


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSString*)textForLayerWithStyle:(TTStyle*)style {
  return [self titleForCurrentState];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (UIImage*)imageForLayerWithStyle:(TTStyle*)style {
  return [self imageForCurrentState];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark TTImageViewDelegate


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)imageView:(TTImageView*)imageView didLoadImage:(UIImage*)image {

}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Public


///////////////////////////////////////////////////////////////////////////////////////////////////
- (UIFont*)font {
  if (!_font) {
    _font = [TTSTYLEVAR(buttonFont) retain];
  }
  return _font;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setFont:(UIFont*)font {
  if (font != _font) {
    [_font release];
    _font = [font retain];
    [self setNeedsDisplay];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSString*)titleForState:(UIControlState)state {
  return [self contentForState:state].title;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setTitle:(NSString*)title forState:(UIControlState)state {
  TTButtonContent* content = [self contentForState:state];
  content.title = title;
  [self setNeedsDisplay];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSString*)imageForState:(UIControlState)state {
  return [self contentForState:state].imageURL;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setImage:(NSString*)imageURL forState:(UIControlState)state {
  TTButtonContent* content = [self contentForState:state];
  content.delegate = self.imageDelegate;
  content.imageURL = imageURL;
  [self setNeedsDisplay];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (TTStyle*)styleForState:(UIControlState)state {
  return [self contentForState:state].style;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setStyle:(TTStyle*)style forState:(UIControlState)state {
  TTButtonContent* content = [self contentForState:state];
  content.style = style;
  [self setNeedsDisplay];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
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


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)suspendLoadingImages:(BOOL)suspended {
  TTButtonContent* content = [self contentForCurrentState];
  if (suspended) {
    [content stopLoading];

  } else if (!content.image) {
    [content reload];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
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
