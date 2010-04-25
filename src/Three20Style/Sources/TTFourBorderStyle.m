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

#import "Three20Style/TTFourBorderStyle.h"

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
@implementation TTFourBorderStyle

@synthesize top     = _top;
@synthesize right   = _right;
@synthesize bottom  = _bottom;
@synthesize left    = _left;
@synthesize width   = _width;


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithNext:(TTStyle*)next {
  if (self = [super initWithNext:next]) {
    _width = 1;
  }

  return self;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)dealloc {
  TT_RELEASE_SAFELY(_top);
  TT_RELEASE_SAFELY(_right);
  TT_RELEASE_SAFELY(_bottom);
  TT_RELEASE_SAFELY(_left);

  [super dealloc];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Class public


///////////////////////////////////////////////////////////////////////////////////////////////////
+ (TTFourBorderStyle*)styleWithTop:(UIColor*)top right:(UIColor*)right bottom:(UIColor*)bottom
                              left:(UIColor*)left width:(CGFloat)width next:(TTStyle*)next {
  TTFourBorderStyle* style = [[[self alloc] initWithNext:next] autorelease];
  style.top = top;
  style.right = right;
  style.bottom = bottom;
  style.left = left;
  style.width = width;
  return style;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
+ (TTFourBorderStyle*)styleWithTop:(UIColor*)top width:(CGFloat)width next:(TTStyle*)next {
  TTFourBorderStyle* style = [[[self alloc] initWithNext:next] autorelease];
  style.top = top;
  style.width = width;
  return style;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
+ (TTFourBorderStyle*)styleWithRight:(UIColor*)right width:(CGFloat)width next:(TTStyle*)next {
  TTFourBorderStyle* style = [[[self alloc] initWithNext:next] autorelease];
  style.right = right;
  style.width = width;
  return style;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
+ (TTFourBorderStyle*)styleWithBottom:(UIColor*)bottom width:(CGFloat)width next:(TTStyle*)next {
  TTFourBorderStyle* style = [[[self alloc] initWithNext:next] autorelease];
  style.bottom = bottom;
  style.width = width;
  return style;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
+ (TTFourBorderStyle*)styleWithLeft:(UIColor*)left width:(CGFloat)width next:(TTStyle*)next {
  TTFourBorderStyle* style = [[[self alloc] initWithNext:next] autorelease];
  style.left = left;
  style.width = width;
  return style;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark TTStyle


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)draw:(TTStyleContext*)context {
  CGRect rect = context.frame;
  CGRect strokeRect = CGRectInset(rect, _width/2, _width/2);
  [context.shape openPath:strokeRect];

  CGContextRef ctx = UIGraphicsGetCurrentContext();
  CGContextSetLineWidth(ctx, _width);

  [context.shape addTopEdgeToPath:strokeRect lightSource:kDefaultLightSource];
  if (_top) {
    [_top setStroke];
  } else {
    [[UIColor clearColor] setStroke];
  }
  CGContextStrokePath(ctx);

  [context.shape addRightEdgeToPath:strokeRect lightSource:kDefaultLightSource];
  if (_right) {
    [_right setStroke];
  } else {
    [[UIColor clearColor] setStroke];
  }
  CGContextStrokePath(ctx);

  [context.shape addBottomEdgeToPath:strokeRect lightSource:kDefaultLightSource];
  if (_bottom) {
    [_bottom setStroke];
  } else {
    [[UIColor clearColor] setStroke];
  }
  CGContextStrokePath(ctx);

  [context.shape addLeftEdgeToPath:strokeRect lightSource:kDefaultLightSource];
  if (_left) {
    [_left setStroke];
  } else {
    [[UIColor clearColor] setStroke];
  }
  CGContextStrokePath(ctx);

  CGContextRestoreGState(ctx);

  context.frame = CGRectMake(rect.origin.x + (_left ? _width : 0),
                             rect.origin.y + (_top ? _width : 0),
                             rect.size.width - ((_left ? _width : 0) + (_right ? _width : 0)),
                             rect.size.height - ((_top ? _width : 0) + (_bottom ? _width : 0)));
  return [self.next draw:context];
}


@end
