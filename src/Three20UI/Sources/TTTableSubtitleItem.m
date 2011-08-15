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

#import "Three20UI/TTTableSubtitleItem.h"

// Core
#import "Three20Core/TTCorePreprocessorMacros.h"


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation TTTableSubtitleItem

@synthesize subtitle      = _subtitle;
@synthesize imageURL      = _imageURL;
@synthesize defaultImage  = _defaultImage;


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)dealloc {
  TT_RELEASE_SAFELY(_subtitle);
  TT_RELEASE_SAFELY(_imageURL);
  TT_RELEASE_SAFELY(_defaultImage);

  [super dealloc];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Class public


///////////////////////////////////////////////////////////////////////////////////////////////////
+ (id)itemWithText:(NSString*)text subtitle:(NSString*)subtitle {
  TTTableSubtitleItem* item = [[[self alloc] init] autorelease];
  item.text = text;
  item.subtitle = subtitle;
  return item;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
+ (id)itemWithText:(NSString*)text subtitle:(NSString*)subtitle URL:(NSString*)URL {
  TTTableSubtitleItem* item = [[[self alloc] init] autorelease];
  item.text = text;
  item.subtitle = subtitle;
  item.URL = URL;
  return item;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
+ (id)itemWithText:(NSString*)text subtitle:(NSString*)subtitle
               URL:(NSString*)URL accessoryURL:(NSString*)accessoryURL {
  TTTableSubtitleItem* item = [[[self alloc] init] autorelease];
  item.text = text;
  item.subtitle = subtitle;
  item.URL = URL;
  item.accessoryURL = accessoryURL;
  return item;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
+ (id)itemWithText:(NSString*)text subtitle:(NSString*)subtitle imageURL:(NSString*)imageURL
               URL:(NSString*)URL {
  TTTableSubtitleItem* item = [[[self alloc] init] autorelease];
  item.text = text;
  item.subtitle = subtitle;
  item.imageURL = imageURL;
  item.URL = URL;
  return item;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
+ (id)itemWithText:(NSString*)text subtitle:(NSString*)subtitle imageURL:(NSString*)imageURL
      defaultImage:(UIImage*)defaultImage URL:(NSString*)URL accessoryURL:(NSString*)accessoryURL {
  TTTableSubtitleItem* item = [[[self alloc] init] autorelease];
  item.text = text;
  item.subtitle = subtitle;
  item.imageURL = imageURL;
  item.defaultImage = defaultImage;
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
    self.subtitle = [decoder decodeObjectForKey:@"subtitle"];
    self.imageURL = [decoder decodeObjectForKey:@"imageURL"];
  }
  return self;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)encodeWithCoder:(NSCoder*)encoder {
  [super encodeWithCoder:encoder];
  if (self.subtitle) {
    [encoder encodeObject:self.subtitle forKey:@"subtitle"];
  }
  if (self.imageURL) {
    [encoder encodeObject:self.imageURL forKey:@"imageURL"];
  }
}


@end
