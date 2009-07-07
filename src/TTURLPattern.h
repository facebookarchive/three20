#import "Three20/TTAppMap.h"

@interface TTURLPattern : NSObject {
  TTLaunchType _launchType;
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

@property(nonatomic,readonly) TTLaunchType launchType;
@property(nonatomic,copy) NSString* URL;
@property(nonatomic,copy) NSURL* parentURL;
@property(nonatomic,assign) id targetObject;
@property(nonatomic) Class targetClass;
@property(nonatomic) SEL selector;
@property(nonatomic) NSInteger specificity;
@property(nonatomic) NSInteger argumentCount;
@property(nonatomic,readonly) BOOL isUniversal;

- (id)initWithType:(TTLaunchType)launchType;

- (void)setTargetOrClass:(id)target;

- (BOOL)matchURL:(NSURL*)URL;
- (void)setArgumentsFromURL:(NSURL*)URL forInvocation:(NSInvocation*)invocation;

@end
