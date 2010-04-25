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

#import "Three20Style/TTReflectiveFillStyle.h"

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
@implementation TTReflectiveFillStyle

@synthesize color               = _color;
@synthesize withBottomHighlight = _withBottomHighlight;


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)dealloc {
  TT_RELEASE_SAFELY(_color);

  [super dealloc];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Class public


///////////////////////////////////////////////////////////////////////////////////////////////////
+ (TTReflectiveFillStyle*)styleWithColor:(UIColor*)color next:(TTStyle*)next {
  TTReflectiveFillStyle* style = [[[self alloc] initWithNext:next] autorelease];
  style.color = color;
  style.withBottomHighlight = NO;
  return style;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
+ (TTReflectiveFillStyle*)styleWithColor:(UIColor*)color
                     withBottomHighlight:(BOOL)withBottomHighlight next:(TTStyle*)next {
  TTReflectiveFillStyle* style = [[[self alloc] initWithNext:next] autorelease];
  style.color = color;
  style.withBottomHighlight = withBottomHighlight;
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
  [context.shape addToPath:rect];
  CGContextClip(ctx);

  // Draw the background color
  [_color setFill];
  CGContextFillRect(ctx, rect);

  // The highlights are drawn using an overlayed, semi-transparent gradient.
  // The values here are absolutely arbitrary. They were nabbed by inspecting the colors of
  // the "Delete Contact" button in the Contacts app.
  UIColor* topStartHighlight = [UIColor colorWithWhite:1.0 alpha:0.685];
  UIColor* topEndHighlight = [UIColor colorWithWhite:1.0 alpha:0.13];
  UIColor* clearColor = [UIColor colorWithWhite:1.0 alpha:0.0];

  UIColor* botEndHighlight;
  if( _withBottomHighlight ) {
    botEndHighlight = [UIColor colorWithWhite:1.0 alpha:0.27];
  } else {
    botEndHighlight = clearColor;
  }

  UIColor* colors[] = {
    topStartHighlight, topEndHighlight,
    clearColor,
    clearColor, botEndHighlight};
  CGFloat locations[] = {0, 0.5, 0.5, 0.6, 1.0};

  CGGradientRef gradient = [self newGradientWithColors:colors locations:locations count:5];
  CGContextDrawLinearGradient(ctx, gradient, CGPointMake(rect.origin.x, rect.origin.y),
                              CGPointMake(rect.origin.x, rect.origin.y+rect.size.height), 0);
  CGGradientRelease(gradient);

  CGContextRestoreGState(ctx);

  return [self.next draw:context];
}


@end
