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

#import "Three20Style/TTRectangleShape.h"

static TTRectangleShape* sharedRectangleShape = nil;


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation TTRectangleShape


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Class public


///////////////////////////////////////////////////////////////////////////////////////////////////
+ (TTRectangleShape*)shape {
  if (!sharedRectangleShape) {
    sharedRectangleShape = [[TTRectangleShape alloc] init];
  }
  return sharedRectangleShape;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Public


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)addToPath:(CGRect)rect {
  [self openPath:rect];

  CGContextRef context = UIGraphicsGetCurrentContext();
  CGContextAddRect(context, CGRectMake(0, 0, rect.size.width, rect.size.height));

  [self closePath:rect];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)addInverseToPath:(CGRect)rect {
  CGContextRef context = UIGraphicsGetCurrentContext();

  CGFloat fw = rect.size.width;
  CGFloat fh = rect.size.height;

  CGFloat width = 5.0f;
  CGRect shadowRect = CGRectMake(-width, -width, fw+width*2, fh+width*2);
  CGMutablePathRef path = CGPathCreateMutable();
  CGPathAddRect(path, nil, shadowRect);
  CGPathCloseSubpath(path);

  CGPathAddRect(path, nil, rect);
  CGPathCloseSubpath(path);

  [self openPath:rect];
  CGContextAddPath(context, path);
  [self closePath:rect];

  CGPathRelease(path);
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)addTopEdgeToPath:(CGRect)rect lightSource:(NSInteger)lightSource {
  CGContextRef context = UIGraphicsGetCurrentContext();
  CGFloat fw = rect.size.width;

  CGContextMoveToPoint(context, 0, 0);
  CGContextAddLineToPoint(context, fw, 0);
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)addRightEdgeToPath:(CGRect)rect lightSource:(NSInteger)lightSource {
  CGContextRef context = UIGraphicsGetCurrentContext();
  CGFloat fw = rect.size.width;
  CGFloat fh = rect.size.height;

  CGContextMoveToPoint(context, fw, 0);
  CGContextAddLineToPoint(context, fw, fh);
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)addBottomEdgeToPath:(CGRect)rect lightSource:(NSInteger)lightSource {
  CGContextRef context = UIGraphicsGetCurrentContext();
  CGFloat fw = rect.size.width;
  CGFloat fh = rect.size.height;

  CGContextMoveToPoint(context, fw, fh);
  CGContextAddLineToPoint(context, 0, fh);
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)addLeftEdgeToPath:(CGRect)rect lightSource:(NSInteger)lightSource {
  CGContextRef context = UIGraphicsGetCurrentContext();
  CGFloat fh = rect.size.height;

  CGContextMoveToPoint(context, 0, fh);
  CGContextAddLineToPoint(context, 0, 0);
}


@end
