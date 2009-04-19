#import "Three20/TTGlobal.h"

@interface TTStyledNode : NSObject {
  TTStyledNode* _nextSibling;
  TTStyledNode* _parentNode;
}

@property(nonatomic, retain) TTStyledNode* nextSibling;
@property(nonatomic, assign) TTStyledNode* parentNode;
@property(nonatomic, readonly) NSString* outerText;
@property(nonatomic, readonly) NSString* outerHTML;

- (id)initWithNextSibling:(TTStyledNode*)nextSibling;

- (id)firstParentOfClass:(Class)cls;

@end

///////////////////////////////////////////////////////////////////////////////////////////////////

@interface TTStyledTextNode : TTStyledNode {
  NSString* _text;
}

@property(nonatomic, retain) NSString* text;

- (id)initWithText:(NSString*)text;
- (id)initWithText:(NSString*)text next:(TTStyledNode*)nextSibling;

@end

///////////////////////////////////////////////////////////////////////////////////////////////////

@interface TTStyledElement : TTStyledNode {
  TTStyledNode* _firstChild;
  TTStyledNode* _lastChild;
  NSString* _className;
}

@property(nonatomic, readonly) TTStyledNode* firstChild;
@property(nonatomic, readonly) TTStyledNode* lastChild;
@property(nonatomic, retain) NSString* className;

- (id)initWithText:(NSString*)text;
- (id)initWithText:(NSString*)text next:(TTStyledNode*)nextSibling;

- (void)addChild:(TTStyledNode*)child;
- (void)addText:(NSString*)text;

@end

///////////////////////////////////////////////////////////////////////////////////////////////////

@interface TTStyledBlock : TTStyledElement
@end

///////////////////////////////////////////////////////////////////////////////////////////////////

@interface TTStyledInline : TTStyledElement
@end

///////////////////////////////////////////////////////////////////////////////////////////////////

@interface TTStyledBoldNode : TTStyledInline
@end

///////////////////////////////////////////////////////////////////////////////////////////////////

@interface TTStyledItalicNode : TTStyledInline
@end

///////////////////////////////////////////////////////////////////////////////////////////////////

@interface TTStyledLinkNode : TTStyledInline {
  NSString* _url;
  BOOL _highlighted;
}

@property(nonatomic) BOOL highlighted;
@property(nonatomic,retain) NSString* url;

- (id)initWithURL:(NSString*)url;
- (id)initWithURL:(NSString*)url next:(TTStyledNode*)nextSibling;
- (id)initWithText:(NSString*)text url:(NSString*)url next:(TTStyledNode*)nextSibling;

@end

///////////////////////////////////////////////////////////////////////////////////////////////////

@interface TTStyledImageNode : TTStyledElement {
  NSString* _url;
  UIImage* _image;
}

@property(nonatomic,retain) NSString* url;
@property(nonatomic,retain) UIImage* image;

- (id)initWithURL:(NSString*)url;

@end
