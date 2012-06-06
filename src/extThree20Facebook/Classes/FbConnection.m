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

#import "FbConnection.h"

@implementation FbConnection

@synthesize count;
@synthesize data;
@synthesize paging;
@synthesize next;

#pragma mark - Initialization

- (id)initWithConnector:(FbObject *)fbObject objectClass:(Class)objectClass connection:(NSString *)connectionString {
    if (( self = [super init] )) {
        // Initialize the collection.
        connector = fbObject;
        connection = connectionString;
        
        data = [[FbObjectConnection alloc] initWithObjectClass:objectClass];
    }
    
    return self;
}

#pragma mark - Load

/**
 * All FB objects are loaded the same way, with their id.
 */
-(void)load{
    if ( connector != nil ) {
        url = [NSString stringWithFormat:@"%@/%@/%@", FB_URL, connector.xmlid, connection];
        [super load];
    }
}

@end
