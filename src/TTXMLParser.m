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
static NSString* kCommonType_DateTime = @"datetime";
NSString* kCommonXMLType_Unknown = @"unknown";

static NSString* kPrivateKey_EntityName = @"___Entity_Name___";
static NSString* kPrivateKey_EntityType = @"___Entity_Type___";
static NSString* kPrivateKey_EntityValue = @"___Entity_Value___";
static NSString* kPrivateKey_EntityBuffer = @"___Entity_Buffer___";
static NSString* kPrivateKey_Array = @"___Array___";


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation TTXMLParser

@synthesize rootObject                      = _rootObject;
@synthesize treatDuplicateKeysAsArrayItems  = _treatDuplicateKeysAsArrayItems;


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)parse {
  _objectStack = [[NSMutableArray alloc] init];

  self.delegate = self;

  BOOL result = [super parse];

  TT_RELEASE_SAFELY(_objectStack);

  return result;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)allocObjectForElementName: (NSString*) elementName
                     attributes: (NSDictionary*) attributeDict {
  id object = [[NSMutableDictionary alloc] init];
  if (!TTIsStringWithAnyText(elementName)) {
    elementName = @"";
  }

  NSString* type = [attributeDict objectForKey:kCommonKey_Type];

  if (!TTIsStringWithAnyText(type)) {
    type = kCommonXMLType_Unknown;
  }

  if ([type isEqualToString:kCommonType_Array]) {
    NSMutableArray* array = [[NSMutableArray alloc] init];
    [object setObject:array forKey:kPrivateKey_Array];
    TT_RELEASE_SAFELY(array);
  }

  for (id key in attributeDict) {
    [object setObject:[attributeDict objectForKey:key] forKey:key];
  }

  [object setObject:elementName forKey:kPrivateKey_EntityName];
  [object setObject:type forKey:kPrivateKey_EntityType];

  return object;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)addChild:(id)childObject toObject:(id)object {

  // Is this an internal common "array" type?
  if ([object isKindOfClass:[NSDictionary class]] &&
      [[object objectForKey:kPrivateKey_EntityType] isEqualToString:kCommonType_Array]) {

    // Yes, it is. Let's add this object to the array then.
    if (nil != childObject) {
      [[object objectForKey:kPrivateKey_Array] addObject:childObject];
    }

  // Is it an unknown dictionary type?
  } else if ([object isKindOfClass:[NSDictionary class]] &&
      [[object objectForKey:kPrivateKey_EntityType] isEqualToString:kCommonXMLType_Unknown]) {

    if (self.treatDuplicateKeysAsArrayItems) {
      NSString* entityName = [childObject objectForKey:kPrivateKey_EntityName];
      id entityObject = [object objectForKey:entityName];
      if (nil == entityObject) {
        // No collision, add it!
        [object setObject:childObject forKey:entityName];

      } else {
        // Collision, check if it's already an array.
        if (TTIsArrayWithItems(entityObject)) {
          [entityObject addObject:childObject];
        } else {
          NSMutableArray* array = [[NSMutableArray alloc] init];
          [array addObject:entityObject];
          [array addObject:childObject];
          [object setObject:array forKey:entityName];
          TT_RELEASE_SAFELY(array);
        }
      }

    } else {
      // Avoid overwriting existing keys.
      // If this is asserting, you probably need treatDuplicateKeysAsArrayItems set to YES.
      TTDASSERT(nil == [object objectForKey:[childObject objectForKey:kPrivateKey_EntityName]]);

      [object setObject:childObject forKey:[childObject objectForKey:kPrivateKey_EntityName]];
    }
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)addCharacters: (NSString*)characters toObject:(id)object {
  if ([object isKindOfClass:[NSDictionary class]] &&
      ([[object objectForKey:kPrivateKey_EntityType] isEqualToString:kCommonType_Integer] ||
       [[object objectForKey:kPrivateKey_EntityType] isEqualToString:kCommonType_DateTime])) {

    NSString* buffer = [object objectForKey:kPrivateKey_EntityBuffer];
    if (nil == buffer) {
      buffer = [[NSString alloc] init];
      [object setObject:buffer forKey:kPrivateKey_EntityBuffer];
      [buffer release];
    }
    buffer = [buffer stringByAppendingString:characters];
    [object setObject:buffer forKey:kPrivateKey_EntityBuffer];

  } else if ([object isKindOfClass:[NSDictionary class]]) {
      // It's an unknown dictionary type, let's just add this object then.
    NSString* value = [object objectForKey:kPrivateKey_EntityValue];
    if (nil == value) {
      value = [[NSString alloc] init];
      [object setObject:value forKey:kPrivateKey_EntityValue];
      [value release];
    }
    [object setObject:[value stringByAppendingString:characters] forKey:kPrivateKey_EntityValue];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)didFinishParsingObject:(id)object {
  if ([object isKindOfClass:[NSDictionary class]] &&
      [[object objectForKey:kPrivateKey_EntityType] isEqualToString:kCommonType_Integer]) {
    NSString* buffer = [object objectForKey:kPrivateKey_EntityBuffer];
    NSNumber* number = [[NSNumber alloc] initWithInt:[buffer intValue]];
    [object setObject:number forKey:kPrivateKey_EntityValue];
    TT_RELEASE_SAFELY(number);

    [object removeObjectForKey:kPrivateKey_EntityBuffer];

  } else if ([object isKindOfClass:[NSDictionary class]] &&
             [[object objectForKey:kPrivateKey_EntityType] isEqualToString:kCommonType_DateTime]) {
    NSString* buffer = [object objectForKey:kPrivateKey_EntityBuffer];

    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeStyle:NSDateFormatterFullStyle];
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZZZZ"];
    NSDate* date = [dateFormatter dateFromString:buffer];
    if (nil == date) {
      [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss'Z'"];
      date = [dateFormatter dateFromString:buffer];
    }

    if (nil != date) {
      [object setObject:date forKey:kPrivateKey_EntityValue];
    }
    TT_RELEASE_SAFELY(dateFormatter);

    [object removeObjectForKey:kPrivateKey_EntityBuffer];

  }
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

  [self didFinishParsingObject:[_objectStack lastObject]];

  if ([_objectStack count] == 1) {
    TTDASSERT(nil == _rootObject);
    _rootObject = [[_objectStack lastObject] retain];
  }

  // Now that we've finished a node, let's step back up the tree.
  [_objectStack removeLastObject];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError {
  TTDERROR(@"Error parsing the XML: %@", [parseError localizedDescription]);
}


@end


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation NSDictionary (TTXMLAdditions)


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSString*)nameForXMLNode {
  return [self objectForKey:kPrivateKey_EntityName];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSString*)typeForXMLNode {
  return [self objectForKey:kPrivateKey_EntityType];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)objectForXMLNode {
  if ([[self typeForXMLNode] isEqualToString:kCommonType_Array]) {
    return [self objectForKey:kPrivateKey_Array];
  } else {
    return [self objectForKey:kPrivateKey_EntityValue];
  }
}

@end

