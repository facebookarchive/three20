#import "Three20/TTStyledText.h"
#import "Three20/TTStyledTextNode.h"
#import "Three20/TTStyledTextParser.h"
#import "Three20/TTAppearance.h"

//////////////////////////////////////////////////////////////////////////////////////////////////

@implementation TTStyledText

@synthesize rootNode = _rootNode, font = _font, width = _width, height = _height;

//////////////////////////////////////////////////////////////////////////////////////////////////
// class public

+ (TTStyledText*)textFromXHTML:(NSString*)source {
  TTStyledTextParser* parser = [[[TTStyledTextParser alloc] init] autorelease];
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

- (UIFont*)defaultFont {
  return [UIFont systemFontOfSize:14];
}

- (UIFont*)boldVersionOfFont:(UIFont*)font {
  return [UIFont boldSystemFontOfSize:font.pointSize];
}

- (UIFont*)italicVersionOfFont:(UIFont*)font {
  return [UIFont italicSystemFontOfSize:font.pointSize];
}

- (TTStyledTextFrame*)addFrameForText:(NSString*)text node:(TTStyledTextNode*)node
                  after:(TTStyledTextFrame*)lastFrame {
  TTStyledTextFrame* frame = [[[TTStyledTextFrame alloc] initWithText:text node:node] autorelease];
  if (lastFrame) {
    lastFrame.nextFrame = frame;
  } else {
    _rootFrame = [frame retain];
  }
  return frame;
}

- (void)layoutFrames {
  UIFont* baseFont = _font ? _font : [self defaultFont];
  UIFont* boldFont = nil;
  UIFont* italicFont = nil;
  NSCharacterSet* whitespace = [NSCharacterSet whitespaceAndNewlineCharacterSet];
  
  TTStyledTextFrame* lastFrame = nil;
  CGFloat lineWidth = 0;
  CGFloat height = 0;

  TTStyledTextNode* node = _rootNode;
  while (node) {
    if ([node isKindOfClass:[TTStyledImageNode class]]) {
      UIImage* image = [(TTStyledImageNode*)node image];

      if (lineWidth + image.size.width > _width) {
        // The image will be placed on the next line, so create a new frame for
        // the current line and mark it with a line break
        lastFrame.lineBreak = YES;
        lineWidth = 0;
      }

      lastFrame = [self addFrameForText:nil node:node after:lastFrame];
      lastFrame.width = image.size.width;
      lastFrame.height = baseFont.ascender;

      if (!lineWidth) {
          height += lastFrame.height;
      }
      lineWidth += image.size.width;
    } else {
      NSString* text = node.text;
      NSUInteger length = text.length;
      
      // Figure out which font to use for the node
      UIFont* font = baseFont;
      if ([node isKindOfClass:[TTStyledLinkNode class]]
          || [node isKindOfClass:[TTStyledBoldNode class]]) {
        if (!boldFont) {
          boldFont = [self boldVersionOfFont:baseFont];
        }
        font = boldFont;
      } else if ([node isKindOfClass:[TTStyledItalicNode class]]) {
        if (!italicFont) {
          italicFont = [self italicVersionOfFont:baseFont];
        }
        font = italicFont;
      }
        
      if (!node.nextNode && node == _rootNode) {
        // This is this is the only node, so measure it all at once and move on
        CGSize textSize = [text sizeWithFont:font
                                 constrainedToSize:CGSizeMake(_width, CGFLOAT_MAX)
                                 lineBreakMode:UILineBreakModeWordWrap];
        lastFrame = [self addFrameForText:text node:node after:lastFrame];
        lastFrame.width = textSize.width;
        lastFrame.height = textSize.height;
        lastFrame.font = font;
        height += textSize.height;
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
        CGSize wordSize = [word sizeWithFont:font];
        if (lineWidth + wordSize.width > _width) {
          if (0 && wordSize.width > _width) {
            // The word is larger than an entire line, so we need to split it across lines
            // XXXjoe TODO
          } else {
            // The word will be placed on the next line, so create a new frame for
            // the current line and mark it with a line break
            NSRange lineRange = NSMakeRange(lineStartIndex, index - lineStartIndex);
            if (lineRange.length) {
              NSString* line = [text substringWithRange:lineRange];
              lastFrame = [self addFrameForText:line node:node after:lastFrame];
              lastFrame.width = frameWidth;
              lastFrame.height = wordSize.height;
              lastFrame.font = font;
            }
            
            lastFrame.lineBreak = YES;
            lineStartIndex = lineRange.location + lineRange.length;
            frameWidth = 0;
            lineWidth = 0;
          }
        }

        if (!lineWidth) {
          // We are at the start of a new line
          if (node.nextNode) {
            // Count the height of the new line
            height += wordSize.height;
          } else {
            // This is the last node, so we don't need to keep measuring every word.  We
            // can just measure all remaining text and create a new frame for all of it.
            NSString* lines = [text substringWithRange:searchRange];
            CGSize linesSize = [lines sizeWithFont:font
                                      constrainedToSize:CGSizeMake(_width, CGFLOAT_MAX)
                                      lineBreakMode:UILineBreakModeWordWrap];

            lastFrame = [self addFrameForText:lines node:node after:lastFrame];
            lastFrame.width = linesSize.width;
            lastFrame.height = linesSize.height;
            lastFrame.font = font;
            height += linesSize.height;
            break;
          }
        }
        
        frameWidth += wordSize.width;
        lineWidth += wordSize.width;
        index = wordRange.location + wordRange.length;

        if (index >= length) {
          // The current word was at the very end of the string
          NSRange lineRange = NSMakeRange(lineStartIndex, (wordRange.location + wordRange.length)
                                                          - lineStartIndex);
          NSString* line = !lineWidth ? word : [text substringWithRange:lineRange];
          lastFrame = [self addFrameForText:line node:node after:lastFrame];
          lastFrame.width = frameWidth;
          lastFrame.height = wordSize.height;
          lastFrame.font = font;
          frameWidth = 0;
        }
      }
    }
    
    node = node.nextNode;
  }
  
  _height = ceil(height);
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// NSObject

- (id)initWithNode:(TTStyledTextNode*)rootNode {
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
  CGContextRef context = UIGraphicsGetCurrentContext();

  CGPoint origin = point;
  TTStyledTextFrame* frame = self.rootFrame;
  
  while (frame) {
    CGRect frameRect = CGRectMake(origin.x, origin.y, frame.width, frame.height);
    if ([frame.node isKindOfClass:[TTStyledLinkNode class]]) {
      TTStyledLinkNode* linkNode = (TTStyledLinkNode*)frame.node;
      if (linkNode.highlighted) {
        UIColor* fill[] = {[UIColor colorWithWhite:0 alpha:0.25]};
        [[TTAppearance appearance] draw:TTStyleFill rect:CGRectInset(frameRect, -4, -3)
                                   fill:fill fillCount:1 stroke:nil radius:4];
      }
      
      if (!highlighted) {
        CGContextSaveGState(context);
        [[TTAppearance appearance].linkTextColor setFill];
      }
      
      [frame.text drawInRect:frameRect withFont:frame.font];

      if (!highlighted) {
        CGContextRestoreGState(context);
      }
    } else if ([frame.node isKindOfClass:[TTStyledBoldNode class]]) {
      [frame.text drawInRect:frameRect withFont:frame.font];
    } else if ([frame.node isKindOfClass:[TTStyledItalicNode class]]) {
      [frame.text drawInRect:frameRect withFont:frame.font];
    } else if ([frame.node isKindOfClass:[TTStyledImageNode class]]) {
      TTStyledImageNode* imageNode = (TTStyledImageNode*)frame.node;
      UIImage* image = imageNode.image;
      CGRect imageRect = CGRectMake(origin.x, (origin.y+frame.height)-image.size.height,
                                    image.size.width, image.size.height);
      [imageNode.image drawInRect:imageRect];
    } else {
      [frame.text drawInRect:frameRect withFont:frame.font];
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

@synthesize node = _node, nextFrame = _nextFrame, text = _text, font = _font,
            width = _width, height = _height, lineBreak = _lineBreak;

///////////////////////////////////////////////////////////////////////////////////////////////////
// NSObject

- (id)initWithText:(NSString*)text node:(TTStyledTextNode*)node {
  if (self = [super init]) {
    _text = [text retain];
    _nextFrame = nil;
    _node = [node retain];
    _font = nil;
    _width = 0;
    _height = 0;
    _lineBreak = NO;
  }
  return self;
}

- (void)dealloc {
  [_node release];
  [_nextFrame release];
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

@end

