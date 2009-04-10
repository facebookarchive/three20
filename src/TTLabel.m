#import "Three20/TTLabel.h"
#import "Three20/TTDefaultStyleSheet.h"

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation TTLabel

@synthesize font = _font, text = _text;

///////////////////////////////////////////////////////////////////////////////////////////////////
// NSObject

- (id)initWithText:(NSString*)text {
  if (self = [self initWithFrame:CGRectZero]) {
    self.text = text;
  }
  return self;
}

- (id)initWithFrame:(CGRect)frame {
  if (self = [super initWithFrame:frame]) {
    _text = nil;
    _font = nil;
  }
  return self;
}

- (void)dealloc {
  [_text release];
  [_font release];
  [super dealloc];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// UIView

- (void)drawRect:(CGRect)rect {
  TTStyleContext* context = [[[TTStyleContext alloc] init] autorelease];
  context.delegate = self;
  context.frame = rect;
  context.contentFrame = rect;
  context.font = _font;

  if (![self.style draw:context]) {
    [self drawContent:rect];
  }
}

- (CGSize)sizeThatFits:(CGSize)size {
  TTStyleContext* context = [[[TTStyleContext alloc] init] autorelease];
  context.delegate = self;
  context.font = _font;
  return [_style addToSize:CGSizeZero context:context];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// TTStyleDelegate

- (NSString*)textForLayerWithStyle:(TTStyle*)style {
  return self.text;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// public

- (UIFont*)font {
  if (!_font) {
    _font = [TTSTYLEVAR(defaultFont) retain];
  }
  return _font;
}

- (void)setFont:(UIFont*)font {
  if (font != _font) {
    [_font release];
    _font = [font retain];
    [self setNeedsDisplay];
  }
}

- (void)setText:(NSString*)text {
  if (text != _text) {
    [_text release];
    _text = [text copy];
    [self setNeedsDisplay];
  }
}

@end
