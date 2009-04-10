#import "Three20/TTStyle.h"
#import "Three20/TTShape.h"

///////////////////////////////////////////////////////////////////////////////////////////////////
// global

static const NSInteger kDefaultLightSource = 125;

#define ZEROLIMIT(_VALUE) (_VALUE < 0 ? 0 : (_VALUE > 1 ? 1 : _VALUE))

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation TTStyle

@synthesize next = _next;

///////////////////////////////////////////////////////////////////////////////////////////////////
// private

- (CGGradientRef)newGradientWithColors:(UIColor**)colors count:(int)count {
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
  CGGradientRef gradient = CGGradientCreateWithColorComponents(space, components, nil, count);
  free(components);
  return gradient;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// NSObject

- (id)initWithNext:(TTStyle*)next {
  if (self = [super init]) {
    _next = [next retain];
  }
  return self;
}

- (id)init {
  return [self initWithNext:nil];
}

- (void)dealloc {
  [_next release];
  [super dealloc];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// public

- (BOOL)drawRect:(CGRect)rect shape:(TTShape*)shape delegate:(id<TTStyleDelegate>)delegate {
  if (_next) {
    return [self.next drawRect:rect shape:shape delegate:delegate];
  } else {
    return NO;
  }
}

- (TTStyle*)firstStyleOfClass:(Class)cls {
  if ([self isKindOfClass:cls]) {
    return self;
  } else {
    return [self.next firstStyleOfClass:cls];
  }
}

- (UIEdgeInsets)addToInsets:(UIEdgeInsets)insets forSize:(CGSize)size {
  if (self.next) {
    return [self.next addToInsets:insets forSize:size];
  } else {
    return insets;
  }
}

- (CGSize)addToSize:(CGSize)size delegate:(id<TTStyleDelegate>)delegate {
  if (_next) {
    return [self.next addToSize:size delegate:delegate];
  } else {
    return size;
  }
}

@end

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation TTContentStyle

///////////////////////////////////////////////////////////////////////////////////////////////////
// class public

+ (TTContentStyle*)styleWithNext:(TTStyle*)next {
  return [[[self alloc] initWithNext:next] autorelease];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// TTStyle

- (BOOL)drawRect:(CGRect)rect shape:(TTShape*)shape delegate:(id<TTStyleDelegate>)delegate {
  [delegate drawLayer:rect withStyle:self shape:shape];
  [self.next drawRect:rect shape:shape delegate:delegate];
  return YES;
}

@end

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation TTShapeStyle

@synthesize shape = _shape;

///////////////////////////////////////////////////////////////////////////////////////////////////
// NSObject

+ (TTShapeStyle*)styleWithShape:(TTShape*)shape next:(TTStyle*)next {
  TTShapeStyle* style = [[[self alloc] initWithNext:next] autorelease];
  style.shape = shape;
  return style;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// NSObject

- (id)initWithNext:(TTStyle*)next {  
  if (self = [super initWithNext:next]) {
    _shape = nil;
  }
  return self;
}

- (void)dealloc {
  [_shape release];
  [super dealloc];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// TTStyle

- (BOOL)drawRect:(CGRect)rect shape:(TTShape*)shape delegate:(id<TTStyleDelegate>)delegate {
  return [self.next drawRect:rect shape:_shape delegate:delegate];
}

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

- (CGSize)addToSize:(CGSize)size delegate:(id<TTStyleDelegate>)delegate {
  UIEdgeInsets shapeInsets = [_shape insetsForSize:size];
  size.width += shapeInsets.left + shapeInsets.right;
  size.height += shapeInsets.top + shapeInsets.bottom;

  if (_next) {
    return [self.next addToSize:size delegate:delegate];
  } else {
    return size;
  }
}

@end

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation TTInsetStyle

@synthesize inset = _inset;

///////////////////////////////////////////////////////////////////////////////////////////////////
// NSObject

+ (TTInsetStyle*)styleWithInset:(UIEdgeInsets)inset next:(TTStyle*)next {
  TTInsetStyle* style = [[[self alloc] initWithNext:next] autorelease];
  style.inset = inset;
  return style;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// NSObject

- (id)initWithNext:(TTStyle*)next {  
  if (self = [super initWithNext:next]) {
    _inset = UIEdgeInsetsZero;
  }
  return self;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// TTStyle

- (BOOL)drawRect:(CGRect)rect shape:(TTShape*)shape delegate:(id<TTStyleDelegate>)delegate {
  CGRect innerRect = CGRectMake(rect.origin.x+_inset.left, rect.origin.y+_inset.top,
    rect.size.width - (_inset.left + _inset.right),
    rect.size.height - (_inset.top + _inset.bottom));
  return [self.next drawRect:innerRect shape:shape delegate:delegate];
}

- (UIEdgeInsets)addToInsets:(UIEdgeInsets)insets forSize:(CGSize)size {
  insets.top += _inset.top;
  insets.right += _inset.right;
  insets.bottom += _inset.bottom;
  insets.left += _inset.left;
  if (self.next) {
    return [self.next addToInsets:insets forSize:size];
  } else {
    return insets;
  }
}

@end

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation TTPaddingStyle

@synthesize padding = _padding;

///////////////////////////////////////////////////////////////////////////////////////////////////
// NSObject

+ (TTPaddingStyle*)styleWithPadding:(UIEdgeInsets)padding next:(TTStyle*)next {
  TTPaddingStyle* style = [[[self alloc] initWithNext:next] autorelease];
  style.padding = padding;
  return style;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// NSObject

- (id)initWithNext:(TTStyle*)next {  
  if (self = [super initWithNext:next]) {
    _padding = UIEdgeInsetsZero;
  }
  return self;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// TTStyle

- (CGSize)addToSize:(CGSize)size delegate:(id<TTStyleDelegate>)delegate {
  size.width += _padding.left + _padding.right;
  size.height += _padding.top + _padding.bottom;

  if (_next) {
    return [self.next addToSize:size delegate:delegate];
  } else {
    return size;
  }
}

@end

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation TTTextStyle

@synthesize font = _font, color = _color, shadowColor = _shadowColor, shadowOffset = _shadowOffset,
            minimumFontSize = _minimumFontSize, textAlignment = _textAlignment,
            verticalAlignment = _verticalAlignment;

///////////////////////////////////////////////////////////////////////////////////////////////////
// class public

+ (TTTextStyle*)styleWithFont:(UIFont*)font next:(TTStyle*)next {
  TTTextStyle* style = [[[self alloc] initWithNext:next] autorelease];
  style.font = font;
  return style;
}

+ (TTTextStyle*)styleWithColor:(UIColor*)color next:(TTStyle*)next {
  TTTextStyle* style = [[[self alloc] initWithNext:next] autorelease];
  style.color = color;
  return style;
}

+ (TTTextStyle*)styleWithFont:(UIFont*)font color:(UIColor*)color next:(TTStyle*)next {
  TTTextStyle* style = [[[self alloc] initWithNext:next] autorelease];
  style.font = font;
  style.color = color;
  return style;
}

+ (TTTextStyle*)styleWithFont:(UIFont*)font color:(UIColor*)color
                shadowColor:(UIColor*)shadowColor shadowOffset:(CGSize)shadowOffset
                next:(TTStyle*)next {
  TTTextStyle* style = [[[self alloc] initWithNext:next] autorelease];
  style.font = font;
  style.color = color;
  style.shadowColor = shadowColor;
  style.shadowOffset = shadowOffset;
  return style;
}

+ (TTTextStyle*)styleWithFont:(UIFont*)font color:(UIColor*)color
                minimumFontSize:(CGFloat)minimumFontSize
                shadowColor:(UIColor*)shadowColor shadowOffset:(CGSize)shadowOffset
                next:(TTStyle*)next {
  TTTextStyle* style = [[[self alloc] initWithNext:next] autorelease];
  style.font = font;
  style.color = color;
  style.minimumFontSize = minimumFontSize;
  style.shadowColor = shadowColor;
  style.shadowOffset = shadowOffset;
  return style;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// private

- (CGRect)rectForText:(NSString*)text forSize:(CGSize)size withFont:(UIFont*)font {
  CGRect rect = CGRectZero;
  if (_textAlignment == UITextAlignmentLeft
      && _verticalAlignment == UIControlContentVerticalAlignmentTop) {
    rect.size = size;
  } else {
    CGSize textSize = [text sizeWithFont:font];

    if (size.width < textSize.width) {
      size.width = textSize.width;
    }
    
    rect.size = textSize;
    
    if (_textAlignment == UITextAlignmentCenter) {
      rect.origin.x = round(size.width/2 - textSize.width/2);
    } else if (_textAlignment == UITextAlignmentRight) {
      rect.origin.x = size.width - textSize.width;
    }

    if (_verticalAlignment == UIControlContentVerticalAlignmentCenter) {
      rect.origin.y = round(size.height/2 - textSize.height/2);
    } else if (_verticalAlignment == UIControlContentVerticalAlignmentBottom) {
      rect.origin.y = size.height - textSize.height;
    }
  }
  return rect;
}

- (void)drawText:(NSString*)text inRect:(CGRect)rect {
  CGContextRef context = UIGraphicsGetCurrentContext();
  CGContextSaveGState(context);

  if (_shadowColor) {
    CGSize offset = CGSizeMake(_shadowOffset.width, -_shadowOffset.height);
    CGContextSetShadowWithColor(context, offset, 0, _shadowColor.CGColor);
  }

  if (_color) {
    [_color setFill];
  }

  CGRect titleRect = [self rectForText:text forSize:rect.size withFont:_font];
  [text drawInRect:CGRectOffset(titleRect, rect.origin.x, rect.origin.y) withFont:_font];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// NSObject

- (id)initWithNext:(TTStyle*)next {  
  if (self = [super initWithNext:next]) {
    _font = nil;
    _color = nil;
    _minimumFontSize = 0;
    _shadowColor = nil;
    _shadowOffset = CGSizeZero;
    _textAlignment = UITextAlignmentCenter;
    _verticalAlignment = UIControlContentVerticalAlignmentCenter;
  }
  return self;
}

- (void)dealloc {
  [_font release];
  [_color release];
  [_shadowColor release];
  [super dealloc];
}
///////////////////////////////////////////////////////////////////////////////////////////////////
// TTStyle

- (BOOL)drawRect:(CGRect)rect shape:(TTShape*)shape delegate:(id<TTStyleDelegate>)delegate {
  BOOL handled = NO;
  
  if ([delegate respondsToSelector:@selector(textForLayerWithStyle:)]) {
    NSString* text = [delegate textForLayerWithStyle:self];
    if (text) {
      handled = YES;
      [self drawText:text inRect:rect];
    }
  }
  
  if (!handled && [delegate respondsToSelector:@selector(drawLayer:withStyle:shape:)]) {
    [delegate drawLayer:rect withStyle:self shape:shape];
    handled = YES;
  }
  
  [self.next drawRect:rect shape:shape delegate:delegate];
  return handled;
}

- (CGSize)addToSize:(CGSize)size delegate:(id<TTStyleDelegate>)delegate {
  if ([delegate respondsToSelector:@selector(textForLayerWithStyle:)]) {
    NSString* text = [delegate textForLayerWithStyle:self];
    CGSize textSize = [text sizeWithFont:_font];
    size.width += textSize.width;
    size.height += textSize.height;
  }
  
  if (_next) {
    return [self.next addToSize:size delegate:delegate];
  } else {
    return size;
  }
}

@end

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation TTImageStyle

@synthesize imageURL = _imageURL, image = _image, defaultImage = _defaultImage;

///////////////////////////////////////////////////////////////////////////////////////////////////
// class public

+ (TTImageStyle*)styleWithImageURL:(NSString*)imageURL next:(TTStyle*)next {
  TTImageStyle* style = [[[self alloc] initWithNext:next] autorelease];
  style.imageURL = imageURL;
  return style;
}

+ (TTImageStyle*)styleWithImageURL:(NSString*)imageURL defaultImage:(UIImage*)defaultImage
                 next:(TTStyle*)next {
  TTImageStyle* style = [[[self alloc] initWithNext:next] autorelease];
  style.imageURL = imageURL;
  style.defaultImage = defaultImage;
  return style;
}

+ (TTImageStyle*)styleWithImage:(UIImage*)image  next:(TTStyle*)next {
  TTImageStyle* style = [[[self alloc] initWithNext:next] autorelease];
  style.image = image;
  return style;
}

+ (TTImageStyle*)styleWithImage:(UIImage*)image defaultImage:(UIImage*)defaultImage
                 next:(TTStyle*)next {
  TTImageStyle* style = [[[self alloc] initWithNext:next] autorelease];
  style.image = image;
  style.defaultImage = defaultImage;
  return style;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// NSObject

- (id)initWithNext:(TTStyle*)next {  
  if (self = [super initWithNext:next]) {
    _imageURL = nil;
    _image = nil;
    _defaultImage = nil;
  }
  return self;
}

- (void)dealloc {
  [_imageURL release];
  [_image release];
  [_defaultImage release];
  [super dealloc];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// TTStyle

- (BOOL)drawRect:(CGRect)rect shape:(TTShape*)shape delegate:(id<TTStyleDelegate>)delegate {
  if (_image) {
    [_image drawInRect:rect];
  } else if (_defaultImage) {
    [_defaultImage drawInRect:rect];
  }
  return [self.next drawRect:rect shape:shape delegate:delegate];
}

- (CGSize)addToSize:(CGSize)size delegate:(id<TTStyleDelegate>)delegate {  
  UIImage* image = _image ? _image : _defaultImage;
  if (image) {
    size.width += image.size.width;
    size.height += image.size.height;
  }
  
  if (_next) {
    return [self.next addToSize:size delegate:delegate];
  } else {
    return size;
  }
}

@end

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation TTSolidFillStyle

@synthesize color = _color;

///////////////////////////////////////////////////////////////////////////////////////////////////
// class public

+ (TTSolidFillStyle*)styleWithColor:(UIColor*)color next:(TTStyle*)next {
  TTSolidFillStyle* style = [[[self alloc] initWithNext:next] autorelease];
  style.color = color;
  return style;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// NSObject

- (id)initWithNext:(TTStyle*)next {  
  if (self = [super initWithNext:next]) {
    _color = nil;
  }
  return self;
}

- (void)dealloc {
  [_color release];
  [super dealloc];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// TTStyle

- (BOOL)drawRect:(CGRect)rect shape:(TTShape*)shape delegate:(id<TTStyleDelegate>)delegate {
  CGContextRef context = UIGraphicsGetCurrentContext();

  CGContextSaveGState(context);
  [shape addToPath:rect];
  [_color setFill];
  CGContextFillPath(context);
  CGContextRestoreGState(context);

  return [self.next drawRect:rect shape:shape delegate:delegate];
}

@end

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation TTLinearGradientFillStyle

@synthesize color1 = _color1, color2 = _color2;

///////////////////////////////////////////////////////////////////////////////////////////////////
// class public

+ (TTLinearGradientFillStyle*)styleWithColor1:(UIColor*)color1 color2:(UIColor*)color2
                              next:(TTStyle*)next {
  TTLinearGradientFillStyle* style = [[[self alloc] initWithNext:next] autorelease];
  style.color1 = color1;
  style.color2 = color2;
  return style;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// NSObject

- (id)initWithNext:(TTStyle*)next {  
  if (self = [super initWithNext:next]) {
    _color1 = nil;
    _color2 = nil;
  }
  return self;
}

- (void)dealloc {
  [_color1 release];
  [_color2 release];
  [super dealloc];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// TTStyle

- (BOOL)drawRect:(CGRect)rect shape:(TTShape*)shape delegate:(id<TTStyleDelegate>)delegate {
  CGContextRef context = UIGraphicsGetCurrentContext();

  CGContextSaveGState(context);
  [shape addToPath:rect];
  CGContextClip(context);

  UIColor* colors[] = {_color1, _color2};
  CGGradientRef gradient = [self newGradientWithColors:colors count:2];
  CGContextDrawLinearGradient(context, gradient, CGPointMake(rect.origin.x, rect.origin.y),
    CGPointMake(rect.origin.x, rect.origin.y+rect.size.height), kCGGradientDrawsAfterEndLocation);
  CGGradientRelease(gradient);

  CGContextRestoreGState(context);

  return [self.next drawRect:rect shape:shape delegate:delegate];
}

@end

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation TTReflectiveFillStyle

@synthesize color = _color;

///////////////////////////////////////////////////////////////////////////////////////////////////
// class public

+ (TTReflectiveFillStyle*)styleWithColor:(UIColor*)color next:(TTStyle*)next {
  TTReflectiveFillStyle* style = [[[self alloc] initWithNext:next] autorelease];
  style.color = color;
  return style;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// NSObject

- (id)initWithNext:(TTStyle*)next {  
  if (self = [super initWithNext:next]) {
    _color = nil;
  }
  return self;
}

- (void)dealloc {
  [_color release];
  [super dealloc];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// TTStyle

- (BOOL)drawRect:(CGRect)rect shape:(TTShape*)shape delegate:(id<TTStyleDelegate>)delegate {
  CGContextRef context = UIGraphicsGetCurrentContext();

  CGContextSaveGState(context);
  [shape addToPath:rect];
  CGContextClip(context);

  [_color setFill];
  CGContextFillRect(context, rect);

  // XXjoe These numbers are totally biased towards the colors I tested with.  I need to figure out
  // a formula that works well for all colors
  UIColor* lighter = nil, *darker = nil;
  if (_color.value < 0.5) {
    lighter = HSVCOLOR(_color.hue, ZEROLIMIT(_color.saturation-0.5), ZEROLIMIT(_color.value+0.25));
    darker = HSVCOLOR(_color.hue, ZEROLIMIT(_color.saturation-0.1), ZEROLIMIT(_color.value+0.1));
  } else if (_color.saturation > 0.6) {
    lighter = HSVCOLOR(_color.hue, _color.saturation*0.3, _color.value*1);
    darker = HSVCOLOR(_color.hue, _color.saturation*0.9, _color.value+0.05);
  } else {
    lighter = HSVCOLOR(_color.hue, _color.saturation*0.4, _color.value*1.2);
    darker = HSVCOLOR(_color.hue, _color.saturation*0.9, _color.value+0.05);
  }
//  //UIColor* lighter = [_color multiplyHue:1 saturation:0.5 value:1.35];
//  //UIColor* darker = [_color multiplyHue:1 saturation:0.88 value:1.05];
  UIColor* colors[] = {lighter, darker};
  
  CGGradientRef gradient = [self newGradientWithColors:colors count:2];
  CGContextDrawLinearGradient(context, gradient, CGPointMake(rect.origin.x, rect.origin.y),
    CGPointMake(rect.origin.x, rect.origin.y+rect.size.height*0.5),
    kCGGradientDrawsBeforeStartLocation);
  CGGradientRelease(gradient);

  CGContextRestoreGState(context);

  return [self.next drawRect:rect shape:shape delegate:delegate];
}

@end

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation TTShadowStyle

@synthesize color = _color, blur = _blur, offset = _offset;

///////////////////////////////////////////////////////////////////////////////////////////////////
// class public

+ (TTShadowStyle*)styleWithColor:(UIColor*)color blur:(CGFloat)blur offset:(CGSize)offset
                  next:(TTStyle*)next {
  TTShadowStyle* style = [[[self alloc] initWithNext:next] autorelease];
  style.color = color;
  style.blur = blur;
  style.offset = offset;
  return style;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// NSObject

- (id)initWithNext:(TTStyle*)next {  
  if (self = [super initWithNext:next]) {
    _color = nil;
    _blur = 0;
    _offset = CGSizeZero;
  }
  return self;
}

- (void)dealloc {
  [_color release];
  [super dealloc];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// TTStyle

- (BOOL)drawRect:(CGRect)rect shape:(TTShape*)shape delegate:(id<TTStyleDelegate>)delegate {
  rect.size.width -= fabs(_offset.width);
  rect.size.height -= fabs(_offset.height);

  CGFloat blurSize = round(_blur / 2);

  if (_offset.width < 0) {
    rect.origin.x += -_offset.width;
    rect.size.width -= blurSize;
  } else if (_offset.width > 0) {
    rect.size.width -= blurSize;
  }
  if (_offset.height < 0) {
    rect.origin.y += -_offset.height;
    rect.size.height -= blurSize;
  } else if (_offset.height > 0) {
    rect.size.height -= blurSize;
  }

  CGContextRef context = UIGraphicsGetCurrentContext();

  CGContextSaveGState(context);
  [shape addToPath:rect];
  [_color setFill];
  CGContextSetShadowWithColor(context, CGSizeMake(_offset.width, -_offset.height), _blur,
                              _color.CGColor);
  CGContextFillPath(context);
  CGContextRestoreGState(context);
  
  return [self.next drawRect:rect shape:shape delegate:delegate];
}

- (CGSize)addToSize:(CGSize)size delegate:(id<TTStyleDelegate>)delegate {
  CGFloat blurSize = round(_blur / 2);
  size.width += _offset.width + (_offset.width ? blurSize : 0);
  size.height += _offset.height + (_offset.height ? blurSize : 0);
  
  if (_next) {
    return [self.next addToSize:size delegate:delegate];
  } else {
    return size;
  }
}
@end

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation TTInnerShadowStyle

///////////////////////////////////////////////////////////////////////////////////////////////////
// TTStyle

- (BOOL)drawRect:(CGRect)rect shape:(TTShape*)shape delegate:(id<TTStyleDelegate>)delegate {
  CGContextRef context = UIGraphicsGetCurrentContext();

  CGContextSaveGState(context);

  [shape addToPath:rect];
  CGContextClip(context);
  
  [shape addInverseToPath:rect];
  [[UIColor whiteColor] setFill];
  CGContextSetShadowWithColor(context, CGSizeMake(_offset.width, -_offset.height), _blur,
                              _color.CGColor);
  CGContextEOFillPath(context);
  CGContextRestoreGState(context);

  return [self.next drawRect:rect shape:shape delegate:delegate];
}

@end

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation TTSolidBorderStyle

@synthesize color = _color, width = _width;

///////////////////////////////////////////////////////////////////////////////////////////////////
// NSObject

+ (TTSolidBorderStyle*)styleWithColor:(UIColor*)color width:(CGFloat)width next:(TTStyle*)next {
  TTSolidBorderStyle* style = [[[self alloc] initWithNext:next] autorelease];
  style.color = color;
  style.width = width;
  return style;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// NSObject

- (id)initWithNext:(TTStyle*)next {  
  if (self = [super initWithNext:next]) {
    _color = nil;
    _width = 1;
  }
  return self;
}

- (void)dealloc {
  [_color release];
  [super dealloc];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// TTStyle

- (BOOL)drawRect:(CGRect)rect shape:(TTShape*)shape delegate:(id<TTStyleDelegate>)delegate {
  CGContextRef context = UIGraphicsGetCurrentContext();
  CGContextSaveGState(context);

  CGRect strokeRect = CGRectInset(rect, _width/2, _width/2);
  [shape addToPath:strokeRect];

  [_color setStroke];
  CGContextSetLineWidth(context, _width);
  CGContextStrokePath(context);

  CGContextRestoreGState(context);

  CGRect innerRect = CGRectInset(rect, _width, _width);
  return [self.next drawRect:innerRect shape:shape delegate:delegate];
}

@end

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation TTFourBorderStyle

@synthesize top = _top, right = _right, bottom = _bottom, left = _left, width = _width;

///////////////////////////////////////////////////////////////////////////////////////////////////
// NSObject

+ (TTFourBorderStyle*)styleWithTop:(UIColor*)top right:(UIColor*)right bottom:(UIColor*)bottom
                      left:(UIColor*)left width:(CGFloat)width next:(TTStyle*)next {
  TTFourBorderStyle* style = [[[self alloc] initWithNext:next] autorelease];
  style.top = top;
  style.right = right;
  style.bottom = bottom;
  style.left = left;
  style.width = width;
  return style;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// NSObject

- (id)initWithNext:(TTStyle*)next {  
  if (self = [super initWithNext:next]) {
    _top = nil;
    _right = nil;
    _bottom = nil;
    _left = nil;
    _width = 1;
  }
  return self;
}

- (void)dealloc {
  [_top release];
  [_right release];
  [_bottom release];
  [_left release];
  [super dealloc];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// TTStyle

- (BOOL)drawRect:(CGRect)rect shape:(TTShape*)shape delegate:(id<TTStyleDelegate>)delegate {
  CGRect strokeRect = CGRectInset(rect, _width/2, _width/2);
  [shape openPath:strokeRect];

  CGContextRef context = UIGraphicsGetCurrentContext();
  CGContextSetLineWidth(context, _width);

  [shape addTopEdgeToPath:strokeRect lightSource:kDefaultLightSource];
  if (_top) {
    [_top setStroke];
  } else {
    [[UIColor clearColor] setStroke];
  }
  CGContextStrokePath(context);
  
  [shape addRightEdgeToPath:strokeRect lightSource:kDefaultLightSource];
  if (_right) {
    [_right setStroke];
  } else {
    [[UIColor clearColor] setStroke];
  }
  CGContextStrokePath(context);
  
  [shape addBottomEdgeToPath:strokeRect lightSource:kDefaultLightSource];
  if (_bottom) {
    [_bottom setStroke];
  } else {
    [[UIColor clearColor] setStroke];
  }
  CGContextStrokePath(context);
  
  [shape addLeftEdgeToPath:strokeRect lightSource:kDefaultLightSource];
  if (_left) {
    [_left setStroke];
  } else {
    [[UIColor clearColor] setStroke];
  }
  CGContextStrokePath(context);
  
  CGContextRestoreGState(context);

  CGRect innerRect = CGRectMake(rect.origin.x + (_left ? _width : 0),
                                rect.origin.y + (_top ? _width : 0),
                                rect.size.width - ((_left ? _width : 0) + (_right ? _width : 0)),
                                rect.size.height - ((_top ? _width : 0) + (_bottom ? _width : 0)));
  return [self.next drawRect:innerRect shape:shape delegate:delegate];
}

@end

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation TTBevelBorderStyle

@synthesize highlight = _highlight, shadow = _shadow, width = _width, lightSource = _lightSource;

///////////////////////////////////////////////////////////////////////////////////////////////////
// NSObject

+ (TTBevelBorderStyle*)styleWithColor:(UIColor*)color width:(CGFloat)width next:(TTStyle*)next {
  return [self styleWithHighlight:[color highlight] shadow:[color shadow] width:width
               lightSource:kDefaultLightSource next:next];
}

+ (TTBevelBorderStyle*)styleWithHighlight:(UIColor*)highlight shadow:(UIColor*)shadow
                       width:(CGFloat)width lightSource:(NSInteger)lightSource next:(TTStyle*)next {
  TTBevelBorderStyle* style = [[[TTBevelBorderStyle alloc] initWithNext:next] autorelease];
  style.highlight = highlight;
  style.shadow = shadow;
  style.width = width;
  style.lightSource = lightSource;
  return style;  
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// NSObject

- (id)initWithNext:(TTStyle*)next {  
  if (self = [super initWithNext:next]) {
    _highlight = nil;
    _shadow = nil;
    _width = 1;
    _lightSource = kDefaultLightSource;
  }
  return self;
}

- (void)dealloc {
  [_highlight release];
  [_shadow release];
  [super dealloc];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// TTStyle

- (BOOL)drawRect:(CGRect)rect shape:(TTShape*)shape delegate:(id<TTStyleDelegate>)delegate {
  CGRect strokeRect = CGRectInset(rect, _width/2, _width/2);
  [shape openPath:strokeRect];

  CGContextRef context = UIGraphicsGetCurrentContext();
  CGContextSetLineWidth(context, _width);

  UIColor* topColor = _lightSource >= 0 && _lightSource <= 180 ? _highlight : _shadow;
  UIColor* leftColor = _lightSource >= 90 && _lightSource <= 270
                        ? _highlight : _shadow;
  UIColor* bottomColor = _lightSource >= 180 && _lightSource <= 360 || _lightSource == 0
                         ? _highlight : _shadow;
  UIColor* rightColor = (_lightSource >= 270 && _lightSource <= 360)
                       || (_lightSource >= 0 && _lightSource <= 90)
                       ? _highlight : _shadow;

  CGRect innerRect = rect;

  [shape addTopEdgeToPath:strokeRect lightSource:_lightSource];
  if (topColor) {
    [topColor setStroke];

    innerRect.origin.y += _width;
    innerRect.size.height -= _width;
  } else {
    [[UIColor clearColor] setStroke];
  }
  CGContextStrokePath(context);

  [shape addRightEdgeToPath:strokeRect lightSource:_lightSource];
  if (rightColor) {
    [rightColor setStroke];

    innerRect.size.width -= _width;
  } else {
    [[UIColor clearColor] setStroke];
  }
  CGContextStrokePath(context);
  
  [shape addBottomEdgeToPath:strokeRect lightSource:_lightSource];
  if (bottomColor) {
    [bottomColor setStroke];

    innerRect.size.height -= _width;
  } else {
    [[UIColor clearColor] setStroke];
  }
  CGContextStrokePath(context);
  
  [shape addLeftEdgeToPath:strokeRect lightSource:_lightSource];
  if (leftColor) {
    [leftColor setStroke];

    innerRect.origin.x += _width;
    innerRect.size.width -= _width;
  } else {
    [[UIColor clearColor] setStroke];
  }
  CGContextStrokePath(context);
  
  CGContextRestoreGState(context);

  return [self.next drawRect:innerRect shape:shape delegate:delegate];
}

@end
