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
#import "GRouteCollection.h"

// Travel Modes
#define GDIRECTION_TRAVEL_MODE_DRIVING @"driving"
#define GDIRECTION_TRAVEL_MODE_WALKING @"walking"
#define GDIRECTION_TRAVEL_MODE_BICYCLING @"bicycling"

// Avoids
#define GDIRECTION_AVOID_TOLLS @"tolls"
#define GDIRECTION_AVOID_HIGHWAYS @"highways"

// Unit System
#define GDIRECTION_UNIT_METRIC @"metric"
#define GDIRECTION_UNIT_IMPERIAL @"imperial"

@interface GDirections : ParentModelJSON {
    NSString            *status;
    GRouteCollection    *routes;
    
    NSString            *mode;
    BOOL                alternatives;
    NSString            *avoid;
    NSString            *units;
    BOOL                sensor;
}

@property (nonatomic, strong) NSString *status;
@property (nonatomic, strong) GRouteCollection *routes;

@property (nonatomic, strong) NSString *mode;
@property BOOL alternatives;
@property (nonatomic, strong) NSString *avoid;
@property (nonatomic, strong) NSString *units;
@property BOOL sensor;

- (BOOL)loadDirectionsFrom:(id)from to:(id)to waypoints:(NSArray *)waypoint;

@end
