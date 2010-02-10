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

#import "Three20/TTTableItem.h"

#import "Three20/TTGlobalCore.h"

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation TTTableItem

@synthesize userInfo = _userInfo;

///////////////////////////////////////////////////////////////////////////////////////////////////
// NSObject

- (id)init {
  if (self = [super init]) {
    _userInfo = nil;
  }
  return self;
}

- (void)dealloc {
  TT_RELEASE_SAFELY(_userInfo);
  [super dealloc];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// NSCoding

- (id)initWithCoder:(NSCoder*)decoder {
  return [self init];
}

- (void)encodeWithCoder:(NSCoder*)encoder {
}

@end

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation TTTableLinkedItem

@synthesize URL = _URL, accessoryURL = _accessoryURL;

///////////////////////////////////////////////////////////////////////////////////////////////////
// NSObject

- (id)init {
  if (self = [super init]) {
    _URL = nil;
    _accessoryURL = nil;
  }
  return self;
}

- (void)dealloc {
  TT_RELEASE_SAFELY(_URL);
  TT_RELEASE_SAFELY(_accessoryURL);
  [super dealloc];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// NSCoding

- (id)initWithCoder:(NSCoder*)decoder {
  if (self = [super initWithCoder:decoder]) {
    self.URL = [decoder decodeObjectForKey:@"URL"];
  }
  return self;
}

- (void)encodeWithCoder:(NSCoder*)encoder {
  [super encodeWithCoder:encoder];
  if (self.URL) {
    [encoder encodeObject:self.URL forKey:@"URL"];
  }
  if (self.accessoryURL) {
    [encoder encodeObject:self.accessoryURL forKey:@"URL"];
  }
}

@end

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation TTTableTextItem

@synthesize text = _text;

///////////////////////////////////////////////////////////////////////////////////////////////////
// class public

+ (id)itemWithText:(NSString*)text {
  TTTableTextItem* item = [[[self alloc] init] autorelease];
  item.text = text;
  return item;
}

+ (id)itemWithText:(NSString*)text URL:(NSString*)URL {
  TTTableTextItem* item = [[[self alloc] init] autorelease];
  item.text = text;
  item.URL = URL;
  return item;
}

+ (id)itemWithText:(NSString*)text URL:(NSString*)URL accessoryURL:(NSString*)accessoryURL {
  TTTableTextItem* item = [[[self alloc] init] autorelease];
  item.text = text;
  item.URL = URL;
  item.accessoryURL = accessoryURL;
  return item;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// NSObject

- (id)init {
  if (self = [super init]) {
    _text = nil;
  }
  return self;
}

- (void)dealloc {
  TT_RELEASE_SAFELY(_text);
  [super dealloc];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// NSCoding

- (id)initWithCoder:(NSCoder*)decoder {
  if (self = [super initWithCoder:decoder]) {
    self.text = [decoder decodeObjectForKey:@"text"];
  }
  return self;
}

- (void)encodeWithCoder:(NSCoder*)encoder {
  [super encodeWithCoder:encoder];
  if (self.text) {
    [encoder encodeObject:self.text forKey:@"text"];
  }
}

@end

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation TTTableCaptionItem

@synthesize caption = _caption;

///////////////////////////////////////////////////////////////////////////////////////////////////
// class public

+ (id)itemWithText:(NSString*)text caption:(NSString*)caption {
  TTTableCaptionItem* item = [[[self alloc] init] autorelease];
  item.text = text;
  item.caption = caption;
  return item;
}

+ (id)itemWithText:(NSString*)text caption:(NSString*)caption URL:(NSString*)URL {
  TTTableCaptionItem* item = [[[self alloc] init] autorelease];
  item.text = text;
  item.caption = caption;
  item.URL = URL;
  return item;
}

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
// NSObject

- (id)init {
  if (self = [super init]) {
    _caption = nil;
  }
  return self;
}

- (void)dealloc {
  TT_RELEASE_SAFELY(_caption);
  [super dealloc];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// NSCoding

- (id)initWithCoder:(NSCoder*)decoder {
  if (self = [super initWithCoder:decoder]) {
    self.caption = [decoder decodeObjectForKey:@"caption"];
  }
  return self;
}

- (void)encodeWithCoder:(NSCoder*)encoder {
  [super encodeWithCoder:encoder];
  if (self.caption) {
    [encoder encodeObject:self.caption forKey:@"caption"];
  }
}

@end

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation TTTableRightCaptionItem
@end

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation TTTableSubtextItem
@end

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation TTTableSubtitleItem

@synthesize subtitle = _subtitle, imageURL = _imageURL, defaultImage = _defaultImage;

///////////////////////////////////////////////////////////////////////////////////////////////////
// class public

+ (id)itemWithText:(NSString*)text subtitle:(NSString*)subtitle {
  TTTableSubtitleItem* item = [[[self alloc] init] autorelease];
  item.text = text;
  item.subtitle = subtitle;
  return item;
}

+ (id)itemWithText:(NSString*)text subtitle:(NSString*)subtitle URL:(NSString*)URL {
  TTTableSubtitleItem* item = [[[self alloc] init] autorelease];
  item.text = text;
  item.subtitle = subtitle;
  item.URL = URL;
  return item;
}

+ (id)itemWithText:(NSString*)text subtitle:(NSString*)subtitle
      URL:(NSString*)URL accessoryURL:(NSString*)accessoryURL {
  TTTableSubtitleItem* item = [[[self alloc] init] autorelease];
  item.text = text;
  item.subtitle = subtitle;
  item.URL = URL;
  item.accessoryURL = accessoryURL;
  return item;
}

+ (id)itemWithText:(NSString*)text subtitle:(NSString*)subtitle imageURL:(NSString*)imageURL
      URL:(NSString*)URL {
  TTTableSubtitleItem* item = [[[self alloc] init] autorelease];
  item.text = text;
  item.subtitle = subtitle;
  item.imageURL = imageURL;
  item.URL = URL;
  return item;
}

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
// NSObject

- (id)init {
  if (self = [super init]) {
    _subtitle = nil;
    _imageURL = nil;
    _defaultImage = nil;
  }
  return self;
}

- (void)dealloc {
  TT_RELEASE_SAFELY(_subtitle);
  TT_RELEASE_SAFELY(_imageURL);
  TT_RELEASE_SAFELY(_defaultImage);
  [super dealloc];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// NSCoding

- (id)initWithCoder:(NSCoder*)decoder {
  if (self = [super initWithCoder:decoder]) {
    self.subtitle = [decoder decodeObjectForKey:@"subtitle"];
    self.imageURL = [decoder decodeObjectForKey:@"imageURL"];
  }
  return self;
}

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

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation TTTableMessageItem

@synthesize title = _title, caption = _caption, timestamp = _timestamp, imageURL = _imageURL;

///////////////////////////////////////////////////////////////////////////////////////////////////
// class public

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
// NSObject

- (id)init {
  if (self = [super init]) {
    _title = nil;
    _caption = nil;
    _timestamp = nil;
    _imageURL = nil;
  }
  return self;
}

- (void)dealloc {
  TT_RELEASE_SAFELY(_title);
  TT_RELEASE_SAFELY(_caption);
  TT_RELEASE_SAFELY(_timestamp);
  TT_RELEASE_SAFELY(_imageURL);
  [super dealloc];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// NSCoding

- (id)initWithCoder:(NSCoder*)decoder {
  if (self = [super initWithCoder:decoder]) {
    self.title = [decoder decodeObjectForKey:@"title"];
    self.caption = [decoder decodeObjectForKey:@"caption"];
    self.timestamp = [decoder decodeObjectForKey:@"timestamp"];
    self.imageURL = [decoder decodeObjectForKey:@"imageURL"];
  }
  return self;
}

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

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation TTTableLongTextItem
@end

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation TTTableGrayTextItem
@end

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation TTTableSummaryItem
@end

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation TTTableLink
@end

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation TTTableButton
@end

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation TTTableMoreButton

@synthesize isLoading = _isLoading;

- (id)init {
  if (self = [super init]) {
    _isLoading = NO;
  }
  return self;
}

- (void)dealloc {
  [super dealloc];
}

@end

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation TTTableImageItem

@synthesize imageURL = _imageURL, defaultImage = _defaultImage, imageStyle = _imageStyle;

///////////////////////////////////////////////////////////////////////////////////////////////////
// class public

+ (id)itemWithText:(NSString*)text imageURL:(NSString*)imageURL {
  TTTableImageItem* item = [[[self alloc] init] autorelease];
  item.text = text;
  item.imageURL = imageURL;
  return item;
}

+ (id)itemWithText:(NSString*)text imageURL:(NSString*)imageURL URL:(NSString*)URL {
  TTTableImageItem* item = [[[self alloc] init] autorelease];
  item.text = text;
  item.imageURL = imageURL;
  item.URL = URL;
  return item;
}

+ (id)itemWithText:(NSString*)text imageURL:(NSString*)imageURL defaultImage:(UIImage*)defaultImage
      URL:(NSString*)URL {
  TTTableImageItem* item = [[[self alloc] init] autorelease];
  item.text = text;
  item.imageURL = imageURL;
  item.defaultImage = defaultImage;
  item.URL = URL;
  return item;
}

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
// NSObject

- (id)init {
  if (self = [super init]) {
    _defaultImage = nil;
    _imageURL = nil;
    _imageStyle = nil;
  }
  return self;
}

- (void)dealloc {
  TT_RELEASE_SAFELY(_imageURL);
  TT_RELEASE_SAFELY(_defaultImage);
  TT_RELEASE_SAFELY(_imageStyle);
  [super dealloc];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
// NSCoding

- (id)initWithCoder:(NSCoder*)decoder {
  if (self = [super initWithCoder:decoder]) {
    self.imageURL = [decoder decodeObjectForKey:@"imageURL"];
  }
  return self;
}

- (void)encodeWithCoder:(NSCoder*)encoder {
  [super encodeWithCoder:encoder];
  if (self.imageURL) {
    [encoder encodeObject:self.imageURL forKey:@"imageURL"];
  }
}
@end

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation TTTableRightImageItem
@end

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation TTTableActivityItem

@synthesize text = _text;

///////////////////////////////////////////////////////////////////////////////////////////////////
// class public

+ (id)itemWithText:(NSString*)text {
  TTTableActivityItem* item = [[[self alloc] init] autorelease];
  item.text = text;
  return item;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// NSObject

- (id)init {
  if (self = [super init]) {
    _text = nil;
  }
  return self;
}

- (void)dealloc {
  TT_RELEASE_SAFELY(_text);
  [super dealloc];
}

@end

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation TTTableStyledTextItem

@synthesize text = _text, margin = _margin, padding = _padding;

///////////////////////////////////////////////////////////////////////////////////////////////////
// class public

+ (id)itemWithText:(TTStyledText*)text {
  TTTableStyledTextItem* item = [[[self alloc] init] autorelease];
  item.text = text;
  return item;
}

+ (id)itemWithText:(TTStyledText*)text URL:(NSString*)URL {
  TTTableStyledTextItem* item = [[[self alloc] init] autorelease];
  item.text = text;
  item.URL = URL;
  return item;
}

+ (id)itemWithText:(TTStyledText*)text URL:(NSString*)URL accessoryURL:(NSString*)accessoryURL {
  TTTableStyledTextItem* item = [[[self alloc] init] autorelease];
  item.text = text;
  item.URL = URL;
  item.accessoryURL = accessoryURL;
  return item;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// NSObject

- (id)init {
  if (self = [super init]) {
    _text = nil;
    _margin = UIEdgeInsetsZero;
    _padding = UIEdgeInsetsMake(6, 6, 6, 6);
  }
  return self;
}

- (void)dealloc {
  TT_RELEASE_SAFELY(_text);
  [super dealloc];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// NSCoding

- (id)initWithCoder:(NSCoder*)decoder {
  if (self = [super initWithCoder:decoder]) {
    self.text = [decoder decodeObjectForKey:@"text"];
  }
  return self;
}

- (void)encodeWithCoder:(NSCoder*)encoder {
  [super encodeWithCoder:encoder];
  if (self.text) {
    [encoder encodeObject:self.text forKey:@"text"];
  }
}

@end

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation TTTableControlItem

@synthesize caption = _caption, control = _control;

///////////////////////////////////////////////////////////////////////////////////////////////////
// class public

+ (id)itemWithCaption:(NSString*)caption control:(UIControl*)control {
  TTTableControlItem* item = [[[self alloc] init] autorelease];
  item.caption = caption;
  item.control = control;
  return item;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// NSObject

- (id)init {
  if (self = [super init]) {
    _caption = nil;
    _control = nil;
  }
  return self;
}

- (void)dealloc {
  TT_RELEASE_SAFELY(_caption);
  TT_RELEASE_SAFELY(_control);
  [super dealloc];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// NSCoding

- (id)initWithCoder:(NSCoder*)decoder {
  if (self = [super initWithCoder:decoder]) {
    self.caption = [decoder decodeObjectForKey:@"caption"];
    self.control = [decoder decodeObjectForKey:@"control"];
  }
  return self;
}

- (void)encodeWithCoder:(NSCoder*)encoder {
  [super encodeWithCoder:encoder];
  if (self.caption) {
    [encoder encodeObject:self.caption forKey:@"caption"];
  }
  if (self.control) {
    [encoder encodeObject:self.control forKey:@"control"];
  }
}

@end

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation TTTableViewItem

@synthesize caption = _caption, view = _view;

///////////////////////////////////////////////////////////////////////////////////////////////////
// class public

+ (id)itemWithCaption:(NSString*)caption view:(UIControl*)view {
  TTTableViewItem* item = [[[self alloc] init] autorelease];
  item.caption = caption;
  item.view = view;
  return item;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// NSObject

- (id)init {
  if (self = [super init]) {
    _caption = nil;
    _view = nil;
  }
  return self;
}

- (void)dealloc {
  TT_RELEASE_SAFELY(_caption);
  TT_RELEASE_SAFELY(_view);
  [super dealloc];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// NSCoding

- (id)initWithCoder:(NSCoder*)decoder {
  if (self = [super initWithCoder:decoder]) {
    self.caption = [decoder decodeObjectForKey:@"caption"];
    self.view = [decoder decodeObjectForKey:@"view"];
  }
  return self;
}

- (void)encodeWithCoder:(NSCoder*)encoder {
  [super encodeWithCoder:encoder];
  if (self.caption) {
    [encoder encodeObject:self.caption forKey:@"caption"];
  }
  if (self.view) {
    [encoder encodeObject:self.view forKey:@"control"];
  }
}

@end
