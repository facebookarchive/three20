#import "Three20/TTGlobal.h"

@class TTStyle, TTStyledNode, TTStyledElement, TTStyledFrame, TTStyledBoxFrame, TTStyledInlineFrame;

@interface TTStyledLayout : NSObject {
  CGFloat _x;
  CGFloat _width;
  CGFloat _height;
  CGFloat _lineWidth;
  CGFloat _lineHeight;
  CGFloat _minX;
  CGFloat _floatLeftWidth;
  CGFloat _floatRightWidth;
  CGFloat _floatHeight;
  TTStyledFrame* _rootFrame;
  TTStyledFrame* _lineFirstFrame;
  TTStyledInlineFrame* _inlineFrame;
  TTStyledBoxFrame* _topFrame;
  TTStyledFrame* _lastFrame;
  UIFont* _font;
  UIFont* _boldFont;
  UIFont* _italicFont;
  TTStyle* _linkStyle;
  TTStyledNode* _rootNode;
  TTStyledNode* _lastNode;
}

@property(nonatomic) CGFloat width;
@property(nonatomic) CGFloat height;
@property(nonatomic,retain) UIFont* font;
@property(nonatomic,readonly) TTStyledFrame* rootFrame;

- (id)initWithRootNode:(TTStyledNode*)rootNode;

- (void)layout:(TTStyledNode*)node;
- (void)layout:(TTStyledNode*)node container:(TTStyledElement*)element;

@end
