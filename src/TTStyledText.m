#import "Three20/TTStyledText.h"
#import "Three20/TTStyledNode.h"
#import "Three20/TTStyledFrame.h"
#import "Three20/TTStyledLayout.h"
#import "Three20/TTStyledTextParser.h"

//////////////////////////////////////////////////////////////////////////////////////////////////

@implementation TTStyledText

@synthesize rootNode = _rootNode, font = _font, width = _width, height = _height;

//////////////////////////////////////////////////////////////////////////////////////////////////
// class public

+ (TTStyledText*)textFromXHTML:(NSString*)source {
  return [self textFromXHTML:source lineBreaks:NO urls:YES];
}

+ (TTStyledText*)textFromXHTML:(NSString*)source lineBreaks:(BOOL)lineBreaks urls:(BOOL)urls {
  TTStyledTextParser* parser = [[[TTStyledTextParser alloc] init] autorelease];
  parser.parseLineBreaks = lineBreaks;
  parser.parseURLs = urls;
  [parser parseXHTML:source];
  if (parser.rootNode) {
    return [[[TTStyledText alloc] initWithNode:parser.rootNode] autorelease];
  } else {
    return nil;
  }
}

+ (TTStyledText*)textWithURLs:(NSString*)source {
  return [self textWithURLs:source lineBreaks:NO];
}

+ (TTStyledText*)textWithURLs:(NSString*)source lineBreaks:(BOOL)lineBreaks {
  TTStyledTextParser* parser = [[[TTStyledTextParser alloc] init] autorelease];
  parser.parseLineBreaks = lineBreaks;
  parser.parseURLs = YES;
  [parser parseText:source];
  if (parser.rootNode) {
    return [[[TTStyledText alloc] initWithNode:parser.rootNode] autorelease];
  } else {
    return nil;
  }
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// NSObject

- (id)initWithNode:(TTStyledNode*)rootNode {
  if (self = [super init]) {
    _rootNode = [rootNode retain];
    _rootFrame = nil;
    _font = nil;
    _width = 0;
    _height = 0;
  }
  return self;
}

- (void)dealloc {
  [_rootNode release];
  [_rootFrame release];
  [_font release];
  [super dealloc];
}

- (NSString*)description {
  return [self.rootFrame description];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// public

- (TTStyledFrame*)rootFrame {
  [self layoutIfNeeded];
  return _rootFrame;
}

- (void)setFont:(UIFont*)font {
  if (font != _font) {
    [_font release];
    _font = [font retain];
    [self setNeedsLayout];
  }
}

- (void)setWidth:(CGFloat)width {
  if (width != _width) {
    _width = width;
    [self setNeedsLayout];
  }
}

- (CGFloat)height {
  [self layoutIfNeeded];
  return _height;
}

- (void)layoutFrames {
  TTStyledLayout* ctx = [[TTStyledLayout alloc] initWithRootNode:_rootNode];
  ctx.font = _font;
  ctx.maxWidth = _width;
  
  [ctx layout:_rootNode];
  
  _rootFrame = [ctx.rootFrame retain];
  _height = ceil(ctx.height);
  [ctx release];
}

- (void)layoutIfNeeded {
  if (!_rootFrame) {
    [self layoutFrames];
  }
}

- (void)setNeedsLayout {
  [_rootFrame release];
  _rootFrame = nil;
  _height = 0;
}

- (void)drawAtPoint:(CGPoint)point {
  [self drawAtPoint:point highlighted:NO];
}

- (void)drawAtPoint:(CGPoint)point highlighted:(BOOL)highlighted {
  CGContextRef ctx = UIGraphicsGetCurrentContext();
  CGContextSaveGState(ctx);
  CGContextTranslateCTM(ctx, point.x, point.y);

  TTStyledFrame* frame = self.rootFrame;
  while (frame) {
    [frame drawInRect:frame.bounds];
    frame = frame.nextFrame;
  }

  CGContextRestoreGState(ctx);
}

- (TTStyledBoxFrame*)hitTest:(CGPoint)point {
  return [self.rootFrame hitTest:point];
}

- (void)addChild:(TTStyledNode*)child {
  if (!_rootNode) {
    self.rootNode = child;
  } else {
    TTStyledNode* previousNode = _rootNode;
    TTStyledNode* node = _rootNode.nextSibling;
    while (node) {
      previousNode = node;
      node = node.nextSibling;
    }
    previousNode.nextSibling = child;
  }
}

- (void)insertChild:(TTStyledNode*)child atIndex:(NSInteger)index {
  if (!_rootNode) {
    self.rootNode = child;
  } else if (index == 0) {
    child.nextSibling = _rootNode;
    self.rootNode = child;
  } else {
    NSInteger i = 0;
    TTStyledNode* previousNode = _rootNode;
    TTStyledNode* node = _rootNode.nextSibling;
    while (node && i != index) {
      ++i;
      previousNode = node;
      node = node.nextSibling;
    }
    child.nextSibling = node;
    previousNode.nextSibling = child;
  }
}

@end
