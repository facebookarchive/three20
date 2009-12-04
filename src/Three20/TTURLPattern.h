/**
 * Copyright 2009 Facebook
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

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
