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
  TTStyledFrame* _lastFrame;
  UIFont* _baseFont;
  UIFont* _font;
  UIFont* _boldFont;
  UIFont* _italicFont;
  TTStyle* _linkStyle;
  TTStyledNode* _rootNode;
  TTStyledNode* _lastNode;
}

@property(nonatomic) CGFloat x;
@property(nonatomic) CGFloat width;
@property(nonatomic) CGFloat height;
@property(nonatomic) CGFloat lineWidth;
@property(nonatomic) CGFloat lineHeight;
@property(nonatomic) CGFloat maxWidth;
@property(nonatomic,readonly) CGFloat fontHeight;
@property(nonatomic,readonly) NSMutableArray* styleStack;
@property(nonatomic,assign) TTStyle* lastStyle;
@property(nonatomic,readonly) TTStyledFrame* rootFrame;
@property(nonatomic,readonly) TTStyledFrame* lineFirstFrame;
@property(nonatomic,readonly) TTStyledFrame* lastFrame;
@property(nonatomic,retain) UIFont* baseFont;
@property(nonatomic,retain) UIFont* font;
@property(nonatomic,retain) UIFont* boldFont;
@property(nonatomic,retain) UIFont* italicFont;
@property(nonatomic,retain) TTStyle* linkStyle;
@property(nonatomic,readonly) TTStyledNode* lastNode;

- (id)initWithRootNode:(TTStyledNode*)rootNode;

- (void)layout:(TTStyledNode*)node;
- (void)layout:(TTStyledNode*)node container:(TTStyledElement*)element;

@end
