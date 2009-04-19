#import "Three20/TTStyledLayout.h"
#import "Three20/TTStyledNode.h"
#import "Three20/TTStyledFrame.h"
#import "Three20/TTDefaultStyleSheet.h"

//////////////////////////////////////////////////////////////////////////////////////////////////

@implementation TTStyledLayout

@synthesize x = _x, width = _width, height = _height, lineWidth = _lineWidth,
            maxWidth = _maxWidth, lineHeight = _lineHeight, lastStyle = _lastStyle,
            rootFrame = _rootFrame, lineFirstFrame = _lineFirstFrame, lastFrame = _lastFrame,
            baseFont = _baseFont, font = _font, boldFont = _boldFont, italicFont = _italicFont,
            linkStyle = _linkStyle; 

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

- (void)layoutElement:(TTStyledElement*)elt {
  TTStyle* style = nil;
  if (elt.className) {
    TTStyle* eltStyle = [[TTStyleSheet globalStyleSheet] styleWithSelector:elt.className];
    if (eltStyle) {
      style = eltStyle;
    }
  }
  if (!style && [elt isKindOfClass:[TTStyledLinkNode class]]) {
    style = self.linkStyle;
  }

  // Figure out which font to use for the node
  // XXXjoe Do this lazily when asked for font
  UIFont* font = nil;
  TTTextStyle* textStyle = nil;
  if ([elt isKindOfClass:[TTStyledLinkNode class]]
      || [elt isKindOfClass:[TTStyledBoldNode class]]) {
    font = self.boldFont;
  } else if ([elt isKindOfClass:[TTStyledItalicNode class]]) {
    font = self.italicFont;
  } else if (style) {
    textStyle = [style firstStyleOfClass:[TTTextStyle class]];
    if (textStyle) {
      font = textStyle.font;
    }        
  }
  if (!font) {
    font = self.baseFont;
  }

  BOOL isBlock = [elt isKindOfClass:[TTStyledBlock class]];
  if (self.lastFrame && isBlock) {
    if (!self.lineWidth) {
      self.lineHeight = self.fontHeight;
    }
    [self breakLine];
  }

  TTStyledFrame* blockFrame = nil;
  if (isBlock && style) {
    blockFrame = [self addBlockFrame:style element:elt width:_maxWidth height:self.height];
  }
    
  if (elt.firstChild) {
    UIFont* lastFont = self.font;
    TTStyle* lastStyle = self.lastStyle;
    self.font = font;
    if (!isBlock) {
      self.lastStyle = style;
    } else {
      self.lastStyle = textStyle;
    }
    
    [self layout:elt.firstChild container:elt];

    self.font = lastFont;
    self.lastStyle = lastStyle;
    
    if (isBlock) {
      [self breakLine];
    }
  }

  if (blockFrame) {
    blockFrame.height = self.height - blockFrame.height;
  }
}

- (void)layoutImage:(TTStyledImageNode*)imageNode container:(TTStyledElement*)element {
  UIImage* image = [imageNode image];

  if (self.lineWidth + image.size.width > _maxWidth) {
    // The image will be placed on the next line, so create a new frame for
    // the current line and mark it with a line break
    [self breakLine];
  }

  TTStyledImageFrame* frame = [[[TTStyledImageFrame alloc] initWithElement:element
                                                           node:imageNode] autorelease];
  [self addFrame:frame width:image.size.width height:image.size.height];
  self.lineWidth += image.size.width;
  if (image.size.height > self.lineHeight) {
    self.lineHeight = image.size.height;
  }
}

- (void)layoutText:(TTStyledTextNode*)textNode container:(TTStyledElement*)element {
  NSString* text = textNode.text;
  NSUInteger length = text.length;
          
  if (!textNode.nextSibling && textNode == _rootNode) {
    // This is the only node, so measure it all at once and move on
    CGSize textSize = [text sizeWithFont:self.font
                            constrainedToSize:CGSizeMake(_maxWidth, CGFLOAT_MAX)
                            lineBreakMode:UILineBreakModeWordWrap];
    [self addFrameForText:text element:element node:textNode width:textSize.width
         height:textSize.height];
    self.height += textSize.height;
    return;
  }

  NSCharacterSet* whitespace = [NSCharacterSet whitespaceAndNewlineCharacterSet];

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
    CGSize wordSize = [word sizeWithFont:self.font
                            constrainedToSize:CGSizeMake(_maxWidth, CGFLOAT_MAX)
                            lineBreakMode:UILineBreakModeWordWrap];
    if (self.lineWidth + wordSize.width > _maxWidth) {
      // The word will be placed on the next line, so create a new frame for
      // the current line and mark it with a line break
      NSRange lineRange = NSMakeRange(lineStartIndex, index - lineStartIndex);
      if (lineRange.length) {
        NSString* line = [text substringWithRange:lineRange];
        [self addFrameForText:line element:element node:textNode width:frameWidth
             height:self.fontHeight];
      }
      
      [self breakLine];
      lineStartIndex = lineRange.location + lineRange.length;
      frameWidth = 0;
    }

    if (!self.lineWidth && textNode == self.lastNode) {
      // We are at the start of a new line, and this is the last node, so we don't need to
      // keep measuring every word.  We can just measure all remaining text and create a new
      // frame for all of it.
      NSString* lines = [text substringWithRange:searchRange];
      CGSize linesSize = [lines sizeWithFont:self.font
                                constrainedToSize:CGSizeMake(_maxWidth, CGFLOAT_MAX)
                                lineBreakMode:UILineBreakModeWordWrap];

      [self addFrameForText:lines element:element node:textNode width:linesSize.width
           height:linesSize.height];
      self.height += linesSize.height;
      break;
    }

    frameWidth += wordSize.width;
    self.lineWidth += wordSize.width;
    if (wordSize.height > self.lineHeight) {
      self.lineHeight = wordSize.height;
    }

    index = wordRange.location + wordRange.length;
    if (index >= length) {
      // The current word was at the very end of the string
      NSRange lineRange = NSMakeRange(lineStartIndex, (wordRange.location + wordRange.length)
                                                      - lineStartIndex);
      NSString* line = !self.lineWidth ? word : [text substringWithRange:lineRange];
      [self addFrameForText:line element:element node:textNode width:frameWidth
            height:self.fontHeight];
      frameWidth = 0;
    }
  }
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
    _maxWidth = 0;
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

//////////////////////////////////////////////////////////////////////////////////////////////////
// public

- (void)layout:(TTStyledNode*)node container:(TTStyledElement*)element {
  while (node) {
    if ([node isKindOfClass:[TTStyledElement class]]) {
      TTStyledElement* elt = (TTStyledElement*)node;
      [self layoutElement:elt];
    } else if ([node isKindOfClass:[TTStyledImageNode class]]) {
      TTStyledImageNode* imageNode = (TTStyledImageNode*)node;
      [self layoutImage:imageNode container:element];
    } else if ([node isKindOfClass:[TTStyledTextNode class]]) {
      TTStyledTextNode* textNode = (TTStyledTextNode*)node;
      [self layoutText:textNode container:element];
    }
    
    node = node.nextSibling;
  }
}

- (void)layout:(TTStyledNode*)node {
  [self layout:node container:nil];
  if (self.lineWidth) {
    [self breakLine];
  }
}

@end
