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

#import "Three20UI/TTTableCaptionItem.h"

// Core
#import "Three20Core/TTCorePreprocessorMacros.h"


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation TTTableCaptionItem

@synthesize caption = _caption;


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)dealloc {
  TT_RELEASE_SAFELY(_caption);

  [super dealloc];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Class public


///////////////////////////////////////////////////////////////////////////////////////////////////
+ (id)itemWithText:(NSString*)text caption:(NSString*)caption {
  TTTableCaptionItem* item = [[[self alloc] init] autorelease];
  item.text = text;
  item.caption = caption;
  return item;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
+ (id)itemWithText:(NSString*)text caption:(NSString*)caption URL:(NSString*)URL {
  TTTableCaptionItem* item = [[[self alloc] init] autorelease];
  item.text = text;
  item.caption = caption;
  item.URL = URL;
  return item;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
+ (id)itemWithText:(NSString*)text caption:(NSString*)caption URL:(NSString*)URL
      accessoryURL:(NSString*)accessoryURL {
  TTTableCaptionItem* item = [[[self alloc] init] autorelease];
  item.text = text;
  item.caption = caption;
  item.URL = URL;
  item.accessoryURL = accessoryURL;
  return item;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark NSCoding


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithCoder:(NSCoder*)decoder {
	self = [super initWithCoder:decoder];
  if (self) {
    self.caption = [decoder decodeObjectForKey:@"caption"];
  }
  return self;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)encodeWithCoder:(NSCoder*)encoder {
  [super encodeWithCoder:encoder];
  if (self.caption) {
    [encoder encodeObject:self.caption forKey:@"caption"];
  }
}


@end
