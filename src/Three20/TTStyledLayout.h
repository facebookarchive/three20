#import "Three20/TTGlobal.h"

@class TTStyle, TTStyledNode, TTStyledElement, TTStyledFrame;

@interface TTStyledLayout : NSObject {
  CGFloat _x;
  CGFloat _width;
  CGFloat _height;
  CGFloat _lineWidth;
  CGFloat _lineHeight;
  CGFloat _maxWidth;
  NSMutableArray* _styleStack;
  TTStyle* _lastStyle;
  TTStyledFrame* _rootFrame;
  TTStyledFrame* _lineFirstFrame;
  TTStyledFrame* _inlineFrame;
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
@property(nonatomic) CGFloat maxWidth;
@property(nonatomic,readonly) TTStyledFrame* rootFrame;
@property(nonatomic,retain) UIFont* font;

- (id)initWithRootNode:(TTStyledNode*)rootNode;

- (void)layout:(TTStyledNode*)node;
- (void)layout:(TTStyledNode*)node container:(TTStyledElement*)element;

@end
