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

@interface FbLink : FbObject {
    FbUser          *from;
    NSString        *link;
    NSString        *name;
    NSString        *description;
    NSString        *icon;
    NSString        *picture;
    NSString        *message;
    FbDateTime      *created_time;
}

@property (nonatomic, strong) NSString *xmlid;
@property (nonatomic, strong) FbUser *from;
@property (nonatomic, strong) NSString *link;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *description;
@property (nonatomic, strong) NSString *icon;
@property (nonatomic, strong) NSString *picture;
@property (nonatomic, strong) NSString *message;
@property (nonatomic, strong) FbDateTime *created_time;

@end
