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

#import "Three20UI/TTLauncherItem.h"

// Core
#import "Three20Core/TTCorePreprocessorMacros.h"


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation TTLauncherItem

@synthesize launcher    = _launcher;
@synthesize title       = _title;
@synthesize image       = _image;
@synthesize URL         = _URL;
@synthesize style       = _style;
@synthesize badgeValue  = _badgeValue;
@synthesize canDelete   = _canDelete;
@synthesize userInfo    = _userInfo;


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark NSObject


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithTitle:(NSString*)title image:(NSString*)image URL:(NSString*)URL {
	self = [self initWithTitle:title image:image URL:URL canDelete:NO];
  if (self) {
  }

  return self;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithTitle:(NSString*)title image:(NSString*)image URL:(NSString*)URL
      canDelete:(BOOL)canDelete {
	self = [super init];
  if (self) {
    _canDelete = canDelete;

    self.title = title;
    self.image = image;
    self.URL = URL;
  }

  return self;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)dealloc {
  TT_RELEASE_SAFELY(_title);
  TT_RELEASE_SAFELY(_image);
  TT_RELEASE_SAFELY(_URL);
  TT_RELEASE_SAFELY(_style);
  TT_RELEASE_SAFELY(_userInfo);

  [super dealloc];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark NSCoding


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithCoder:(NSCoder*)decoder {
	self = [super init];
  if (self) {
    self.title = [decoder decodeObjectForKey:@"title"];
    self.image = [decoder decodeObjectForKey:@"image"];
    self.URL = [decoder decodeObjectForKey:@"URL"];
    self.style = [decoder decodeObjectForKey:@"style"];
    self.canDelete = [decoder decodeBoolForKey:@"canDelete"];
  }

  return self;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)encodeWithCoder:(NSCoder*)encoder {
  [encoder encodeObject:_title forKey:@"title"];
  [encoder encodeObject:_image forKey:@"image"];
  [encoder encodeObject:_URL forKey:@"URL"];
  [encoder encodeObject:_style forKey:@"style"];
  [encoder encodeBool:_canDelete forKey:@"canDelete"];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Public


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSInteger)badgeNumber {
  return [self.badgeValue integerValue];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setBadgeNumber:(NSInteger)badgeNumber {
  if (badgeNumber == 0) {
    [self setBadgeValue:nil];

  } else {
    [self setBadgeValue:[NSString stringWithFormat:@"%d",badgeNumber]];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setBadgeValue:(NSString *)badgeValue {
  if (_badgeValue != badgeValue) {
    [_badgeValue release];
    _badgeValue = [badgeValue copy];
  }

  [_launcher performSelector:@selector(updateItemBadge:) withObject:self];
}

@end
