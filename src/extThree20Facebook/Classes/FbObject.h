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
#define FB_CONNECTION_VIDEOS     @"videos"
#define FB_CONNECTION_LIKES      @"likes"
#define FB_CONNECTION_COMMENTS   @"comments"
#define FB_CONNECTION_LINKS      @"links"
#define FB_CONNECTION_ACCOUNTS   @"accounts"
#define FB_CONNECTION_ACHIEVEMENTS @"achievements"
#define FB_CONNECTION_SCORES     @"scores"
#define FB_CONNECTION_POSTS      @"posts"
#define FB_CONNECTION_STATUSES      @"statuses"
#define FB_CONNECTION_ALBUMS      @"albums"
#define FB_CONNECTION_BOOKS      @"books"
#define FB_CONNECTION_GAMES      @"games"
#define FB_CONNECTION_EVENTS      @"events"
#define FB_CONNECTION_FEEDS      @"feed"
#define FB_CONNECTION_HOME      @"home"
#define FB_CONNECTION_FRIENDLISTS      @"friendlists"
#define FB_CONNECTION_FRIENDS      @"friends"
#define FB_CONNECTION_NOTIFICATIONS      @"notifications"
#define FB_CONNECTION_NOTES      @"notes"
#define FB_CONNECTION_PICTURE      @"picture"
#define FB_CONNECTION_QUESTIONS      @"questions"
#define FB_CONNECTION_GROUPS      @"groups"

@interface FbObject : FbParentModel {
    NSString                    *xmlid;
    
    // Connections to the object.
    FbConnection                *photos;
    FbConnection                *videos;
    FbConnection                *likes;
    FbConnection                *comments;
    FbConnection                *links;
    FbConnection                *accounts;
    FbConnection                *achievements;
    FbConnection                *scores;
    FbConnection                *posts;
    FbConnection                *statuses;
    FbConnection                *albums;
    FbConnection                *books;
    FbConnection                *feeds;
    FbConnection                *events;
    FbConnection                *home;
    FbConnection                *friendlists;
    FbConnection                *friends;
    FbConnection                *notifications;
    FbConnection                *notes;
    FbConnection                *pictures;
    FbConnection                *questions;
    FbConnection                *groups;
    FbConnection                *games;
}

@property (nonatomic, strong) NSString *xmlid;
@property (nonatomic, strong) FbConnection *photos;
@property (nonatomic, strong) FbConnection *videos;
@property (nonatomic, strong) FbConnection *likes;
@property (nonatomic, strong) FbConnection *comments;
@property (nonatomic, strong) FbConnection *links;
@property (nonatomic, strong) FbConnection *accounts;
@property (nonatomic, strong) FbConnection *achievements;
@property (nonatomic, strong) FbConnection *scores;
@property (nonatomic, strong) FbConnection *posts;
@property (nonatomic, strong) FbConnection *statuses;
@property (nonatomic, strong) FbConnection *albums;
@property (nonatomic, strong) FbConnection *books;
@property (nonatomic, strong) FbConnection *events;
@property (nonatomic, strong) FbConnection *feeds;
@property (nonatomic, strong) FbConnection *home;
@property (nonatomic, strong) FbConnection *friendlists;
@property (nonatomic, strong) FbConnection *friends;
@property (nonatomic, strong) FbConnection *notifications;
@property (nonatomic, strong) FbConnection *notes;
@property (nonatomic, strong) FbConnection *pictures;
@property (nonatomic, strong) FbConnection *questions;
@property (nonatomic, strong) FbConnection *groups;
@property (nonatomic, strong) FbConnection *games;

// User to be loaded. 
- (id)initWithId:(NSString *)objectId;
- (void)postToUrl:(NSString *)urlStr;
- (void)postToUrlWithNoData:(NSString *)urlStr;
- (void)newConnection:(FbObject *)obj;
- (void)editConnection:(FbObject *)obj;
- (FbConnection *)setupConnection:(NSString *)connection;

@end
