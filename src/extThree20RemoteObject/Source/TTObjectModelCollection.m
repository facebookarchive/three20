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

#import "TTObjectModelCollection.h"
#import "TTObjectModel.h"

@implementation TTObjectModelCollection

@synthesize objects;

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
#endif
    } else {
#ifdef EXT_REMOTE_XML  
        // This is an xml document.
        rootObject = ((TTURLXMLResponse *)request.response).rootObject;
        if ( rootObject != nil && [rootObject isKindOfClass:[GDataXMLDocument class]] ) {
            rootObject = ((GDataXMLDocument *)rootObject).rootElement;
            
            // If the root is not an array, its possible its children are.
            if ( ![rootObject isKindOfClass:[NSArray class]] ) { 
                rootObject = [((GDataXMLElement *)rootObject) children];
            }
        } else {
            rootObject = nil;
        }
#endif
    }
    
    // Is the response an array?
    if ( rootObject != nil && [rootObject isKindOfClass:[NSArray class]] ) {
        
        // Remember the current list of objects.
        NSArray *lastArray = objects;
        
        // Get the root feed.
        NSArray *feed = rootObject;
        
        //Initialize object
        [self loadWithArray:feed];
        
        // If we are refreshing, then add the last array to the new array.
        if ( doNotRefresh && lastArray != nil ) {
            [objects addObjectsFromArray:lastArray];
        }
        
        // Call the parent as we are done.
        [super requestDidFinishLoad:request];
        
    } else {
        NSLog(@"Inavlid or unexpected response type. (%@)", [rootObject class]);
        [super requestDidCancelLoad:request];
    }
    
    // Show the response received.
    NSLog(@"response = %@", rootObject );
}

/**
 * Remove the passed object from server.
 */
-(void)removeObject:(TTObjectModel *)model {
    
    // Set up the URL.
    NSLog(@"Making request to delete URL: %@", url);
    
    TTURLRequest* request = [TTURLRequest requestWithURL:url delegate:self];
    
    // Set the HTTP Method.
    request.httpMethod =  httpMethod;
    
    // Set the values.
    [request.parameters setDictionary:parameters];
    
    // Right now, we are disabling cache.
    request.cachePolicy = TTURLRequestCachePolicyNoCache;
    request.cacheExpirationAge = TT_CACHE_EXPIRATION_AGE_NEVER;
    
    NSLog(@"request.parameters : %@", request.parameters);
    
    // Finally send the request.
    [request send];
    
    // Delete from list of objects.
    if ( model != nil ) {
        [objects removeObject:model];
    } else {
        [objects removeAllObjects];
    }
}

/**
 * Load with given data.
 */
-(void)loadWithArray:(NSArray *)data {
               
    if ( objects == nil || primaryKey == nil ) {
        objects = [[NSMutableArray alloc ]init];
    }
    
    // Read all the data and load to the collection's array.
    if ( documentFormat == DOCUMENT_FORMAT_JSON ) {
        
#ifdef EXT_REMOTE_JSON        
        for (NSDictionary *entry in data) {
            TTObjectModel *sp = [[objectClass alloc] init];
            sp.documentFormat = DOCUMENT_FORMAT_JSON;
            [sp decodeFromDocument:entry];
            
            // If objects have a concept of a primary key, then 
            // use that to create a predicate. This ensures that
            // we update the values for same primary key, instead of
            // adding a new instance.
            if ( primaryKey != nil ) {
                
                NSString *predicateString = [NSString stringWithFormat:@"%@ == %@", primaryKey, @"%@"];
                NSPredicate *predicate = [NSPredicate predicateWithFormat:predicateString, 
                                          [sp valueForKey:primaryKey]];
                
                NSArray *filteredArray = [objects filteredArrayUsingPredicate:predicate];
                
                // If we found the object, update it instead of adding a new object.
                if ([filteredArray count] > 0) {
                    sp = [filteredArray objectAtIndex:0];
                    [sp decodeFromDocument:entry];
                } else {
                    [objects addObject: sp];
                }
            } else {
                [objects addObject: sp];
            }
        }
#endif        
    } else {
#ifdef EXT_REMOTE_XML        
        for ( GDataXMLElement *xmlElement in data ) {
            TTObjectModel *sp = [[objectClass alloc] init];
            sp.documentFormat = DOCUMENT_FORMAT_XML;
            [sp decodeFromDocument:xmlElement];
            
            // If objects have a concept of a primary key, then 
            // use that to create a predicate. This ensures that
            // we update the values for same primary key, instead of
            // adding a new instance.
            if ( primaryKey != nil ) {
                
                NSString *predicateString = [NSString stringWithFormat:@"%@ == %@", primaryKey, @"%@"];
                NSPredicate *predicate = [NSPredicate predicateWithFormat:predicateString, 
                                          [sp valueForKey:primaryKey]];

                NSArray *filteredArray = [objects filteredArrayUsingPredicate:predicate];
                
                // If we found the object, update it instead of adding a new object.
                if ([filteredArray count] > 0) {
                    sp = [filteredArray objectAtIndex:0];
                    [sp decodeFromDocument:xmlElement];
                } else {
                    [objects addObject: sp];
                }
            } else {
                [objects addObject: sp];
            }
        }
#endif
    }
}
 
@end
