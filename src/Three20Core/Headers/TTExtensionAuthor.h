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

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface TTExtensionAuthor : NSObject {
@private
  NSString* _name;
  NSString* _github;
  NSString* _twitter;
  NSString* _website;
}

@property (nonatomic, copy) NSString* name;
@property (nonatomic, copy) NSString* github;
@property (nonatomic, copy) NSString* twitter;
@property (nonatomic, copy) NSString* website;

+ (id)authorWithName: (NSString*)name;

+ (id)authorWithName: (NSString*)name
              github: (NSString*)github
             twitter: (NSString*)twitter
             website: (NSString*)website;

// Designated initializer
- (id)initWithName: (NSString*)name
            github: (NSString*)github
           twitter: (NSString*)twitter
           website: (NSString*)website;

@end
