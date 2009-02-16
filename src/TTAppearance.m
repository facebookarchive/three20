#import "Three20/TTAppearance.h"

///////////////////////////////////////////////////////////////////////////////////////////////////

static TTAppearance* gAppearance = nil;

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation TTAppearance

@synthesize linkTextColor = _linkTextColor, navigationBarTintColor = _navigationBarTintColor,
  barTintColor = _barTintColor,
  searchTableBackgroundColor = _searchTableBackgroundColor,
  searchTableSeparatorColor = _searchTableSeparatorColor;

+ (TTAppearance*)appearance {
  if (!gAppearance) {
    [self setAppearance:[[[TTAppearance alloc] init] autorelease]];
  }
  return gAppearance;
}

+ (void)setAppearance:(TTAppearance*)appearance {
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
    self.barTintColor = RGBCOLOR(109, 132, 162);
    self.searchTableBackgroundColor = RGBCOLOR(235, 235, 235);
    self.searchTableSeparatorColor = [UIColor colorWithWhite:0.85 alpha:1];
  }
  return self;
}

- (void)dealloc {
  [_linkTextColor release];
  [_navigationBarTintColor release];
  [_barTintColor release];
  [_searchTableBackgroundColor release];
  [_searchTableSeparatorColor release];
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
  CGFloat* locations = nil;//malloc(sizeof(CGFloat)*count);
  for (int i = 0; i < count; ++i) {
    //locations[i] = i/(count-1);

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
  CGGradientRef gradient = CGGradientCreateWithColorComponents(space, components, locations, count);
  free(components);
  //free(locations);
  return gradient;
}

- (void)drawRoundedRect:(CGRect)rect fill:(UIColor**)fillColors fillCount:(int)fillCount
    stroke:(UIColor*)strokeColor radius:(CGFloat)radius {
  CGContextRef context = UIGraphicsGetCurrentContext();

  if (radius == TT_RADIUS_ROUNDED) {
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

  if (radius == TT_RADIUS_ROUNDED) {
    radius = rect.size.height/2;
  }
  
  if (fillColors) {
    CGContextSaveGState(context);
    [self addInvertedRoundedRectPath:context rect:rect radius:radius];
    [fillColors[0] setFill];
    CGContextEOFillPath(context);
    CGContextRestoreGState(context);
  }
  
  if (strokeColor) {
    CGContextSaveGState(context);
    [self addRoundedRectToPath:context rect:rect radius:radius];
    [strokeColor setStroke];
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

  CGPoint topLine[] = {0, 0, rect.size.width, 0};
  CGFloat shadowColor[] = {130/256.0, 130/256.0, 130/256.0, 1};
  CGContextSetStrokeColorSpace(context, space);
  CGContextSetStrokeColor(context, shadowColor);
  CGContextStrokeLineSegments(context, topLine, 2);

  CGColorSpaceRelease(space);
  CGContextRestoreGState(context);
}

- (void)strokeLines:(CGRect)rect style:(TTDrawStyle)style stroke:(UIColor*)strokeColor {
  CGContextRef context = UIGraphicsGetCurrentContext();
  CGContextSaveGState(context);

  [strokeColor setStroke];
  CGContextSetLineWidth(context, 1.0);
  
  if (style == TTDrawStrokeTop) {
    CGPoint points[] = {rect.origin.x, rect.origin.y-0.5,
      rect.origin.x+rect.size.width, rect.origin.y-0.5};
    CGContextStrokeLineSegments(context, points, 2);
  }
  if (style == TTDrawStrokeRight) {
    CGPoint points[] = {rect.origin.x+rect.size.width, rect.origin.y,
      rect.origin.x+rect.size.width, rect.origin.y+rect.size.height};
    CGContextStrokeLineSegments(context, points, 2);
  }
  if (style == TTDrawStrokeBottom) {
    CGPoint points[] = {rect.origin.x, rect.origin.y+rect.size.height-0.5,
      rect.origin.x+rect.size.width, rect.origin.y+rect.size.height-0.5};
    CGContextStrokeLineSegments(context, points, 2);
  }
  if (style == TTDrawStrokeLeft) {
    CGPoint points[] = {rect.origin.x, rect.origin.y,
      rect.origin.x, rect.origin.y+rect.size.height};
    CGContextStrokeLineSegments(context, points, 2);
  }
  
  CGContextRestoreGState(context);
}

///////////////////////////////////////////////////////////////////////////////////////////////////

- (void)draw:(TTDrawStyle)style rect:(CGRect)rect fill:(UIColor**)fillColors
    fillCount:(int)fillCount stroke:(UIColor*)strokeColor radius:(CGFloat)radius {
  switch (style) {
    case TTDrawFillRect:
      [self drawRoundedRect:rect fill:fillColors fillCount:fillCount stroke:strokeColor
        radius:radius];
      break;
    case TTDrawFillRectInverted:
      [self drawRoundedMask:rect fill:fillColors stroke:strokeColor radius:radius];
      break;
    case TTDrawInnerShadow:
      [self drawInnerShadow:rect];
      break;
    case TTDrawStrokeTop:
    case TTDrawStrokeRight:
    case TTDrawStrokeBottom:
    case TTDrawStrokeLeft:
      [self strokeLines:rect style:style stroke:strokeColor];
      break;
    default:
      break;
  }
}

- (void)draw:(TTDrawStyle)style rect:(CGRect)rect {
  [self draw:style rect:rect fill:nil fillCount:0 stroke:nil
    radius:TT_RADIUS_ROUNDED];
}

- (void)drawLine:(CGPoint)from to:(CGPoint)to color:(UIColor*)color {
  CGContextRef context = UIGraphicsGetCurrentContext();
  CGContextSaveGState(context);

  CGPoint points[] = {from.x, from.y, to.x, from.y};
  [color setStroke];
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
    [fillColors[0] setFill];
    CGContextFillPath(context);
  }

  CGColorSpaceRelease(space);
}

- (void)stroke:(UIColor*)strokeColor {
  CGContextRef context = UIGraphicsGetCurrentContext();
  [strokeColor setStroke];
  CGContextSetLineWidth(context, 1.0);
  CGContextStrokePath(context);
}

@end
