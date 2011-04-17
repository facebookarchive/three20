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

#import "Three20UI/TTExtensionAuthorController.h"

// Core
#import "Three20Core/TTCorePreprocessorMacros.h"
#import "Three20Core/TTExtensionInfo.h"
#import "Three20Core/TTExtensionAuthor.h"
#import "Three20Core/TTExtensionLoader.h"


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation TTExtensionAuthorController


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)dealloc {
  TT_RELEASE_SAFELY(_author);

  [super dealloc];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithExtensionID:(NSString*)identifier authorIndex:(NSInteger)authorIndex {
  self = [super initWithNibName:nil bundle:nil];
  if (nil != self) {
    TTExtensionInfo* extensionInfo = [[TTExtensionLoader availableExtensions]
                                      objectForKey:identifier];

    _author = [[extensionInfo.authors objectAtIndex:authorIndex] retain];

    self.title = _author.name;
  }

  return self;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
  return [self initWithExtensionID:nil authorIndex:0];
}


@end

