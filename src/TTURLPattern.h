#import "Three20/TTAppMap.h"

@interface TTURLPattern : NSObject {
  TTDisplayMode _displayMode;
  NSString* _URL;
  NSURL* _parentURL;
  id _targetObject;
  Class _targetClass;
  SEL _selector;
  NSString* _scheme;
  NSMutableArray* _path;
  NSMutableDictionary* _query;
  NSInteger _specificity;
  NSInteger _argumentCount;
}

@property(nonatomic,readonly) TTDisplayMode displayMode;
@property(nonatomic,copy) NSString* URL;
@property(nonatomic,copy) NSURL* parentURL;
@property(nonatomic,assign) id targetObject;
@property(nonatomic) Class targetClass;
@property(nonatomic) SEL selector;
@property(nonatomic) NSInteger specificity;
@property(nonatomic) NSInteger argumentCount;
@property(nonatomic,readonly) BOOL isUniversal;

- (id)initWithType:(TTDisplayMode)displayMode target:(id)target;

- (void)compile;

- (BOOL)matchURL:(NSURL*)URL;

- (id)invokeSelectorForTarget:(id)target withURL:(NSURL*)URL;

@end
