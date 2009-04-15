#import "Three20/TTGlobal.h"

@class TTStyledTextNode;

/**
 * The parser and DOM are still a very immature work-in-progress.  As of this writing,
 * this code is very experimental.
 */
@interface TTStyledTextNode : NSObject {
  NSString* _text;
  TTStyledTextNode* _nextNode;
}

@property(nonatomic, retain) NSString* text;
@property(nonatomic, readonly) NSString* plainText;
@property(nonatomic, retain) TTStyledTextNode* nextNode;

- (id)initWithText:(NSString*)text;
- (id)initWithText:(NSString*)text next:(TTStyledTextNode*)nextNode;

@end

///////////////////////////////////////////////////////////////////////////////////////////////////

@interface TTStyledSpanNode : TTStyledTextNode {
  NSString* _className;
}

@property(nonatomic, retain) NSString* className;

@end

///////////////////////////////////////////////////////////////////////////////////////////////////

@interface TTStyledBoldNode : TTStyledSpanNode
@end

///////////////////////////////////////////////////////////////////////////////////////////////////

@interface TTStyledItalicNode : TTStyledSpanNode
@end

///////////////////////////////////////////////////////////////////////////////////////////////////

@interface TTStyledLinkNode : TTStyledSpanNode {
  NSString* _url;
  BOOL _highlighted;
}

@property(nonatomic) BOOL highlighted;
@property(nonatomic,retain) NSString* url;

- (id)initWithText:(NSString*)text url:(NSString*)url next:(TTStyledTextNode*)nextNode;

@end

///////////////////////////////////////////////////////////////////////////////////////////////////

@interface TTStyledImageNode : TTStyledTextNode {
  NSString* _url;
  UIImage* _image;
}

@property(nonatomic,retain) NSString* url;
@property(nonatomic,retain) UIImage* image;

@end
