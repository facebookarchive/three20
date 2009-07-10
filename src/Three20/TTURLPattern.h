#import "Three20/TTURLMap.h"

@interface TTURLPattern : NSObject {
  TTNavigationMode _navigationMode;
  NSString* _URL;
  NSString* _parentURL;
  id _targetObject;
  Class _targetClass;
  SEL _selector;
  NSString* _scheme;
  NSMutableArray* _path;
  NSMutableDictionary* _query;
  NSInteger _specificity;
  NSInteger _argumentCount;
}

@property(nonatomic,readonly) TTNavigationMode navigationMode;
@property(nonatomic,copy) NSString* URL;
@property(nonatomic,copy) NSString* parentURL;
@property(nonatomic,assign) id targetObject;
@property(nonatomic) Class targetClass;
@property(nonatomic) SEL selector;
@property(nonatomic) NSInteger specificity;
@property(nonatomic) NSInteger argumentCount;
@property(nonatomic,readonly) BOOL isUniversal;

- (id)initWithMode:(TTNavigationMode)navigationMode target:(id)target;

- (void)compile;

- (BOOL)matchURL:(NSURL*)URL;

- (id)invoke:(id)target withURL:(NSURL*)URL query:(NSDictionary*)query;

@end
