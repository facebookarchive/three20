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

#import "TTObjectModel.h"
#import "TTDocumentForwardPointer.h"
#import "TTDocumentBackPointer.h"
#import "TTDocumentElementPointer.h"
#import "TTDocumentAttributePointer.h"
#import "TTDocumentValuePointer.h"
#import "TTObjectModelCollection.h"
#import "NSMutableArray+Stack.h"

@implementation TTObjectModel

#pragma mark Object Decoder / Encoder.

/**
 * Decoder using an xml / json document.
 */
- (void)decodeFromDocument:(id)doc {
    
    // Get the list of properties.
    objc_property_t  *objectProperties;
    unsigned int     propertiesCount;
    
    objectProperties = class_copyPropertyList([self class], &propertiesCount);
    
    // Initialize a stack to maintain the tree traversal of this document.
    NSMutableArray *elementsStack = [[NSMutableArray alloc] initWithCapacity:1];
    
    // By default we are looking in the xml elements.
    BOOL searchElements = YES;
    NSArray *elementAttibutes = nil;
    BOOL docIsValue = NO;
    
    // Set all properties
    for ( int i = 0; i < propertiesCount; i++ ) {
        NSString *propertyName = [NSString stringWithUTF8String:property_getName(objectProperties[i])];
        
        // Get the class for this property.
        const char *type = property_getAttributes(objectProperties[i]);
        NSString *typeString = [NSString stringWithUTF8String:type];
        NSArray *attributes = [typeString componentsSeparatedByString:@","];
        NSString *typeAttribute = [attributes objectAtIndex:0];
        NSString *typeClassName = nil;
        Class typeClass = nil;
        
        // If this is not a primitive object.
        if ([typeAttribute length] > 3 ) {
            typeClassName = [typeAttribute substringWithRange:NSMakeRange(3, [typeAttribute length]-4)];
            typeClass = NSClassFromString(typeClassName);
        }
        
        // Some properties in the document may conflict with its parent (example: url), or with
        // Objective-C keywords. The solution is to add an xml prefix to those objects. Here
        // we remove that prefix. Please note that if the variable itself is named xml in the XML
        // document, then we would need to name corresponding object as xmlxml.
        NSString *propertyNameForXML = propertyName;
        if( [propertyNameForXML hasPrefix:@"xml"]) {
			propertyNameForXML = [propertyNameForXML substringFromIndex:3];
		}
        
        // Holds the value(s)
        NSArray *values = nil;
        id value = nil;
               
        if ( documentFormat == DOCUMENT_FORMAT_XML ) {
#ifdef EXT_REMOTE_XML 
            // If we need to get the value from the document's child.
            if ( docIsValue ) {
                value = ((GDataXMLElement *)doc).stringValue;
                values = value;
            } else if ( searchElements ) {
                // Get the element from the XML document.
                values = [(GDataXMLElement *)doc elementsForName:propertyNameForXML];
            
                if ( values.count > 0 ) {
                    value = (GDataXMLElement *) [values objectAtIndex:0];
                } else {
                    value = values;
                }
            } else {
                
                // Loop through the attibutes to find desired value.
                for ( int j = 0; j < elementAttibutes.count; j++ ) {
                    GDataXMLNode *attr = [elementAttibutes objectAtIndex:j];
                    
                    // Is this the attribute we were looking for?
                    if ( [attr.name isEqualToString:propertyNameForXML] ) {
                        value = attr.stringValue;
                        values = value;
                        break;
                    }
                }
            }
#endif
        } else {
#ifdef EXT_REMOTE_JSON
            // Get the value received from JSON document.
            value = [(NSDictionary *)doc objectForKey:propertyNameForXML];
            values = value;
#endif        
        }
        
        // Did we get a value?
        if ( value != nil || values.count > 0 ) {
            
            if ( typeClass == [TTDocumentForwardPointer class] ) {
                // Push the current xml element to to the stack.
                [elementsStack push:doc];
                
                // Make the child xml Element the root element.
                doc = value;
            } else {
                // Set the value using value mappers so that the value is 
                // correctly mapped to local object.
                [valueMapper documentToObjectForClass:typeClass object:self property:propertyName values:values value:value];
            }
        } else {
            // All these pointers are nil, so we put their checks here.
            if ( typeClass == [TTDocumentBackPointer class] ) {
                // Go back to the parent's element.
                doc = [elementsStack pop];
#ifdef EXT_REMOTE_XML                
            } else if ( typeClass == [TTDocumentAttributePointer class] ) {
                // We want to now search attributes.
                searchElements = NO;
                
                // Get the attributes from the XML element.
                elementAttibutes = [(GDataXMLElement *)doc attributes];
#endif
            } else if ( typeClass == [TTDocumentElementPointer class] ) {
                // We want to now search elements.
                searchElements = YES;
                
                // Do not need the attributes list now.
                elementAttibutes = nil;
                
            } else if ( typeClass == [TTDocumentValuePointer class] ) {
                // The value of the current xml document needs to be placed in the 
                // next property encountered.
                docIsValue = YES;                
            }
        }
        
        // If we were in write child mode, then go back to writing elements.
        if ( docIsValue == YES && typeClass != [TTDocumentValuePointer class] ) {
            docIsValue = NO;
        }
    }
    
    // Clean up
    free(objectProperties);
}

/**
 * Setup an encoder from this object.
 */
- (void)encodeToDocument:(id)doc {
    
    // Get the list of properties.
    objc_property_t  *objectProperties;
    unsigned int     propertiesCount;
    
    objectProperties = class_copyPropertyList([self class], &propertiesCount);
    
    // Initialize a stack to maintain the tree traversal of this document.
    NSMutableArray *elementsStack = [[NSMutableArray alloc] initWithCapacity:1];
    
    // By default we are looking in the xml elements.
    int writeMode = VALUEMAPPER_WRITE_ELEMENT;
    
    // Set all properties
    for ( int i = 0; i < propertiesCount; i++ ) {
        NSString *propertyName = [NSString stringWithUTF8String:property_getName(objectProperties[i])];
        
        // Get the class for this property.
        const char *type = property_getAttributes(objectProperties[i]);
        NSString *typeString = [NSString stringWithUTF8String:type];
        NSArray *attributes = [typeString componentsSeparatedByString:@","];
        NSString *typeAttribute = [attributes objectAtIndex:0];
        NSString *typeClassName = nil;
        Class typeClass = nil;
        
        // If this is not a primitive object.
        if ([typeAttribute length] > 3 ) {
            typeClassName = [typeAttribute substringWithRange:NSMakeRange(3, [typeAttribute length]-4)];
            typeClass = NSClassFromString(typeClassName);
        }
        
        // Some properties in the document may conflict with its parent (example: url), or with
        // Objective-C keywords. The solution is to add an xml prefix to those objects. Here
        // we remove that prefix. Please note that if the variable itself is named xml in the XML
        // document, then we would need to name corresponding object as xmlxml.
        NSString *propertyNameForXML = propertyName;
        if( [propertyNameForXML hasPrefix:@"xml"]) {
			propertyNameForXML = [propertyNameForXML substringFromIndex:3];
		}
        
        // Holds the value(s)
        id value = nil;
        
        // Get the value for this property.
        value = [self valueForKey:propertyName];
                
        // Did we get a value?
        if ( value != nil ) {
            [valueMapper objectToDocumentForClass:typeClass document:doc property:propertyNameForXML mode:writeMode value:value];
        } else {
            // All these pointers are nil, so we put their checks here.
            if ( typeClass == [TTDocumentBackPointer class] ) {

                if ( documentFormat == DOCUMENT_FORMAT_XML) {
#ifdef EXT_REMOTE_XML
                
                    // Go back to the parent's element.
                    GDataXMLElement *parent = [elementsStack pop];
                
                    // Add child to the parent.
                    [parent addChild:doc];
                    doc = parent;
#endif
                } else if ( documentFormat == DOCUMENT_FORMAT_JSON ) { 

#ifdef EXT_REMOTE_JSON                
                    doc = [elementsStack pop];
#endif
                }

#ifdef EXT_REMOTE_XML                
            } else if ( typeClass == [TTDocumentAttributePointer class] ) {
                // We want to now search attributes.
                writeMode = VALUEMAPPER_WRITE_ATTRIBUTE;
                
#endif
            } else if ( typeClass == [TTDocumentElementPointer class] ) {
                // We want to now search elements.
                writeMode = VALUEMAPPER_WRITE_ELEMENT;
                
            } else if ( typeClass == [TTDocumentForwardPointer class] ) {
                
                // Make the child xml Element the root element.
                if ( documentFormat == DOCUMENT_FORMAT_XML ) {
#ifdef EXT_REMOTE_XML
                    // Push the current xml element to to the stack.
                    [elementsStack push:doc];
                    
                    doc = [GDataXMLNode elementWithName:propertyNameForXML];
#endif
                } else if ( documentFormat == DOCUMENT_FORMAT_JSON ) {
#ifdef EXT_REMOTE_JSON
                    // Push the current root to stack.
                    [elementsStack push:doc];
                    
                    // Set up a new dictionary.
                    NSMutableDictionary *child = [[NSMutableDictionary alloc] init];
                    
                    // Add this dictionary to the current root.
                    [doc setObject:child forKey:propertyNameForXML];
                    
                    // Become the current root.
                    doc = child;
#endif
                }
                
                // We search elements by default.
                writeMode = VALUEMAPPER_WRITE_ELEMENT;
            } else if ( typeClass == [TTDocumentValuePointer class] ) {
                // The value of the current xml document needs to be placed in the 
                // as a child to the documents element.
                writeMode = VALUEMAPPER_WRITE_CHILD;
            }
        }
        
        // If we were in write child mode, then go back to writing elements.
        if ( writeMode == VALUEMAPPER_WRITE_CHILD && 
            typeClass != [TTDocumentValuePointer class] ) {
            writeMode = VALUEMAPPER_WRITE_ELEMENT;
        }
    }

#ifdef EXT_REMOTE_XML
    if ( documentFormat == DOCUMENT_FORMAT_XML ) {
        // Add all children to their parents.
        GDataXMLElement *parent = [elementsStack pop];
    
        while ( parent != nil ) {
            [parent addChild:doc];
            doc = parent;
            parent = [elementsStack pop];
        }
    } 
#endif

    // Clean up
    free(objectProperties);
}

#pragma mark Convert object to document

/**
 * Converts the object back in to a document.
 */
-(NSData *)toDocumentWithRoot:(NSString *)root {
    NSData *content;
    
    if ( documentFormat == DOCUMENT_FORMAT_XML ) {
#ifdef EXT_REMOTE_XML        
        GDataXMLElement *rootElement = [GDataXMLNode elementWithName:root];
        
        [self encodeToDocument:rootElement];
        
        GDataXMLDocument *document = [[GDataXMLDocument alloc] 
                                       initWithRootElement:rootElement];
        content = document.XMLData;
#endif    
    } else if ( documentFormat == DOCUMENT_FORMAT_JSON ) {
#ifdef EXT_REMOTE_JSON
        NSMutableDictionary *rootElement = [[NSMutableDictionary alloc] init];
        
        [self encodeToDocument:rootElement];
        
        SBJsonWriter *writer = [[SBJsonWriter alloc] init];
        content = [writer dataWithObject:rootElement];
#endif
    }
         
    return content;
}

#pragma mark Load Data from Response

/**
 * We have received a response.
 */
-(void)requestDidFinishLoad:(TTURLRequest*)request {
    
    // Make sure the response is correct.
    id rootObject = nil;
    
    // Prepare the response object depending on remote document format.
    if ( documentFormat == DOCUMENT_FORMAT_JSON ) {
#ifdef EXT_REMOTE_JSON        
        rootObject = ((TTURLJSONResponse *)request.response).rootObject;
        
        // Since we are expecting a single object, we are expecting the response to be a
        // dictionary.
        if ( rootObject != nil && [rootObject isKindOfClass:[NSDictionary class]] ) {
            
            [self decodeFromDocument:rootObject];
            
            // Call the parent as we are done.
            [super requestDidFinishLoad:request];
            
        } else {
            NSLog(@"Inavlid or unexpected response type. (%@)", [rootObject class]);
            [super requestDidCancelLoad:request];
        }
#endif   
        
    } else {
#ifdef EXT_REMOTE_XML        
        // This is an xml document.
        rootObject = ((TTURLXMLResponse *)request.response).rootObject;
        if ( rootObject != nil && [rootObject isKindOfClass:[GDataXMLDocument class]] ) {
            [self decodeFromDocument:((GDataXMLDocument *)rootObject).rootElement];
            
            // Call the parent as we are done.
            [super requestDidFinishLoad:request];
            
        } else {
            NSLog(@"Inavlid or unexpected response type. (%@)", [rootObject class]);
            [super requestDidCancelLoad:request];
        }
#endif

    }
    
    // Show the response received.
    NSLog(@"response = %@", rootObject );
}

@end
