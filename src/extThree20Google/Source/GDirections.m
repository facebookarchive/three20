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

#import "GDirections.h"

#define GOOGLE_DIRECTION_API @"https://maps.googleapis.com/maps/api/directions/json"

@implementation GDirections

@synthesize status;
@synthesize routes;
@synthesize mode;
@synthesize alternatives;
@synthesize avoid;
@synthesize units;
@synthesize sensor;

#pragma mark - Load Directions

/**
 * Loads directions from an address string or CLocationCoordinate2D to an address
 * string or CLocationCoordinate2D with the given way points.
 */
- (BOOL)loadDirectionsFrom:(id)from to:(id)to waypoints:(NSArray *)waypoint {
    BOOL st = YES;
    NSString *f;
    NSString *t;
    
    // Is the from address a string?
    if ( [from isKindOfClass:[NSString class]] ) {
        f = from;
    } else if ( [from class] == [CLLocation class] )  {
        CLLocation *loc = from;
        f = [NSString stringWithFormat:@"%f,%f", loc.coordinate.latitude, 
             loc.coordinate.longitude];
    } else {
        st = NO;
    }
    
    // Is the to an address string?
    if ( [to isKindOfClass:[NSString class]] ) {
        t = to;
    } else if ( [to class] == [CLLocation class] ) {
        CLLocation *loc = to;
        t = [NSString stringWithFormat:@"%f,%f", loc.coordinate.latitude,
             loc.coordinate.longitude];
    } else {
        st = NO;
    }
    
    // Should we make the request?
    if ( st ) {
        parameters = [NSMutableDictionary dictionaryWithObjectsAndKeys:f, @"origin", 
                      t, @"destination", mode, @"mode", 
                      ( alternatives ) ? @"true" : @"false", @"alternatives",
                      ( sensor ) ? @"true" : @"false", @"sensor", nil];
        
        if ( avoid != nil ) {
            [parameters setObject:avoid forKey:@"avoid"];
        }
        
        if ( units != nil ) {
            [parameters setObject:units forKey:@"units"];
        }
        
        [super load];
    }
    
    return st;
}

#pragma mark - Initialization

/**
 * Initialize with url
 */
- (id)init {
    if ( ( self = [super init] ) ) {
        url = GOOGLE_DIRECTION_API;
        mode = GDIRECTION_TRAVEL_MODE_DRIVING;
        alternatives = NO;
        sensor = YES;
    }
    
    return self;
}

@end
