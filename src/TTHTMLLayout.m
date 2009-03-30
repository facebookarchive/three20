#import "Three20/TTHTMLLayout.h"
#import "Three20/TTHTMLNode.h"
#import "Three20/TTAppearance.h"

//////////////////////////////////////////////////////////////////////////////////////////////////

@implementation TTHTMLLayout

@synthesize html = _html, font = _font, width = _width, height = _height,
            lastLineWidth = _lastLineWidth;

///////////////////////////////////////////////////////////////////////////////////////////////////
// private

- (TTHTMLFrame*)addFrameForText:(NSString*)text node:(TTHTMLNode*)node
                  after:(TTHTMLFrame*)lastFrame {
  TTHTMLFrame* frame = [[[TTHTMLFrame alloc] initWithText:text node:node] autorelease];
  if (lastFrame) {
    lastFrame.nextFrame = frame;
  } else {
    _rootFrame = [frame retain];
  }
  return frame;
}

- (void)layoutFrames {
  UIFont* boldFont = [UIFont boldSystemFontOfSize:_font.pointSize];
  CGSize spaceSize = [@" " sizeWithFont:_font];
  NSCharacterSet* whitespace = [NSCharacterSet whitespaceCharacterSet];
  
  _lineHeight = spaceSize.height;
  _height = _lineHeight;
  _lastLineWidth = 0;

  TTHTMLFrame* lastFrame = nil;

  TTHTMLNode* node = _html;
  while (node) {
    if ([node isKindOfClass:[TTHTMLText class]]) {
      TTHTMLText* textNode = (TTHTMLText*)node;
      NSString* text = textNode.text;
      
      UIFont* font = [node isKindOfClass:[TTHTMLLinkNode class]]
                     || [node isKindOfClass:[TTHTMLBoldNode class]] ? boldFont : _font;
    
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

- (id)initWithHTML:(TTHTMLNode*)html {
  if (self = [super init]) {
    _html = [html retain];
    _rootFrame = nil;
    _font = nil;
    _width = 0;
    _height = 0;
    _lastLineWidth = 0;
  }
  return self;
}

- (void)dealloc {
  [_html release];
  [_rootFrame release];
  [_font release];
  [super dealloc];
}

- (NSString*)description {
  return [self.rootFrame description];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// public

- (TTHTMLFrame*)rootFrame {
  if (!_rootFrame) {
    [self layoutFrames];
  }
  return _rootFrame;
}

- (void)setFont:(UIFont*)font {
  if (font != _font) {
    [_font release];
    _font = [font retain];
    [_rootFrame release];
    _rootFrame = nil;
    _height = 0;
  }
}

- (void)setWidth:(CGFloat)width {
  if (width != _width) {
    _width = width;
    _height = 0;
    [_rootFrame release];
    _rootFrame = nil;
  }
}

- (CGFloat)height {
  self.rootFrame;
  return _height;
}

- (void)drawAtPoint:(CGPoint)point {
  [self drawAtPoint:point highlighted:NO];
}

- (void)drawAtPoint:(CGPoint)point highlighted:(BOOL)highlighted {
  CGContextRef context = UIGraphicsGetCurrentContext();
  UIFont* boldFont = [UIFont boldSystemFontOfSize:_font.pointSize];

  CGPoint origin = point;
  TTHTMLFrame* frame = self.rootFrame;
  while (frame) {
    if ([frame.node isKindOfClass:[TTHTMLLinkNode class]]) {
      TTHTMLLinkNode* linkNode = (TTHTMLLinkNode*)frame.node;
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
    } else if ([frame.node isKindOfClass:[TTHTMLBoldNode class]]) {
      [frame.text drawAtPoint:origin withFont:boldFont];
    } else {
      [frame.text drawAtPoint:origin withFont:_font];
    }

    origin.x += frame.width;
    if (frame.lineBreak) {
      origin.x = 0;
      origin.y += _lineHeight;
    }
    
    frame = frame.nextFrame;
  }
}

- (TTHTMLFrame*)hitTest:(CGPoint)point {
  CGPoint origin = CGPointMake(0, 0);
  TTHTMLFrame* frame = self.rootFrame;
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

@implementation TTHTMLFrame

@synthesize node = _node, text = _text, nextFrame = _nextFrame, width = _width,
            lineBreak = _lineBreak;

///////////////////////////////////////////////////////////////////////////////////////////////////
// NSObject

- (id)initWithText:(NSString*)text node:(TTHTMLNode*)node {
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
  TTHTMLFrame* frame = self;
  while (frame) {
    [string appendFormat:@"%@ (%d)\n", frame.text, frame.lineBreak];
    frame = frame.nextFrame;
  }
  
  return string;
}

@end

