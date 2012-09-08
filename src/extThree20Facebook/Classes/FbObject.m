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
#import "FbStatus.h"
#import "FbAccount.h"
#import "FbAlbum.h"
#import "FbEvent.h"
#import "FbFriendlist.h"
#import "FbNotification.h"
#import "FbPhoto.h"
#import "FbVideo.h"
#import "FbNote.h"
#import "FbQuestion.h"
#import "FbGroup.h"
#import "FbCommon.h"
#import "FbConnection.h"

@implementation FbObject

@synthesize xmlid;
@synthesize photos;
@synthesize videos;
@synthesize likes;
@synthesize comments;
@synthesize links;
@synthesize accounts;
@synthesize achievements;
@synthesize scores;
@synthesize posts;
@synthesize statuses;
@synthesize albums;
@synthesize books;
@synthesize events;
@synthesize feeds;
@synthesize home;
@synthesize friendlists;
@synthesize friends;
@synthesize notes;
@synthesize notifications;
@synthesize pictures;
@synthesize questions;
@synthesize groups;
@synthesize games;

#pragma mark - Connections

/**
 * Setup the connection and return its instance.
 */
- (FbConnection *)setupConnection:(NSString *)connection {
    
    FbConnection *conn = nil;
    
    if ( [connection isEqualToString:FB_CONNECTION_PHOTOS] ) {
        
        conn = [[FbConnection alloc] initWithConnector:self objectClass:[FbPhoto class]
                                            connection:connection];
        self.photos = conn;
                
    } else if ( [connection isEqualToString:FB_CONNECTION_VIDEOS] ) {
        
        conn = [[FbConnection alloc] initWithConnector:self objectClass:[FbVideo class]
                                            connection:connection];
        self.videos = conn;
        
    } else if ( [connection isEqualToString:FB_CONNECTION_LIKES] ) {
                
        conn = [[FbConnection alloc] initWithConnector:self objectClass:[FbPost class]
                                            connection:connection];
        self.likes = conn;
        
    } else if ( [connection isEqualToString:FB_CONNECTION_COMMENTS] ) {
        
    } else if ( [connection isEqualToString:FB_CONNECTION_LINKS] ) {
        
        conn = [[FbConnection alloc] initWithConnector:self objectClass:[FbLink class]
                                            connection:connection];
        self.links = conn;
   
    } else if ( [connection isEqualToString:FB_CONNECTION_ACCOUNTS] ) {

        conn = [[FbConnection alloc] initWithConnector:self objectClass:[FbAccount class]
                                            connection:connection];
        self.accounts = conn;
        
    } else if ( [connection isEqualToString:FB_CONNECTION_ACHIEVEMENTS] ) {
        
        
    } else if ( [connection isEqualToString:FB_CONNECTION_SCORES] ) {
        
        conn = [[FbConnection alloc] initWithConnector:self objectClass:[FbScore class]
                                            connection:connection];
        self.scores = conn;
    
    } else if ( [connection isEqualToString:FB_CONNECTION_POSTS] ) {
        
        conn = [[FbConnection alloc] initWithConnector:self objectClass:[FbPost class]
                                            connection:connection];
        self.posts = conn;
    
    } else if ( [connection isEqualToString:FB_CONNECTION_STATUSES] ) {
        
        conn = [[FbConnection alloc] initWithConnector:self objectClass:[FbPost class]
                                            connection:connection];
        self.statuses = conn;
        
    } else if ( [connection isEqualToString:FB_CONNECTION_ALBUMS] ) {
        
        conn = [[FbConnection alloc] initWithConnector:self objectClass:[FbAlbum class]
                                            connection:connection];
        self.albums = conn;

    } else if ( [connection isEqualToString:FB_CONNECTION_BOOKS] ) {
        
        conn = [[FbConnection alloc] initWithConnector:self objectClass:[FbCommon class]
                                            connection:connection];
        self.books = conn;
        
    } else if ( [connection isEqualToString:FB_CONNECTION_GAMES] ) {
        
        conn = [[FbConnection alloc] initWithConnector:self objectClass:[FbCommon class]
                                            connection:connection];
        self.games = conn;
        
    } else if ( [connection isEqualToString:FB_CONNECTION_EVENTS] ) {
        
        conn = [[FbConnection alloc] initWithConnector:self objectClass:[FbEvent class]
                                            connection:connection];
        self.events = conn;
        
    } else if ( [connection isEqualToString:FB_CONNECTION_FEEDS] ) {
        
        conn = [[FbConnection alloc] initWithConnector:self objectClass:[FbPost class]
                                            connection:connection];
        self.feeds = conn;
        
    } else if ( [connection isEqualToString:FB_CONNECTION_HOME] ) {
        
        conn = [[FbConnection alloc] initWithConnector:self objectClass:[FbPost class]
                                            connection:connection];
        self.home = conn;
        
    } else if ( [connection isEqualToString:FB_CONNECTION_FRIENDLISTS] ) {
        
        conn = [[FbConnection alloc] initWithConnector:self objectClass:[FbFriendlist class]
                                            connection:connection];
        self.friendlists = conn;
        
    } else if ( [connection isEqualToString:FB_CONNECTION_FRIENDS] ) {
        
        conn = [[FbConnection alloc] initWithConnector:self objectClass:[FbPost class]
                                            connection:connection];
        self.friends = conn;
        
    } else if ( [connection isEqualToString:FB_CONNECTION_NOTIFICATIONS] ) {
        
        conn = [[FbConnection alloc] initWithConnector:self objectClass:[FbNotification class]
                                            connection:connection];
        self.notifications = conn;
        
    } else if ( [connection isEqualToString:FB_CONNECTION_NOTES] ) {
        
        conn = [[FbConnection alloc] initWithConnector:self objectClass:[FbNote class]
                                            connection:connection];
        self.notes = conn;
        
    } else if ( [connection isEqualToString:FB_CONNECTION_PICTURE] ) {
        
        conn = [[FbConnection alloc] initWithConnector:self objectClass:[FbPost class]
                                            connection:connection];
        self.pictures = conn;
        
    } else if ( [connection isEqualToString:FB_CONNECTION_QUESTIONS] ) {
        
        conn = [[FbConnection alloc] initWithConnector:self objectClass:[FbQuestion class]
                                            connection:connection];
        self.questions = conn;        
        
    } else if ( [connection isEqualToString:FB_CONNECTION_GROUPS] ) {
        
        conn = [[FbConnection alloc] initWithConnector:self objectClass:[FbGroup class]
                                            connection:connection];
        self.groups = conn;
        
    }
    
    return conn;
}

/**
 * Upload File.
 */
- (void) uploadFiles:(FbObject *)obj {

    NSString *fileName = nil;

    httpMethod = @"POST";
    
    // Get all the files to be posted.
    files = [[NSMutableArray alloc] init];
    
    // Get the path to this document.
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, 
                                                         NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    
    if ( [obj class] == [FbPhoto class] ) {
        
        FbPhoto *photo = (FbPhoto *) obj;
        fileName = photo.name;
        
        if(fileName != nil){
            
            NSString *documentsPath = [documentsDirectory
                                       stringByAppendingPathComponent:fileName];
            NSLog(@"Document Path: %@", documentsPath);
            
            // Does the file exist?
            if ( [[NSFileManager defaultManager] fileExistsAtPath:documentsPath] ) {
                
                // Read data from file in to this object.
                UIImage *img = [UIImage imageWithContentsOfFile:documentsPath];
                
                NSData *data = UIImagePNGRepresentation(img);
                
                // Add this to the list of files.
                NSDictionary *file = [NSDictionary dictionaryWithObjectsAndKeys:
                                      data, @"data", 
                                      @"image/png", @"mimeType",
                                      fileName, @"name",
                                      @"signature", @"key",
                                      nil];
                [files addObject:file];
            }
        }
        
    } else if ( [obj class] == [FbVideo class] ) {
    
        FbVideo *video = (FbVideo *) obj;
        fileName = video.name;
        
        if(fileName != nil){
            
            NSString *documentsPath = [documentsDirectory
                                       stringByAppendingPathComponent:fileName];
            NSLog(@"Document Path: %@", documentsPath);
            
            // Does the file exist?
            if ( [[NSFileManager defaultManager] fileExistsAtPath:documentsPath] ) {
                
                NSError * error=nil;
                NSData *videoData = [NSData dataWithContentsOfFile:documentsPath options: NSMappedRead error: &error];            
                
                // Add this to the list of files.
                NSDictionary *file = [NSDictionary dictionaryWithObjectsAndKeys:
                                      videoData, @"data", 
                                      @"image/png", @"mimeType",
                                      fileName, @"name",
                                      @"signature", @"key",
                                      nil];
                [files addObject:file];
            }
        }
        
    }
        
        
    // Do not cache this reuquest.
    [super load:TTURLRequestCachePolicyNoCache cacheExpirationAge:0 more:NO];
        
    // Clear the files array.
    files = nil;
    httpMethod = @"GET";
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
        
        urlStr = [NSString stringWithFormat:@"%@/%@/feed", FB_URL, @"me"];
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
        
        urlStr = [NSString stringWithFormat:@"%@/%@/feed", FB_URL, @"me"];
        [obj postToUrl:urlStr];
        [self.links.data.objects addObject:obj];
    } else if ( [obj class] == [FbAlbum class] ) {
        
        // If the connection for this object is not setup, do it now.
        if ( self.albums == nil ) {
            [self setupConnection:FB_CONNECTION_ALBUMS];
        }
        
        urlStr = [NSString stringWithFormat:@"%@/%@/albums", FB_URL, @"me"];
        [obj postToUrl:urlStr];
        [self.albums.data.objects addObject:obj];
    } else if ( [obj class] == [FbEvent class] ) {
        
        // If the connection for this object is not setup, do it now.
        if ( self.events == nil ) {
            [self setupConnection:FB_CONNECTION_EVENTS];
        }
        
        urlStr = [NSString stringWithFormat:@"%@/%@/events", FB_URL, @"me"];
        [obj postToUrl:urlStr];
        [self.events.data.objects addObject:obj];
    } else if ( [obj class] == [FbFriendlist class] ) {
        
        // If the connection for this object is not setup, do it now.
        if ( self.friendlists == nil ) {
            [self setupConnection:FB_CONNECTION_FRIENDLISTS];
        }
        
        urlStr = [NSString stringWithFormat:@"%@/%@/friendlists", FB_URL, @"me"];
        [obj postToUrl:urlStr];
        [self.friendlists.data.objects addObject:obj];
        
    } else if ( [obj class] == [FbPhoto class] ) {
        
        // If the connection for this object is not setup, do it now.
        if ( self.photos == nil ) {
            [self setupConnection:FB_CONNECTION_PHOTOS];
        }
        
        urlStr = [NSString stringWithFormat:@"%@/%@/photos", FB_URL, @"me"];
        url = urlStr;
        
        FbPhoto *photo = (FbPhoto *) obj;
        [self uploadFiles:photo];
        
    } else if ( [obj class] == [FbVideo class] ) {
        
        // If the connection for this object is not setup, do it now.
        if ( self.videos == nil ) {
            [self setupConnection:FB_CONNECTION_VIDEOS];
        }
        
        urlStr = [NSString stringWithFormat:@"%@/%@/videos", FB_URL, @"me"];
        url = urlStr;
        
        FbVideo *video = (FbVideo *) obj;
        [self uploadFiles:video];
        
    } else if ( [obj class] == [FbNote class] ) {
        
        // If the connection for this object is not setup, do it now.
        if ( self.notes == nil ) {
            [self setupConnection:FB_CONNECTION_NOTES];
        }
        
        urlStr = [NSString stringWithFormat:@"%@/%@/notes", FB_URL, @"me"];
        [obj postToUrl:urlStr];
        [self.notes.data.objects addObject:obj];
        
    } else if ( [obj class] == [FbQuestion class] ) {
        
        // If the connection for this object is not setup, do it now.
        if ( self.questions == nil ) {
            [self setupConnection:FB_CONNECTION_QUESTIONS];
        }
        
        urlStr = [NSString stringWithFormat:@"%@/%@/questions", FB_URL, @"me"];
        [obj postToUrl:urlStr];
        [self.questions.data.objects addObject:obj];
    }
}


/**
 * Edit connection value of this object.
 */
- (void)editConnection:(FbObject *)obj {
    NSString *urlStr = nil;
    
    if ( [obj class] == [FbEvent class] ) {
        
        // If the connection for this object is not setup, do it now.
        if ( self.events == nil ) {
            [self setupConnection:FB_CONNECTION_EVENTS];
        }
        
        urlStr = [NSString stringWithFormat:@"%@/%@", FB_URL, @"322465451168200"];
        [obj postToUrl:urlStr];
        [self.events.data.objects addObject:obj];

    } else if ( [obj class] == [FbNotification class] ) {
        
        // If the connection for this object is not setup, do it now.
        if ( self.notifications == nil ) {
            [self setupConnection:FB_CONNECTION_NOTIFICATIONS];
        }
        
        urlStr = [NSString stringWithFormat:@"%@/%@?unread=0", FB_URL, @"notif_100000694531327_20891003"];
        [obj postToUrl:urlStr];
        [self.notifications.data.objects addObject:obj];
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
