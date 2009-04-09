#import "Three20/TTStyle.h"

@class TTStyledTextNode, TTStyledTextFrame, TTStyledTextNode;

@interface TTStyledText : NSObject {
  TTStyledTextNode* _rootNode;
  TTStyledTextFrame* _rootFrame;
  UIFont* _font;
  CGFloat _width;
  CGFloat _height;
}

/**
 * The first in the sequence of nodes that contain the styled text.
 */
@property(nonatomic, retain) TTStyledTextNode* rootNode;

/**
 * The first in the sequence of frames of text calculated by the layout.
 */
@property(nonatomic, readonly) TTStyledTextFrame* rootFrame;

/**
 * The font that will be used to measure and draw all text.
 */
@property(nonatomic, retain) UIFont* font;

/**
 * The width that the text should be constrained to fit within.
 */
@property(nonatomic) CGFloat width;

/**
 * The height of the text.
 *
 * The height is automatically calculated based on the width and the size of word-wrapped text.
 */
@property(nonatomic, readonly) CGFloat height;

/**
 * Constructs styled text with XHTML tags turned into style nodes.
 *
 * Only the following XHTML tags are supported: <b>, <i>, <img>, <a>.  The source must
 * be a well-formed XHTML fragment.  You do not need to enclose the source in an tag --
 * it can be any string with XHTML tags throughout.
 */
+ (TTStyledText*)textFromXHTML:(NSString*)source;

/**
 * Constructs styled text with all URLs transformed into links.
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

@interface TTStyledTextFrame : NSObject <TTStyleDelegate> {
  TTStyledTextNode* _node;
  TTStyledTextFrame* _nextFrame;
  TTStyle* _style;
  NSString* _text;
  UIFont* _font;
  CGFloat _width;
  CGFloat _height;
  BOOL _lineBreak;
}

/** 
 * The node represented by the frame
 */
@property(nonatomic, readonly) TTStyledTextNode* node;

/**
 * The next in the linked list of frames.
 */
@property(nonatomic, retain) TTStyledTextFrame* nextFrame;

/**
 * The style used to render the frame;
 */
@property(nonatomic, retain) TTStyle* style;

/**
 * The text that is displayed by this frame.
 */
@property(nonatomic, readonly) NSString* text;

/**
 * The font that is used to measure and display the text of this frame.
 */
@property(nonatomic, retain) UIFont* font;

/**
 * The width of the text that is displayed by this frame.
 */
@property(nonatomic) CGFloat width;

/**
 * The height of the text that is displayed by this frame.
 */
@property(nonatomic) CGFloat height;

/**
 * Indicates if the layout will break to a new line after this frame.
 */
@property(nonatomic) BOOL lineBreak;

- (id)initWithText:(NSString*)text node:(TTStyledTextNode*)node;

/**
 * Draws the frame.
 */
- (void)drawInRect:(CGRect)rect;

@end
