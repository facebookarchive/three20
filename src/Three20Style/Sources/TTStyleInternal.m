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

#import "Three20Style/private/TTStyleInternal.h"

const NSInteger kDefaultLightSource = 125;


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation TTStyle (TTInternal)


///////////////////////////////////////////////////////////////////////////////////////////////////
- (CGGradientRef)newGradientWithColors:(UIColor**)colors locations:(CGFloat*)locations
                                 count:(int)count {
  CGFloat* components = malloc(sizeof(CGFloat)*4*count);
  for (int i = 0; i < count; ++i) {
    UIColor* color = colors[i];
    size_t n = CGColorGetNumberOfComponents(color.CGColor);
    const CGFloat* rgba = CGColorGetComponents(color.CGColor);
    if (n == 2) {
      components[i*4] = rgba[0];
      components[i*4+1] = rgba[0];
      components[i*4+2] = rgba[0];
      components[i*4+3] = rgba[1];
    } else if (n == 4) {
      components[i*4] = rgba[0];
      components[i*4+1] = rgba[1];
      components[i*4+2] = rgba[2];
      components[i*4+3] = rgba[3];
    }
  }

  CGContextRef context = UIGraphicsGetCurrentContext();
  CGColorSpaceRef space = CGBitmapContextGetColorSpace(context);
  CGGradientRef gradient = CGGradientCreateWithColorComponents(space, components, locations, count);
  free(components);

  return gradient;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (CGGradientRef)newGradientWithColors:(UIColor**)colors count:(int)count {
  return [self newGradientWithColors:colors locations:nil count:count];
}


@end

