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

#import "FbParentModel.h"

@class FbConnection;

#define FB_CONNECTION_PHOTOS     @"photos"
#define FB_CONNECTION_LIKES      @"likes"
#define FB_CONNECTION_COMMENTS   @"comments"
#define FB_CONNECTION_LINKS      @"links"
#define FB_CONNECTION_ACCOUNTS   @"accounts"
#define FB_CONNECTION_ACHIEVEMENTS @"achievements"
#define FB_CONNECTION_SCORES     @"scores"
#define FB_CONNECTION_POSTS      @"posts"

@interface FbObject : FbParentModel {
    NSString                    *xmlid;
    
    // Connections to the object.
    FbConnection                *photos;
    FbConnection                *likes;
    FbConnection                *comments;
    FbConnection                *links;
    FbConnection                *accounts;
    FbConnection                *achievements;
    FbConnection                *scores;
    FbConnection                *posts;
}

@property (nonatomic, strong) NSString *xmlid;
@property (nonatomic, strong) FbConnection *photos;
@property (nonatomic, strong) FbConnection *likes;
@property (nonatomic, strong) FbConnection *comments;
@property (nonatomic, strong) FbConnection *links;
@property (nonatomic, strong) FbConnection *accounts;
@property (nonatomic, strong) FbConnection *achievements;
@property (nonatomic, strong) FbConnection *scores;
@property (nonatomic, strong) FbConnection *posts;

// User to be loaded. 
- (id)initWithId:(NSString *)objectId;
- (void)postToUrl:(NSString *)urlStr;
- (void)postToUrlWithNoData:(NSString *)urlStr;
- (void)newConnection:(FbObject *)obj;
- (FbConnection *)setupConnection:(NSString *)connection;

@end
