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

#import <Foundation/Foundation.h>

extern NSString* kCommonXMLType_Unknown;

/**
 * An implementation of the NSXMLParser object that turns XML into NSObjects.
 *
 * Uses a simple stack-based traversal of the XML document to recursively create the objects
 * at each level. Upon successful completion, rootObject will be an NSDictionary object.
 *
 * To traverse the resulting NSObject hierarchy, use the NSDictionary additions provided at the end
 * of this file to access the XML entity name, type, and object. For example:
 *
 * <?xml version="1.0" encoding="UTF-8"?>
 * <issues type="array">
 *  <issue>
 *    <number type="integer">3</number>
 *  </issue>
 *  <issue>
 *    <number type="integer">10</number>
 *  </issue>
 * </issues>
 *
 * Logic to parse the above XML as an NSData* object:
 *
 *     TTXMLParser* parser = [[TTXMLParser alloc] initWithData:xmlData];
 *     [parser parse];
 *
 * parser.rootObject will become the following NSObject:
 *
 * rootObject => NSDictionary* (root)
 *          <key>         <value>
 *  - ___Entity_Name___:  "issues"
 *  - ___Entity_Type___:  "array"
 *  - ___Entity_Value___: NSArray of NSDictionaries, accessed with [rootObject objectForXMLNode]
 *
 * [rootObject objectForXMLNode] => NSArray* of NSDictionaries
 * Each item of the NSArray is an NSDictionary*:
 * foreach item in array:
 *   - ___Entity_Name___:  "issue"
 *   - ___Entity_Type___:  kCommonXMLType_Unknown
 *   - ___Entity_Value___: NSDictionary*
 * etc...
 *
 * Implementation note: This class is designed as a simple means of parsing XML documents. It has
 * not been optimized for speed or memory usage, and has only been tested with documents less than
 * one MB (megabyte) in size.
 */
@interface TTXMLParser : NSXMLParser {
@private
  id              _rootObject;

  BOOL            _treatDuplicateKeysAsArrayItems;

  NSMutableArray* _objectStack;
}

/**
 * Only valid after [parser parse] has been called.
 *
 * Will return an NSDictionary* after successful parsing.
 */
@property (nonatomic, readonly) id    rootObject;

/**
 * When a duplicate key is encountered, the key's value is turned into an array and both
 * the original item and the new duplicate item are added to the array. Any subsequent duplicates
 * are also added to this array.
 * This is useful for RSS feeds, where feed items are presented inline (and not as array items).
 *
 * @default NO
 */
@property (nonatomic, assign)   BOOL  treatDuplicateKeysAsArrayItems;

@end


/**
 * Additions for accessing TTXMLParser results.
 */
@interface NSDictionary (TTXMLAdditions)

/**
 * @return The XML entity name.
 */
- (NSString*)nameForXMLNode;

/**
 * @return The XML entity type.
 */
- (NSString*)typeForXMLNode;

/**
 * @return The XML processed value for this object.
 */
- (id)objectForXMLNode;

/**
 * @return Performs an "objectForKey", then puts the object into an array. If the
 * object is already an array, that array is returned.
 */
- (NSArray*)arrayForKey:(id)key;

@end
