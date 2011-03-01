//
// Copyright 2009-2011 Facebook
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

#import "extThree20XML/TTXMLParser.h"

// Core
#import "Three20Core/TTGlobalCore.h"
#import "Three20Core/TTCorePreprocessorMacros.h"
#import "Three20Core/TTDebug.h"

// XML attribute keys.
static NSString* kCommonXMLKey_Type       = @"type";

// XML object types.
static NSString* kCommonXMLType_Array     = @"array";
static NSString* kCommonXMLType_Integer   = @"integer";
static NSString* kCommonXMLType_DateTime  = @"datetime";
       NSString* kCommonXMLType_Unknown   = @"unknown";

// Internal key names for the resulting NSDictionaries.
static NSString* kInternalKey_EntityName    = @"___Entity_Name___";
static NSString* kInternalKey_EntityType    = @"___Entity_Type___";
static NSString* kInternalKey_EntityValue   = @"___Entity_Value___";
static NSString* kInternalKey_Array         = @"___Array___";


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation TTXMLParser

@synthesize rootObject                      = _rootObject;
@synthesize treatDuplicateKeysAsArrayItems  = _treatDuplicateKeysAsArrayItems;


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)dealloc {
  TT_RELEASE_SAFELY(_rootObject);

  [super dealloc];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)parse {
  _objectStack = [[NSMutableArray alloc] init];

  self.delegate = self;

  BOOL result = [super parse];

  TT_RELEASE_SAFELY(_objectStack);

  return result;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
/**
 * Create an NSDictionary from the given XML node.
 * All XML attributes are added to the dictionary.
 */
- (id)allocObjectForElementName: (NSString*)elementName
                     attributes: (NSDictionary*)attributeDict {
  static const int kNumberOfInternalKeys = 3;

  id object = [[NSMutableDictionary alloc]
               initWithCapacity:kNumberOfInternalKeys + [attributeDict count]];
  if (!TTIsStringWithAnyText(elementName)) {
    elementName = @"";
  }

  NSString* type = [attributeDict objectForKey:kCommonXMLKey_Type];

  if (!TTIsStringWithAnyText(type)) {
    type = kCommonXMLType_Unknown;
  }

  if ([type isEqualToString:kCommonXMLType_Array]) {
    NSMutableArray* array = [[NSMutableArray alloc] init];
    [object setObject:array forKey:kInternalKey_Array];
    TT_RELEASE_SAFELY(array);
  }

  for (id key in attributeDict) {
    [object setObject:[attributeDict objectForKey:key] forKey:key];
  }

  [object setObject:elementName forKey:kInternalKey_EntityName];
  [object setObject:type        forKey:kInternalKey_EntityType];

  return object;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)addChildObject:(id)childObject toObject:(id)object {

  if ([object isKindOfClass:[NSDictionary class]]) {

    // Is this an internal common "array" type?
    if ([[object objectForKey:kInternalKey_EntityType]
         isEqualToString:kCommonXMLType_Array]) {

      // Yes, it is. Let's add this object to the array then.
      if (nil != childObject) {
        [[object objectForKey:kInternalKey_Array] addObject:childObject];
      }

    // Is it an unknown dictionary type?
    } else if ([[object objectForKey:kInternalKey_EntityType]
                isEqualToString:kCommonXMLType_Unknown]) {

      if (self.treatDuplicateKeysAsArrayItems) {
        NSString* entityName = [childObject objectForKey:kInternalKey_EntityName];
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
        TTDASSERT(nil == [object objectForKey:[childObject objectForKey:kInternalKey_EntityName]]);

        [object setObject:childObject forKey:[childObject objectForKey:kInternalKey_EntityName]];
      }
    }
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)addCharacters:(NSString*)characters toObject:(id)object {
  if ([object isKindOfClass:[NSDictionary class]]) {
    NSString* value = [object objectForKey:kInternalKey_EntityValue];
    if (nil == value) {
      value = [[NSString alloc] init];
      [object setObject:value forKey:kInternalKey_EntityValue];
      [value release];
    }
    [object setObject:[value stringByAppendingString:characters] forKey:kInternalKey_EntityValue];

  } else {
    // Not implemented, we're losing data here.
    TTDASSERT(false);
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
/**
 * Post-object parsing cleanup. Turns integers and dates into their respective NSObject types.
 */
- (void)didFinishParsingObject:(id)object {
  if ([object isKindOfClass:[NSDictionary class]] &&
      [[object objectForKey:kInternalKey_EntityType] isEqualToString:kCommonXMLType_Integer]) {
    NSString* buffer = [object objectForKey:kInternalKey_EntityValue];

    NSNumber* number = [[NSNumber alloc] initWithInt:[buffer intValue]];
    TTDASSERT(nil != number);
    if (nil != number) {
      [object setObject:number forKey:kInternalKey_EntityValue];
    }
    TT_RELEASE_SAFELY(number);

  } else if ([object isKindOfClass:[NSDictionary class]] &&
             [[object objectForKey:kInternalKey_EntityType]
              isEqualToString:kCommonXMLType_DateTime]) {
    NSString* buffer = [object objectForKey:kInternalKey_EntityValue];

    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeStyle:NSDateFormatterFullStyle];
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZZZZ"];
    NSDate* date = [dateFormatter dateFromString:buffer];
    if (nil == date) {
      [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss'Z'"];
      date = [dateFormatter dateFromString:buffer];
    }

    if (nil != date) {
      [object setObject:date forKey:kInternalKey_EntityValue];

    } else {
      // We weren't able to parse the date properly, so the value at this node has been left as
      // a string.
      TTDPRINT(@"Unparseable date: %@", buffer);
      TTDASSERT(false);
    }
    TT_RELEASE_SAFELY(dateFormatter);
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
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
    [self addChildObject:object toObject:[_objectStack lastObject]];
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
    TT_RELEASE_SAFELY(_rootObject);
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
  return [self objectForKey:kInternalKey_EntityName];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSString*)typeForXMLNode {
  return [self objectForKey:kInternalKey_EntityType];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)objectForXMLNode {
  if ([[self typeForXMLNode] isEqualToString:kCommonXMLType_Array]) {
    return [self objectForKey:kInternalKey_Array];

  } else {
    return [self objectForKey:kInternalKey_EntityValue];
  }
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSArray*)arrayForKey:(id)key {
  id object = [self objectForKey:key];

  // if it's not an array, then make it a 1-element array
  if (![object isKindOfClass:[NSArray class]]) {
    object = [NSArray arrayWithObject:object];
  }

  return object;
}

@end

