#import "Three20/TTGlobal.h"

@class TTStyledTextNode;

@interface TTStyledTextParser : NSObject {
  TTStyledTextNode* _rootNode;
  TTStyledTextNode* _lastNode;
  TTStyledTextNode* _openNode;
  NSError* _parserError;
  NSMutableString* _chars;
}

@property(nonatomic, retain) TTStyledTextNode* rootNode;

- (void)parseXHTML:(NSString*)html;

- (void)parseURLs:(NSString*)string;

@end
