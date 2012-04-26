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

#import "ParentModelJSON.h"
#import <extThree20JSON/SBJsonParser.h>

@implementation ParentModelJSON

#pragma mark Load From File

/**
 * Load from file.
 */
- (BOOL)loadFromFile:(NSString *)fileName {
    
    // Was the file loaded?
    BOOL fileLoaded = NO;
    
    // Get the path to this document.
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, 
                                                         NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *documentsPath = [documentsDirectory
                               stringByAppendingPathComponent:fileName];
    
    // Does the file exist?
    if ( [[NSFileManager defaultManager] fileExistsAtPath:documentsPath] ) {
        // Read data from file in to this object.
        NSData *jsonData = [[NSMutableData alloc] initWithContentsOfFile:documentsPath];
        
        documentFormat = DOCUMENT_FORMAT_JSON;
        
        SBJsonParser *doc = [[SBJsonParser alloc] init];
        id rootElement = [doc objectWithData:jsonData];
        
        // If there was no error.
        if ( doc.error == nil ) {
            [super decodeFromDocument:rootElement];
            fileLoaded = YES;
        } else {
            NSLog(@"Error while reading data from file: %@", doc.error);
        }
    }
        
    return fileLoaded;
}

#pragma mark Save to File

/**
 * Save object to file.
 */
- (BOOL)saveToFile:(NSString *)fileName {
    
    // Was the file saved?
    BOOL fileSaved = YES;
    
    // Get the path to this document.
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, 
                                                         NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *documentsPath = [documentsDirectory
                               stringByAppendingPathComponent:fileName];
    
    // Get the JSON
    NSData *jsonData = [self toDocumentWithRoot:@"root"];
    [jsonData writeToFile:documentsPath atomically:YES];
    
    return fileSaved;
}

#pragma mark Initialization

- (id)init {
    if ( ( self = [super init] ) ) {
        httpMethod = @"GET";
        
        // Set the document format.
        documentFormat = DOCUMENT_FORMAT_JSON;
    }
    return self;
}

/**
 * Default load needs to cache data for 1 day.
 */
-(void)load{
    [self load:TTURLRequestCachePolicyDefault cacheExpirationAge:TT_DEFAULT_CACHE_INVALIDATION_AGE more:NO];
}

@end
