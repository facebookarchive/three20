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

#import "Three20UI/TTTableImageItem.h"

// Core
#import "Three20Core/TTCorePreprocessorMacros.h"


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation TTTableImageItem

@synthesize imageURL      = _imageURL;
@synthesize defaultImage  = _defaultImage;
@synthesize imageStyle    = _imageStyle;


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)dealloc {
  TT_RELEASE_SAFELY(_imageURL);
  TT_RELEASE_SAFELY(_defaultImage);
  TT_RELEASE_SAFELY(_imageStyle);

  [super dealloc];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Class public


///////////////////////////////////////////////////////////////////////////////////////////////////
+ (id)itemWithText:(NSString*)text imageURL:(NSString*)imageURL {
  TTTableImageItem* item = [[[self alloc] init] autorelease];
  item.text = text;
  item.imageURL = imageURL;
  return item;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
+ (id)itemWithText:(NSString*)text imageURL:(NSString*)imageURL URL:(NSString*)URL {
  TTTableImageItem* item = [[[self alloc] init] autorelease];
  item.text = text;
  item.imageURL = imageURL;
  item.URL = URL;
  return item;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
+ (id)itemWithText:(NSString*)text imageURL:(NSString*)imageURL defaultImage:(UIImage*)defaultImage
               URL:(NSString*)URL {
  TTTableImageItem* item = [[[self alloc] init] autorelease];
  item.text = text;
  item.imageURL = imageURL;
  item.defaultImage = defaultImage;
  item.URL = URL;
  return item;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
+ (id)itemWithText:(NSString*)text imageURL:(NSString*)imageURL defaultImage:(UIImage*)defaultImage
        imageStyle:(TTStyle*)imageStyle URL:(NSString*)URL {
  TTTableImageItem* item = [[[self alloc] init] autorelease];
  item.text = text;
  item.imageURL = imageURL;
  item.defaultImage = defaultImage;
  item.imageStyle = imageStyle;
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
    self.imageURL = [decoder decodeObjectForKey:@"imageURL"];
  }
  return self;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)encodeWithCoder:(NSCoder*)encoder {
  [super encodeWithCoder:encoder];
  if (self.imageURL) {
    [encoder encodeObject:self.imageURL forKey:@"imageURL"];
  }
}


@end
