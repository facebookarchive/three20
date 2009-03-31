#import "Three20/TTGlobal.h"

@class TTStyledTextNode, TTStyledTextFrame, TTStyledTextNode;

@interface TTStyledText : NSObject {
  TTStyledTextNode* _rootNode;
  TTStyledTextFrame* _rootFrame;
  UIFont* _font;
  CGFloat _width;
  CGFloat _height;
  CGFloat _lineHeight;
  CGFloat _lastLineWidth;
}

@property(nonatomic, retain) TTStyledTextNode* rootNode;
@property(nonatomic, readonly) TTStyledTextFrame* rootFrame;
@property(nonatomic, retain) UIFont* font;
@property(nonatomic) CGFloat width;
@property(nonatomic, readonly) CGFloat height;
@property(nonatomic, readonly) CGFloat lastLineWidth;

/**
 * Constructs a tree of HTML nodes from a well-formatted XHTML string.
 *
 * NOT YET IMPLEMENTED.
 */
+ (TTStyledText*)textFromHTMLString:(NSString*)string;

/**
 * Constructs a tree of HTML nodes from a string containing URLs.
 *
 * Only URLs are parsed, not HTML markup. URLs are turned into links.
 */ 
+ (TTStyledText*)textFromURLString:(NSString*)string;

- (id)initWithNode:(TTStyledTextNode*)rootNode;

- (void)setNeedsLayout;

- (void)drawAtPoint:(CGPoint)point;
- (void)drawAtPoint:(CGPoint)point highlighted:(BOOL)highlighted;

- (TTStyledTextFrame*)hitTest:(CGPoint)point;

@end

///////////////////////////////////////////////////////////////////////////////////////////////////

@interface TTStyledTextFrame : NSObject {
  TTStyledTextNode* _node;
  NSString* _text;
  TTStyledTextFrame* _nextFrame;
  CGFloat _width;
  BOOL _lineBreak;
}

@property(nonatomic, readonly) TTStyledTextNode* node;
@property(nonatomic, readonly) NSString* text;
@property(nonatomic, retain) TTStyledTextFrame* nextFrame;
@property(nonatomic) CGFloat width;
@property(nonatomic) BOOL lineBreak;

- (id)initWithText:(NSString*)text node:(TTStyledTextNode*)node;

@end
