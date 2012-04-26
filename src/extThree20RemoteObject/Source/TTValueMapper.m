//
// Copyright 2012 RIKSOF
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

#import "TTValueMapper.h"
#import "TTObjectModelCollection.h"

@implementation TTValueMapper

#pragma mark - Value Mapping

/**
 * Do the value mapping for given class.
 */
- (BOOL)documentToObjectForClass:(Class)valueClass object:(id)object property:(NSString *)property values:(id)values value:(id)value {
    void(^conversionBlock)(id, NSString *, __unsafe_unretained Class, id, id) = nil;
    
    // Loop through the keys to find best match.
    for ( int i = 0; i < keysForDocumentToObjectMappers.count; i++ ) {
        Class currentKey = [keysForDocumentToObjectMappers objectAtIndex:i];
        
        // If we encounter the default key, set it. When we go out of the loop
        // and we have not found another matching entry, this will be used.
        if ( currentKey == [NSNull null] ) {
            conversionBlock = [documentToObjectMappers objectAtIndex:i];
            
        } else if ( [valueClass isSubclassOfClass:currentKey] ) {
            // We have found the best matching key.
            conversionBlock = [documentToObjectMappers objectAtIndex:i];
            break;
        }
    }
    
    // If we found it, use the conversion block.
    if ( conversionBlock != nil ) {
        conversionBlock(object, property, valueClass, values, value);
    }
    
    return YES;
}

/**
 * Map from object to XML document for given class.
 */
- (BOOL)objectToDocumentForClass:(Class)valueClass document:(id)document property:(NSString *)property 
                       mode:(int)mode value:(id)value {
    void(^conversionBlock)(id, NSString *, int, id) = nil;
    
    // Loop through the keys to find best match.
    for ( int i = 0; i < keysForObjectToDocumentMappers.count; i++ ) {
        Class currentKey = [keysForObjectToDocumentMappers objectAtIndex:i];
        
        // If we encounter the default key, set it. When we go out of the loop
        // and we have not found another matching entry, this will be used.
        if ( currentKey == [NSNull null] ) {
            conversionBlock = [objectToDocumentMappers objectAtIndex:i];
            
        } else if ( [valueClass isSubclassOfClass:currentKey] || [value isKindOfClass:currentKey] ) {
            // We have found the best matching key.
            conversionBlock = [objectToDocumentMappers objectAtIndex:i];
            break;
        }
    }
    
    // If we found it, use the conversion block.
    if ( conversionBlock != nil ) {
        conversionBlock(document, property, mode, value);
    }
    
    return YES;
}

#pragma mark - Manage Mappers

/**
 * Adds a new mapper to map value from document to the given value class. If there was a mapper associated with
 * this class, it gets overwritten.
 *
 * For the actual mapping, a code block with the following arguments is given:
 *
 * 1. Reference to the local receipent of the XML value.
 * 2. Property name to be set.
 * 3. Class of property.
 * 4. Values array.
 * 5. Single value
 *
 * The code block will map the value to the value that can be correctly set in the member property. It can use
 * either the values array or the single value depending on its own requirements.
 */
- (void)addDocumentToObjectMapperForClass:(Class)valueClass 
                          conversionBlock:(void(^)(id, NSString *, __unsafe_unretained Class, id, id))conversionBlock {
    int i;
    
    // Loop through the keys to find best match.
    for ( i = 0; i < keysForDocumentToObjectMappers.count; i++ ) {
        Class currentKey = [keysForDocumentToObjectMappers objectAtIndex:i];
        
        // We have found the best matching key.
        if ( valueClass == currentKey ) {
            [documentToObjectMappers replaceObjectAtIndex:i withObject:[conversionBlock copy]];
            
            // Update the keys.
            [keysForDocumentToObjectMappers replaceObjectAtIndex:i withObject:valueClass];
            
            break;
        }
    }
    
    // If a matching entry is not found, then insert a new one.
    if ( i == keysForDocumentToObjectMappers.count ) {
    
        [documentToObjectMappers addObject:[conversionBlock copy]];
    
        // Update the keys.
        [keysForDocumentToObjectMappers addObject:valueClass];
    }
}

/**
 * Remove previously set mapper.
 */
- (void)removeDocumentToObjectMapperForClass:(Class)valueClass {
    
    // Loop through the keys to find best match.
    for ( int i = 0; i < keysForDocumentToObjectMappers.count; i++ ) {
        Class currentKey = [keysForDocumentToObjectMappers objectAtIndex:i];
        
        // We have found the best matching key.
        if ( valueClass == currentKey ) {
            [documentToObjectMappers removeObjectAtIndex:i];
            [keysForDocumentToObjectMappers removeObjectAtIndex:i];
            break;
        }
    }
}

/**
 * Adds a new mapper to map value from object to the given element in document. If there was a mapper associated with
 * this class, it gets overwritten.
 *
 * For the actual mapping, a code block with the following arguments is given:
 *
 * 1. Reference to the document.
 * 2. Property name to be set.
 * 3. Boolean to indicate if we are setting an attribute or an element.
 * 4. Value to be set for this property.
 *
 * The code block will map the value to the value that can be correctly set in the member property.
 */
- (void)addObjectToDocumentMapperForClass:(Class)valueClass conversionBlock:(void(^)(id, NSString *, int, id))conversionBlock {
    
    int i;
    
    // Loop through the keys to find best match.
    for ( i = 0; i < keysForObjectToDocumentMappers.count; i++ ) {
        Class currentKey = [keysForObjectToDocumentMappers objectAtIndex:i];
        
        // We have found the best matching key.
        if ( valueClass == currentKey ) {
            [objectToDocumentMappers replaceObjectAtIndex:i withObject:[conversionBlock copy]];
            
            // Update the keys.
            [keysForObjectToDocumentMappers replaceObjectAtIndex:i withObject:valueClass];
            
            break;
        }
    }
    
    if ( i == keysForObjectToDocumentMappers.count ) {
    
        [objectToDocumentMappers addObject:[conversionBlock copy]];
    
        // Update the keys
        [keysForObjectToDocumentMappers addObject:valueClass];
    }
}

/**
 * Remove previously set mapper.
 */
- (void)removeObjectToDocumentMapperForClass:(Class)valueClass {
    // Loop through the keys to find best match.
    for ( int i = 0; i < keysForObjectToDocumentMappers.count; i++ ) {
        Class currentKey = [keysForObjectToDocumentMappers objectAtIndex:i];
        
        // We have found the best matching key.
        if ( valueClass == currentKey ) {
            [objectToDocumentMappers removeObjectAtIndex:i];
            [keysForObjectToDocumentMappers removeObjectAtIndex:i];
            break;
        }
    }
}

#pragma mark - Initializations

/**
 * Initialize the dictionaries that holds the mappers.
 */
- (id)init {
    if ( (self = [super init] ) ) {
        keysForDocumentToObjectMappers = [[NSMutableArray alloc] init];
        documentToObjectMappers = [[NSMutableArray alloc] init];
        keysForObjectToDocumentMappers = [[NSMutableArray alloc] init];
        objectToDocumentMappers = [[NSMutableArray alloc] init];
    }
    
    return self;
}

/**
 * Special initialization specifically for making a copy.
 */
- (id)initWithCopyOfMapper:(NSArray *)documentToObject keysDocToObj:(NSArray *)keysDocToObj 
          objectToDocument:(NSArray *)objectToDocument keysObjToDoc:(NSArray *)keysObjToDoc {
    if ( (self = [super init] ) ) {
        documentToObjectMappers = [documentToObject copy];
        objectToDocumentMappers = [objectToDocument copy];
        
        // Copy the keys in a loop as it does not copy the NSNull (Default) key using the
        // copy method.
        keysForDocumentToObjectMappers = [[NSMutableArray alloc] initWithCapacity:keysDocToObj.count];
        for ( int i = 0; i < keysDocToObj.count; i++ ) {
            [keysForDocumentToObjectMappers addObject:[keysDocToObj objectAtIndex:i]];
        }
        
        keysForObjectToDocumentMappers = [[NSMutableArray alloc] initWithCapacity:keysObjToDoc.count];
        for ( int i = 0; i < keysObjToDoc.count; i++ ) {
            [keysForObjectToDocumentMappers addObject:[keysObjToDoc objectAtIndex:i]];
        }
     }
    return self;
}

#pragma mark - Shared Instance

/**
 * This instance is the default mappers that is assigned to any object.
 * Each object has a copy of this mapper that they can then modify to 
 * suit their needs.
 */
+ (TTValueMapper *)sharedInstance {
    
    static TTValueMapper *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[TTValueMapper alloc] init];
        
        // We add the basic document to object mappers here.
        [sharedInstance addDocumentToObjectMapperForClass:[TTObjectModelCollection class] conversionBlock:
         ^(id object, NSString *propertyName, __unsafe_unretained Class typeClass, id values, id value) {
             // This is a new collection. Set up a new instance, if the
             // current one is nil.
             TTObjectModelCollection *collection = [object valueForKey:propertyName];
             
             if ( collection == nil ) {
                 collection = [[typeClass alloc] init];
                 
                 // Set the document format.
                 collection.documentFormat = [object documentFormat];
                 
                 // Set this collection.
                 [object setValue:collection forKey:propertyName];
             }
             
             // Load data in to the collection.
             [collection loadWithArray:values];
            
         }];
        
        [sharedInstance addDocumentToObjectMapperForClass:[TTObjectModel class] conversionBlock:
         ^(id object, NSString *propertyName, __unsafe_unretained Class typeClass, id values, id value) {
             // Does this property already have data?
             TTObjectModel *sp = [object valueForKey:propertyName];
             
             // If it does not, initialize the property in memory.
             if ( sp == nil ) {
                 // Setting a single object.
                 sp = [[typeClass alloc] init];
                 sp.documentFormat = [object documentFormat];
                 [sp decodeFromDocument:value];
                 [object setValue:sp forKey:propertyName];
             } else {
                 // Otherwise, the object already exists, so just 
                 // update the values.
                 sp.documentFormat = [object documentFormat];
                 [sp decodeFromDocument:value];
             }
         }];
        
        // Finally set the default mapper.
        [sharedInstance addDocumentToObjectMapperForClass:(Class)[NSNull null] conversionBlock:
         ^(id object, NSString *property, __unsafe_unretained Class typeClass, id values, id value) {
            
             // Just set the value directly. We can expect to receive an a basic type, NSString
             // or a GDataXMLElement. Check the type and set the value accordingly.
#ifdef EXT_REMOTE_XML             
             if ( [value class] == [GDataXMLElement class]  ) {
                 [object setValue:((GDataXMLElement *)value).stringValue 
                           forKey:property];
             } else
#endif
             {
                 [object setValue:value forKey:property];
             }
         }];
        
        // We now add the basic object to document mappers here.
        [sharedInstance addObjectToDocumentMapperForClass:[TTObjectModelCollection class] conversionBlock:
         ^(id doc, NSString *propertyName, int mode, id value) {

             TTObjectModelCollection *obj = value;
             
             if ( obj.documentFormat == DOCUMENT_FORMAT_XML ) {
#ifdef EXT_REMOTE_XML 
                 for ( int j = 0; j < obj.objects.count; j++ ) {
                     id node = [GDataXMLNode elementWithName:propertyName];
                     TTObjectModel *model = [((TTObjectModelCollection *)value).objects objectAtIndex:j];
                     [model encodeToDocument:node];
                     [((GDataXMLElement *)doc) addChild:node]; 
                 }
#endif
             } else if ( obj.documentFormat == DOCUMENT_FORMAT_JSON ) {
                 
#ifdef EXT_REMOTE_JSON                 
                 NSMutableArray *list = [[NSMutableArray alloc] initWithCapacity:obj.objects.count];
                 
                 for ( int j = 0; j < obj.objects.count; j++ ) {
                     NSMutableDictionary *node = [[NSMutableDictionary alloc] init];
                     TTObjectModel *model = [obj.objects objectAtIndex:j];
                     [model encodeToDocument:node];
                     
                     // Add to list.
                     [list addObject:node];
                 }
                 
                 // Add the list to document.
                 [((NSMutableDictionary *)doc) setObject:list forKey:propertyName];
#endif
             }
             
         }];
        
        [sharedInstance addObjectToDocumentMapperForClass:[TTObjectModel class] conversionBlock:
         ^(id doc, NSString *propertyName, int mode, id value) {
            
#ifdef EXT_REMOTE_XML
             if ( [[doc class] isSubclassOfClass:[GDataXMLNode class]] ) { 
                GDataXMLElement *node = [GDataXMLNode elementWithName:propertyName];
                 [((TTObjectModel *)value) encodeToDocument:node];
                 [((GDataXMLElement *)doc) addChild:node];
             }
#endif

#ifdef EXT_REMOTE_JSON
             if ( [doc isKindOfClass:[NSDictionary class]] ) {
                 [((TTObjectModel *)value) encodeToDocument:doc];
             }
#endif
         }];
        
        // Mapper for NSNumber
        [sharedInstance addObjectToDocumentMapperForClass:[NSNumber class] conversionBlock:
         ^(id document, NSString *property, int mode, id value) {
             
#ifdef EXT_REMOTE_XML
             if ( [[document class] isSubclassOfClass:[GDataXMLNode class]] ) {
                 id node = nil;
                 if (mode == VALUEMAPPER_WRITE_ELEMENT ) {
                     node = [GDataXMLNode elementWithName:property];
                     [((GDataXMLElement *)node) setStringValue:[((NSNumber *)value) stringValue]];
                 } else if ( mode == VALUEMAPPER_WRITE_ATTRIBUTE ) {
                     node = [GDataXMLNode attributeWithName:property stringValue:[((NSNumber *)value) stringValue]];
                 } else {
                     ((GDataXMLElement *)document).stringValue = [((NSNumber *)value) stringValue];
                 }
             
                 if ( node != nil ) {
                     [((GDataXMLElement *)document) addChild:node];
                 }
             }
#endif
             
#ifdef EXT_REMOTE_JSON
             if ( [document isKindOfClass:[NSMutableDictionary class]] ) {
                 [((NSMutableDictionary *)document) setObject:[((NSNumber *)value) stringValue]
                                                       forKey:property];
             }
#endif
         }];
        
        // Default mapper.
        [sharedInstance addObjectToDocumentMapperForClass:(Class)[NSNull null] conversionBlock:
         ^(id document, NSString *property, int mode, id value) {
#ifdef EXT_REMOTE_XML
             if ( [[document class] isSubclassOfClass:[GDataXMLNode class]] ) {
                 // Just set the value directly. Search elements makes sure we
                 // have an element. Otherwise we have an attribute
                 id node = nil;
                 if ( mode == VALUEMAPPER_WRITE_ELEMENT ) {
                     node = [GDataXMLNode elementWithName:property];
                     [((GDataXMLElement *)node) setStringValue:value];
                 } else if ( mode == VALUEMAPPER_WRITE_ATTRIBUTE ) {
                     node = [GDataXMLNode attributeWithName:property stringValue:value];
                 } else {
                     ((GDataXMLElement *)document).stringValue = value;
                 }
             
                 if ( node != nil ) {
                     [((GDataXMLElement *)document) addChild:node];
                 }
             }
#endif
             
#ifdef EXT_REMOTE_JSON
             if ( [document isKindOfClass:[NSMutableDictionary class]] ) {
                 [((NSMutableDictionary *)document) setObject:value
                                                       forKey:property];
             }
#endif
             
         }];
        
    });
    return sharedInstance;
}

#pragma mark Copy

/**
 * Make a copy of our self.
 */
-(id)copyWithZone:(NSZone *)zone {
    TTValueMapper *copiedObj = [[TTValueMapper alloc] initWithCopyOfMapper:documentToObjectMappers keysDocToObj:keysForDocumentToObjectMappers objectToDocument:objectToDocumentMappers keysObjToDoc:keysForObjectToDocumentMappers];
    
    return copiedObj;
}

@end