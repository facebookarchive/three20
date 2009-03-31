#import "Three20/TTGlobal.h"

@class TTStyledText, TTStyledLinkNode;

/**
 * A view that can display styled text.
 */
@interface TTStyledLabel : UIView {
  TTStyledText* _text;
  UIFont* _font;
  UIColor* _textColor;
  UIColor* _linkTextColor;
  UIColor* _highlightedTextColor;
  BOOL _highlighted;
  TTStyledLinkNode* _highlightedNode;
}

/**
 * The styled text displayed by the view.
 *
 * Settings this will set text to the html belonging to this layout.  If this layout
 * has already been computed for the dimensions of this view, it will not be re-computed.
 */
@property(nonatomic, retain) TTStyledText* text;

/**
 * The font of the text.
 */
@property(nonatomic, retain) UIFont* font;

/**
 * The color of the text.
 */
@property(nonatomic, retain) UIColor* textColor;

/**
 * The color applied to links in the html.
 */
@property(nonatomic, retain) UIColor* linkTextColor;

/**
 * The highlight color applied to the label’s text.
 */
@property(nonatomic, retain) UIColor* highlightedTextColor;

/**
 * A Boolean value indicating whether the receiver should be drawn with a highlight.
 */
@property(nonatomic) BOOL highlighted;

@property(nonatomic,retain) TTStyledLinkNode* highlightedNode;

@end

///////////////////////////////////////////////////////////////////////////////////////////////////

/**
 * You must use TTStyledTextTableView if you want links in your html to be touchable.
 */
@interface TTStyledTextTableView : UITableView {
  TTStyledLabel* _highlightedLabel;
  CGPoint _highlightStartPoint;
}

@property(nonatomic,retain) TTStyledLabel* highlightedLabel;

@end
