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

#import "extThree20Google.h"
#import "extThree20GoogleLocation.h"

@implementation extThree20Google

#pragma mark - Initialization

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

/**
 * We only have one instance of this model. It is the container of all
 * data for the app.
 */
+ (extThree20Google *)sharedInstance {
    
    static extThree20Google *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[extThree20Google alloc] init];
        
        // Do any other initialisation stuff here
        
        // Set the Value mappers for mapping xml values to local object values.
        TTValueMapper *mappers = [TTValueMapper sharedInstance];
        
        // Mapper for extThree20GoogleLocation. Takes the lat, lng and makes a new value.
        [mappers addDocumentToObjectMapperForClass:[extThree20GoogleLocation class] conversionBlock:
         ^(id object, NSString *property, __unsafe_unretained Class typeClass, id values, id value) {
             // Make sure this is a dictionary
             if ( [value isKindOfClass:[NSDictionary class]] ) {
                 double lat = [((NSNumber *)[((NSDictionary *)value) objectForKey:@"lat"]) doubleValue];
                 double lng = [((NSNumber *)[((NSDictionary *)value) objectForKey:@"lng"]) doubleValue];
                 
                 // Instantiate the location.
                 extThree20GoogleLocation *loc = [[extThree20GoogleLocation alloc] initWithLatitude:lat
                                                                                          longitude:lng];
                                                                                                     
                 [object setValue:loc forKey:property];
             }
             
         }];
        
        // Takes the lat lng, makes in to a new ditionary and adds to the document tree.
        [mappers addObjectToDocumentMapperForClass:[extThree20GoogleLocation class] conversionBlock:
         ^(id document, NSString *property, int mode, id value) {
             extThree20GoogleLocation *loc = value;
             
             NSDictionary *locDict = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithDouble:loc.coordinate.latitude], @"lat", [NSNumber numberWithDouble:loc.coordinate.longitude], 
                                      @"lng", nil];
             
             NSMutableDictionary *doc = document;
             [doc setObject:locDict forKey:property];
         }];
        
    });
    return sharedInstance;
}

@end
