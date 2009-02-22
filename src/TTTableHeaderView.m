#include "Three20/TTTableHeaderView.h"
#include "Three20/TTAppearance.h"

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation TTTableHeaderView

- (id)initWithTitle:(NSString*)title {
  if (self = [super initWithFrame:CGRectZero]) {
    self.backgroundColor = [UIColor clearColor];
    
    _label = [[UILabel alloc] initWithFrame:CGRectZero];
    _label.text = title;
    _label.backgroundColor = [UIColor clearColor];
    _label.textColor = [TTAppearance appearance].tableHeaderTextColor
      ? [TTAppearance appearance].tableHeaderTextColor : [TTAppearance appearance].linkTextColor;
    _label.shadowColor = [TTAppearance appearance].tableHeaderShadowColor
      ? [TTAppearance appearance].tableHeaderShadowColor : [UIColor whiteColor];
    _label.shadowOffset = CGSizeMake(0, 1);
    _label.font = [UIFont boldSystemFontOfSize:18];
    [self addSubview:_label];
  }
  return self;
}

- (void)dealloc {
  [_label release];
  [super dealloc];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// UIView

- (void)drawRect:(CGRect)rect {
  UIColor* tint = [TTAppearance appearance].tableHeaderTintColor;
  UIColor* fill[] = {tint};
  [[TTAppearance appearance] draw:TTDrawReflection rect:rect
    fill:fill fillCount:1 stroke:nil radius:0];
    
//  CGContextRef context = UIGraphicsGetCurrentContext();
//  CGColorSpaceRef space = CGColorSpaceCreateDeviceRGB();
//
//  CGFloat locations[] = {0, 1};
//  
//  CGGradientRef gradient = CGGradientCreateWithColorComponents(space, kGradient1, locations, 2);
//  CGContextDrawLinearGradient(context, gradient, CGPointMake(0, 0),
//    CGPointMake(0, rect.size.height/2), 0);
//  CGGradientRelease(gradient);
//
//  CGContextSetFillColor(context, kGradient2);
//  CGContextFillRect(context,
//    CGRectMake(rect.origin.x, rect.size.height/2, rect.size.width, rect.size.height/2));
//  
//  CGPoint topLine[] = {rect.origin.x, rect.origin.y,
//    rect.origin.x+rect.size.width, rect.origin.y};
//  CGPoint bottomLine[] = {rect.origin.x, rect.origin.y+rect.size.height,
//    rect.origin.x+rect.size.width, rect.origin.y+rect.size.height};
//
//  CGContextSaveGState(context);
//  CGContextSetStrokeColorSpace(context, space);
//  CGContextSetLineWidth(context, 1.0);
//  CGContextSetStrokeColor(context, kStroke2);
//  CGContextStrokeLineSegments(context, bottomLine, 2);
//  CGContextSetStrokeColor(context, kStroke1);
//  CGContextStrokeLineSegments(context, topLine, 2);
//  CGContextRestoreGState(context);
//  
//  CGColorSpaceRelease(space);
}

- (void)layoutSubviews {
  _label.frame = CGRectMake(12, 0, self.width, 23);
}

@end

