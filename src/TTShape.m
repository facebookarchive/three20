#import "Three20/TTShape.h"

///////////////////////////////////////////////////////////////////////////////////////////////////
// global

static TTRectangleShape* sharedRectangleShape = nil;

static const CGFloat kArrowPointWidth = 2.8;
static const CGFloat kArrowRadius = 2;

#define RD(RADIUS) (RADIUS == TT_ROUNDED ? floor(fh/2) : RADIUS)

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

- (UIEdgeInsets)insetsForSize:(CGSize)size {
  return UIEdgeInsetsMake(floor(MAX(_topLeftRadius, _topRightRadius)),
                          floor(MAX(_topLeftRadius, _bottomLeftRadius)),
                          floor(MAX(_bottomLeftRadius, _bottomRightRadius)),
                          floor(MAX(_topRightRadius, _bottomRightRadius)));
}

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
  CGFloat fh = size.height;
  CGFloat point = floor(fh/kArrowPointWidth)+1;
  return UIEdgeInsetsMake(floor(_radius), floor(_radius)-1, floor(_radius), point+floor(_radius/2));
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
  CGFloat fh = size.height;
  CGFloat point = floor((fh/kArrowPointWidth))-1;
  return UIEdgeInsetsMake(floor(_radius), point+floor(_radius/2), floor(_radius), floor(_radius)+1);
}

@end
