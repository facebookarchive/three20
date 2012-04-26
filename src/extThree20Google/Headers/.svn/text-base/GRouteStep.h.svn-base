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
#import "extThree20GoogleLocation.h"

@interface GRouteStep : ParentModelJSON {
    NSString                *travel_mode;
    extThree20GoogleLocation *start_location;
    extThree20GoogleLocation *end_location;

    TTDocumentForwardPointer *polyline;
    NSString                 *points;
    TTDocumentBackPointer    *polylineBack;
    
    NSDictionary             *duration;
    NSString                 *html_instructions;
    NSDictionary             *distance;
}

@property (nonatomic, strong) NSString *travel_mode;
@property (nonatomic, strong) extThree20GoogleLocation *start_location;
@property (nonatomic, strong) extThree20GoogleLocation *end_location;
@property (nonatomic, strong) TTDocumentForwardPointer *polyline;
@property (nonatomic, strong) NSString *points;
@property (nonatomic, strong) TTDocumentBackPointer *polylineBack;
@property (nonatomic, strong) NSDictionary *duration;
@property (nonatomic, strong) NSString *html_instructions;
@property (nonatomic, strong) NSDictionary *distance;

@end
