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

#import "Three20Style/TTSpeechBubbleShape.h"

// Style (private)
#import "Three20Style/private/TTShapeInternal.h"

static const CGFloat kInsetWidth = 5;


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation TTSpeechBubbleShape

@synthesize radius        = _radius;
@synthesize pointLocation = _pointLocation;
@synthesize pointAngle    = _pointAngle;
@synthesize pointSize     = _pointSize;


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Class public


///////////////////////////////////////////////////////////////////////////////////////////////////
+ (TTSpeechBubbleShape*)shapeWithRadius:(CGFloat)radius pointLocation:(CGFloat)pointLocation
                             pointAngle:(CGFloat)pointAngle pointSize:(CGSize)pointSize {
  TTSpeechBubbleShape* shape = [[[TTSpeechBubbleShape alloc] init] autorelease];
  shape.radius = radius;
  shape.pointLocation = pointLocation;
  shape.pointAngle = pointAngle;
  shape.pointSize = pointSize;
  return shape;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Private


///////////////////////////////////////////////////////////////////////////////////////////////////
- (CGRect)subtractPointFromRect:(CGRect)rect {
  CGFloat x = 0;
  CGFloat y = 0;
  CGFloat w = rect.size.width;
  CGFloat h = rect.size.height;

  if ((_pointLocation >= 0 && _pointLocation < 45)
      || (_pointLocation >= 315 && _pointLocation < 360)) {
    if ((_pointAngle >= 270 && _pointAngle <= 360) || (_pointAngle >= 0 && _pointAngle <= 90)) {
      x += _pointSize.width;
      w -= _pointSize.width;
    }

  } else if (_pointLocation >= 45 && _pointLocation < 135) {
    if (_pointAngle >= 0 && _pointAngle <= 180) {
      y += _pointSize.height;
      h -= _pointSize.height;
    }

  } else if (_pointLocation >= 135 && _pointLocation < 225) {
    if (_pointAngle >= 90 && _pointAngle <= 270) {
      w -= _pointSize.width;
    }

  } else if (_pointLocation >= 225 && _pointLocation < 315) {
    if (_pointAngle >= 180 && _pointAngle <= 360) {
      h -= _pointSize.height;
    }
  }

  return CGRectMake(x, y, w, h);
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)addTopEdge:(CGSize)size lightSource:(NSInteger)lightSource toPath:(CGMutablePathRef)path
             reset:(BOOL)reset {
  CGFloat fw = size.width;
  CGFloat fh = size.height;
  CGFloat pointX = 0;
  CGFloat radius = RD(_radius);

  if (lightSource >= 0 && lightSource <= 90) {
    if (reset) {
      CGPathMoveToPoint(path, nil, radius, 0);
    }

  } else {
    if (reset) {
      CGPathMoveToPoint(path, nil, 0, radius);
    }
    CGPathAddArcToPoint(path, nil, 0, 0, radius, 0, radius);
  }

  if (_pointLocation >= 45 && _pointLocation < 135) {
    CGFloat ph = _pointAngle >= 0 && _pointAngle <= 180 ? _pointSize.height : -_pointSize.height;
    pointX = (((_pointLocation-45)/90) * (fw - 2 *radius - _pointSize.width) +
              radius + floor(_pointSize.width/2));

    CGPathAddLineToPoint(path, nil, pointX-floor(_pointSize.width/2), 0);
    CGPathAddLineToPoint(path, nil, pointX, -ph);
    CGPathAddLineToPoint(path, nil, pointX+floor(_pointSize.width/2), 0);
  }

  CGPathAddArcToPoint(path, nil, fw, 0, fw, radius, radius);
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)addRightEdge:(CGSize)size lightSource:(NSInteger)lightSource toPath:(CGMutablePathRef)path
               reset:(BOOL)reset {
  CGFloat fw = size.width;
  CGFloat fh = size.height;
  CGFloat pointY = 0;
  CGFloat radius = RD(_radius);

  if (reset) {
    CGPathMoveToPoint(path, nil, fw, radius);
  }

  if (_pointLocation >= 135 && _pointLocation < 225) {
    CGFloat pw = _pointAngle >= 90 && _pointAngle <= 270 ? _pointSize.width : -_pointSize.width;
    pointY = (((_pointLocation-135)/90) * (fh - 2 * radius - _pointSize.height) +
              radius + floor(_pointSize.height/2));

    CGPathAddLineToPoint(path, nil, fw, pointY-floor(_pointSize.height/2));
    CGPathAddLineToPoint(path, nil, fw+pw, pointY);
    CGPathAddLineToPoint(path, nil, fw, pointY+floor(_pointSize.height/2));
  }

  CGPathAddArcToPoint(path, nil, fw, fh, fw-radius, fh, radius);
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)addBottomEdge:(CGSize)size lightSource:(NSInteger)lightSource toPath:(CGMutablePathRef)path
                reset:(BOOL)reset {
  CGFloat fw = size.width;
  CGFloat fh = size.height;
  CGFloat pointX = 0;
  CGFloat radius = RD(_radius);

  if (reset) {
    CGPathMoveToPoint(path, nil, fw-radius, fh);
  }

  if (_pointLocation >= 225 && _pointLocation < 315) {
    CGFloat ph;

    if (_pointAngle >= 0 && _pointAngle <= 180) {
      ph = _pointSize.height;

    } else {
      ph = -_pointSize.height;
    }

    pointX = fw - (((_pointLocation-225)/90) * (fw - 2 *radius - _pointSize.width)
                   + radius + floor(_pointSize.width/2));

    CGPathAddLineToPoint(path, nil, pointX+floor(_pointSize.width/2), fh);
    CGPathAddLineToPoint(path, nil, pointX, fh-ph);
    CGPathAddLineToPoint(path, nil, pointX-floor(_pointSize.width/2), fh);
  }

  CGPathAddArcToPoint(path, nil, 0, fh, 0, fh-radius, radius);
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)addLeftEdge:(CGSize)size lightSource:(NSInteger)lightSource toPath:(CGMutablePathRef)path
              reset:(BOOL)reset {
  CGFloat fh = size.height;
  CGFloat pointY = 0;
  CGFloat radius = RD(_radius);

  if (reset) {
    CGPathMoveToPoint(path, nil, 0, fh-radius);
  }

  // Use a custom pointLocation with a value between 315 and 405 instead of 0-45 and 315-360
  // to ease calculations
  CGFloat myPointLocation = _pointLocation;
  if (myPointLocation >= 0 && myPointLocation < 45) {
    myPointLocation += 360;
  }

  if (myPointLocation >= 315 && myPointLocation < 405) {

    // Compute extension of arrow
    CGFloat pw = _pointAngle >= 270 || _pointAngle <= 90 ? -_pointSize.width : _pointSize.width;

    // Compute location of arrow on line
    // Do not place the arrow on the arcs at the corner!
    pointY = fh - (((myPointLocation - 315) / 90) * (fh - 2 * radius - _pointSize.height) +
                   radius + _pointSize.height/2);

    // Draw the lines, first to the arrow...
    CGPathAddLineToPoint(path, nil, 0, pointY+floor(_pointSize.height/2));
    // Then up to the point...
    CGPathAddLineToPoint(path, nil, pw, pointY);
    // And back again to the rectangle..
    CGPathAddLineToPoint(path, nil, 0, pointY-floor(_pointSize.height/2));
  }

  // Then continue the rest of the line
  if (lightSource >= 0 && lightSource <= 90) {
    CGPathAddArcToPoint(path, nil, 0, 0, radius, 0, radius);

  } else {
    CGPathAddLineToPoint(path, nil, 0, radius);
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)addToPath:(CGSize)size path:(CGMutablePathRef)path {
  [self addTopEdge:size lightSource:0 toPath:path reset:YES];
  [self addRightEdge:size lightSource:0 toPath:path reset:NO];
  [self addBottomEdge:size lightSource:0 toPath:path reset:NO];
  [self addLeftEdge:size lightSource:0 toPath:path reset:NO];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)drawPath:(CGMutablePathRef)path inRect:(CGRect)rect {
  CGContextRef context = UIGraphicsGetCurrentContext();
  CGContextTranslateCTM(context, rect.origin.x, rect.origin.y);
  CGContextAddPath(context, path);
  CGContextTranslateCTM(context, -rect.origin.x, -rect.origin.y);
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Public


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)addToPath:(CGRect)rect {
  [self openPath:rect];

  CGMutablePathRef path = CGPathCreateMutable();
  rect = [self subtractPointFromRect:rect];
  [self addToPath:rect.size path:path];
  CGPathCloseSubpath(path);
  [self drawPath:path inRect:rect];
  CGPathRelease(path);

  [self closePath:rect];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)addInverseToPath:(CGRect)rect {
  [self openPath:rect];

  CGMutablePathRef path = CGPathCreateMutable();
  rect = [self subtractPointFromRect:rect];
  CGRect shadowRect = CGRectMake(-kInsetWidth, -kInsetWidth,
                                 rect.size.width+kInsetWidth*2, rect.size.height+kInsetWidth*2);
  CGPathAddRect(path, nil, shadowRect);
  [self addToPath:rect.size path:path];
  CGPathCloseSubpath(path);
  [self drawPath:path inRect:rect];
  CGPathRelease(path);

  [self closePath:rect];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)addTopEdgeToPath:(CGRect)rect lightSource:(NSInteger)lightSource {
  rect = [self subtractPointFromRect:rect];

  CGMutablePathRef path = CGPathCreateMutable();
  [self addTopEdge:rect.size lightSource:lightSource toPath:path reset:YES];
  [self drawPath:path inRect:rect];
  CGPathRelease(path);
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)addRightEdgeToPath:(CGRect)rect lightSource:(NSInteger)lightSource {
  rect = [self subtractPointFromRect:rect];

  CGMutablePathRef path = CGPathCreateMutable();
  [self addRightEdge:rect.size lightSource:lightSource toPath:path reset:YES];
  [self drawPath:path inRect:rect];
  CGPathRelease(path);
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)addBottomEdgeToPath:(CGRect)rect lightSource:(NSInteger)lightSource {
  rect = [self subtractPointFromRect:rect];

  CGMutablePathRef path = CGPathCreateMutable();
  [self addBottomEdge:rect.size lightSource:lightSource toPath:path reset:YES];
  [self drawPath:path inRect:rect];
  CGPathRelease(path);
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)addLeftEdgeToPath:(CGRect)rect lightSource:(NSInteger)lightSource {
  rect = [self subtractPointFromRect:rect];

  CGMutablePathRef path = CGPathCreateMutable();
  [self addLeftEdge:rect.size lightSource:lightSource toPath:path reset:YES];
  [self drawPath:path inRect:rect];
  CGPathRelease(path);
}


@end
