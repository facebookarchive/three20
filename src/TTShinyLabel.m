#import "Three20/TTShinyLabel.h"

@implementation TTShinyLabel

@synthesize text, font, textColor, spotlightColor, textAlignment;

- (id)initWithFrame:(CGRect)frame {
	if (self = [super initWithFrame:frame]) {
    timer = nil;
    
    self.text = @"";
    self.font = [UIFont systemFontOfSize:14];
    self.textColor = [UIColor colorWithWhite:0.25 alpha:1];
    self.spotlightColor = [UIColor whiteColor];
    self.textAlignment = UITextAlignmentLeft;
    self.backgroundColor = [UIColor clearColor];
    self.contentMode = UIViewContentModeCenter;
	}
	return self;
}

- (void)dealloc {
  [self stopAnimating];
  [text release];
  [font release];
  [textColor release];
  [spotlightColor release];
	[super dealloc];
}

//////////////////////////////////////////////////////////////////////////////////////////////////

- (void)createMask {
  CGRect rect = self.frame;
  CGColorSpaceRef space = CGColorSpaceCreateDeviceRGB();
  int bitmapBytesPerRow = (rect.size.width * 4);
  int bitmapByteCount = (bitmapBytesPerRow * rect.size.height);
  maskData = malloc(bitmapByteCount);
  maskContext = CGBitmapContextCreate(maskData, rect.size.width, rect.size.height,
                          8, bitmapBytesPerRow, space, kCGImageAlphaPremultipliedLast);
  CGColorSpaceRelease(space);
}

- (void)releaseMask {
  CGContextRelease(maskContext);
  free(maskData);
  maskContext = nil;
  maskData = nil;
}

- (CGImageRef)createShinyMask:(CGRect)rect origin:(CGPoint)origin radius:(CGFloat)radius {
  CGContextClearRect(maskContext, rect);

  CGColorSpaceRef space = CGColorSpaceCreateDeviceRGB();
  CGFloat components[] = {1, 1, 1, 1, 0, 0, 0, 0};
  CGFloat locations[] = {0, 1};
  CGGradientRef gradient = CGGradientCreateWithColorComponents(space, components, locations, 2);
  CGContextDrawRadialGradient(maskContext, gradient, origin, 0, origin, radius, 0);
  CGGradientRelease(gradient);
  CGColorSpaceRelease(space);

  return CGBitmapContextCreateImage(maskContext);
}

- (void)updateShiny {
  spotlightPoint += 1.3/32;
  if (spotlightPoint > 2) {
    spotlightPoint = -0.5;
  }
  if (spotlightPoint <= 1.5) {
    [self setNeedsDisplay];
  }
}

//////////////////////////////////////////////////////////////////////////////////////////////////
// UIView

- (void)drawRect:(CGRect)rect {
  CGContextRef context = UIGraphicsGetCurrentContext();

  CGSize textSize = [self sizeThatFits:CGSizeZero];
  
  CGFloat x = 0;
  if (textAlignment == UITextAlignmentRight) {
    x = self.frame.size.width - textSize.width;
  } else if (textAlignment == UITextAlignmentCenter) {
    x = ceil(self.frame.size.width/2 - textSize.width/2);
  }
  
  CGFloat y = 0;
  if (self.contentMode == UIViewContentModeCenter) {
    y = ceil(rect.size.height/2 + font.capHeight/2);
  } else if (self.contentMode == UIViewContentModeBottom) {
    y = rect.size.height + font.descender;
  } else {
    y = font.capHeight;
  }
  
  CGContextSelectFont(context, [font.fontName UTF8String], font.pointSize, kCGEncodingMacRoman);
  CGContextSetTextDrawingMode(context, kCGTextFill);
  CGContextSetTextMatrix(context, CGAffineTransformScale(CGAffineTransformIdentity, 1, -1));

  CGContextSetFillColorWithColor(context, textColor.CGColor);
  CGContextShowTextAtPoint(context, x, y, [self.text UTF8String], self.text.length);

  if (timer) {
    CGPoint spotOrigin = CGPointMake(x + (textSize.width * spotlightPoint),
      y - ceil(self.font.capHeight/2));
    CGFloat spotRadius = self.font.capHeight*2;

    CGImageRef mask = [self createShinyMask:rect origin:spotOrigin radius:spotRadius];
    CGContextClipToMask(context, rect, mask);
    CGImageRelease(mask);
    
    CGContextSetFillColorWithColor(context, spotlightColor.CGColor);
    CGContextShowTextAtPoint(context, x, y, [self.text UTF8String], self.text.length);
  }
}

- (CGSize)sizeThatFits:(CGSize)size {
  return [self.text sizeWithFont:self.font constrainedToSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX)];
}

//////////////////////////////////////////////////////////////////////////////////////////////////

- (void)startAnimating {
  if (!timer) {
    timer = [NSTimer scheduledTimerWithTimeInterval:1.0/32 target:self
      selector:@selector(updateShiny) userInfo:nil repeats:YES];
    spotlightPoint = -0.5;
    [self createMask];
  }
}

- (void)stopAnimating {
  if (timer) {
    [timer invalidate];
    timer = nil;
    [self releaseMask];
  }
}

@end
