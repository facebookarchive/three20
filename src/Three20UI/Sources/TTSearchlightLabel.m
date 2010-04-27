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

#import "Three20UI/TTSearchlightLabel.h"

// Style
#import "Three20Style/TTGlobalStyle.h"
#import "Three20Style/TTDefaultStyleSheet.h"

// Core
#import "Three20Core/TTCorePreprocessorMacros.h"


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation TTSearchlightLabel

@synthesize text            = _text;
@synthesize font            = _font;
@synthesize textColor       = _textColor;
@synthesize spotlightColor  = _spotlightColor;
@synthesize textAlignment   = _textAlignment;


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithFrame:(CGRect)frame {
  if (self = [super initWithFrame:frame]) {
    self.text = @"";
    self.font = TTSTYLEVAR(font);
    self.textColor = [UIColor colorWithWhite:0.25 alpha:1];
    self.spotlightColor = [UIColor whiteColor];
    self.textAlignment = UITextAlignmentLeft;
    self.backgroundColor = [UIColor clearColor];
    self.contentMode = UIViewContentModeCenter;
  }

  return self;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)dealloc {
  [self stopAnimating];
  TT_RELEASE_SAFELY(_text);
  TT_RELEASE_SAFELY(_font);
  TT_RELEASE_SAFELY(_textColor);
  TT_RELEASE_SAFELY(_spotlightColor);

  [super dealloc];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Private


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)newMask {
  CGRect rect = self.frame;
  CGColorSpaceRef space = CGColorSpaceCreateDeviceRGB();
  int bitmapBytesPerRow = (rect.size.width * 4);
  int bitmapByteCount = (bitmapBytesPerRow * rect.size.height);
  _maskData = malloc(bitmapByteCount);
  _maskContext = CGBitmapContextCreate(_maskData, rect.size.width, rect.size.height,
                          8, bitmapBytesPerRow, space, kCGImageAlphaPremultipliedLast);
  CGColorSpaceRelease(space);
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)releaseMask {
  CGContextRelease(_maskContext);
  free(_maskData);
  _maskContext = nil;
  _maskData = nil;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (CGImageRef)newSpotlightMask:(CGRect)rect origin:(CGPoint)origin radius:(CGFloat)radius {
  CGContextClearRect(_maskContext, rect);

  CGColorSpaceRef space = CGColorSpaceCreateDeviceRGB();
  CGFloat components[] = {1, 1, 1, 1, 0, 0, 0, 0};
  CGFloat locations[] = {0, 1};
  CGGradientRef gradient = CGGradientCreateWithColorComponents(space, components, locations, 2);
  CGContextDrawRadialGradient(_maskContext, gradient, origin, 0, origin, radius, 0);
  CGGradientRelease(gradient);
  CGColorSpaceRelease(space);

  return CGBitmapContextCreateImage(_maskContext);
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)updateSpotlight {
  _spotlightPoint += 1.3/32;
  if (_spotlightPoint > 2) {
    _spotlightPoint = -0.5;
  }
  if (_spotlightPoint <= 1.5) {
    [self setNeedsDisplay];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark UIView


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)drawRect:(CGRect)rect {
  CGContextRef context = UIGraphicsGetCurrentContext();

  CGSize textSize = [self sizeThatFits:CGSizeZero];

  CGFloat x = 0;
  if (_textAlignment == UITextAlignmentRight) {
    x = self.frame.size.width - textSize.width;
  } else if (_textAlignment == UITextAlignmentCenter) {
    x = ceil(self.frame.size.width/2 - textSize.width/2);
  }

  CGFloat y = 0;
  if (self.contentMode == UIViewContentModeCenter) {
    y = ceil(rect.size.height/2 + _font.capHeight/2);
  } else if (self.contentMode == UIViewContentModeBottom) {
    y = rect.size.height + _font.descender;
  } else {
    y = _font.capHeight;
  }

  CGContextSelectFont(context, [_font.fontName UTF8String], _font.pointSize, kCGEncodingMacRoman);
  CGContextSetTextDrawingMode(context, kCGTextFill);
  CGContextSetTextMatrix(context, CGAffineTransformScale(CGAffineTransformIdentity, 1, -1));

  CGContextSetFillColorWithColor(context, _textColor.CGColor);
  CGContextShowTextAtPoint(context, x, y, [self.text UTF8String], self.text.length);

  if (_timer) {
    CGPoint spotOrigin = CGPointMake(x + (textSize.width * _spotlightPoint),
      y - ceil(self.font.capHeight/2));
    CGFloat spotRadius = self.font.capHeight*2;

    CGImageRef mask = [self newSpotlightMask:rect origin:spotOrigin radius:spotRadius];
    CGContextClipToMask(context, rect, mask);
    CGImageRelease(mask);

    [_spotlightColor setFill];
    CGContextShowTextAtPoint(context, x, y, [self.text UTF8String], self.text.length);
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (CGSize)sizeThatFits:(CGSize)size {
  return [self.text sizeWithFont:self.font constrainedToSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX)];
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
  return _text;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (UIAccessibilityTraits)accessibilityTraits {
  return [super accessibilityTraits] | UIAccessibilityTraitStaticText;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Public


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)startAnimating {
  if (!_timer) {
    _timer = [NSTimer scheduledTimerWithTimeInterval:1.0/32 target:self
      selector:@selector(updateSpotlight) userInfo:nil repeats:YES];
    _spotlightPoint = -0.5;
    [self newMask];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)stopAnimating {
  if (_timer) {
    [_timer invalidate];
    _timer = nil;
    [self releaseMask];
  }
  [self setNeedsDisplay];
}


@end
