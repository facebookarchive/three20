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

#import "Three20Core/TTExtensionAuthor.h"

// Core
#import "Three20Core/TTCorePreprocessorMacros.h"


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation TTExtensionAuthor

@synthesize name    = _name;
@synthesize github  = _github;
@synthesize twitter = _twitter;
@synthesize website = _website;


///////////////////////////////////////////////////////////////////////////////////////////////////
+ (id)authorWithName:(NSString*)name {
  return [[[self alloc] initWithName: name
                              github: nil
                             twitter: nil
                             website: nil] autorelease];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
+ (id)authorWithName: (NSString*)name
              github: (NSString*)github
             twitter: (NSString*)twitter
             website: (NSString*)website {
  return [[[self alloc] initWithName: name
                              github: github
                             twitter: twitter
                             website: website] autorelease];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithName: (NSString*)name
            github: (NSString*)github
           twitter: (NSString*)twitter
           website: (NSString*)website {
  if (self = [super init]) {
    self.name     = name;
    self.github   = github;
    self.twitter  = twitter;
    self.website  = website;
  }
  return self;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)init {
  return [self initWithName:@"Unknown" github:nil twitter:nil website:nil];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)dealloc {
  TT_RELEASE_SAFELY(_name);
  TT_RELEASE_SAFELY(_github);
  TT_RELEASE_SAFELY(_twitter);
  TT_RELEASE_SAFELY(_website);

  [super dealloc];
}


@end

