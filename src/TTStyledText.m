#import "Three20/TTStyledText.h"
#import "Three20/TTStyledTextNode.h"
#import "Three20/TTAppearance.h"

//////////////////////////////////////////////////////////////////////////////////////////////////

@implementation TTStyledText

@synthesize rootNode = _rootNode, font = _font, width = _width, height = _height,
            lastLineWidth = _lastLineWidth;

//////////////////////////////////////////////////////////////////////////////////////////////////
// class public

+ (TTStyledText*)textFromHTMLString:(NSString*)string {
  // XXXjoe XHTML parser yet to be implemented
  return nil;
}

+ (TTStyledText*)textFromURLString:(NSString*)string {
  TTStyledTextNode* rootNode = nil;
  TTStyledTextNode* lastNode = nil;
  
  NSInteger index = 0;
  while (index < string.length) {
    NSRange searchRange = NSMakeRange(index, string.length - index);
    NSRange startRange = [string rangeOfString:@"http://" options:NSCaseInsensitiveSearch
                                 range:searchRange];
    if (startRange.location == NSNotFound) {
      NSString* text = [string substringWithRange:searchRange];
      TTStyledTextNode* node = [[[TTStyledTextNode alloc] initWithText:text] autorelease];
      if (lastNode) {
        lastNode.nextNode = node;
      } else {
        rootNode = node;
      }
      lastNode = node;
      break;
    } else {
      NSRange beforeRange = NSMakeRange(searchRange.location,
        startRange.location - searchRange.location);
      if (beforeRange.length) {
        NSString* text = [string substringWithRange:beforeRange];

        TTStyledTextNode* node = [[[TTStyledTextNode alloc] initWithText:text] autorelease];
        if (lastNode) {
          lastNode.nextNode = node;
        } else {
          rootNode = node;
        }
        lastNode = node;
      }

      NSRange searchRange = NSMakeRange(startRange.location, string.length - startRange.location);
      NSRange endRange = [string rangeOfString:@" " options:NSCaseInsensitiveSearch
                                 range:searchRange];
      if (endRange.location == NSNotFound) {
        NSString* url = [string substringWithRange:searchRange];
        TTStyledLinkNode* node = [[[TTStyledLinkNode alloc] initWithText:url] autorelease];
        node.url = url;
        if (lastNode) {
          lastNode.nextNode = node;
        } else {
          rootNode = node;
        }
        lastNode = node;
        break;
      } else {
        NSRange urlRange = NSMakeRange(startRange.location,
                                             endRange.location - startRange.location);
        NSString* url = [string substringWithRange:urlRange];
        TTStyledLinkNode* node = [[[TTStyledLinkNode alloc] initWithText:url] autorelease];
        node.url = url;
        if (lastNode) {
          lastNode.nextNode = node;
        } else {
          rootNode = node;
        }
        lastNode = node;
        index = endRange.location;
      }
    }
  }
  
  return [[[TTStyledText alloc] initWithNode:rootNode] autorelease];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// private

- (UIFont*)defaultFont {
  return [UIFont systemFontOfSize:14];
}

- (UIFont*)boldVersionOfFont:(UIFont*)font {
  return [UIFont boldSystemFontOfSize:font.pointSize];
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
  UIFont* boldFont = [self boldVersionOfFont:baseFont];
  CGSize spaceSize = [@" " sizeWithFont:baseFont];
  NSCharacterSet* whitespace = [NSCharacterSet whitespaceCharacterSet];
  
  _lineHeight = spaceSize.height;
  _height = _lineHeight;
  _lastLineWidth = 0;

  TTStyledTextFrame* lastFrame = nil;

  TTStyledTextNode* node = _rootNode;
  while (node) {
    if ([node isKindOfClass:[TTStyledTextNode class]]) {
      TTStyledTextNode* textNode = (TTStyledTextNode*)node;
      NSString* text = textNode.text;
      
      UIFont* font = [node isKindOfClass:[TTStyledLinkNode class]]
                     || [node isKindOfClass:[TTStyledBoldNode class]] ? boldFont : baseFont;
    
      NSInteger index = 0;
      NSInteger lineStartIndex = 0;
      CGFloat frameWidth = 0;
      while (index < text.length) {
        NSRange searchRange = NSMakeRange(index, text.length - index);
        NSRange spaceRange = [text rangeOfCharacterFromSet:whitespace options:0 range:searchRange];
        
        NSRange wordRange;
        if (spaceRange.location != NSNotFound) {
          wordRange = NSMakeRange(searchRange.location,
                                  (spaceRange.location+1) - searchRange.location);
        } else {
          wordRange = NSMakeRange(searchRange.location, text.length - searchRange.location);
        }
        
        NSString* word = [text substringWithRange:wordRange];
        CGSize wordSize = [word sizeWithFont:font];
        
        if (_lastLineWidth + wordSize.width > _width) {
          if (wordSize.width > _width) {
            // XXXjoe Split word into multiple frames here
          }

          NSRange lineRange = NSMakeRange(lineStartIndex, index - lineStartIndex);
          if (lineRange.length) {
            NSString* line = [text substringWithRange:lineRange];
            TTLOG(@"ADD FINAL LINE %f %@", frameWidth, line);
            lastFrame = [self addFrameForText:line node:node after:lastFrame];
            lastFrame.width = frameWidth;
            frameWidth = 0;
          }
          
          lastFrame.lineBreak = YES;
          lineStartIndex = lineRange.location + lineRange.length;

          _lastLineWidth = 0;
          _height += _lineHeight;
        }

        _lastLineWidth += wordSize.width;
        frameWidth += wordSize.width;
        index = wordRange.location + wordRange.length;

        if (index >= text.length) {
          NSRange lineRange = NSMakeRange(lineStartIndex,
                                          (wordRange.location + wordRange.length) - lineStartIndex);
          NSString* line = [text substringWithRange:lineRange];
          TTLOG(@"ADD FINAL LINE %f %@", frameWidth, line);
          lastFrame = [self addFrameForText:line node:node after:lastFrame];
          lastFrame.width = frameWidth;
          frameWidth = 0;
        }
      }
    }
    
    node = node.nextNode;
  }
  
  _height = ceil(_height);
  _lastLineWidth = ceil(_lastLineWidth);
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
    _lastLineWidth = 0;
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

  UIFont* baseFont = _font ? _font : [self defaultFont];
  UIFont* boldFont = [self boldVersionOfFont:baseFont];
  
  CGPoint origin = point;
  TTStyledTextFrame* frame = self.rootFrame;
  
  while (frame) {
    if ([frame.node isKindOfClass:[TTStyledLinkNode class]]) {
      TTStyledLinkNode* linkNode = (TTStyledLinkNode*)frame.node;
      if (linkNode.highlighted) {
        CGRect frameRect = CGRectMake(origin.x, origin.y, frame.width, _lineHeight);
        UIColor* fill[] = {[UIColor colorWithWhite:0 alpha:0.3]};
        [[TTAppearance appearance] draw:TTStyleFill rect:frameRect fill:fill fillCount:1
                                   stroke:nil radius:3];
      }
      
      if (!highlighted) {
        CGContextSaveGState(context);
        [[TTAppearance appearance].linkTextColor setFill];
      }
      
      [frame.text drawAtPoint:origin withFont:boldFont];

      if (!highlighted) {
        CGContextRestoreGState(context);
      }
    } else if ([frame.node isKindOfClass:[TTStyledBoldNode class]]) {
      [frame.text drawAtPoint:origin withFont:boldFont];
    } else {
      [frame.text drawAtPoint:origin withFont:baseFont];
    }

    origin.x += frame.width;
    if (frame.lineBreak) {
      origin.x = 0;
      origin.y += _lineHeight;
    }
    
    frame = frame.nextFrame;
  }
}

- (TTStyledTextFrame*)hitTest:(CGPoint)point {
  CGPoint origin = CGPointMake(0, 0);
  TTStyledTextFrame* frame = self.rootFrame;
  while (frame) {
    CGRect rect = CGRectMake(origin.x, origin.y, frame.width, _lineHeight);
    if (CGRectContainsPoint(rect, point)) {
      return frame;
    }
    
    origin.x += frame.width;
    if (frame.lineBreak) {
      origin.x = 0;
      origin.y += _lineHeight;
    }
    
    frame = frame.nextFrame;
  }
  return nil;
}

@end

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation TTStyledTextFrame

@synthesize node = _node, text = _text, nextFrame = _nextFrame, width = _width,
            lineBreak = _lineBreak;

///////////////////////////////////////////////////////////////////////////////////////////////////
// NSObject

- (id)initWithText:(NSString*)text node:(TTStyledTextNode*)node {
  if (self = [super init]) {
    _text = [text retain];
    _node = [node retain];
    _nextFrame = nil;
    _lineBreak = NO;
  }
  return self;
}

- (void)dealloc {
  [_text release];
  [_node release];
  [_nextFrame release];
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

