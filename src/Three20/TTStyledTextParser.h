#import "Three20/TTGlobal.h"

@class TTStyledNode, TTStyledElement;

@interface TTStyledTextParser : NSObject {
  TTStyledNode* _rootNode;
  TTStyledElement* _topElement;
  TTStyledNode* _lastNode;
  NSError* _parserError;
  NSMutableString* _chars;
  NSMutableArray* _stack;
  BOOL _parseLineBreaks;
  BOOL _parseURLs;
}

@property(nonatomic, retain) TTStyledNode* rootNode;
@property(nonatomic) BOOL parseLineBreaks;
@property(nonatomic) BOOL parseURLs;

- (void)parseXHTML:(NSString*)html;
- (void)parseText:(NSString*)string;

@end
