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

/**
 * Define the document format.
 */
#define DOCUMENT_FORMAT_JSON    1
#define DOCUMENT_FORMAT_XML     2

@protocol TTRemoteObjectDelegate;

@interface TTRemoteObject : TTURLRequestModel {
    /**
     * URL to be invoked to get this objects data.
     */
    NSString    *url;
    
    /**
     * Method to use for getting data.
     */
    NSString    *httpMethod;
    
    /**
     * Parameters to be passed to the server.
     */
    NSMutableDictionary *parameters;
    
    /**
     * File to be sent to the server.
     */
    NSMutableArray *files;
    
    /**
     * Document format to be used.
     */
    int         documentFormat;
    
    /**
     * Array of delegates interested in hearing about this
     * objects load progress.
     */
    NSMutableArray  *delegates;
    
    /**
     * Value mappers to map values between document representation
     * and local object representation.
     */
    TTValueMapper   *valueMapper;
}

@property int documentFormat;

/**
 * Methods exposed by this object.
 */
-(id)init;
-(void)load:(TTURLRequestCachePolicy)cachePolicy cacheExpirationAge:(NSTimeInterval)cacheExpirationAge more:(BOOL)more;
-(void)load;
-(void)registerDelegate:(id<TTRemoteObjectDelegate>)listener;
-(void)removeDelegate:(id<TTRemoteObjectDelegate>)listener;

@end

/**
 * This protocol is used to enhance the object loading with specific features.
 */
@protocol TTRemoteObjectDelegate <NSObject>

@optional
- (void)load:(TTRemoteObject *)obj;
- (void)remoteObject:(TTRemoteObject *)remoteObject didFailLoadWithError:(NSError*)error 
         forRequest:(TTURLRequest *)request;
- (void)remoteObject:(TTRemoteObject *)remoteObject didFinishLoadForRequest:(TTURLRequest *)request;

@end

