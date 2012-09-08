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
#import "GRouteStepCollection.h"

@interface GRouteLeg : ParentModelJSON {
    NSDictionary        *distance;
    NSDictionary        *duration;
    NSString            *end_address;
    CLLocation          *end_location;
    NSString            *start_address;
    CLLocation          *start_location;
    GRouteStepCollection *steps;
}

@property (nonatomic, strong) NSDictionary *distance;
@property (nonatomic, strong) NSDictionary *duration;
@property (nonatomic, strong) NSString *end_address;
@property (nonatomic, strong) CLLocation *end_location;
@property (nonatomic, strong) NSString *start_address;
@property (nonatomic, strong) CLLocation *start_location;
@property (nonatomic, strong) GRouteStepCollection *steps;

@end
