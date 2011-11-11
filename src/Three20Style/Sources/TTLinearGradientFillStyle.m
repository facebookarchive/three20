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

#import "Three20Style/TTLinearGradientFillStyle.h"

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
@implementation TTLinearGradientFillStyle

@synthesize color1 = _color1;
@synthesize color2 = _color2;
@synthesize color1Position = _color1Position;
@synthesize color2Position = _color2Position;

///////////////////////////////////////////////////////////////////////////////////////////////////

- (id)initWithNext:(TTStyle*)next {
	
	self = [super initWithNext:next];
	
	if(self) {
		_color1Position = CGPointZero;
		_color2Position = CGPointZero;
	}
	
	return self;
}

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
+ (TTLinearGradientFillStyle*)styleWithColor1:(UIColor*)color1 color2:(UIColor*)color2
                                         next:(TTStyle*)next {
  TTLinearGradientFillStyle* style = [[[self alloc] initWithNext:next] autorelease];
  style.color1 = color1;
  style.color2 = color2;
  return style;
}

+ (TTLinearGradientFillStyle*)styleWithColor1:(UIColor*)color1 color1Position: (CGPoint) position1 color2:(UIColor*)color2
							   color2Position: (CGPoint) position2 next:(TTStyle*)next {
	
	TTLinearGradientFillStyle* style = [TTLinearGradientFillStyle styleWithColor1: color1 color2: color2 next: next];
	style.color1Position = position1;
	style.color2Position = position2;
	
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

  UIColor* colors[] = {_color1, _color2};

	CGPoint color1Position = CGPointEqualToPoint(_color1Position, CGPointZero) ? CGPointMake(rect.origin.x, rect.origin.y) : CGPointMake(rect.origin.x + _color1Position.x, rect.origin.y + _color1Position.y);
	CGPoint color2Position = CGPointEqualToPoint(_color2Position, CGPointZero) ? CGPointMake(rect.origin.x, rect.origin.y+rect.size.height) : CGPointMake(rect.origin.x + _color2Position.x, rect.origin.y+_color2Position.y);
	
  CGGradientRef gradient = [self newGradientWithColors:colors count:2];
  CGContextDrawLinearGradient(ctx, gradient, color1Position,
                              color2Position,
                              kCGGradientDrawsAfterEndLocation);
  CGGradientRelease(gradient);

  CGContextRestoreGState(ctx);

  return [self.next draw:context];
}


@end
