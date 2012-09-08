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
#import "FbConnection.h"

@interface FbPage : FbObject {
    NSString            *name;
    NSString            *link;
    NSString            *category;
    BOOL                is_published;
    BOOL                can_post;
    int                 xmllikes;
    NSDictionary        *location;
    NSString            *phone;
    int                 checkins;
    NSString            *picture;
    NSString            *website;
    NSString            *talking_about_count;
}

@property (nonatomic, strong) NSString *xmlid;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *link;
@property (nonatomic, strong) NSString *category;
@property BOOL is_published;
@property BOOL can_post;
@property int xmllikes;
@property (nonatomic, strong) NSDictionary *location;
@property (nonatomic, strong) NSString *phone;
@property int checkins;
@property (nonatomic, strong) NSString *picture;
@property (nonatomic, strong) NSString *website;
@property (nonatomic, strong) NSString *talking_about_count;

@end
