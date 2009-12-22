//
// Copyright 2009-2010 Facebook
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//    http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

#import "Three20/TTXMLParser.h"

#import "Three20/TTGlobalCore.h"

static NSString* kCommonKey_Type = @"type";
static NSString* kCommonType_Array = @"array";
static NSString* kCommonType_Integer = @"integer";
static NSString* kCommonType_Unknown = @"unknown";

static NSString* kPrivateKey_EntityName = @"___Entity_Name___";
static NSString* kPrivateKey_EntityType = @"___Entity_Type___";
static NSString* kPrivateKey_EntityValue = @"___Entity_Value___";
static NSString* kPrivateKey_EntityBuffer = @"___Entity_Buffer___";
static NSString* kPrivateKey_Array = @"___Array___";


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation TTXMLParser


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithContentsOfURL:(NSURL *)url {
  if (self = [super initWithContentsOfURL:url]) {
    super.delegate = self;
  }

  return self;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithData:(NSData*)data {
  if (self = [super initWithData:data]) {
    super.delegate = self;
  }

  return self;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setResultDelegate:(id<TTXMLParserDelegate>)delegate {
  _resultDelegate = delegate;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id<TTXMLParserDelegate>)resultDelegate {
  return _resultDelegate;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)parse {
  _objectStack = [[NSMutableArray alloc] init];

  BOOL result = [super parse];

  TT_RELEASE_SAFELY(_objectStack);

  return result;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)allocObjectForElementName: (NSString*) elementName
                     attributes: (NSDictionary*) attributeDict {
  id object = nil;

  if ([_resultDelegate respondsToSelector:@selector(allocObjectForElementName:attributes:)]) {
    object = [_resultDelegate allocObjectForElementName:elementName attributes:attributeDict];
  }

  if (nil == object) {
    // At this point, we have no idea what this object is. Let's just create a dictionary.
    object = [[NSMutableDictionary alloc] init];
    if (!TTIsStringWithAnyText(elementName)) {
      elementName = @"";
    }

    NSString* type = [attributeDict objectForKey:kCommonKey_Type];

    if (!TTIsStringWithAnyText(type)) {
      type = kCommonType_Unknown;
    }

    if ([type isEqualToString:kCommonType_Array]) {
      NSMutableArray* array = [[NSMutableArray alloc] init];
      [object setObject:array forKey:kPrivateKey_Array];
      TT_RELEASE_SAFELY(array);
    }

    [object setObject:elementName forKey:kPrivateKey_EntityName];
    [object setObject:type forKey:kPrivateKey_EntityType];
  }

  return object;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)addChild:(id)childObject toObject:(id)object {
  // Is this an internal common "array" type?
  BOOL couldAddChild = NO;

  if ([_resultDelegate respondsToSelector:@selector(addChild:toObject:)]) {
    couldAddChild = [_resultDelegate addChild:childObject toObject:object];
  }

  if (!couldAddChild) {
    if ([object isKindOfClass:[NSDictionary class]] &&
        [[object objectForKey:kPrivateKey_EntityType] isEqualToString:kCommonType_Array]) {

      // Yes, it is. Let's add this object to the array then.
      if (nil != childObject) {
        [[object objectForKey:kPrivateKey_Array] addObject:childObject];
        couldAddChild = YES;
      }

    } else if ([object isKindOfClass:[NSDictionary class]] &&
        [[object objectForKey:kPrivateKey_EntityType] isEqualToString:kCommonType_Unknown]) {
      // It's an unknown dictionary type, let's just add this object then.
      [object setObject:childObject forKey:[childObject objectForKey:kPrivateKey_EntityName]];
      couldAddChild = YES;
    }
  }

  return couldAddChild;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)addCharacters: (NSString*)characters toObject:(id)object {
  BOOL couldAddCharacters = NO;

  if ([_resultDelegate respondsToSelector:@selector(addCharacters:toObject:)]) {
    couldAddCharacters = [_resultDelegate addCharacters:characters toObject:object];
  }

  if (!couldAddCharacters) {
    if ([object isKindOfClass:[NSDictionary class]] &&
        [[object objectForKey:kPrivateKey_EntityType] isEqualToString:kCommonType_Unknown]) {
      // It's an unknown dictionary type, let's just add this object then.
      NSString* value = [object objectForKey:kPrivateKey_EntityValue];
      if (nil == value) {
        value = [[NSString alloc] init];
        [object setObject:value forKey:kPrivateKey_EntityValue];
        [value release];
      }
      [object setObject:[value stringByAppendingString:characters] forKey:kPrivateKey_EntityValue];

      couldAddCharacters = YES;

    } else if ([object isKindOfClass:[NSDictionary class]] &&
        [[object objectForKey:kPrivateKey_EntityType] isEqualToString:kCommonType_Integer]) {

      NSString* buffer = [object objectForKey:kPrivateKey_EntityBuffer];
      if (nil == buffer) {
        buffer = [[NSString alloc] init];
        [object setObject:buffer forKey:kPrivateKey_EntityBuffer];
        [buffer release];
      }
      buffer = [buffer stringByAppendingString:characters];
      [object setObject:buffer forKey:kPrivateKey_EntityBuffer];

      NSNumber* number = [[NSNumber alloc] initWithInt:[buffer intValue]];
      [object setObject:number forKey:kPrivateKey_EntityValue];

      couldAddCharacters = YES;
    }
  }

  return couldAddCharacters;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)performCleanupForObject:(id)object {
  BOOL couldPerformCleanup = NO;

  if ([_resultDelegate respondsToSelector:@selector(performCleanupForObject:)]) {
    couldPerformCleanup = [_resultDelegate performCleanupForObject:object];
  }

  if (!couldPerformCleanup) {
    if ([object isKindOfClass:[NSDictionary class]] &&
        [[object objectForKey:kPrivateKey_EntityType] isEqualToString:kCommonType_Integer]) {
      [object removeObjectForKey:kPrivateKey_EntityBuffer];

    }
  }

  return couldPerformCleanup;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark NSXMLParserDelegateEventAdditions


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)         parser: (NSXMLParser*) parser
        didStartElement: (NSString*) elementName
           namespaceURI: (NSString*) namespaceURI
          qualifiedName: (NSString*) qName
             attributes: (NSDictionary*)attributeDict {
  id object = [self allocObjectForElementName:elementName attributes:attributeDict];

  if (nil == object) {
    object = [[NSNull null] retain];
  }

  if ([_objectStack count] > 0) {
    // The only case where there won't be anything on the stack is if this is the root node.
    [self addChild:object toObject:[_objectStack lastObject]];
  }

  [_objectStack addObject:object];

  TT_RELEASE_SAFELY(object);
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)         parser: (NSXMLParser*) parser
        foundCharacters: (NSString*) string {
  [self addCharacters:string toObject:[_objectStack lastObject]];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)         parser: (NSXMLParser*) parser
          didEndElement: (NSString*) elementName
           namespaceURI: (NSString*) namespaceURI
          qualifiedName: (NSString*) qName {

  [self performCleanupForObject:[_objectStack lastObject]];

  if ([_objectStack count] == 1) {
    [_resultDelegate didParseXML:[_objectStack lastObject]];
  }

  // Now that we've finished a node, let's step back up the tree.
  [_objectStack removeLastObject];
}


@end


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation NSDictionary (TTXMLAdditions)

- (id)objectForXMLValue {
  return [self objectForKey:kPrivateKey_EntityValue];
}

@end

