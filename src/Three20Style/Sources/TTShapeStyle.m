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

#import "Three20Style/TTShapeStyle.h"

// Style
#import "Three20Style/TTStyleContext.h"
#import "Three20Style/TTShape.h"

// Core
#import "Three20Core/TTCorePreprocessorMacros.h"
#import "Three20Core/TTGlobalCoreRects.h"


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation TTShapeStyle

@synthesize shape = _shape;


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)dealloc {
  TT_RELEASE_SAFELY(_shape);

  [super dealloc];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Class public


///////////////////////////////////////////////////////////////////////////////////////////////////
+ (TTShapeStyle*)styleWithShape:(TTShape*)shape next:(TTStyle*)next {
  TTShapeStyle* style = [[[self alloc] initWithNext:next] autorelease];
  style.shape = shape;
  return style;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark TTStyle


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)draw:(TTStyleContext*)context {
  UIEdgeInsets shapeInsets = [_shape insetsForSize:context.frame.size];
  context.contentFrame = TTRectInset(context.contentFrame, shapeInsets);
  context.shape = _shape;
  [self.next draw:context];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (UIEdgeInsets)addToInsets:(UIEdgeInsets)insets forSize:(CGSize)size {
  UIEdgeInsets shapeInsets = [_shape insetsForSize:size];
  insets.top += shapeInsets.top;
  insets.right += shapeInsets.right;
  insets.bottom += shapeInsets.bottom;
  insets.left += shapeInsets.left;

  if (self.next) {
    return [self.next addToInsets:insets forSize:size];

  } else {
    return insets;
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (CGSize)addToSize:(CGSize)size context:(TTStyleContext*)context {
  CGSize innerSize = [self.next addToSize:size context:context];
  UIEdgeInsets shapeInsets = [_shape insetsForSize:innerSize];
  innerSize.width += shapeInsets.left + shapeInsets.right;
  innerSize.height += shapeInsets.top + shapeInsets.bottom;

  return innerSize;
}


@end
