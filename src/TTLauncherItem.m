#import "Three20/TTLauncherItem.h"

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation TTLauncherItem

@synthesize launcher = _launcher, title = _title, image = _image, URL = _URL, style = _style,
            badgeNumber = _badgeNumber, canDelete = _canDelete;

///////////////////////////////////////////////////////////////////////////////////////////////////
// NSObject

- (id)initWithTitle:(NSString*)title image:(NSString*)image URL:(NSString*)URL {
  return [self initWithTitle:title image:image URL:URL canDelete:NO];
}

- (id)initWithTitle:(NSString*)title image:(NSString*)image URL:(NSString*)URL
      canDelete:(BOOL)canDelete {
  if (self = [super init]) {
    _launcher = nil;
    _title = nil;
    _image = nil;
    _URL = nil;
    _style = nil;
    _badgeNumber = 0;
    _canDelete = canDelete;

    self.title = title;
    self.image = image;
    self.URL = URL;
  }
  return self;
}

- (void)dealloc {
  TT_RELEASE_SAFELY(_title);
  TT_RELEASE_SAFELY(_image);
  TT_RELEASE_SAFELY(_URL);
  TT_RELEASE_SAFELY(_style);
  [super dealloc];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// NSCoding

- (id)initWithCoder:(NSCoder*)decoder {
  if (self = [super init]) {
    self.title = [decoder decodeObjectForKey:@"title"];
    self.image = [decoder decodeObjectForKey:@"image"];
    self.URL = [decoder decodeObjectForKey:@"URL"];
    self.style = [decoder decodeObjectForKey:@"style"];
    self.canDelete = [decoder decodeBoolForKey:@"canDelete"];
  }
  return self;
}

- (void)encodeWithCoder:(NSCoder*)encoder {
  [encoder encodeObject:_title forKey:@"title"];
  [encoder encodeObject:_image forKey:@"image"];
  [encoder encodeObject:_URL forKey:@"URL"];
  [encoder encodeObject:_style forKey:@"style"];
  [encoder encodeBool:_canDelete forKey:@"canDelete"];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// public

- (void)setBadgeNumber:(NSInteger)badgeNumber {
  _badgeNumber = badgeNumber;
  
  [_launcher performSelector:@selector(updateItemBadge:) withObject:self];
}

@end
