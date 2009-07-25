#import "Three20/TTURLMap.h"

@protocol TTURLPatternText;

@interface TTURLPattern : NSObject {
  NSString* _URL;
  NSString* _scheme;
  NSMutableArray* _path;
  NSMutableDictionary* _query;
  id<TTURLPatternText> _fragment;
  NSInteger _specificity;
  SEL _selector;
}

@property(nonatomic,copy) NSString* URL;
@property(nonatomic,readonly) NSString* scheme;
@property(nonatomic,readonly) NSInteger specificity;
@property(nonatomic,readonly) Class classForInvocation;
@property(nonatomic) SEL selector;

- (void)setSelectorIfPossible:(SEL)selector;

- (void)compileURL;

@end

///////////////////////////////////////////////////////////////////////////////////////////////////

@interface TTURLNavigatorPattern : TTURLPattern {
  Class _targetClass;
  id _targetObject;
  TTNavigationMode _navigationMode;
  NSString* _parentURL;
  NSInteger _transition;
  NSInteger _argumentCount;
}

@property(nonatomic) Class targetClass;
@property(nonatomic,assign) id targetObject;
@property(nonatomic,readonly) TTNavigationMode navigationMode;
@property(nonatomic,copy) NSString* parentURL;
@property(nonatomic) NSInteger transition;
@property(nonatomic) NSInteger argumentCount;
@property(nonatomic,readonly) BOOL isUniversal;
@property(nonatomic,readonly) BOOL isFragment;

- (id)initWithTarget:(id)target;
- (id)initWithTarget:(id)target mode:(TTNavigationMode)navigationMode;

- (void)compile;

- (BOOL)matchURL:(NSURL*)URL;

- (id)invoke:(id)target withURL:(NSURL*)URL query:(NSDictionary*)query;
- (id)createObjectFromURL:(NSURL*)URL query:(NSDictionary*)query;

@end

///////////////////////////////////////////////////////////////////////////////////////////////////

@interface TTURLGeneratorPattern : TTURLPattern {
  Class _targetClass;
}

@property(nonatomic) Class targetClass;

- (id)initWithTargetClass:(Class)targetClass;

- (void)compile;
- (NSString*)generateURLFromObject:(id)object;

@end
