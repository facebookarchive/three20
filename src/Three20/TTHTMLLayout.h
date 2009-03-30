#import "Three20/TTGlobal.h"

@class TTHTMLNode, TTHTMLFrame, TTHTMLNode;

@interface TTHTMLLayout : NSObject {
  TTHTMLNode* _html;
  TTHTMLFrame* _rootFrame;
  UIFont* _font;
  CGFloat _width;
  CGFloat _height;
  CGFloat _lineHeight;
  CGFloat _lastLineWidth;
}

@property(nonatomic, readonly) TTHTMLNode* html;
@property(nonatomic, readonly) TTHTMLFrame* rootFrame;
@property(nonatomic, retain) UIFont* font;
@property(nonatomic) CGFloat width;
@property(nonatomic, readonly) CGFloat height;
@property(nonatomic, readonly) CGFloat lastLineWidth;

- (id)initWithHTML:(TTHTMLNode*)html;

- (void)drawAtPoint:(CGPoint)point;
- (void)drawAtPoint:(CGPoint)point highlighted:(BOOL)highlighted;

- (TTHTMLFrame*)hitTest:(CGPoint)point;

@end

///////////////////////////////////////////////////////////////////////////////////////////////////

@interface TTHTMLFrame : NSObject {
  TTHTMLNode* _node;
  NSString* _text;
  TTHTMLFrame* _nextFrame;
  CGFloat _width;
  BOOL _lineBreak;
}

@property(nonatomic, readonly) TTHTMLNode* node;
@property(nonatomic, readonly) NSString* text;
@property(nonatomic, retain) TTHTMLFrame* nextFrame;
@property(nonatomic) CGFloat width;
@property(nonatomic) BOOL lineBreak;

- (id)initWithText:(NSString*)text node:(TTHTMLNode*)node;

@end
