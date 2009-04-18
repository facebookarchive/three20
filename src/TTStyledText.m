#import "Three20/TTStyledText.h"
#import "Three20/TTStyledNode.h"
#import "Three20/TTStyledFrame.h"
#import "Three20/TTStyledTextParser.h"
#import "Three20/TTDefaultStyleSheet.h"

//////////////////////////////////////////////////////////////////////////////////////////////////

@interface TTLayoutContext : NSObject {
  CGFloat _x;
  CGFloat _width;
  CGFloat _height;
  CGFloat _lineWidth;
  CGFloat _lineHeight;
  NSMutableArray* _styleStack;
  TTStyle* _lastStyle;
  TTStyledFrame* _rootFrame;
  TTStyledFrame* _lineFirstFrame;
  TTStyledFrame* _lastFrame;
  UIFont* _baseFont;
  UIFont* _font;
  UIFont* _boldFont;
  UIFont* _italicFont;
  TTStyle* _linkStyle;
  TTStyledNode* _rootNode;
  TTStyledNode* _lastNode;
}

@property(nonatomic) CGFloat x;
@property(nonatomic) CGFloat width;
@property(nonatomic) CGFloat height;
@property(nonatomic) CGFloat lineWidth;
@property(nonatomic) CGFloat lineHeight;
@property(nonatomic,readonly) CGFloat fontHeight;
@property(nonatomic,readonly) NSMutableArray* styleStack;
@property(nonatomic,assign) TTStyle* lastStyle;
@property(nonatomic,readonly) TTStyledFrame* rootFrame;
@property(nonatomic,readonly) TTStyledFrame* lineFirstFrame;
@property(nonatomic,readonly) TTStyledFrame* lastFrame;
@property(nonatomic,retain) UIFont* baseFont;
@property(nonatomic,retain) UIFont* font;
@property(nonatomic,retain) UIFont* boldFont;
@property(nonatomic,retain) UIFont* italicFont;
@property(nonatomic,retain) TTStyle* linkStyle;
@property(nonatomic,readonly) TTStyledNode* lastNode;

- (id)initWithRootNode:(TTStyledNode*)rootNode;

- (void)breakLine;

@end

@implementation TTLayoutContext

@synthesize x = _x, width = _width, height = _height, lineWidth = _lineWidth,
            lineHeight = _lineHeight, lastStyle = _lastStyle, rootFrame = _rootFrame,
            lineFirstFrame = _lineFirstFrame, lastFrame = _lastFrame, baseFont = _baseFont,
            font = _font, boldFont = _boldFont, italicFont = _italicFont, linkStyle = _linkStyle; 

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
    _x = 0;
    _width = 0;
    _height = 0;
    _lineWidth = 0;
    _lineHeight = 0;
    _styleStack = nil;
    _lastStyle = nil;
    _rootFrame = nil;
    _lineFirstFrame = nil;
    _lastFrame = nil;
    _baseFont = nil;
    _font = nil;
    _boldFont = nil;
    _italicFont = nil;
    _linkStyle = nil;
    _rootNode = nil;
    _lastNode = nil;
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
  return (self.font.ascender - self.font.descender)+1;
}

- (void)addFrame:(TTStyledFrame*)frame width:(CGFloat)width height:(CGFloat)height {
  frame.style = self.lastStyle;
  frame.bounds = CGRectMake(_x, _height, width, height);
  if (!_rootFrame) {
    _rootFrame = [frame retain];
  } else {
    _lastFrame.nextFrame = frame;
  }
  _lastFrame = frame;
  if (!_lineFirstFrame) {
    _lineFirstFrame = frame;
  }
  _x += width;
}

- (TTStyledFrame*)addBlockFrame:(TTStyle*)style element:(TTStyledElement*)element
                  width:(CGFloat)width height:(CGFloat)height {
  TTStyledFrame* frame = [[[TTStyledFrame alloc] initWithElement:element] autorelease];
  frame.style = style;
  frame.bounds = CGRectMake(_x, _height, width, height);
  if (!_rootFrame) {
    _rootFrame = [frame retain];
  } else {
    _lastFrame.nextFrame = frame;
  }
  _lastFrame = frame;
  return frame;
}

- (TTStyledFrame*)addFrameForText:(NSString*)text element:(TTStyledElement*)element
                      node:(TTStyledTextNode*)node width:(CGFloat)width height:(CGFloat)height {
  TTStyledTextFrame* frame = [[[TTStyledTextFrame alloc] initWithText:text element:element
                                                         node:node] autorelease];
  frame.font = self.font;
  [self addFrame:frame width:width height:height];
  return frame;
}

- (void)breakLine {
  // Vertically align all frames on the current line
  if (_lineFirstFrame.nextFrame) {
    TTStyledFrame* frame = _lineFirstFrame;
    while (frame) {
      if (frame.height < _lineHeight) {
        frame.y += (_lineHeight - frame.height) + self.font.descender;
      }
      frame = frame.nextFrame;
    }
  }
  
  _height += _lineHeight;
  _x = 0;
  _lineWidth = 0;
  _lineHeight = 0;
  _lineFirstFrame = nil;
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
      if (elt.className) {
        TTStyle* eltStyle = [[TTStyleSheet globalStyleSheet] styleWithSelector:elt.className];
        if (eltStyle) {
          style = eltStyle;
        }
      }
      if (!style && [node isKindOfClass:[TTStyledLinkNode class]]) {
        style = ctx.linkStyle;
      }

      // Figure out which font to use for the node
      // XXXjoe Do this lazily when asked for font
      UIFont* font = nil;
      if ([node isKindOfClass:[TTStyledLinkNode class]]
          || [node isKindOfClass:[TTStyledBoldNode class]]) {
        font = ctx.boldFont;
      } else if ([node isKindOfClass:[TTStyledItalicNode class]]) {
        font = ctx.italicFont;
      } else if (style) {
        TTTextStyle* textStyle = [style firstStyleOfClass:[TTTextStyle class]];
        if (textStyle) {
          font = textStyle.font;
        }        
      }
      if (!font) {
        font = ctx.baseFont;
      }

      BOOL isBlock = [node isKindOfClass:[TTStyledBlock class]];
      if (ctx.lastFrame && isBlock) {
        if (!ctx.lineWidth) {
          ctx.height += ctx.fontHeight;
        }
        [ctx breakLine];
      }

      TTStyledFrame* blockFrame = nil;
      if (isBlock && style) {
        blockFrame = [ctx addBlockFrame:style element:element width:_width height:ctx.height];
      }
        
      if (elt.firstChild) {
        UIFont* lastFont = ctx.font;
        TTStyle* lastStyle = ctx.lastStyle;
        ctx.font = font;
        if (!isBlock) {
          ctx.lastStyle = style;
        }
        [self layoutElement:elt.firstChild element:elt context:ctx];

        ctx.font = lastFont;
        
        if (!isBlock) {
          ctx.lastStyle = lastStyle;
        } else {
          [ctx breakLine];
        }
      }
      
      if (blockFrame) {
        blockFrame.height = ctx.height - blockFrame.height;
      }
    } else if ([node isKindOfClass:[TTStyledImageNode class]]) {
      TTStyledImageNode* imageNode = (TTStyledImageNode*)node;
      UIImage* image = [imageNode image];

      if (ctx.lineWidth + image.size.width > _width) {
        // The image will be placed on the next line, so create a new frame for
        // the current line and mark it with a line break
        [ctx breakLine];
      }

      TTStyledImageFrame* frame = [[[TTStyledImageFrame alloc] initWithElement:element
                                                               node:imageNode] autorelease];
      [ctx addFrame:frame width:image.size.width height:image.size.height];
      if (!ctx.lineWidth) {
        ctx.height += ctx.lastFrame.height;
      }
      ctx.lineWidth += image.size.width;
      if (image.size.height > ctx.lineHeight) {
        ctx.lineHeight = image.size.height;
      }
    } else if ([node isKindOfClass:[TTStyledTextNode class]]) {
      TTStyledTextNode* textNode = (TTStyledTextNode*)node;
      NSString* text = textNode.text;
      NSUInteger length = text.length;
              
      if (!node.nextSibling && node == _rootNode) {
        // This is the only node, so measure it all at once and move on
        CGSize textSize = [text sizeWithFont:ctx.font
                                constrainedToSize:CGSizeMake(_width, CGFLOAT_MAX)
                                lineBreakMode:UILineBreakModeWordWrap];
        [ctx addFrameForText:text element:element node:textNode width:textSize.width
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
        if (ctx.lineWidth + wordSize.width > _width) {
          // The word will be placed on the next line, so create a new frame for
          // the current line and mark it with a line break
          NSRange lineRange = NSMakeRange(lineStartIndex, index - lineStartIndex);
          if (lineRange.length) {
            NSString* line = [text substringWithRange:lineRange];
            [ctx addFrameForText:line element:element node:textNode width:frameWidth
                 height:ctx.fontHeight];
          }
          
          [ctx breakLine];
          lineStartIndex = lineRange.location + lineRange.length;
          frameWidth = 0;
        }

        if (!ctx.lineWidth && node == ctx.lastNode) {
          // We are at the start of a new line, and this is the last node, so we don't need to
          // keep measuring every word.  We can just measure all remaining text and create a new
          // frame for all of it.
          NSString* lines = [text substringWithRange:searchRange];
          CGSize linesSize = [lines sizeWithFont:ctx.font
                                    constrainedToSize:CGSizeMake(_width, CGFLOAT_MAX)
                                    lineBreakMode:UILineBreakModeWordWrap];

          [ctx addFrameForText:lines element:element node:textNode width:linesSize.width
               height:linesSize.height];
          ctx.height += linesSize.height;
          break;
        }

        frameWidth += wordSize.width;
        ctx.lineWidth += wordSize.width;
        if (wordSize.height > ctx.lineHeight) {
          ctx.lineHeight = wordSize.height;
        }

        index = wordRange.location + wordRange.length;
        if (index >= length) {
          // The current word was at the very end of the string
          NSRange lineRange = NSMakeRange(lineStartIndex, (wordRange.location + wordRange.length)
                                                          - lineStartIndex);
          NSString* line = !ctx.lineWidth ? word : [text substringWithRange:lineRange];
          [ctx addFrameForText:line element:element node:textNode width:frameWidth
               height:ctx.fontHeight];
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
  
  if (ctx.lineWidth) {
    ctx.height += ctx.lineHeight;
  }
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

- (TTStyledFrame*)rootFrame {
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

- (TTStyledFrame*)hitTest:(CGPoint)point {
  TTStyledFrame* frame = self.rootFrame;
  while (frame) {
    if (CGRectContainsPoint(frame.bounds, point)) {
      return frame;
    }
    frame = frame.nextFrame;
  }
  return nil;
}

@end
