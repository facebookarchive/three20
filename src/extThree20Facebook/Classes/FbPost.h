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
#import "FbUser.h"

@interface FbPost : FbObject {
    FbUser              *from;
    FbObjectConnection  *to;
    NSString            *message;
    NSDictionary        *message_tags;
    NSString            *picture;
    NSString            *link;
    NSString            *name;
    NSString            *caption;
    NSString            *description;
    NSString            *source;
    NSArray             *properties;
    NSString            *icon;
    NSArray             *actions;
    NSDictionary        *privacy;
    NSString            *type;
    
}

@property (nonatomic, strong) NSString *xmlid;
@property (nonatomic, strong) FbUser *from;
@property (nonatomic, strong) FbObjectConnection *to;
@property (nonatomic, strong) NSString *message;
@property (nonatomic, strong) NSDictionary *message_tags;
@property (nonatomic, strong) NSString *picture;
@property (nonatomic, strong) NSString *link;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *caption;
@property (nonatomic, strong) NSString *description;
@property (nonatomic, strong) NSString *source;
@property (nonatomic, strong) NSArray  *properties;
@property (nonatomic, strong) NSString *icon;
@property (nonatomic, strong) NSArray *actions;
@property (nonatomic, strong) NSDictionary *privacy;
@property (nonatomic, strong) NSString *type;

@end
