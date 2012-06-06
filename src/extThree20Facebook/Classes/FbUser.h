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
#import "FbDate.h"
#import "FbDateTime.h"
#import "FbConnection.h"

@interface FbUser : FbObject {
    NSString                    *name;
    NSString                    *first_name;
    NSString                    *middle_name;	
    NSString                    *last_name;
    NSString                    *gender;
    NSString                    *locale;
    NSArray                     *languages;	
    NSString                    *link;
    NSString                    *username;
    float                       timezone;
    FbDateTime                  *updated_time;
    int                         verified;
    NSString                    *bio;
    FbDate                      *birthday;
    NSArray                     *education;
    NSString                    *email;
    NSDictionary                *hometown;	
    NSArray                     *interested_in;
	NSDictionary                *location;
    NSString                    *political;
	NSArray                     *favorite_athletes;	
    NSArray                     *favorite_teams;
    NSString                    *quotes;	
    NSString                    *relationship_status;
    NSString                    *religion;
    NSDictionary                *significant_other;
    NSString                    *website;
    NSArray                     *work;
}

@property (nonatomic, strong) NSString *xmlid;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *first_name;
@property (nonatomic, strong) NSString *middle_name;	
@property (nonatomic, strong) NSString *last_name;
@property (nonatomic, strong) NSString *gender;
@property (nonatomic, strong) NSString *locale;
@property (nonatomic, strong) NSArray *languages;	
@property (nonatomic, strong) NSString *link;
@property (nonatomic, strong) NSString *username;
@property float timezone;
@property (nonatomic, strong) NSDate *updated_time;
@property int verified;
@property (nonatomic, strong) NSString *bio;
@property (nonatomic, strong) NSDate *birthday;
@property (nonatomic, strong) NSArray *education;
@property (nonatomic, strong) NSString *email;
@property (nonatomic, strong) NSDictionary *hometown;	
@property (nonatomic, strong) NSArray *interested_in;
@property (nonatomic, strong) NSDictionary *location;
@property (nonatomic, strong) NSString *political;
@property (nonatomic, strong) NSArray *favorite_athletes;	
@property (nonatomic, strong) NSArray *favorite_teams;
@property (nonatomic, strong) NSString *quotes;	
@property (nonatomic, strong) NSString *relationship_status;
@property (nonatomic, strong) NSString *religion;
@property (nonatomic, strong) NSDictionary *significant_other;
@property (nonatomic, strong) NSString *website;
@property (nonatomic, strong) NSArray *work;

@end
