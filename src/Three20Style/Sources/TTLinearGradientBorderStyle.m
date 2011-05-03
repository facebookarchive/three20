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

#import "Three20Style/TTLinearGradientBorderStyle.h"

// Style
#import "Three20Style/TTShape.h"
#import "Three20Style/TTStyleContext.h"

// Style (private)
#import "Three20Style/private/TTStyleInternal.h"

// Core
#import "Three20Core/TTCorePreprocessorMacros.h"


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation TTLinearGradientBorderStyle

@synthesize color1    = _color1;
@synthesize color2    = _color2;
@synthesize location1 = _location1;
@synthesize location2 = _location2;
@synthesize width     = _width;


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithNext:(TTStyle*)next {
  if (self = [super initWithNext:next]) {
    _location2 = 1;
    _width = 1;
  }

  return self;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)dealloc {
  TT_RELEASE_SAFELY(_color1);
  TT_RELEASE_SAFELY(_color2);

  [super dealloc];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Class public


///////////////////////////////////////////////////////////////////////////////////////////////////
+ (TTLinearGradientBorderStyle*)styleWithColor1:(UIColor*)color1 color2:(UIColor*)color2
                                          width:(CGFloat)width next:(TTStyle*)next {
  TTLinearGradientBorderStyle* style = [[[TTLinearGradientBorderStyle alloc] initWithNext:next]
                                        autorelease];
  style.color1 = color1;
  style.color2 = color2;
  style.width = width;
  return style;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
+ (TTLinearGradientBorderStyle*)styleWithColor1:(UIColor*)color1 location1:(CGFloat)location1
                                         color2:(UIColor*)color2 location2:(CGFloat)location2
                                          width:(CGFloat)width next:(TTStyle*)next {
  TTLinearGradientBorderStyle* style = [[[TTLinearGradientBorderStyle alloc] initWithNext:next]
                                        autorelease];
  style.color1 = color1;
  style.color2 = color2;
  style.width = width;
  style.location1 = location1;
  style.location2 = location2;
  return style;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark TTStyle


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)draw:(TTStyleContext*)context {
  CGContextRef ctx = UIGraphicsGetCurrentContext();
  CGRect rect = context.frame;

  CGContextSaveGState(ctx);

  CGRect strokeRect = CGRectInset(context.frame, _width/2, _width/2);
  [context.shape addToPath:strokeRect];
  CGContextSetLineWidth(ctx, _width);
  CGContextReplacePathWithStrokedPath(ctx);
  CGContextClip(ctx);

  UIColor* colors[] = {_color1, _color2};
  CGFloat locations[] = {_location1, _location2};
  CGGradientRef gradient = [self newGradientWithColors:colors locations:locations count:2];
  CGContextDrawLinearGradient(ctx, gradient, CGPointMake(rect.origin.x, rect.origin.y),
                              CGPointMake(rect.origin.x, rect.origin.y+rect.size.height),
                              kCGGradientDrawsAfterEndLocation);
  CGGradientRelease(gradient);

  CGContextRestoreGState(ctx);

  context.frame = CGRectInset(context.frame, _width, _width);
  return [self.next draw:context];
}


@end
