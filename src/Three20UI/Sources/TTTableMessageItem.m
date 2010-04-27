//
// Copyright 2009-2010 Facebook
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

#import "Three20UI/TTTableMessageItem.h"

// Core
#import "Three20Core/TTCorePreprocessorMacros.h"


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation TTTableMessageItem

@synthesize title     = _title;
@synthesize caption   = _caption;
@synthesize timestamp = _timestamp;
@synthesize imageURL  = _imageURL;


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)dealloc {
  TT_RELEASE_SAFELY(_title);
  TT_RELEASE_SAFELY(_caption);
  TT_RELEASE_SAFELY(_timestamp);
  TT_RELEASE_SAFELY(_imageURL);

  [super dealloc];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Class public


///////////////////////////////////////////////////////////////////////////////////////////////////
+ (id)itemWithTitle:(NSString*)title caption:(NSString*)caption text:(NSString*)text
          timestamp:(NSDate*)timestamp URL:(NSString*)URL {
  TTTableMessageItem* item = [[[self alloc] init] autorelease];
  item.title = title;
  item.caption = caption;
  item.text = text;
  item.timestamp = timestamp;
  item.URL = URL;
  return item;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
+ (id)itemWithTitle:(NSString*)title caption:(NSString*)caption text:(NSString*)text
          timestamp:(NSDate*)timestamp imageURL:(NSString*)imageURL URL:(NSString*)URL {
  TTTableMessageItem* item = [[[self alloc] init] autorelease];
  item.title = title;
  item.caption = caption;
  item.text = text;
  item.timestamp = timestamp;
  item.imageURL = imageURL;
  item.URL = URL;
  return item;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark NSCoding


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithCoder:(NSCoder*)decoder {
  if (self = [super initWithCoder:decoder]) {
    self.title = [decoder decodeObjectForKey:@"title"];
    self.caption = [decoder decodeObjectForKey:@"caption"];
    self.timestamp = [decoder decodeObjectForKey:@"timestamp"];
    self.imageURL = [decoder decodeObjectForKey:@"imageURL"];
  }
  return self;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)encodeWithCoder:(NSCoder*)encoder {
  [super encodeWithCoder:encoder];
  if (self.title) {
    [encoder encodeObject:self.title forKey:@"title"];
  }
  if (self.caption) {
    [encoder encodeObject:self.caption forKey:@"caption"];
  }
  if (self.timestamp) {
    [encoder encodeObject:self.timestamp forKey:@"timestamp"];
  }
  if (self.imageURL) {
    [encoder encodeObject:self.imageURL forKey:@"imageURL"];
  }
}


@end
