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

#import "FbParentCollection.h"
#import "extThree20Facebook.h"

@implementation FbParentCollection

@synthesize accessToken;

#pragma mark - Initialization

- (id)init {
    if ( ( self = [super init] ) ) {
        httpMethod = @"GET";
        
        documentFormat = DOCUMENT_FORMAT_JSON;
        
        // Initialize an empty array.
        objects = [[NSMutableArray alloc] init];
    }
    return self;
}

#pragma mark - Loading

/**
 * Default load needs to cache data for 7 days.
 */
- (void)load {
    
    // If no access token is set, we attempt to set one now.
    if ( [parameters valueForKey:@"access_token"] == nil ) {
        
        // Add access token if we have a valid session.
        extThree20Facebook *model = [extThree20Facebook sharedInstance];
        
        // If this instance of the object defines its own token, use it.
        if ( accessToken != nil ) {
            [parameters setValue:accessToken forKey:@"access_token"];
        } else if ( [model.facebook isSessionValid] ) {
            // User is logged in, use that logged in token.
            [parameters setValue:model.facebook.accessToken forKey:@"access_token"];
            
            // If needed, extend the access token.
            [model.facebook extendAccessTokenIfNeeded];
        }
    }
    
    // Finally load the object by asking the parent to do it.
    [super load];
}


@end
