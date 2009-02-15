#import "Three20/T3Appearance.h"

///////////////////////////////////////////////////////////////////////////////////////////////////

static T3Appearance* gAppearance = nil;

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation T3Appearance

@synthesize linkTextColor = _linkTextColor, navigationBarTintColor = _navigationBarTintColor;

+ (T3Appearance*)appearance {
  if (!gAppearance) {
    [self setAppearance:[[[T3Appearance alloc] init] autorelease]];
  }
  return gAppearance;
}

+ (void)setAppearance:(T3Appearance*)appearance {
  if (gAppearance != appearance) {
    [gAppearance release];
    gAppearance = [appearance retain];
  }
}

///////////////////////////////////////////////////////////////////////////////////////////////////

- (id)init {
  if (self = [super init]) {
    self.linkTextColor = RGBCOLOR(87, 107, 149);
    self.navigationBarTintColor = nil;
  }
  return self;
}

- (void)dealloc {
  [_linkTextColor release];
  [_navigationBarTintColor release];
  [super dealloc];
}

///////////////////////////////////////////////////////////////////////////////////////////////////

- (void)addRoundedRectToPath:(CGContextRef)context rect:(CGRect)rect radius:(float)radius {
  CGContextBeginPath(context);
  CGContextSaveGState(context);

  if (radius == 0) {
    CGContextTranslateCTM(context, CGRectGetMinX(rect), CGRectGetMinY(rect));
    CGContextAddRect(context, rect);
  } else {
    rect = CGRectOffset(CGRectInset(rect, 0.5, 0.5), 0.5, 0.5);
    CGContextTranslateCTM(context, CGRectGetMinX(rect)-0.5, CGRectGetMinY(rect)-0.5);
    CGContextScaleCTM(context, radius, radius);
    float fw = CGRectGetWidth(rect) / radius;
    float fh = CGRectGetHeight(rect) / radius;
    
    CGContextMoveToPoint(context, fw, fh/2);
    CGContextAddArcToPoint(context, fw, fh, fw/2, fh, 1);
    CGContextAddArcToPoint(context, 0, fh, 0, fh/2, 1);
    CGContextAddArcToPoint(context, 0, 0, fw/2, 0, 1);
    CGContextAddArcToPoint(context, fw, 0, fw, fh/2, 1);
  }

  CGContextClosePath(context);
  CGContextRestoreGState(context);
}

- (void)addInvertedRoundedRectPath:(CGContextRef)context rect:(CGRect)rect radius:(float)radius {
  CGMutablePathRef path = CGPathCreateMutable();
  CGPathAddRect(path, nil, rect);
  CGPathCloseSubpath(path);

  if (radius == 0) {
    CGContextAddRect(context, rect);
  } else {
    float fw = CGRectGetWidth(rect) / radius;
    float fh = CGRectGetHeight(rect) / radius;

    CGPathMoveToPoint(path, nil, fw, fh/2);
    CGPathAddArcToPoint(path, nil, fw, fh, fw/2, fh, 1);
    CGPathAddArcToPoint(path, nil, 0, fh, 0, fh/2, 1);
    CGPathAddArcToPoint(path, nil, 0, 0, fw/2, 0, 1);
    CGPathAddArcToPoint(path, nil, fw, 0, fw, fh/2, 1);
    CGPathCloseSubpath(path);
  }
  
  CGContextSaveGState(context);
  CGContextTranslateCTM(context, CGRectGetMinX(rect), CGRectGetMinY(rect));
  CGContextScaleCTM(context, radius, radius);
  CGContextAddPath(context, path);
  CGContextRestoreGState(context);
  
  CGPathRelease(path);
}

- (CGGradientRef)gradientWithColors:(UIColor**)colors count:(int)count
    space:(CGColorSpaceRef)space {
  CGFloat* components = malloc(sizeof(CGFloat)*4*count);
  CGFloat* locations = malloc(sizeof(CGFloat)*count);
  for (int i = 0; i < count; ++i) {
    UIColor* color = colors[i];
    const CGFloat* rgba = CGColorGetComponents(color.CGColor);
    components[i*4] = rgba[0];
    components[i*4+1] = rgba[1];
    components[i*4+2] = rgba[2];
    components[i*4+3] = rgba[3];
    locations[i] = (i+1)/count;
  }
  CGGradientRef gradient = CGGradientCreateWithColorComponents(space, components, locations, count);
  free(components);
  free(locations);
  return gradient;
}

- (void)drawRoundedRect:(CGRect)rect fill:(UIColor**)fillColors fillCount:(int)fillCount
    stroke:(UIColor*)strokeColor radius:(CGFloat)radius {
  CGContextRef context = UIGraphicsGetCurrentContext();

  if (radius == T3_RADIUS_ROUNDED) {
    radius = rect.size.height/2;
  }
  
  if (fillColors) {
    CGContextSaveGState(context);
    [self addRoundedRectToPath:context rect:rect radius:radius];
    [self fill:rect fillColors:fillColors count:fillCount];
    CGContextRestoreGState(context);
  }
  
  if (strokeColor) {
    CGContextSaveGState(context);
    [self addRoundedRectToPath:context rect:rect radius:radius];
    [self stroke:strokeColor];
    CGContextRestoreGState(context);
  }
}

- (void)drawRoundedMask:(CGRect)rect fill:(UIColor**)fillColors stroke:(UIColor*)strokeColor
    radius:(CGFloat)radius {
  CGContextRef context = UIGraphicsGetCurrentContext();

  if (radius == T3_RADIUS_ROUNDED) {
    radius = rect.size.height/2;
  }
  
  if (fillColors) {
    CGContextSaveGState(context);
    [self addInvertedRoundedRectPath:context rect:rect radius:radius];
    CGContextSetFillColor(context, CGColorGetComponents(fillColors[0].CGColor));
    CGContextEOFillPath(context);
    CGContextRestoreGState(context);
  }
  
  if (strokeColor) {
    CGContextSaveGState(context);
    [self addRoundedRectToPath:context rect:rect radius:radius];
    CGContextSetStrokeColor(context, CGColorGetComponents(strokeColor.CGColor));
    CGContextSetLineWidth(context, 1.0);
    CGContextStrokePath(context);
    CGContextRestoreGState(context);
  }
}

- (void)drawInnerShadow:(CGRect)rect {
  CGContextRef context = UIGraphicsGetCurrentContext();
  CGColorSpaceRef space = CGBitmapContextGetColorSpace(context);
  CGContextSaveGState(context);

  CGFloat components[] = {0, 0, 0, 0.15, 0, 0, 0, 0};
  CGFloat locations[] = {0, 0.5};
  CGGradientRef gradient = CGGradientCreateWithColorComponents(space, components, locations, 2);
  CGContextDrawLinearGradient(context, gradient, CGPointMake(0, 0),
    CGPointMake(0, rect.size.height), kCGGradientDrawsBeforeStartLocation);
  CGGradientRelease(gradient);

//  CGPoint topLine[] = {0, 0, rect.size.width, 0};
//  CGFloat shadowColor[] = {130/256.0, 130/256.0, 130/256.0, 1};
//  CGContextSetStrokeColorSpace(context, space);
//  CGContextSetStrokeColor(context, shadowColor);
//  CGContextStrokeLineSegments(context, topLine, 2);

  CGColorSpaceRelease(space);
  CGContextRestoreGState(context);
}

- (void)strokeLines:(CGRect)rect background:(T3Background)background stroke:(UIColor*)strokeColor {
  CGContextRef context = UIGraphicsGetCurrentContext();
  CGContextSaveGState(context);

  CGContextSetStrokeColor(context, CGColorGetComponents(strokeColor.CGColor));
  CGContextSetLineWidth(context, 1.0);
  
  if (background == T3BackgroundStrokeTop) {
    CGPoint points[] = {rect.origin.x, rect.origin.y-0.5,
      rect.origin.x+rect.size.width, rect.origin.y-0.5};
    CGContextStrokeLineSegments(context, points, 2);
  }
//  if (background == T3BackgroundStrokeRight) {
//    CGPoint points[] = {rect.origin.x, rect.origin.y+rect.size.height,
//      rect.origin.x+rect.size.width, rect.origin.y+rect.size.height};
//    CGContextStrokeLineSegments(context, points, 2);
//  }
  if (background == T3BackgroundStrokeBottom) {
    CGPoint points[] = {rect.origin.x, rect.origin.y+rect.size.height-0.5,
      rect.origin.x+rect.size.width, rect.origin.y+rect.size.height-0.5};
    CGContextStrokeLineSegments(context, points, 2);
  }
//  if (background == T3BackgroundStrokeLeft) {
//    CGPoint points[] = {rect.origin.x, rect.origin.y+rect.size.height,
//      rect.origin.x+rect.size.width, rect.origin.y+rect.size.height};
//    CGContextStrokeLineSegments(context, points, 2);
//  }
  
  CGContextRestoreGState(context);
}

///////////////////////////////////////////////////////////////////////////////////////////////////

- (void)drawBackground:(T3Background)background rect:(CGRect)rect fill:(UIColor**)fillColors
    fillCount:(int)fillCount stroke:(UIColor*)strokeColor radius:(CGFloat)radius {
  switch (background) {
    case T3BackgroundRoundedRect:
      [self drawRoundedRect:rect fill:fillColors fillCount:fillCount stroke:strokeColor
        radius:radius];
      break;
    case T3BackgroundRoundedMask:
      [self drawRoundedMask:rect fill:fillColors stroke:strokeColor radius:radius];
      break;
    case T3BackgroundInnerShadow:
      [self drawInnerShadow:rect];
      break;
    case T3BackgroundStrokeTop:
    case T3BackgroundStrokeRight:
    case T3BackgroundStrokeBottom:
    case T3BackgroundStrokeLeft:
      [self strokeLines:rect background:background stroke:strokeColor];
      break;
    default:
      break;
  }
}

- (void)drawBackground:(T3Background)background rect:(CGRect)rect {
  [self drawBackground:background rect:rect fill:nil fillCount:0 stroke:nil
    radius:T3_RADIUS_ROUNDED];
}

- (void)drawLine:(CGPoint)from to:(CGPoint)to color:(UIColor*)color {
  CGContextRef context = UIGraphicsGetCurrentContext();
  CGContextSaveGState(context);

  CGPoint points[] = {from.x, from.y, to.x, from.y};
  CGContextSetStrokeColorWithColor(context, color.CGColor);
  CGContextSetLineWidth(context, 1.0);
  CGContextStrokeLineSegments(context, points, 2);

  CGContextRestoreGState(context);
}

- (void)fill:(CGRect)rect fillColors:(UIColor**)fillColors count:(int)count {
  CGContextRef context = UIGraphicsGetCurrentContext();
  CGColorSpaceRef space = CGBitmapContextGetColorSpace(context);

  if (count > 1) {
    CGContextClip(context);
    CGGradientRef gradient = [self gradientWithColors:fillColors count:count space:space];
    CGContextDrawLinearGradient(context, gradient, CGPointMake(0, 0),
      CGPointMake(0, rect.size.height), kCGGradientDrawsAfterEndLocation);
    CGGradientRelease(gradient);
  } else {
    CGContextSetFillColor(context, CGColorGetComponents(fillColors[0].CGColor));
    CGContextFillPath(context);
  }

  CGColorSpaceRelease(space);
}

- (void)stroke:(UIColor*)strokeColor {
  CGContextRef context = UIGraphicsGetCurrentContext();
  CGColorSpaceRef space = CGBitmapContextGetColorSpace(context);

  CGContextSetStrokeColorSpace(context, space);
  CGContextSetStrokeColor(context, CGColorGetComponents(strokeColor.CGColor));
  CGContextSetLineWidth(context, 1.0);
  CGContextStrokePath(context);

  CGColorSpaceRelease(space);
}

@end
