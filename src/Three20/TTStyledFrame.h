#import "Three20/TTStyle.h"

@class TTStyledElement, TTStyledTextNode, TTStyledImageNode;

@interface TTStyledFrame : NSObject {
  TTStyledElement* _element;
  TTStyledFrame* _nextFrame;
  TTStyle* _style;
  CGRect _bounds;
}

/** 
 * The element that contains the frame.
 */
@property(nonatomic,readonly) TTStyledElement* element;

/**
 * The next in the linked list of frames.
 */
@property(nonatomic,retain) TTStyledFrame* nextFrame;

/**
 * The style used to render the frame;
 */
@property(nonatomic,retain) TTStyle* style;

/**
 * The bounds of the content that is displayed by this frame.
 */
@property(nonatomic) CGRect bounds;
@property(nonatomic) CGFloat x;
@property(nonatomic) CGFloat y;
@property(nonatomic) CGFloat width;
@property(nonatomic) CGFloat height;

- (id)initWithElement:(TTStyledElement*)element;

/**
 * Draws the frame.
 */
- (void)drawInRect:(CGRect)rect;

@end

///////////////////////////////////////////////////////////////////////////////////////////////////

@interface TTStyledTextFrame : TTStyledFrame <TTStyleDelegate> {
  TTStyledTextNode* _node;
  NSString* _text;
  UIFont* _font;
}

/** 
 * The node represented by the frame.
 */
@property(nonatomic,readonly) TTStyledTextNode* node;

/**
 * The text that is displayed by this frame.
 */
@property(nonatomic,readonly) NSString* text;

/**
 * The font that is used to measure and display the text of this frame.
 */
@property(nonatomic,retain) UIFont* font;

- (id)initWithText:(NSString*)text element:(TTStyledElement*)element node:(TTStyledTextNode*)node;

@end

///////////////////////////////////////////////////////////////////////////////////////////////////

@interface TTStyledImageFrame : TTStyledFrame <TTStyleDelegate> {
  TTStyledImageNode* _imageNode;
}

/** 
 * The node represented by the frame.
 */
@property(nonatomic,readonly) TTStyledImageNode* imageNode;

- (id)initWithElement:(TTStyledElement*)element node:(TTStyledImageNode*)node;

@end
