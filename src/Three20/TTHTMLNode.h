#import "Three20/TTGlobal.h"

@class TTHTMLNode;

/**
 * The HTML DOM and parser are still a very immature work-in-progress.  As of this writing,
 * this code is very experimental.
 */
@interface TTHTMLNode : NSObject {
  TTHTMLNode* _nextNode;
}

/**
 * Constructs a tree of HTML nodes from a well-formatted XHTML string.
 *
 * NOT YET IMPLEMENTED.
 */
+ (TTHTMLNode*)htmlFromXHTMLString:(NSString*)string;

/**
 * Constructs a tree of HTML nodes from a string containing URLs.
 *
 * Only URLs are parsed, not HTML markup. URLs are turned into links.
 */ 
+ (TTHTMLNode*)htmlFromURLString:(NSString*)string;

@property(nonatomic, retain) TTHTMLNode* nextNode;

@end

///////////////////////////////////////////////////////////////////////////////////////////////////

@interface TTHTMLText : TTHTMLNode {
  NSString* _text;
}

@property(nonatomic,retain) NSString* text;

- (id)initWithText:(NSString*)text;
- (id)initWithText:(NSString*)text next:(TTHTMLNode*)nextNode;

@end

///////////////////////////////////////////////////////////////////////////////////////////////////

@interface TTHTMLBoldNode : TTHTMLText
@end

///////////////////////////////////////////////////////////////////////////////////////////////////

@interface TTHTMLLinkNode : TTHTMLText {
  BOOL _highlighted;
}

@property(nonatomic) BOOL highlighted;

@end
