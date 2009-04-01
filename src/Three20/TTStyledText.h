#import "Three20/TTGlobal.h"

@class TTStyledTextNode, TTStyledTextFrame, TTStyledTextNode;

@interface TTStyledText : NSObject {
  TTStyledTextNode* _rootNode;
  TTStyledTextFrame* _rootFrame;
  UIFont* _font;
  CGFloat _width;
  CGFloat _height;
}

@property(nonatomic, retain) TTStyledTextNode* rootNode;
@property(nonatomic, readonly) TTStyledTextFrame* rootFrame;
@property(nonatomic, retain) UIFont* font;
@property(nonatomic) CGFloat width;
@property(nonatomic, readonly) CGFloat height;

/**
 * Constructs a tree of HTML nodes from a well-formed XHTML fragment.
 */
+ (TTStyledText*)textFromXHTML:(NSString*)source;

/**
 * Constructs a tree of HTML nodes from a string containing URLs.
 *
 * Only URLs are parsed, not HTML markup. URLs are turned into links.
 */ 
+ (TTStyledText*)textWithURLs:(NSString*)source;

- (id)initWithNode:(TTStyledTextNode*)rootNode;

/**
 * Called to indicate that the layout needs to be re-calculated.
 */
- (void)setNeedsLayout;

/** 
 * Draws the text at a point.
 */
- (void)drawAtPoint:(CGPoint)point;

/**
 * Draws the text at a point with optional highlighting.
 *
 * If highlighted is YES, text colors will be ignored and all text will be drawn in the same color.
 */
- (void)drawAtPoint:(CGPoint)point highlighted:(BOOL)highlighted;

/**
 * Determines which frame is intersected by a point.
 */
- (TTStyledTextFrame*)hitTest:(CGPoint)point;

@end

///////////////////////////////////////////////////////////////////////////////////////////////////

@interface TTStyledTextFrame : NSObject {
  TTStyledTextNode* _node;
  TTStyledTextFrame* _nextFrame;
  NSString* _text;
  UIFont* _font;
  CGFloat _width;
  CGFloat _height;
  BOOL _lineBreak;
}

@property(nonatomic, readonly) TTStyledTextNode* node;
@property(nonatomic, retain) TTStyledTextFrame* nextFrame;
@property(nonatomic, readonly) NSString* text;
@property(nonatomic, retain) UIFont* font;
@property(nonatomic) CGFloat width;
@property(nonatomic) CGFloat height;
@property(nonatomic) BOOL lineBreak;

- (id)initWithText:(NSString*)text node:(TTStyledTextNode*)node;

@end
