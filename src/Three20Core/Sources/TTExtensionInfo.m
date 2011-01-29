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

#import "Three20Core/TTExtensionInfo.h"

// Core
#import "Three20Core/TTCorePreprocessorMacros.h"

// Core (private)
#import "Three20Core/private/TTExtensionInfoPrivate.h"


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation TTExtensionInfo

@synthesize identifier  = _id;
@synthesize name        = _name;
@synthesize description = _description;
@synthesize version     = _version;
@synthesize copyright   = _copyright;
@synthesize license     = _license;
@synthesize authors     = _authors;


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)init {
  if (self = [super init]) {
    self.version = @"No version provided.";
    self.description = @"No description provided.";
    self.copyright = @"No copyright provided.";
    self.license = @"No license provided.";
  }

  return self;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)dealloc {
  TT_RELEASE_SAFELY(_id);
  TT_RELEASE_SAFELY(_description);
  TT_RELEASE_SAFELY(_name);
  TT_RELEASE_SAFELY(_version);
  TT_RELEASE_SAFELY(_copyright);
  TT_RELEASE_SAFELY(_license);
  TT_RELEASE_SAFELY(_authors);

  [super dealloc];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)isEqual:(TTExtensionInfo*)extension {
  return [_id isEqualToString:extension.identifier];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setIdentifier:(NSString*)identifier {
  if (_id != identifier) {
    [_id release];
    _id = [identifier copy];
  }
}


@end

