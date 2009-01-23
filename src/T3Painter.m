/*
 * Copyright 2008 Facebook
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

#import "Three20/T3Painter.h"

static void addRoundedRectToPath(CGContextRef context, CGRect rect, float radius) {
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

static void addPointedRectToPath(CGContextRef context, CGRect rect, float radius) {
  CGContextBeginPath(context);
  CGContextSaveGState(context);

  if (radius == 0) {
    CGContextTranslateCTM(context, CGRectGetMinX(rect), CGRectGetMinY(rect));
    CGContextAddRect(context, rect);
  } else {
    CGFloat pointSize = 7;
    rect = CGRectOffset(CGRectInset(rect, 0.5+pointSize, 0.5), 0.5+pointSize, 0.5);
    CGContextTranslateCTM(context, CGRectGetMinX(rect)-0.5, CGRectGetMinY(rect)-0.5);
    CGContextScaleCTM(context, radius, radius);
    float fw = CGRectGetWidth(rect) / radius;
    float fh = CGRectGetHeight(rect) / radius;
    float ptx = fw / 25;
    float pty = ptx*2;
    
    CGContextMoveToPoint(context, fw, fh/2);
    CGContextAddArcToPoint(context, fw, fh, fw/2, fh, 1);
    CGContextAddArcToPoint(context, 0, fh, 0, fh/8+pty, 1);
    CGContextAddLineToPoint(context, 0, fh/8+pty);
    CGContextAddLineToPoint(context, -ptx, fh/8+pty);
    CGContextAddLineToPoint(context, 0, fh/8);
    CGContextAddArcToPoint(context, 0, 0, fw/2, 0, 1);
    CGContextAddArcToPoint(context, fw, 0, fw, fh/2, 1);
  }

  CGContextClosePath(context);
  CGContextRestoreGState(context);
}

static void addInvertedRoundedRectPath(CGContextRef context, CGRect rect, float radius) {
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

@implementation T3Painter

+ (void)drawGrayBar:(CGRect)rect bottom:(BOOL)bottom {
  CGContextRef context = UIGraphicsGetCurrentContext();

  CGFloat components[] = {RGBA(233, 238, 246, 1), RGBA(214, 220, 230, 1)};
  CGFloat locations[] = {0, 1};
  CGColorSpaceRef space = CGColorSpaceCreateDeviceRGB();
  CGGradientRef gradient = CGGradientCreateWithColorComponents(space, components, locations, 2);
  CGContextDrawLinearGradient(context, gradient, CGPointMake(0, 0),
    CGPointMake(0, rect.size.height), 0);
  CGGradientRelease(gradient);

  CGContextSetStrokeColorSpace(context, space);

  CGPoint topLine[] = {0, 0, rect.size.width, 0};
  CGPoint topLine2[] = {0, 1, rect.size.width, 1};
  CGPoint bottomLine[] = {0, rect.size.height, rect.size.width, rect.size.height};
  CGFloat lightColor[] = {RGBA(256, 256, 256, 1)};
  CGFloat shadowColor[] = {RGBA(183, 183, 183, 1)};
  if (bottom) {
    CGContextSetStrokeColor(context, lightColor);
    CGContextStrokeLineSegments(context, topLine2, 2);
    CGContextSetStrokeColor(context, shadowColor);
    CGContextStrokeLineSegments(context, topLine, 2);
  } else {
    CGContextSetStrokeColor(context, lightColor);
    CGContextStrokeLineSegments(context, topLine, 2);
    CGContextSetStrokeColor(context, shadowColor);
    CGContextStrokeLineSegments(context, bottomLine, 2);
  }
  CGColorSpaceRelease(space);
}

+ (void)drawInnerShadow:(CGRect)rect {
  CGContextRef context = UIGraphicsGetCurrentContext();
  CGColorSpaceRef space = CGColorSpaceCreateDeviceRGB();
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

+ (void)drawRoundedRect:(CGRect)rect fill:(const CGFloat*)fillColors fillCount:(int)fillCount
    stroke:(const CGFloat*)strokeColor radius:(CGFloat)radius {
  CGContextRef context = UIGraphicsGetCurrentContext();
  CGColorSpaceRef space = CGColorSpaceCreateDeviceRGB();

  CGFloat locations[] = {0, 1};
  if (radius == NSUIntegerMax) {
    radius = rect.size.height/2;
  }
  
  if (fillColors) {
    CGContextSaveGState(context);
    addRoundedRectToPath(context, rect, radius);
    if (fillCount > 1) {
      CGContextClip(context);
      CGGradientRef gradient = CGGradientCreateWithColorComponents(space, fillColors, locations, 2);
      CGContextDrawLinearGradient(context, gradient, CGPointMake(0, 0),
        CGPointMake(0, rect.size.height), kCGGradientDrawsAfterEndLocation);
      CGGradientRelease(gradient);
    } else {
      CGContextSetFillColor(context, fillColors);
      CGContextFillPath(context);
    }
    CGContextRestoreGState(context);
  }
  
  if (strokeColor) {
    CGContextSaveGState(context);
    addRoundedRectToPath(context, rect, radius);
    CGContextSetStrokeColorSpace(context, space);
    CGContextSetStrokeColor(context, strokeColor);
    CGContextSetLineWidth(context, 1.0);
    CGContextStrokePath(context);
    CGContextRestoreGState(context);
  }
  
  CGColorSpaceRelease(space);
}

+ (void)drawPointedRect:(CGRect)rect fill:(const CGFloat*)fillColors fillCount:(int)fillCount
    stroke:(const CGFloat*)strokeColor radius:(CGFloat)radius {
  CGContextRef context = UIGraphicsGetCurrentContext();
  CGColorSpaceRef space = CGColorSpaceCreateDeviceRGB();

  CGFloat locations[] = {0, 1};
  if (radius == NSUIntegerMax) {
    radius = rect.size.height/2;
  }
  
  if (fillColors) {
    CGContextSaveGState(context);
    addPointedRectToPath(context, rect, radius);
    if (fillCount > 1) {
      CGContextClip(context);
      CGGradientRef gradient = CGGradientCreateWithColorComponents(space, fillColors, locations, 2);
      CGContextDrawLinearGradient(context, gradient, CGPointMake(0, 0),
        CGPointMake(0, rect.size.height), kCGGradientDrawsAfterEndLocation);
      CGGradientRelease(gradient);
    } else {
      CGContextSetFillColor(context, fillColors);
      CGContextFillPath(context);
    }
    CGContextRestoreGState(context);
  }
  
  if (strokeColor) {
    CGContextSaveGState(context);
    addPointedRectToPath(context, rect, radius);
    CGContextSetStrokeColorSpace(context, space);
    CGContextSetStrokeColor(context, strokeColor);
    CGContextSetLineWidth(context, 1.0);
    CGContextStrokePath(context);
    CGContextRestoreGState(context);
  }
  
  CGColorSpaceRelease(space);
}

+ (void)drawRoundedMask:(CGRect)rect fill:(const CGFloat*)fillColors
    stroke:(const CGFloat*)strokeColor radius:(CGFloat)radius {
  CGContextRef context = UIGraphicsGetCurrentContext();
  CGColorSpaceRef space = CGColorSpaceCreateDeviceRGB();

  if (radius == NSUIntegerMax) {
    radius = rect.size.height/2;
  }
  
  if (fillColors) {
    CGContextSaveGState(context);
    addInvertedRoundedRectPath(context, rect, radius);
    CGContextSetFillColor(context, fillColors);
    CGContextEOFillPath(context);
    CGContextRestoreGState(context);
  }
  
  if (strokeColor) {
    CGContextSaveGState(context);
    addRoundedRectToPath(context, rect, radius);
    CGContextSetStrokeColorSpace(context, space);
    CGContextSetStrokeColor(context, strokeColor);
    CGContextSetLineWidth(context, 1.0);
    CGContextStrokePath(context);
    CGContextRestoreGState(context);
  }
  
  CGColorSpaceRelease(space);
}

+ (void)strokeLines:(CGRect)rect background:(T3Background)background
  stroke:(const CGFloat*)strokeColor {
  CGContextRef context = UIGraphicsGetCurrentContext();
  CGContextSaveGState(context);
  CGColorSpaceRef space = CGColorSpaceCreateDeviceRGB();
  CGContextSetStrokeColorSpace(context, space);
  CGContextSetStrokeColor(context, strokeColor);
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
  
  CGColorSpaceRelease(space);
  CGContextRestoreGState(context);
}

+ (void)drawLine:(CGPoint)from to:(CGPoint)to color:(UIColor*)color {
  CGContextRef context = UIGraphicsGetCurrentContext();
  CGContextSaveGState(context);
  CGColorSpaceRef space = CGColorSpaceCreateDeviceRGB();
  CGContextSetStrokeColorSpace(context, space);

  CGPoint points[] = {from.x, from.y, to.x, from.y};
  CGContextSetStrokeColorWithColor(context, color.CGColor);
  CGContextSetLineWidth(context, 1.0);
  CGContextStrokeLineSegments(context, points, 2);

  CGColorSpaceRelease(space);
  CGContextRestoreGState(context);
}

+ (void)drawBackground:(T3Background)background rect:(CGRect)rect fill:(UIColor*)fillColor
  fillCount:(int)fillCount stroke:(UIColor*)strokeColor radius:(CGFloat)radius {
  const CGFloat* fill = fillColor ? CGColorGetComponents(fillColor.CGColor) : nil;
  const CGFloat* stroke = strokeColor ? CGColorGetComponents(strokeColor.CGColor) : nil;

  switch (background) {
    case T3BackgroundGrayBar:
      [self drawGrayBar:rect bottom:NO];
      break;
    case T3BackgroundInnerShadow:
      [self drawInnerShadow:rect];
      break;
    case T3BackgroundRoundedRect:
      [self drawRoundedRect:rect fill:fill fillCount:fillCount stroke:stroke radius:radius];
      break;
    case T3BackgroundPointedRect:
      [self drawPointedRect:rect fill:fill fillCount:fillCount stroke:stroke radius:radius];
      break;
    case T3BackgroundRoundedMask:
      [self drawRoundedMask:rect fill:fill stroke:stroke radius:radius];
      break;
    case T3BackgroundStrokeTop:
    case T3BackgroundStrokeRight:
    case T3BackgroundStrokeBottom:
    case T3BackgroundStrokeLeft:
      [self strokeLines:rect background:background stroke:stroke];
      break;
    default:
      break;
  }
}

+ (void)drawBackground:(T3Background)background rect:(CGRect)rect {
  [self drawBackground:background rect:rect fill:nil fillCount:0 stroke:nil
    radius:NSUIntegerMax];
}

@end

