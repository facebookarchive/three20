#import "Three20/TTStyledText.h"

@class TTStyledElement, TTStyledBoxFrame, TTStyle;

/**
 * A view that can display styled text.
 */
@interface TTStyledTextLabel : UIView <TTStyledTextDelegate> {
  TTStyledText* _text;
  UIFont* _font;
  UIColor* _textColor;
  UIColor* _highlightedTextColor;
  UITextAlignment _textAlignment;
  UIEdgeInsets _contentInset;
  BOOL _highlighted;
  TTStyledElement* _highlightedNode;
  TTStyledBoxFrame* _highlightedFrame;
}

/**
 * The styled text displayed by the label.
 */
@property(nonatomic, retain) TTStyledText* text;

/**
 * A shortcut for setting the text property to an HTML string.
 */
@property(nonatomic, copy) NSString* html;

/**
 * The font of the text.
 */
@property(nonatomic, retain) UIFont* font;

/**
 * The color of the text.
 */
@property(nonatomic, retain) UIColor* textColor;

/**
 * The highlight color applied to the text.
 */
@property(nonatomic, retain) UIColor* highlightedTextColor;

/**
 * The alignment of the text. (NOT YET IMPLEMENTED)
 */
@property(nonatomic) UITextAlignment textAlignment;

/** 
 * The inset of the edges around the text.
 *
 * This will increase the size of the label when sizeToFit is called.
 */
@property(nonatomic) UIEdgeInsets contentInset;

/**
 * A Boolean value indicating whether the receiver should be drawn with a highlight.
 */
@property(nonatomic) BOOL highlighted;

/**
 * The link node which is being touched and highlighted by the user.
 */
@property(nonatomic,retain) TTStyledElement* highlightedNode;

@end
