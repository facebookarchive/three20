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

#import "FbObject.h"
#import "FbScore.h"
#import "FbLink.h"
#import "FbPost.h"
#import "FbConnection.h"

@implementation FbObject

@synthesize xmlid;
@synthesize photos;
@synthesize likes;
@synthesize comments;
@synthesize links;
@synthesize accounts;
@synthesize achievements;
@synthesize scores;
@synthesize posts;

#pragma mark - Connections

/**
 * Setup the connection and return its instance.
 */
- (FbConnection *)setupConnection:(NSString *)connection {
    FbConnection *conn = nil;
    
    if ( [connection isEqualToString:FB_CONNECTION_PHOTOS] ) {
        
    } else if ( [connection isEqualToString:FB_CONNECTION_LIKES] ) {
    } else if ( [connection isEqualToString:FB_CONNECTION_COMMENTS] ) {
    } else if ( [connection isEqualToString:FB_CONNECTION_LINKS] ) {
        conn = [[FbConnection alloc] initWithConnector:self objectClass:[FbLink class]
                                            connection:connection];
        self.links = conn;
    } else if ( [connection isEqualToString:FB_CONNECTION_ACCOUNTS] ) {
    } else if ( [connection isEqualToString:FB_CONNECTION_ACHIEVEMENTS] ) {
    } else if ( [connection isEqualToString:FB_CONNECTION_SCORES] ) {
        conn = [[FbConnection alloc] initWithConnector:self objectClass:[FbScore class]
                                            connection:connection];
        self.scores = conn;
    } else if ( [connection isEqualToString:FB_CONNECTION_POSTS] ) {
        conn = [[FbConnection alloc] initWithConnector:self objectClass:[FbPost class]
                                            connection:connection];
        self.posts = conn;
    }

    return conn;
}

/**
 * Publish a new connection to this object.
 */
- (void)newConnection:(FbObject *)obj {
    NSString *urlStr = nil;
    
    if ( [obj class] == [FbPost class] ) {
        
        // If the connection for this object is not setup, do it now.
        if ( self.posts == nil ) {
            [self setupConnection:FB_CONNECTION_POSTS];
        }
        
        urlStr = [NSString stringWithFormat:@"%@/%@/feed", FB_URL, xmlid];
        [obj postToUrl:urlStr];
        [self.posts.data.objects addObject:obj];
    }  else if ( [obj class] == [FbUser class] ) {
        
        // If the connection for this object is not setup, do it now.
        if ( self.likes == nil ) {
            [self setupConnection:FB_CONNECTION_LIKES];
        }
        
        urlStr = [NSString stringWithFormat:@"%@/%@/likes", FB_URL, xmlid];
        [obj postToUrlWithNoData:urlStr];
        [self.likes.data.objects addObject:obj];
    } else if ( [obj class] == [FbLink class] ) {
        
        // If the connection for this object is not setup, do it now.
        if ( self.links == nil ) {
            [self setupConnection:FB_CONNECTION_LINKS];
        }
        
        urlStr = [NSString stringWithFormat:@"%@/%@/feed", FB_URL, xmlid];
        [obj postToUrl:urlStr];
        [self.links.data.objects addObject:obj];
    }
}

#pragma mark - Initialization

/**
 * The user we need to load.
 */
- (id)initWithId:(NSString *)objectId {
    if ( ( self = [super init] ) ) {
        xmlid = objectId;
    }
    return self;
}

#pragma mark - Load

/**
 * All FB objects are loaded the same way, with their id.
 */
-(void)load {
    if ( xmlid != nil ) {
        url = [NSString stringWithFormat:@"%@/%@", FB_URL, xmlid];
        [super load];
    }
}

/**
 * Push to a connection of this object.
 */
-(void)postToUrl:(NSString *)urlStr {
    url = urlStr;
    [self serializeToParameters];
    httpMethod = @"POST";
    [super load];
    httpMethod = @"GET";
}

/**
 * No data to be posted.
 */
- (void)postToUrlWithNoData:(NSString *)urlStr {
    url = urlStr;
    httpMethod = @"POST";
    [super load];
    httpMethod = @"GET";
}

@end
