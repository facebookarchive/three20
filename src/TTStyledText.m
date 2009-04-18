#import "Three20/TTStyledText.h"
#import "Three20/TTStyledNode.h"
#import "Three20/TTStyledTextParser.h"
#import "Three20/TTStyle.h"
#import "Three20/TTDefaultStyleSheet.h"

//////////////////////////////////////////////////////////////////////////////////////////////////

@interface TTLayoutContext : NSObject {
  CGFloat _width;
  CGFloat _height;
  CGFloat _lineWidth;
  CGFloat _lineHeight;
  NSMutableArray* _styleStack;
  TTStyle* _lastStyle;
  TTStyledTextFrame* _rootFrame;
  TTStyledTextFrame* _lastFrame;
  UIFont* _baseFont;
  UIFont* _font;
  UIFont* _boldFont;
  UIFont* _italicFont;
  TTStyle* _linkStyle;
  TTStyledNode* _rootNode;
  TTStyledNode* _lastNode;
  BOOL _lineBreak;
}

@property(nonatomic) CGFloat width;
@property(nonatomic) CGFloat height;
@property(nonatomic) CGFloat lineWidth;
@property(nonatomic) CGFloat lineHeight;
@property(nonatomic,readonly) CGFloat fontHeight;
@property(nonatomic,readonly) NSMutableArray* styleStack;
@property(nonatomic,assign) TTStyle* lastStyle;
@property(nonatomic,assign) TTStyledTextFrame* rootFrame;
@property(nonatomic,assign) TTStyledTextFrame* lastFrame;
@property(nonatomic,retain) UIFont* baseFont;
@property(nonatomic,retain) UIFont* font;
@property(nonatomic,retain) UIFont* boldFont;
@property(nonatomic,retain) UIFont* italicFont;
@property(nonatomic,retain) TTStyle* linkStyle;
@property(nonatomic,readonly) TTStyledNode* lastNode;
@property(nonatomic) BOOL lineBreak;

- (id)initWithRootNode:(TTStyledNode*)rootNode;

@end

@implementation TTLayoutContext

@synthesize width = _width, height = _height, lineWidth = _lineWidth, lineHeight = _lineHeight,
            lastStyle = _lastStyle, rootFrame = _rootFrame, lastFrame = _lastFrame,
            baseFont = _baseFont, font = _font, boldFont = _boldFont, italicFont = _italicFont,
            linkStyle = _linkStyle, lineBreak = _lineBreak; 

//////////////////////////////////////////////////////////////////////////////////////////////////
// private

- (UIFont*)boldVersionOfFont:(UIFont*)font {
  // XXXjoe Clearly this doesn't work if your font is not the system font
  return [UIFont boldSystemFontOfSize:font.pointSize];
}

- (UIFont*)italicVersionOfFont:(UIFont*)font {
  // XXXjoe Clearly this doesn't work if your font is not the system font
  return [UIFont italicSystemFontOfSize:font.pointSize];
}

- (TTStyledNode*)findLastNode:(TTStyledNode*)node {
  TTStyledNode* lastNode = nil;
  while (node) {
    if ([node isKindOfClass:[TTStyledElement class]]) {
      TTStyledElement* element = (TTStyledElement*)node;
      lastNode = [self findLastNode:element.firstChild];
    } else {
      lastNode = node;
    }
    node = node.nextSibling;
  }
  return lastNode;
}

//////////////////////////////////////////////////////////////////////////////////////////////////
// NSObject

- (id)initWithRootNode:(TTStyledNode*)rootNode {
  if (self = [self init]) {
    _rootNode = rootNode;
  }
  return self;
}

- (id)init {
  if (self = [super init]) {
    _width = 0;
    _height = 0;
    _lineWidth = 0;
    _lineHeight = 0;
    _styleStack = nil;
    _lastStyle = nil;
    _rootFrame = nil;
    _lastFrame = nil;
    _baseFont = nil;
    _font = nil;
    _boldFont = nil;
    _italicFont = nil;
    _linkStyle = nil;
    _rootNode = nil;
    _lastNode = nil;
    _lineBreak = NO;
  }
  return self;
}

- (void)dealloc {
  [_rootFrame release];
  [_baseFont release];
  [_font release];
  [_boldFont release];
  [_italicFont release];
  [_linkStyle release];
  [super dealloc];
}

- (NSMutableArray*)styleStack {
  if (!_styleStack) {
    _styleStack = [[NSMutableArray alloc] init];
  }
  return _styleStack;
}

- (UIFont*)baseFont {
  if (!_baseFont) {
    self.baseFont = TTSTYLEVAR(font);
  }
  return _baseFont;
}

- (UIFont*)boldFont {
  if (!_boldFont) {
    self.boldFont = [self boldVersionOfFont:self.baseFont];
  }
  return _boldFont;
}

- (UIFont*)italicFont {
  if (!_italicFont) {
    self.italicFont = [self italicVersionOfFont:self.baseFont];
  }
  return _italicFont;
}

- (TTStyle*)linkStyle {
  if (!_linkStyle) {
    self.linkStyle = TTSTYLE(linkText);
  }
  return _linkStyle;
}

- (TTStyledNode*)lastNode {
  if (!_lastNode) {
    _lastNode = [self findLastNode:_rootNode];
  }
  return _lastNode;
}

- (CGFloat)fontHeight {
  return self.font.ascender - self.font.descender;
}

- (TTStyledTextFrame*)addFrameForText:(NSString*)text element:(TTStyledElement*)element
                      node:(TTStyledNode*)node width:(CGFloat)width height:(CGFloat)height {
  TTStyledTextFrame* frame = [[[TTStyledTextFrame alloc] initWithText:text element:element
                                                         node:node] autorelease];
  frame.style = self.lastStyle;
  frame.font = self.font;
  frame.width = width;
  frame.height = height;
  if (!_rootFrame) {
    _rootFrame = [frame retain];
  } else {
    _lastFrame.nextFrame = frame;
  }
  _lastFrame = frame;
  _lineBreak = NO;
  return frame;
}
@end

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
  TTStyledTextParser* parser = [[[TTStyledTextParser alloc] init] autorelease];
  [parser parseURLs:source];
  if (parser.rootNode) {
    return [[[TTStyledText alloc] initWithNode:parser.rootNode] autorelease];
  } else {
    return nil;
  }
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// private

- (void)layoutElement:(TTStyledNode*)node element:(TTStyledElement*)element
        context:(TTLayoutContext*)ctx {
  NSCharacterSet* whitespace = [NSCharacterSet whitespaceAndNewlineCharacterSet];

  while (node) {
    if ([node isKindOfClass:[TTStyledElement class]]) {
      TTStyledElement* elt = (TTStyledElement*)node;

      TTStyle* style = nil;
      if ([node isKindOfClass:[TTStyledElement class]]) {
        if ([node isKindOfClass:[TTStyledLinkNode class]]) {
          style = ctx.linkStyle;
        }
        TTStyle* eltStyle = [[TTStyleSheet globalStyleSheet] styleWithSelector:elt.className];
        if (eltStyle) {
          style = eltStyle;
        }
      }

      // Figure out which font to use for the node
      // XXXjoe Do this lazily when asked for font
      UIFont* font = ctx.baseFont;
      if ([node isKindOfClass:[TTStyledLinkNode class]]
          || [node isKindOfClass:[TTStyledBoldNode class]]) {
        font = ctx.boldFont;
      } else if ([node isKindOfClass:[TTStyledItalicNode class]]) {
        font = ctx.italicFont;
      }

      BOOL isBlock = [node isKindOfClass:[TTStyledBlock class]];
      if (ctx.lastFrame && isBlock) {
        ctx.lineBreak = NO;
        ctx.lastFrame.lineBreak = YES;
        if (!ctx.lineWidth) {
          ctx.lastFrame.height = ctx.fontHeight;
          ctx.height += ctx.lastFrame.height;
        }
        ctx.lineWidth = 0;
        
        TTStyledBlock* block = (TTStyledBlock*)node;
        if (!block.firstChild) {
          [ctx addFrameForText:nil element:element node:node width:0 height:0];
        }
      }
        
      UIFont* lastFont = ctx.font;
      TTStyle* lastStyle = ctx.lastStyle;
      ctx.font = font;
      ctx.lastStyle = style;
      [self layoutElement:elt.firstChild element:elt context:ctx];
      ctx.font = lastFont;
      ctx.lastStyle = lastStyle;
      
      if (isBlock) {
        ctx.lineBreak = YES;
        ctx.lineWidth = 0;
      }
    } else if ([node isKindOfClass:[TTStyledImageNode class]]) {
      UIImage* image = [(TTStyledImageNode*)node image];

      if (ctx.lineWidth + image.size.width > _width) {
        // The image will be placed on the next line, so create a new frame for
        // the current line and mark it with a line break
        ctx.lastFrame.lineBreak = YES;
        ctx.lineBreak = NO;
        ctx.lineWidth = 0;
      }

      [ctx addFrameForText:nil element:element node:node width:image.size.width
           height:ctx.font.ascender];
      if (!ctx.lineWidth) {
          ctx.height += ctx.lastFrame.height;
      }
      ctx.lineWidth += image.size.width;
    } else if ([node isKindOfClass:[TTStyledTextNode class]]) {
      TTStyledTextNode* textNode = (TTStyledTextNode*)node;
      NSString* text = textNode.text;
      NSUInteger length = text.length;
              
      if (!node.nextSibling && node == _rootNode) {
        // This is the only node, so measure it all at once and move on
        CGSize textSize = [text sizeWithFont:ctx.font
                                constrainedToSize:CGSizeMake(_width, CGFLOAT_MAX)
                                lineBreakMode:UILineBreakModeWordWrap];
        [ctx addFrameForText:text element:element node:node width:textSize.width
             height:textSize.height];
        ctx.height += textSize.height;
        break;
      }

      NSInteger index = 0;
      NSInteger lineStartIndex = 0;
      CGFloat frameWidth = 0;
            
      while (index < length) {
        // Search for the next whitespace character
        NSRange searchRange = NSMakeRange(index, length - index);
        NSRange spaceRange = [text rangeOfCharacterFromSet:whitespace options:0 range:searchRange];

        // Get the word prior to the whitespace
        NSRange wordRange = spaceRange.location != NSNotFound
          ? NSMakeRange(searchRange.location, (spaceRange.location+1) - searchRange.location)
          : NSMakeRange(searchRange.location, length - searchRange.location);
        NSString* word = [text substringWithRange:wordRange];

        // Measure the word and check to see if it fits on the current line
        CGSize wordSize = [word sizeWithFont:ctx.font
                                constrainedToSize:CGSizeMake(_width, CGFLOAT_MAX)
                                lineBreakMode:UILineBreakModeWordWrap];
        if (ctx.lineWidth + wordSize.width > _width || ctx.lineBreak) {
          // The word will be placed on the next line, so create a new frame for
          // the current line and mark it with a line break
          NSRange lineRange = NSMakeRange(lineStartIndex, index - lineStartIndex);
          if (lineRange.length) {
            NSString* line = [text substringWithRange:lineRange];
            [ctx addFrameForText:line element:element node:node width:frameWidth
                 height:ctx.fontHeight];
          }
          
          ctx.lastFrame.lineBreak = YES;
          ctx.lineBreak = NO;
          lineStartIndex = lineRange.location + lineRange.length;
          frameWidth = 0;
          ctx.lineWidth = 0;
        }

        if (!ctx.lineWidth) {
          // We are at the start of a new line
          if (node != ctx.lastNode) {
            // Count the height of the new line
            ctx.height += wordSize.height;

            if (wordSize.width > _width) {
              // The word is larger than an entire line, so we need to split it across lines
              // XXXjoe TODO
            }
          } else {
            // This is the last node, so we don't need to keep measuring every word.  We
            // can just measure all remaining text and create a new frame for all of it.
            NSString* lines = [text substringWithRange:searchRange];
            CGSize linesSize = [lines sizeWithFont:ctx.font
                                      constrainedToSize:CGSizeMake(_width, CGFLOAT_MAX)
                                      lineBreakMode:UILineBreakModeWordWrap];

            [ctx addFrameForText:lines element:element node:node width:linesSize.width
                 height:linesSize.height];
            ctx.height += linesSize.height;
            break;
          }
        }
        
        frameWidth += wordSize.width;
        ctx.lineWidth += wordSize.width;
        index = wordRange.location + wordRange.length;

        if (index >= length) {
          // The current word was at the very end of the string
          NSRange lineRange = NSMakeRange(lineStartIndex, (wordRange.location + wordRange.length)
                                                          - lineStartIndex);
          NSString* line = !ctx.lineWidth ? word : [text substringWithRange:lineRange];
          [ctx addFrameForText:line element:element node:node width:frameWidth
               height:wordSize.height];
          frameWidth = 0;
        }
      }
    }
    
    node = node.nextSibling;
  }
}

- (void)layoutFrames {
  //TTLOG(@"LAYOUT! %@", [NSDate date]);
  TTLayoutContext* ctx = [[TTLayoutContext alloc] initWithRootNode:_rootNode];
  ctx.baseFont = ctx.font = _font;
  
  [self layoutElement:_rootNode element:nil context:ctx];
  _rootFrame = [ctx.rootFrame retain];
  _height = ceil(ctx.height);
  [ctx release];
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

- (TTStyledTextFrame*)rootFrame {
  if (!_rootFrame) {
    [self layoutFrames];
  }
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
  self.rootFrame;
  return _height;
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
  CGPoint origin = point;
  TTStyledTextFrame* frame = self.rootFrame;
  
  while (frame) {
    CGRect frameRect = CGRectMake(origin.x, origin.y, frame.width, frame.height);
    if ([frame.node isKindOfClass:[TTStyledImageNode class]]) {
      TTStyledImageNode* imageNode = (TTStyledImageNode*)frame.node;
      UIImage* image = imageNode.image;
      CGRect imageRect = CGRectMake(origin.x, (origin.y+frame.height)-image.size.height,
                                    image.size.width, image.size.height);
      [imageNode.image drawInRect:imageRect];
    } else {
      [frame drawInRect:frameRect];
    }

    origin.x += frame.width;
    if (frame.lineBreak) {
      origin.x = point.x;
      origin.y += frame.height;
    }
    
    frame = frame.nextFrame;
  }
}

- (TTStyledTextFrame*)hitTest:(CGPoint)point {
  CGPoint origin = CGPointMake(0, 0);
  TTStyledTextFrame* frame = self.rootFrame;
  while (frame) {
    CGRect rect = CGRectMake(origin.x, origin.y, frame.width, frame.height);
    if (CGRectContainsPoint(rect, point)) {
      return frame;
    }
    
    origin.x += frame.width;
    if (frame.lineBreak) {
      origin.x = 0;
      origin.y += frame.height;
    }
    
    frame = frame.nextFrame;
  }
  return nil;
}

@end

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation TTStyledTextFrame

@synthesize element = _element, node = _node, nextFrame = _nextFrame, style = _style, text = _text,
            font = _font, width = _width, height = _height, lineBreak = _lineBreak;

///////////////////////////////////////////////////////////////////////////////////////////////////
// NSObject

- (id)initWithText:(NSString*)text element:(TTStyledElement*)element node:(TTStyledNode*)node {
  if (self = [super init]) {
    _text = [text retain];
    _nextFrame = nil;
    _element = [element retain];
    _node = [node retain];
    _style = nil;
    _font = nil;
    _width = 0;
    _height = 0;
    _lineBreak = NO;
  }
  return self;
}

- (void)dealloc {
  [_element release];
  [_nextFrame release];
  [_style release];
  [_text release];
  [_font release];
  [super dealloc];
}

- (NSString*)description {
  NSMutableString* string = [NSMutableString string];
  TTStyledTextFrame* frame = self;
  while (frame) {
    [string appendFormat:@"%@ (%d)\n", frame.text, frame.lineBreak];
    frame = frame.nextFrame;
  }
  
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
