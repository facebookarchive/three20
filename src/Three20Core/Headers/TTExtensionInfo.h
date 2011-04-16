//
// Copyright 2009-2011 Facebook
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

// Core
#import "Three20Core/TTLicenseInfo.h"

@interface TTExtensionInfo : NSObject {
@private
  NSString* _id;
  NSString* _name;
  NSString* _description;
  NSString* _website;
  NSString* _version;

  // License information
  NSArray*  _licenses;

  NSArray*  _authors;
}

@property (nonatomic, readonly) NSString* identifier;
@property (nonatomic, copy)     NSString* name;
@property (nonatomic, copy)     NSString* description;
@property (nonatomic, copy)     NSString* website;
@property (nonatomic, copy)     NSString* version;
@property (nonatomic, copy)     NSArray*  licenses; // NSArray of TTLicenseInfo* objects.
@property (nonatomic, copy)     NSArray*  authors;  // NSArray of TTExtensionAuthor* objects.

@end
