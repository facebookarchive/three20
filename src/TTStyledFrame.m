#import "Three20/TTStyledFrame.h"
#import "Three20/TTStyledNode.h"
#import "Three20/TTDefaultStyleSheet.h"

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation TTStyledFrame

@synthesize element = _element, nextFrame = _nextFrame, style = _style, bounds = _bounds;

///////////////////////////////////////////////////////////////////////////////////////////////////
// NSObject

- (id)initWithElement:(TTStyledElement*)element {
  if (self = [super init]) {
    _element = element;
    _nextFrame = nil;
    _style = nil;
    _bounds = CGRectZero;
  }
  return self;
}

- (void)dealloc {
  [_nextFrame release];
  [_style release];
  [super dealloc];
}

- (NSString*)description {
  NSMutableString* string = [NSMutableString string];
//  TTStyledFrame* frame = self;
//  while (frame) {
//    [string appendFormat:@"%@ (%d)\n", frame.text, frame.lineBreak];
//    frame = frame.nextFrame;
//  }
  return string;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// public

- (CGFloat)x {
  return _bounds.origin.x;
}

- (void)setX:(CGFloat)x {
  _bounds.origin.x = x;
}

- (CGFloat)y {
  return _bounds.origin.y;
}

- (void)setY:(CGFloat)y {
  _bounds.origin.y = y;
}

- (CGFloat)width {
  return _bounds.size.width;
}

- (void)setWidth:(CGFloat)width {
  _bounds.size.width = width;
}

- (CGFloat)height {
  return _bounds.size.height;
}

- (void)setHeight:(CGFloat)height {
  _bounds.size.height = height;
}

- (void)drawInRect:(CGRect)rect {
  if (_style) {
    TTStyleContext* context = [[[TTStyleContext alloc] init] autorelease];
    context.frame = rect;
    context.contentFrame = rect;

    [_style draw:context];
  }
}

@end

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation TTStyledTextFrame

@synthesize node = _node, text = _text, font = _font;

///////////////////////////////////////////////////////////////////////////////////////////////////
// NSObject

- (id)initWithText:(NSString*)text element:(TTStyledElement*)element node:(TTStyledTextNode*)node {
  if (self = [super initWithElement:element]) {
    _text = [text retain];
    _node = node;
    _font = nil;
  }
  return self;
}

- (void)dealloc {
  [_text release];
  [_font release];
  [super dealloc];
}

- (NSString*)description {
  NSMutableString* string = [NSMutableString string];
//  TTStyledFrame* frame = self;
//  while (frame) {
//    [string appendFormat:@"%@ (%d)\n", frame.text, frame.lineBreak];
//    frame = frame.nextFrame;
//  }
  return string;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// TTStyleDelegate

- (void)drawLayer:(TTStyleContext*)context withStyle:(TTStyle*)style {
  CGRect rect = context.frame;
  if ([style isKindOfClass:[TTTextStyle class]]) {
    TTTextStyle* textStyle = (TTTextStyle*)style;
    UIFont* font = textStyle.font ? textStyle.font : _font;
    if (textStyle.color) {
      CGContextRef context = UIGraphicsGetCurrentContext();
      CGContextSaveGState(context);
      [textStyle.color setFill];
      [_text drawInRect:rect withFont:font];
      CGContextRestoreGState(context);
    } else {
      [_text drawInRect:rect withFont:font];
    }
  } else {
    [_text drawInRect:rect withFont:_font];
  }
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// public

- (void)drawInRect:(CGRect)rect {
  TTStyleContext* context = [[[TTStyleContext alloc] init] autorelease];
  context.delegate = self;
  context.frame = rect;
  context.contentFrame = rect;

  if ([_element isKindOfClass:[TTStyledLinkNode class]] && [(TTStyledLinkNode*)_element highlighted]) {
    TTStyle* style = TTSTYLE(linkTextHighlighted);
    [style draw:context];
  } else {
    if (_style) {
      [_style draw:context];
      if (context.didDrawContent) {
        return;
      }
    }
    [_text drawInRect:rect withFont:_font];
  }
}

@end

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation TTStyledImageFrame

@synthesize imageNode = _imageNode;

///////////////////////////////////////////////////////////////////////////////////////////////////
// NSObject

- (id)initWithElement:(TTStyledElement*)element node:(TTStyledImageNode*)node {
  if (self = [super initWithElement:element]) {
    _imageNode = node;
  }
  return self;
}

- (void)dealloc {
  [super dealloc];
}

- (NSString*)description {
  NSMutableString* string = [NSMutableString string];
//  TTStyledFrame* frame = self;
//  while (frame) {
//    [string appendFormat:@"%@ (%d)\n", frame.text, frame.lineBreak];
//    frame = frame.nextFrame;
//  }
  return string;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// TTStyleDelegate

- (void)drawLayer:(TTStyleContext*)context withStyle:(TTStyle*)style {
  [_imageNode.image drawInRect:context.frame];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// public

- (void)drawInRect:(CGRect)rect {
  if (_style) {
    TTStyleContext* context = [[[TTStyleContext alloc] init] autorelease];
    context.delegate = self;
    context.frame = rect;
    context.contentFrame = rect;

    [_style draw:context];
    if (context.didDrawContent) {
      return;
    }
  }
  [_imageNode.image drawInRect:rect];
}

@end
