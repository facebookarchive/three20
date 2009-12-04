/**
 * Copyright 2009 Facebook
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#import "Three20/TTShape.h"

///////////////////////////////////////////////////////////////////////////////////////////////////
// global

static TTRectangleShape* sharedRectangleShape = nil;

static const CGFloat kArrowPointWidth = 2.8;
static const CGFloat kArrowRadius = 2;
static CGFloat kInsetWidth = 5;

#define RD(_RADIUS) (_RADIUS == TT_ROUNDED ? round(fh/2) : _RADIUS)

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation TTShape

///////////////////////////////////////////////////////////////////////////////////////////////////
// public

- (void)openPath:(CGRect)rect {
  CGContextRef context = UIGraphicsGetCurrentContext();
  CGContextSaveGState(context);
  CGContextTranslateCTM(context, CGRectGetMinX(rect), CGRectGetMinY(rect));
  CGContextBeginPath(context);
}

- (void)closePath:(CGRect)rect {
  CGContextRef context = UIGraphicsGetCurrentContext();
  CGContextClosePath(context);
  CGContextRestoreGState(context);
}

- (UIEdgeInsets)insetsForSize:(CGSize)size {
  return UIEdgeInsetsZero;
}

- (void)addTopEdgeToPath:(CGRect)rect lightSource:(NSInteger)lightSource {
}

- (void)addRightEdgeToPath:(CGRect)rect lightSource:(NSInteger)lightSource {
}

- (void)addBottomEdgeToPath:(CGRect)rect lightSource:(NSInteger)lightSource {
}

- (void)addLeftEdgeToPath:(CGRect)rect lightSource:(NSInteger)lightSource {
}

- (void)addToPath:(CGRect)rect {
}

- (void)addInverseToPath:(CGRect)rect {
}

@end

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation TTRectangleShape

///////////////////////////////////////////////////////////////////////////////////////////////////
// class public

+ (TTRectangleShape*)shape {
  if (!sharedRectangleShape) {
    sharedRectangleShape = [[TTRectangleShape alloc] init];
  }
  return sharedRectangleShape;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// public

- (void)addToPath:(CGRect)rect {
  [self openPath:rect];

  CGContextRef context = UIGraphicsGetCurrentContext();
  CGContextAddRect(context, CGRectMake(0, 0, rect.size.width, rect.size.height));

  [self closePath:rect];
}

- (void)addInverseToPath:(CGRect)rect {
  CGContextRef context = UIGraphicsGetCurrentContext();

  CGFloat fw = rect.size.width;
  CGFloat fh = rect.size.height;

  CGFloat width = 5;
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

- (void)addTopEdgeToPath:(CGRect)rect lightSource:(NSInteger)lightSource {
  CGContextRef context = UIGraphicsGetCurrentContext();
  CGFloat fw = rect.size.width;
  
  CGContextMoveToPoint(context, 0, 0);
  CGContextAddLineToPoint(context, fw, 0);
}

- (void)addRightEdgeToPath:(CGRect)rect lightSource:(NSInteger)lightSource {
  CGContextRef context = UIGraphicsGetCurrentContext();
  CGFloat fw = rect.size.width;
  CGFloat fh = rect.size.height;
  
  CGContextMoveToPoint(context, fw, 0);
  CGContextAddLineToPoint(context, fw, fh);
}

- (void)addBottomEdgeToPath:(CGRect)rect lightSource:(NSInteger)lightSource {
  CGContextRef context = UIGraphicsGetCurrentContext();
  CGFloat fw = rect.size.width;
  CGFloat fh = rect.size.height;
  
  CGContextMoveToPoint(context, fw, fh);
  CGContextAddLineToPoint(context, 0, fh);
}

- (void)addLeftEdgeToPath:(CGRect)rect lightSource:(NSInteger)lightSource {
  CGContextRef context = UIGraphicsGetCurrentContext();
  CGFloat fh = rect.size.height;
  
  CGContextMoveToPoint(context, 0, fh);
  CGContextAddLineToPoint(context, 0, 0);
}

@end

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation TTRoundedRectangleShape

@synthesize topLeftRadius = _topLeftRadius, topRightRadius = _topRightRadius,
  bottomRightRadius = _bottomRightRadius, bottomLeftRadius = _bottomLeftRadius;

///////////////////////////////////////////////////////////////////////////////////////////////////
// class public

+ (TTRoundedRectangleShape*)shapeWithRadius:(CGFloat)radius {
  TTRoundedRectangleShape* shape = [[[TTRoundedRectangleShape alloc] init] autorelease];
  shape.topLeftRadius = shape.topRightRadius = shape.bottomRightRadius = shape.bottomLeftRadius
    = radius;
  return shape;
}

+ (TTRoundedRectangleShape*)shapeWithTopLeft:(CGFloat)topLeft topRight:(CGFloat)topRight
      bottomRight:(CGFloat)bottomRight bottomLeft:(CGFloat)bottomLeft {
  TTRoundedRectangleShape* shape = [[[TTRoundedRectangleShape alloc] init] autorelease];
  shape.topLeftRadius = topLeft;
  shape.topRightRadius = topRight;
  shape.bottomRightRadius = bottomRight;
  shape.bottomLeftRadius = bottomLeft;
  return shape;
}      

///////////////////////////////////////////////////////////////////////////////////////////////////
// public

- (void)addToPath:(CGRect)rect {
  [self openPath:rect];

  CGFloat fw = rect.size.width;
  CGFloat fh = rect.size.height;

  CGContextRef context = UIGraphicsGetCurrentContext();
  CGContextMoveToPoint(context, fw, floor(fh/2));
  CGContextAddArcToPoint(context, fw, fh, floor(fw/2), fh, RD(_bottomRightRadius));
  CGContextAddArcToPoint(context, 0, fh, 0, floor(fh/2), RD(_bottomLeftRadius));
  CGContextAddArcToPoint(context, 0, 0, floor(fw/2), 0, RD(_topLeftRadius));
  CGContextAddArcToPoint(context, fw, 0, fw, floor(fh/2), RD(_topRightRadius));

  [self closePath:rect];
}

- (void)addInverseToPath:(CGRect)rect {
  CGContextRef context = UIGraphicsGetCurrentContext();

  CGFloat fw = rect.size.width;
  CGFloat fh = rect.size.height;

  CGFloat width = 5;
  CGRect shadowRect = CGRectMake(-width, -width, fw+width*2, fh+width*2);
  CGMutablePathRef path = CGPathCreateMutable();
  CGPathAddRect(path, nil, shadowRect);
  CGPathCloseSubpath(path);

  CGPathMoveToPoint(path, nil, fw, floor(fh/2));
  CGPathAddArcToPoint(path, nil, fw, fh, floor(fw/2), fh, RD(_bottomRightRadius));
  CGPathAddArcToPoint(path, nil, 0, fh, 0, floor(fh/2), RD(_bottomLeftRadius));
  CGPathAddArcToPoint(path, nil, 0, 0, floor(fw/2), 0, RD(_topLeftRadius));
  CGPathAddArcToPoint(path, nil, fw, 0, fw, floor(fh/2), RD(_topRightRadius));
  CGPathCloseSubpath(path);

  [self openPath:rect];
  CGContextAddPath(context, path);
  [self closePath:rect];

  CGPathRelease(path);
}

- (void)addTopEdgeToPath:(CGRect)rect lightSource:(NSInteger)lightSource {
  CGContextRef context = UIGraphicsGetCurrentContext();
  CGFloat fw = rect.size.width;
  CGFloat fh = rect.size.height;
  
  if (lightSource >= 0 && lightSource <= 90) {
    CGContextMoveToPoint(context, RD(_topLeftRadius), 0);
  } else {
    CGContextMoveToPoint(context, 0, RD(_topLeftRadius));
    CGContextAddArcToPoint(context, 0, 0, RD(_topLeftRadius), 0, RD(_topLeftRadius));
  }
  CGContextAddArcToPoint(context, fw, 0, fw, RD(_topRightRadius), RD(_topRightRadius));
  CGContextAddLineToPoint(context, fw, RD(_topRightRadius));
}

- (void)addRightEdgeToPath:(CGRect)rect lightSource:(NSInteger)lightSource {
  CGContextRef context = UIGraphicsGetCurrentContext();
  CGFloat fw = rect.size.width;
  CGFloat fh = rect.size.height;

  CGContextMoveToPoint(context, fw, RD(_topRightRadius));
  CGContextAddArcToPoint(context, fw, fh, fw-RD(_bottomRightRadius), fh, RD(_bottomRightRadius));
  CGContextAddLineToPoint(context, fw-RD(_bottomRightRadius), fh);
}

- (void)addBottomEdgeToPath:(CGRect)rect lightSource:(NSInteger)lightSource {
  CGContextRef context = UIGraphicsGetCurrentContext();
  CGFloat fw = rect.size.width;
  CGFloat fh = rect.size.height;

  CGContextMoveToPoint(context, fw-RD(_bottomRightRadius), fh);
  CGContextAddLineToPoint(context, RD(_bottomLeftRadius), fh);
  CGContextAddArcToPoint(context, 0, fh, 0, fh-RD(_bottomLeftRadius), RD(_bottomLeftRadius));
}

- (void)addLeftEdgeToPath:(CGRect)rect lightSource:(NSInteger)lightSource {
  CGContextRef context = UIGraphicsGetCurrentContext();
  CGFloat fh = rect.size.height;
  
  CGContextMoveToPoint(context, 0, fh-RD(_bottomLeftRadius));
  CGContextAddLineToPoint(context, 0, RD(_topLeftRadius));

  if (lightSource >= 0 && lightSource <= 90) {
    CGContextAddArcToPoint(context, 0, 0, RD(_topLeftRadius), 0, RD(_topLeftRadius));
  }
}

//- (UIEdgeInsets)insetsForSize:(CGSize)size {
//  CGFloat fh = size.height/3;
//  return UIEdgeInsetsMake(floor(MAX(RD(_topLeftRadius), RD(_topRightRadius))),
//                          floor(MAX(RD(_topLeftRadius), RD(_bottomLeftRadius))),
//                          floor(MAX(RD(_bottomLeftRadius), RD(_bottomRightRadius))),
//                          floor(MAX(RD(_topRightRadius), RD(_bottomRightRadius))));
//}

@end

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation TTRoundedRightArrowShape

@synthesize radius = _radius;

///////////////////////////////////////////////////////////////////////////////////////////////////
// class public

+ (TTRoundedRightArrowShape*)shapeWithRadius:(CGFloat)radius {
  TTRoundedRightArrowShape* shape = [[[TTRoundedRightArrowShape alloc] init] autorelease];
  shape.radius = radius;
  return shape;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// public

- (void)addToPath:(CGRect)rect {
  [self openPath:rect];

  CGFloat fw = rect.size.width;
  CGFloat fh = rect.size.height;
  CGFloat point = floor(fh/kArrowPointWidth);
  CGFloat radius = RD(_radius);
  CGFloat radius2 = radius*kArrowRadius;
  
  CGContextRef context = UIGraphicsGetCurrentContext();
  CGContextMoveToPoint(context, fw, floor(fh/2));
  CGContextAddArcToPoint(context, fw-point, fh, 0, fh, radius2);
  CGContextAddArcToPoint(context, 0, fh, 0, 0, radius);
  CGContextAddArcToPoint(context, 0, 0, fw-point, 0, radius);
  CGContextAddArcToPoint(context, fw-point, 0, fw, floor(fh/2), radius2);
  CGContextAddLineToPoint(context, fw, floor(fh/2));

  [self closePath:rect];
}

- (void)addTopEdgeToPath:(CGRect)rect lightSource:(NSInteger)lightSource {
  CGContextRef context = UIGraphicsGetCurrentContext();
  CGFloat fw = rect.size.width;
  CGFloat fh = rect.size.height;
  CGFloat point = floor(fh/kArrowPointWidth);
  CGFloat radius = RD(_radius);
  CGFloat radius2 = radius*kArrowRadius;
  
  if (lightSource >= 0 && lightSource <= 90) {
    CGContextMoveToPoint(context, radius, 0);
  } else {
    CGContextMoveToPoint(context, 0, radius);
    CGContextAddArcToPoint(context, 0, 0, radius, 0, radius);
  }
  CGContextAddLineToPoint(context, fw-(point+radius2), 0);
  CGContextAddArcToPoint(context, fw-point, 0, fw, floor(fh/2), radius2);
  CGContextAddLineToPoint(context, fw, floor(fh/2));
}

- (void)addRightEdgeToPath:(CGRect)rect lightSource:(NSInteger)lightSource {
  CGContextRef context = UIGraphicsGetCurrentContext();
  CGFloat fw = rect.size.width;
  CGFloat fh = rect.size.height;
  CGFloat point = floor(fh/kArrowPointWidth);
  CGFloat radius = RD(_radius);
  CGFloat radius2 = radius*kArrowRadius;
  
  CGContextMoveToPoint(context, fw, floor(fh/2));
  CGContextAddArcToPoint(context, fw-point, fh, fw-(point+radius2), fh, radius2);
  CGContextAddLineToPoint(context, fw-(point+radius2), fh);
}

- (void)addBottomEdgeToPath:(CGRect)rect lightSource:(NSInteger)lightSource {
  CGContextRef context = UIGraphicsGetCurrentContext();
  CGFloat fw = rect.size.width;
  CGFloat fh = rect.size.height;
  CGFloat point = floor(fh/kArrowPointWidth);
  CGFloat radius = RD(_radius);
  CGFloat radius2 = radius*kArrowRadius;

  CGContextMoveToPoint(context, floor(fw-(point+radius2)), fh);
  CGContextAddArcToPoint(context, 0, fh, 0, floor(fh-radius), radius);
}

- (void)addLeftEdgeToPath:(CGRect)rect lightSource:(NSInteger)lightSource {
  CGContextRef context = UIGraphicsGetCurrentContext();
  CGFloat fh = rect.size.height;
  CGFloat radius = RD(_radius);

  CGContextMoveToPoint(context, 0, floor(fh-radius));
  CGContextAddLineToPoint(context, 0, floor(radius));

  if (lightSource >= 0 && lightSource <= 90) {
    CGContextAddArcToPoint(context, 0, 0, floor(radius), 0, radius);
  }
}

- (UIEdgeInsets)insetsForSize:(CGSize)size {
  CGFloat fh = size.height/3;
  return UIEdgeInsetsMake(0, 0, 0, floor(RD(_radius)));
//  CGFloat fh = size.height/3;
//  return UIEdgeInsetsMake(floor(RD(_radius)), floor(RD(_radius)),
//                          floor(RD(_radius)), floor(RD(_radius))*2);
}

@end

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation TTRoundedLeftArrowShape

@synthesize radius = _radius;

///////////////////////////////////////////////////////////////////////////////////////////////////
// class public

+ (TTRoundedLeftArrowShape*)shapeWithRadius:(CGFloat)radius {
  TTRoundedLeftArrowShape* shape = [[[TTRoundedLeftArrowShape alloc] init] autorelease];
  shape.radius = radius;
  return shape;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// public

- (void)addToPath:(CGRect)rect {
  [self openPath:rect];

  CGFloat fw = rect.size.width;
  CGFloat fh = rect.size.height;
  CGFloat point = floor(fh/kArrowPointWidth);
  CGFloat radius = RD(_radius);
  CGFloat radius2 = radius*kArrowRadius;
  
  CGContextRef context = UIGraphicsGetCurrentContext();
  CGContextMoveToPoint(context, 0, floor(fh/2));
  CGContextAddArcToPoint(context, point, 0, floor(fw-radius), 0, radius2);
  CGContextAddArcToPoint(context, fw, 0, fw, floor(radius), radius);
  CGContextAddArcToPoint(context, fw, fh, floor(point+radius2), fh, radius);
  CGContextAddArcToPoint(context, point, fh, 0, floor(fh/2), radius2);

  [self closePath:rect];
}

- (void)addInverseToPath:(CGRect)rect {
  CGContextRef context = UIGraphicsGetCurrentContext();
  CGFloat fw = rect.size.width;
  CGFloat fh = rect.size.height;
  CGFloat point = floor(fh/kArrowPointWidth);
  CGFloat radius = RD(_radius);
  CGFloat radius2 = radius*kArrowRadius;

  CGFloat width = 5;
  CGRect shadowRect = CGRectMake(-width, -width, fw+width*2, fh+width*2);
  CGMutablePathRef path = CGPathCreateMutable();
  CGPathAddRect(path, nil, shadowRect);
  CGPathCloseSubpath(path);
  
  CGPathMoveToPoint(path, nil, 0, floor(fh/2));
  CGPathAddArcToPoint(path, nil, point, 0, floor(fw-radius), 0, radius2);
  CGPathAddArcToPoint(path, nil, fw, 0, fw, floor(radius), radius);
  CGPathAddArcToPoint(path, nil, fw, fh, floor(point+radius2), fh, radius);
  CGPathAddArcToPoint(path, nil, point, fh, 0, floor(fh/2), radius2);

  [self openPath:rect];
  CGContextAddPath(context, path);
  [self closePath:rect];

  CGPathRelease(path);
}

- (void)addTopEdgeToPath:(CGRect)rect lightSource:(NSInteger)lightSource {
  CGContextRef context = UIGraphicsGetCurrentContext();
  CGFloat fw = rect.size.width;
  CGFloat fh = rect.size.height;
  CGFloat point = floor(fh/kArrowPointWidth);
  CGFloat radius = RD(_radius);
  CGFloat radius2 = radius*kArrowRadius;
  
  CGContextMoveToPoint(context, 0, floor(fh/2));
  CGContextAddArcToPoint(context, point, 0, floor(fw-radius), 0, radius2);

  if (lightSource >= 0 && lightSource <= 90) {
    CGContextAddLineToPoint(context, floor(fw-radius), 0);
  } else {
    CGContextAddArcToPoint(context, fw, 0, fw, floor(radius), radius);
  }
}

- (void)addRightEdgeToPath:(CGRect)rect lightSource:(NSInteger)lightSource {
  CGContextRef context = UIGraphicsGetCurrentContext();
  CGFloat fw = rect.size.width;
  CGFloat fh = rect.size.height;
  CGFloat radius = RD(_radius);
  
  if (lightSource >= 0 && lightSource <= 90) {
    CGContextMoveToPoint(context, floor(fw-radius), 0);
    CGContextAddArcToPoint(context, fw, 0, fw, floor(radius), radius);
  } else {
    CGContextMoveToPoint(context, fw, radius);
    CGContextAddLineToPoint(context, fw, fh-radius);
  }
}

- (void)addBottomEdgeToPath:(CGRect)rect lightSource:(NSInteger)lightSource {
  CGContextRef context = UIGraphicsGetCurrentContext();
  CGFloat fw = rect.size.width;
  CGFloat fh = rect.size.height;
  CGFloat point = floor(fh/kArrowPointWidth);
  CGFloat radius = RD(_radius);
  CGFloat radius2 = _radius*kArrowRadius;

  CGContextMoveToPoint(context, fw, floor(fh-radius));
  CGContextAddArcToPoint(context, fw, fh, floor(point+radius2), fh, radius);
  CGContextAddLineToPoint(context, floor(point+radius2)-1, fh);
}

- (void)addLeftEdgeToPath:(CGRect)rect lightSource:(NSInteger)lightSource {
  CGContextRef context = UIGraphicsGetCurrentContext();
  CGFloat fh = rect.size.height;
  CGFloat point = floor(fh/kArrowPointWidth);
  CGFloat radius = RD(_radius);
  CGFloat radius2 = radius*kArrowRadius;

  CGContextMoveToPoint(context, floor(point+radius2), fh);
  CGContextAddArcToPoint(context, point, fh, 0, floor(fh/2), radius2);
  CGContextAddLineToPoint(context, 0, floor(fh/2));
}

- (UIEdgeInsets)insetsForSize:(CGSize)size {
  CGFloat fh = size.height/3;
  return UIEdgeInsetsMake(0, floor(RD(_radius)), 0, 0);
//  CGFloat fh = size.height/3;
//  return UIEdgeInsetsMake(floor(RD(_radius)), floor(RD(_radius))*2,
//                          floor(RD(_radius)), floor(RD(_radius)));
}

@end

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation TTSpeechBubbleShape

@synthesize radius = _radius, pointLocation = _pointLocation, pointAngle = _pointAngle,
            pointSize = _pointSize;

///////////////////////////////////////////////////////////////////////////////////////////////////
// class public

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
// private

- (CGRect)subtractPointFromRect:(CGRect)rect {
  CGFloat x = 0;
  CGFloat y = 0;
  CGFloat w = rect.size.width;
  CGFloat h = rect.size.height;

  if ((_pointLocation >= 0 && _pointLocation < 45)
      || (_pointLocation >= 315 && _pointLocation < 360)) {
    if ((_pointAngle >= 270 && _pointAngle < 360) || (_pointAngle >= 0 && _pointAngle < 90)) {
      x += _pointSize.width;
      w -= _pointSize.width;
    }
  } else if (_pointLocation >= 45 && _pointLocation < 135) {
    if (_pointAngle >= 0 && _pointAngle < 180) {
      y += _pointSize.height;
      h -= _pointSize.height;
    }
  } else if (_pointLocation >= 135 && _pointLocation < 225) {
    if (_pointAngle >= 90 && _pointAngle < 270) {
      w -= _pointSize.width;
    }
  } else if (_pointLocation >= 225 && _pointLocation <= 315) {
    if (_pointAngle >= 180 && _pointAngle < 360) {
      h -= _pointSize.height;
    }
  }
  
  return CGRectMake(x, y, w, h);
}

- (void)addTopEdge:(CGSize)size lightSource:(NSInteger)lightSource toPath:(CGMutablePathRef)path
        reset:(BOOL)reset {
  CGFloat fw = size.width;
  CGFloat fh = size.height;
  CGFloat pointX = 0;

  if (lightSource >= 0 && lightSource <= 90) {
    if (reset) {
      CGPathMoveToPoint(path, nil, RD(_radius), 0);
    }
  } else {
    if (reset) {
      CGPathMoveToPoint(path, nil, 0, RD(_radius));
    }
    CGPathAddArcToPoint(path, nil, 0, 0, RD(_radius), 0, RD(_radius));
  }
  
  if (_pointLocation >= 45 && _pointLocation <= 135) {
    CGFloat ph = _pointAngle >= 0 && _pointAngle < 180 ? _pointSize.height : -_pointSize.height;
    pointX = ((_pointLocation-45)/90) * fw;
    
    CGPathAddLineToPoint(path, nil, pointX-floor(_pointSize.width/2), 0);
    CGPathAddLineToPoint(path, nil, pointX, -ph);
    CGPathAddLineToPoint(path, nil, pointX+floor(_pointSize.width/2), 0);
  }

  CGPathAddArcToPoint(path, nil, fw, 0, fw, RD(_radius), RD(_radius));
}

- (void)addRightEdge:(CGSize)size lightSource:(NSInteger)lightSource toPath:(CGMutablePathRef)path
        reset:(BOOL)reset {
  CGFloat fw = size.width;
  CGFloat fh = size.height;

  if (reset) {
    CGPathMoveToPoint(path, nil, fw, RD(_radius));
  }
  
  CGPathAddArcToPoint(path, nil, fw, fh, fw-RD(_radius), fh, RD(_radius));
}

- (void)addBottomEdge:(CGSize)size lightSource:(NSInteger)lightSource toPath:(CGMutablePathRef)path
        reset:(BOOL)reset {
  CGFloat fw = size.width;
  CGFloat fh = size.height;
  CGFloat pointX = 0;

  if (reset) {
    CGPathMoveToPoint(path, nil, fw-RD(_radius), fh);
  }
  
  if (_pointLocation >= 225 && _pointLocation <= 315) {
    CGFloat ph;
    if (_pointAngle >= 0 && _pointAngle < 180) {
      ph = _pointSize.height;
    } else {
      ph = -_pointSize.height;
    }

    pointX = fw - (((_pointLocation-225)/90) * fw);
    CGPathAddArcToPoint(path, nil,  fw-RD(_radius), fh, floor(fw/2), fh, RD(_radius));
    CGPathAddLineToPoint(path, nil, pointX+floor(_pointSize.width/2), fh);
    CGPathAddLineToPoint(path, nil, pointX, fh-ph);
    CGPathAddLineToPoint(path, nil, pointX-floor(_pointSize.width/2), fh);
    CGPathAddLineToPoint(path, nil, RD(_radius), fh);
  }

  CGPathAddArcToPoint(path, nil, 0, fh, 0, fh-RD(_radius), RD(_radius));
}

- (void)addLeftEdge:(CGSize)size lightSource:(NSInteger)lightSource toPath:(CGMutablePathRef)path
        reset:(BOOL)reset {
  CGFloat fh = size.height;

  if (reset) {
    CGPathMoveToPoint(path, nil, 0, fh-RD(_radius));
  }
  
  if (lightSource >= 0 && lightSource <= 90) {
    CGPathAddArcToPoint(path, nil, 0, 0, RD(_radius), 0, RD(_radius));
  } else {
    CGPathAddLineToPoint(path, nil, 0, RD(_radius));
  }
}

- (void)addToPath:(CGSize)size path:(CGMutablePathRef)path {
  [self addTopEdge:size lightSource:0 toPath:path reset:YES];
  [self addRightEdge:size lightSource:0 toPath:path reset:NO];
  [self addBottomEdge:size lightSource:0 toPath:path reset:NO];
  [self addLeftEdge:size lightSource:0 toPath:path reset:NO];
}

- (void)drawPath:(CGMutablePathRef)path inRect:(CGRect)rect {
  CGContextRef context = UIGraphicsGetCurrentContext();
  CGContextTranslateCTM(context, rect.origin.x, rect.origin.y);
  CGContextAddPath(context, path);
  CGContextTranslateCTM(context, -rect.origin.x, -rect.origin.y);
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// public

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

- (void)addTopEdgeToPath:(CGRect)rect lightSource:(NSInteger)lightSource {
  rect = [self subtractPointFromRect:rect];

  CGMutablePathRef path = CGPathCreateMutable();
  [self addTopEdge:rect.size lightSource:lightSource toPath:path reset:YES];
  [self drawPath:path inRect:rect];
  CGPathRelease(path);
}

- (void)addRightEdgeToPath:(CGRect)rect lightSource:(NSInteger)lightSource {
  rect = [self subtractPointFromRect:rect];

  CGMutablePathRef path = CGPathCreateMutable();
  [self addRightEdge:rect.size lightSource:lightSource toPath:path reset:YES];
  [self drawPath:path inRect:rect];
  CGPathRelease(path);
}

- (void)addBottomEdgeToPath:(CGRect)rect lightSource:(NSInteger)lightSource {
  rect = [self subtractPointFromRect:rect];

  CGMutablePathRef path = CGPathCreateMutable();
  [self addBottomEdge:rect.size lightSource:lightSource toPath:path reset:YES];
  [self drawPath:path inRect:rect];
  CGPathRelease(path);
}

- (void)addLeftEdgeToPath:(CGRect)rect lightSource:(NSInteger)lightSource {
  rect = [self subtractPointFromRect:rect];

  CGMutablePathRef path = CGPathCreateMutable();
  [self addLeftEdge:rect.size lightSource:lightSource toPath:path reset:YES];
  [self drawPath:path inRect:rect];
  CGPathRelease(path);
}

@end
