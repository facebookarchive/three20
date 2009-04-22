#import "Three20/TTStyledLayout.h"
#import "Three20/TTStyledNode.h"
#import "Three20/TTStyledFrame.h"
#import "Three20/TTDefaultStyleSheet.h"

//////////////////////////////////////////////////////////////////////////////////////////////////

@implementation TTStyledLayout

@synthesize width = _width, height = _height, maxWidth = _maxWidth, rootFrame = _rootFrame,
            font = _font; 

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

- (UIFont*)boldFont {
  if (!_boldFont) {
    _boldFont = [[self boldVersionOfFont:self.font] retain];
  }
  return _boldFont;
}

- (UIFont*)italicFont {
  if (!_italicFont) {
    _italicFont = [[self italicVersionOfFont:self.font] retain];
  }
  return _italicFont;
}

- (TTStyle*)linkStyle {
  if (!_linkStyle) {
    _linkStyle = [TTSTYLE(linkText:) retain];
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
  return (_font.ascender - _font.descender)+1;
}

- (void)offsetFrame:(TTStyledFrame*)frame by:(CGFloat)y {
   frame.y += y;

  if ([frame isKindOfClass:[TTStyledInlineFrame class]]) {
    TTStyledInlineFrame* inlineFrame = (TTStyledInlineFrame*)frame;
    TTStyledFrame* child = inlineFrame.firstChildFrame;
    while (child) {
      [self offsetFrame:child by:y];
      child = child.nextFrame;
    }
  }
}

- (void)addFrame:(TTStyledFrame*)frame {
  if (!_rootFrame) {
    _rootFrame = [frame retain];
  } else if (_topFrame) {
    if (!_topFrame.firstChildFrame) {
      _topFrame.firstChildFrame = frame;
    } else {
      _lastFrame.nextFrame = frame;
    }
  } else {
    _lastFrame.nextFrame = frame;
  }
  _lastFrame = frame;
}

- (void)pushFrame:(TTStyledBoxFrame*)frame {
  [self addFrame:frame];
  frame.parentFrame = _topFrame;
  _topFrame = frame;
}

- (void)popFrame {
  _lastFrame = _topFrame;
  _topFrame = _topFrame.parentFrame;
}

- (void)addContentFrame:(TTStyledFrame*)frame width:(CGFloat)width height:(CGFloat)height {
  frame.bounds = CGRectMake(_x, _height, width, height);
  [self addFrame:frame];
  if (!_lineFirstFrame) {
    _lineFirstFrame = frame;
  }
  _x += width;
  
  TTStyledInlineFrame* inlineFrame = _inlineFrame;
  while (inlineFrame) {
    inlineFrame.width += width;
    inlineFrame = inlineFrame.inlineParentFrame;
  }
}

- (TTStyledInlineFrame*)addInlineFrame:(TTStyle*)style element:(TTStyledElement*)element
                        width:(CGFloat)width height:(CGFloat)height {
  TTStyledInlineFrame* frame = [[[TTStyledInlineFrame alloc] initWithElement:element] autorelease];
  frame.style = style;
  frame.bounds = CGRectMake(_x, _height, width, height);
  [self pushFrame:frame];
  if (!_lineFirstFrame) {
    _lineFirstFrame = frame;
  }
  return frame;
}

- (TTStyledInlineFrame*)cloneInlineFrame:(TTStyledInlineFrame*)frame {
  TTStyledInlineFrame* parent = frame.inlineParentFrame;
  if (parent) {
    [self cloneInlineFrame:parent];
  }
  return [self addInlineFrame:frame.style element:frame.element width:0 height:0];
}

- (TTStyledFrame*)addBlockFrame:(TTStyle*)style element:(TTStyledElement*)element
                  width:(CGFloat)width height:(CGFloat)height {
  TTStyledBoxFrame* frame = [[[TTStyledBoxFrame alloc] initWithElement:element] autorelease];
  frame.style = style;
  frame.bounds = CGRectMake(_x, _height, width, height);
  [self pushFrame:frame];
  return frame;
}

- (void)breakLine {
  if (_inlineFrame) {
    // XXXjoe This is wrong - we need to track the height of nodes inside the inline frame
    // so that the frame height wraps them all, not just the height of the last font
    TTStyledInlineFrame* inlineFrame = _inlineFrame;
    while (inlineFrame) {
      inlineFrame.height += self.fontHeight;
      if (inlineFrame.style) {
        TTBoxStyle* padding = [inlineFrame.style firstStyleOfClass:[TTBoxStyle class]];
        if (padding) {
          TTStyledInlineFrame* inlineFrame2 = inlineFrame;
          while (inlineFrame2) {
            inlineFrame2.y -= padding.padding.top;
            inlineFrame2.height += padding.padding.top+padding.padding.bottom;
            inlineFrame2 = inlineFrame2.inlineParentFrame;
          }
        }
      }
      inlineFrame = inlineFrame.inlineParentFrame;
    }
  }

  // Vertically align all frames on the current line
  if (_lineFirstFrame.nextFrame) {
    TTStyledFrame* frame = _lineFirstFrame;
    while (frame) {
      // Align to the text baseline
      // XXXjoe Support top, bottom, and center alignment also
      if (frame.height < _lineHeight) {
        [self offsetFrame:frame by:(_lineHeight - frame.height) + _font.descender];
      }
      frame = frame.nextFrame;
    }
  }

  _height += _lineHeight;
  _lineWidth = 0;
  _lineHeight = 0;
  _x = _minX;
  _lineFirstFrame = nil;

  if (_inlineFrame) {
    while ([_topFrame isKindOfClass:[TTStyledInlineFrame class]]) {
      [self popFrame];
    }
    _inlineFrame = [self cloneInlineFrame:_inlineFrame];
  }
}

- (TTStyledFrame*)addFrameForText:(NSString*)text element:(TTStyledElement*)element
                      node:(TTStyledTextNode*)node width:(CGFloat)width height:(CGFloat)height {
  TTStyledTextFrame* frame = [[[TTStyledTextFrame alloc] initWithText:text element:element
                                                         node:node] autorelease];
  frame.font = _font;
  [self addContentFrame:frame width:width height:height];
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
  UIFont* font = nil;
  TTTextStyle* textStyle = nil;
  if (style) {
    textStyle = [style firstStyleOfClass:[TTTextStyle class]];
    if (textStyle) {
      font = textStyle.font;
    }        
  }
  if (!font) {
    if ([elt isKindOfClass:[TTStyledLinkNode class]]
        || [elt isKindOfClass:[TTStyledBoldNode class]]) {
      font = self.boldFont;
    } else if ([elt isKindOfClass:[TTStyledItalicNode class]]) {
      font = self.italicFont;
    } else {
      font = self.font;
    }
  }

  CGFloat minX = _minX;
  CGFloat maxWidth = _maxWidth;
  TTStyledFrame* blockFrame = nil;
  BOOL isBlock = [elt isKindOfClass:[TTStyledBlock class]];
  TTBoxStyle* padding = style ? [style firstStyleOfClass:[TTBoxStyle class]] : nil;
  
  if (isBlock) {
    if (padding) {
      _x += padding.margin.left;
      _minX += padding.margin.left;
      _maxWidth -= padding.margin.left + padding.margin.right;
      _height += padding.margin.top;
    }

    if (_lastFrame) {
      if (!_lineHeight && [elt isKindOfClass:[TTStyledLineBreakNode class]]) {
        _lineHeight = self.fontHeight;
      }
      [self breakLine];
    }
    if (style) {
      blockFrame = [self addBlockFrame:style element:elt width:_maxWidth height:_height];
    }
  } else {
    if (padding) {
      _x += padding.margin.left;
    }
    if (style) {
      _inlineFrame = [self addInlineFrame:style element:elt width:0 height:0];
    }
  }  

  if (padding) {
    if (isBlock) {
      _minX += padding.padding.left;
    }
    _maxWidth -= padding.padding.left+padding.padding.right;
    _x += padding.padding.left;
    _lineWidth += padding.padding.left;
    
    TTStyledInlineFrame* inlineFrame = _inlineFrame;
    while (inlineFrame) {
      inlineFrame.width += padding.padding.left;
      inlineFrame = inlineFrame.inlineParentFrame;
    }

    if (isBlock) {
      _height += padding.padding.top;
    }
  }
    
  UIFont* lastFont = _font;
  self.font = font;

  if (elt.firstChild) {
    [self layout:elt.firstChild container:elt];
  }

  if (isBlock) {
    _minX = minX;
    _maxWidth = maxWidth;
    [self breakLine];

    if (padding) {
      _height += padding.padding.bottom;
    }
    blockFrame.height = _height - blockFrame.height;
    if (padding) {
      _height += padding.margin.bottom;
    }
  } else if (!isBlock && style) {
    _inlineFrame.height += _lineHeight;
    if (padding) {
      _x += padding.padding.right + padding.margin.right;
      _lineWidth += padding.padding.right + padding.margin.right;

      TTStyledInlineFrame* inlineFrame = _inlineFrame;
      while (inlineFrame) {
        if (inlineFrame != _inlineFrame) {
          inlineFrame.width += padding.margin.right;
        }
        inlineFrame.width += padding.padding.right;
        inlineFrame.y -= padding.padding.top;
        inlineFrame.height += padding.padding.top+padding.padding.bottom;
        inlineFrame = inlineFrame.inlineParentFrame;
      }
    }
    _inlineFrame = _inlineFrame.inlineParentFrame;
  }

  self.font = lastFont;

  if (style) {
    [self popFrame];
  }
}

- (void)layoutImage:(TTStyledImageNode*)imageNode container:(TTStyledElement*)element {
  UIImage* image = [imageNode image];
  CGFloat imageHeight = image.size.height;
  
  TTStyle* style = nil;
  if (imageNode.className) {
    style = [[TTStyleSheet globalStyleSheet] styleWithSelector:imageNode.className];
  }

  TTBoxStyle* padding = style ? [style firstStyleOfClass:[TTBoxStyle class]] : nil;
  if (padding) {
    _x += padding.margin.left;
    imageHeight += padding.margin.top + padding.margin.bottom;
  }

  if (_lineWidth + image.size.width > _maxWidth) {
    // The image will be placed on the next line, so create a new frame for
    // the current line and mark it with a line break
    [self breakLine];
  }

  TTStyledImageFrame* frame = [[[TTStyledImageFrame alloc] initWithElement:element
                                                           node:imageNode] autorelease];
  [self addContentFrame:frame width:image.size.width height:image.size.height];
  _lineWidth += image.size.width;
  if (imageHeight > _lineHeight) {
    _lineHeight = imageHeight;
  }

  if (padding) {
    frame.y += padding.margin.top;
    _x += padding.margin.right;
  }
}

- (void)layoutText:(TTStyledTextNode*)textNode container:(TTStyledElement*)element {
  NSString* text = textNode.text;
  NSUInteger length = text.length;
          
  if (!textNode.nextSibling && textNode == _rootNode) {
    // This is the only node, so measure it all at once and move on
    CGSize textSize = [text sizeWithFont:_font
                            constrainedToSize:CGSizeMake(_maxWidth, CGFLOAT_MAX)
                            lineBreakMode:UILineBreakModeWordWrap];
    [self addFrameForText:text element:element node:textNode width:textSize.width
         height:textSize.height];
    _height += textSize.height;
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
    CGSize wordSize = [word sizeWithFont:_font
                            constrainedToSize:CGSizeMake(_maxWidth, CGFLOAT_MAX)
                            lineBreakMode:UILineBreakModeWordWrap];
    if (_lineWidth + wordSize.width > _maxWidth) {
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

    if (!_lineWidth && textNode == _lastNode) {
      // We are at the start of a new line, and this is the last node, so we don't need to
      // keep measuring every word.  We can just measure all remaining text and create a new
      // frame for all of it.
      NSString* lines = [text substringWithRange:searchRange];
      CGSize linesSize = [lines sizeWithFont:_font
                                constrainedToSize:CGSizeMake(_maxWidth, CGFLOAT_MAX)
                                lineBreakMode:UILineBreakModeWordWrap];

      [self addFrameForText:lines element:element node:textNode width:linesSize.width
           height:linesSize.height];
      _height += linesSize.height;
      break;
    }

    frameWidth += wordSize.width;
    _lineWidth += wordSize.width;
    if (wordSize.height > _lineHeight) {
      _lineHeight = wordSize.height;
    }

    index = wordRange.location + wordRange.length;
    if (index >= length) {
      // The current word was at the very end of the string
      NSRange lineRange = NSMakeRange(lineStartIndex, (wordRange.location + wordRange.length)
                                                      - lineStartIndex);
      NSString* line = !_lineWidth ? word : [text substringWithRange:lineRange];
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
    _minX = 0;
    _maxWidth = 0;
    _rootFrame = nil;
    _lineFirstFrame = nil;
    _inlineFrame = nil;
    _topFrame = nil;
    _lastFrame = nil;
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
  [_font release];
  [_boldFont release];
  [_italicFont release];
  [_linkStyle release];
  [super dealloc];
}

//////////////////////////////////////////////////////////////////////////////////////////////////
// public

- (UIFont*)font {
  if (!_font) {
    self.font = TTSTYLEVAR(font);
  }
  return _font;
}

- (void)setFont:(UIFont*)font {
  if (font != _font) {
    [_font release];
    _font = [font retain];
    [_boldFont release];
    _boldFont = nil;
    [_italicFont release];
    _italicFont = nil;
  }
}

- (void)layout:(TTStyledNode*)node container:(TTStyledElement*)element {
  while (node) {
    if ([node isKindOfClass:[TTStyledImageNode class]]) {
      TTStyledImageNode* imageNode = (TTStyledImageNode*)node;
      [self layoutImage:imageNode container:element];
    } else if ([node isKindOfClass:[TTStyledElement class]]) {
      TTStyledElement* elt = (TTStyledElement*)node;
      [self layoutElement:elt];
    } else if ([node isKindOfClass:[TTStyledTextNode class]]) {
      TTStyledTextNode* textNode = (TTStyledTextNode*)node;
      [self layoutText:textNode container:element];
    }
    
    node = node.nextSibling;
  }
}

- (void)layout:(TTStyledNode*)node {
  [self layout:node container:nil];
  if (_lineWidth) {
    [self breakLine];
  }
}

@end
