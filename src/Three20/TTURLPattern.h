#import "Three20/TTURLMap.h"

@protocol TTURLPatternText;

@interface TTURLPattern : NSObject {
  TTNavigationMode _navigationMode;
  NSString* _URL;
  NSString* _parentURL;
  id _targetObject;
  Class _targetClass;
  SEL _selector;
  NSInteger _transition;
  NSString* _scheme;
  NSMutableArray* _path;
  NSMutableDictionary* _query;
  id<TTURLPatternText> _fragment;
  NSInteger _specificity;
  NSInteger _argumentCount;
}

@property(nonatomic,readonly) TTNavigationMode navigationMode;
@property(nonatomic,readonly) NSString* scheme;
@property(nonatomic,copy) NSString* URL;
@property(nonatomic,copy) NSString* parentURL;
@property(nonatomic,assign) id targetObject;
@property(nonatomic) Class targetClass;
@property(nonatomic) SEL selector;
@property(nonatomic) NSInteger transition;
@property(nonatomic) NSInteger specificity;
@property(nonatomic) NSInteger argumentCount;
@property(nonatomic,readonly) BOOL isUniversal;
@property(nonatomic,readonly) BOOL isFragment;

- (id)initWithMode:(TTNavigationMode)navigationMode target:(id)target;

- (void)compileForObject;
- (void)compileForString;

- (BOOL)matchURL:(NSURL*)URL;

- (id)invoke:(id)target withURL:(NSURL*)URL query:(NSDictionary*)query;

- (id)createObjectFromURL:(NSURL*)URL query:(NSDictionary*)query;
- (NSString*)generateURLFromObject:(id)object;

@end
