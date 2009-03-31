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
@property(nonatomic, retain) TTStyledTextNode* nextNode;

- (id)initWithText:(NSString*)text;
- (id)initWithText:(NSString*)text next:(TTStyledTextNode*)nextNode;

@end

///////////////////////////////////////////////////////////////////////////////////////////////////

@interface TTStyledBoldNode : TTStyledTextNode
@end

///////////////////////////////////////////////////////////////////////////////////////////////////

@interface TTStyledLinkNode : TTStyledTextNode {
  NSString* _url;
  BOOL _highlighted;
}

@property(nonatomic) BOOL highlighted;
@property(nonatomic,retain) NSString* url;

@end
