#import "Three20/TTGlobal.h"

@class TTHTMLNode, TTHTMLLayout, TTHTMLLinkNode;

/**
 * A view that can display HTML text.
 */
@interface TTHTMLView : UIView {
  TTHTMLNode* _html;
  TTHTMLLayout* _layout;
  UIFont* _font;
  UIColor* _textColor;
  UIColor* _linkTextColor;
  UIColor* _highlightedTextColor;
  BOOL _highlighted;
  TTHTMLLinkNode* _highlightedNode;
}

/**
 * The html text displayed by the view.
 *
 * Setting this will reset the layout and automatically re-compute it based on
 * the styles and dimensions of this view.
 */
@property(nonatomic, retain) TTHTMLNode* html;

/**
 * The layout calculations for the html to be displayed by the view.
 *
 * Settings this will set text to the html belonging to this layout.  If this layout
 * has already been computed for the dimensions of this view, it will not be re-computed.
 */
@property(nonatomic, retain) TTHTMLLayout* layout;

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

@end

///////////////////////////////////////////////////////////////////////////////////////////////////

/**
 * You must use TTHTMLTableView if you want links in your html to be touchable.
 */
@interface TTHTMLTableView : UITableView
@end
