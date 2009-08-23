// Copyright 2004-2009 Facebook. All Rights Reserved.

#import "Three20/TTLauncherItem.h"

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation TTLauncherItem

@synthesize launcher = _launcher, title = _title, image = _image, URL = _URL,
            badgeNumber = _badgeNumber;

///////////////////////////////////////////////////////////////////////////////////////////////////
// NSObject

- (id)initWithTitle:(NSString*)title image:(NSString*)image URL:(NSString*)URL {
  if (self = [super init]) {
    self.title = title;
    self.image = image;
    self.URL = URL;
    
    _launcher = nil;
    _badgeNumber = 0;
  }
  return self;
}

- (void)dealloc {
  TT_RELEASE_SAFELY(_title);
  TT_RELEASE_SAFELY(_image);
  TT_RELEASE_SAFELY(_URL);
  [super dealloc];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// NSCoding

- (id)initWithCoder:(NSCoder*)decoder {
  if (self = [super init]) {
    self.title = [decoder decodeObjectForKey:@"title"];
    self.image = [decoder decodeObjectForKey:@"image"];
    self.URL = [decoder decodeObjectForKey:@"URL"];
  }
  return self;
}

- (void)encodeWithCoder:(NSCoder*)encoder {
  [encoder encodeObject:_title forKey:@"title"];
  [encoder encodeObject:_image forKey:@"image"];
  [encoder encodeObject:_URL forKey:@"URL"];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// public

- (void)setBadgeNumber:(NSInteger)badgeNumber {
  _badgeNumber = badgeNumber;
  
  [_launcher performSelector:@selector(updateItemBadge:) withObject:self];
}

@end
