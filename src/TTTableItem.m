#include "Three20/TTTableItem.h"
#include "Three20/TTStyledNode.h"
#include "Three20/TTStyledText.h"

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation TTTableItem

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
  TT_RELEASE_MEMBER(_URL);
  TT_RELEASE_MEMBER(_accessoryURL);
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
  TT_RELEASE_MEMBER(_text);
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

@implementation TTTableCaptionedItem

@synthesize caption = _caption;

///////////////////////////////////////////////////////////////////////////////////////////////////
// class public

+ (id)itemWithText:(NSString*)text caption:(NSString*)caption {
  TTTableCaptionedItem* item = [[[self alloc] init] autorelease];
  item.text = text;
  item.caption = caption;
  return item;
}

+ (id)itemWithText:(NSString*)text caption:(NSString*)caption URL:(NSString*)URL {
  TTTableCaptionedItem* item = [[[self alloc] init] autorelease];
  item.text = text;
  item.caption = caption;
  item.URL = URL;
  return item;
}

+ (id)itemWithText:(NSString*)text caption:(NSString*)caption URL:(NSString*)URL
      accessoryURL:(NSString*)accessoryURL {
  TTTableCaptionedItem* item = [[[self alloc] init] autorelease];
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
  TT_RELEASE_MEMBER(_caption);
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

@implementation TTTableRightCaptionedItem
@end

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation TTTableBelowCaptionedItem
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

@synthesize image = _image, defaultImage = _defaultImage, imageStyle = _imageStyle;

///////////////////////////////////////////////////////////////////////////////////////////////////
// class public

+ (id)itemWithText:(NSString*)text image:(NSString*)image {
  TTTableImageItem* item = [[[self alloc] init] autorelease];
  item.text = text;
  item.image = image;
  return item;
}

+ (id)itemWithText:(NSString*)text URL:(NSString*)URL image:(NSString*)image {
  TTTableImageItem* item = [[[self alloc] init] autorelease];
  item.text = text;
  item.image = image;
  item.URL = URL;
  return item;
}

+ (id)itemWithText:(NSString*)text URL:(NSString*)URL image:(NSString*)image
      defaultImage:(UIImage*)defaultImage {
  TTTableImageItem* item = [[[self alloc] init] autorelease];
  item.text = text;
  item.image = image;
  item.defaultImage = defaultImage;
  item.URL = URL;
  return item;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// NSObject

- (id)init {
  if (self = [super init]) {
    _defaultImage = nil;
    _image = nil;
    _imageStyle = nil;
  }
  return self;
}

- (void)dealloc {
  TT_RELEASE_MEMBER(_image);
  TT_RELEASE_MEMBER(_defaultImage);
  TT_RELEASE_MEMBER(_imageStyle);
  [super dealloc];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
// NSCoding

- (id)initWithCoder:(NSCoder*)decoder {
  if (self = [super initWithCoder:decoder]) {
    self.image = [decoder decodeObjectForKey:@"image"];
  }
  return self;
}

- (void)encodeWithCoder:(NSCoder*)encoder {
  [super encodeWithCoder:encoder];
  if (self.image) {
    [encoder encodeObject:self.image forKey:@"image"];
  }
}
@end

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation TTTableRightImageItem
@end

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation TTTableStatusItem

@synthesize sizeToFit = _sizeToFit;

- (id)init {
  if (self = [super init]) {
    _sizeToFit = NO;
  }
  return self;
}

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
  TT_RELEASE_MEMBER(_text);
  [super dealloc];
}

@end

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation TTTableErrorItem

@synthesize image = _image, title = _title, subtitle = _subtitle;


///////////////////////////////////////////////////////////////////////////////////////////////////
// class public

+ (id)itemWithTitle:(NSString*)title subtitle:(NSString*)subtitle image:(UIImage*)image {
  TTTableErrorItem* item = [[[self alloc] init] autorelease];
  item.title = title;
  item.subtitle = subtitle;
  item.image = image;
  return item;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// NSObject

- (id)init {
  if (self = [super init]) {
    _title = nil;
    _subtitle = nil;
    _image = nil;
  }
  return self;
}

- (void)dealloc {
  TT_RELEASE_MEMBER(_title);
  TT_RELEASE_MEMBER(_subtitle);
  TT_RELEASE_MEMBER(_image);
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
    _padding = UIEdgeInsetsMake(10, 10, 10, 10);    
  }
  return self;
}

- (void)dealloc {
  TT_RELEASE_MEMBER(_text);
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
// NSObject

- (id)init {
  if (self = [super init]) {
    _caption = nil;
    _control = nil;
  }
  return self;
}

- (void)dealloc {
  TT_RELEASE_MEMBER(_caption);
  TT_RELEASE_MEMBER(_control);
  [super dealloc];
}

+ (id)itemWithCaption:(NSString*)caption control:(UIControl*)control {
  TTTableControlItem* item = [[[self alloc] init] autorelease];
  item.caption = caption;
  item.control = control;
  return item;
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
// NSObject

- (id)init {
  if (self = [super init]) {
    _caption = nil;
    _view = nil;
  }
  return self;
}

- (void)dealloc {
  TT_RELEASE_MEMBER(_caption);
  TT_RELEASE_MEMBER(_view);
  [super dealloc];
}

+ (id)itemWithCaption:(NSString*)caption view:(UIControl*)view {
  TTTableViewItem* item = [[[self alloc] init] autorelease];
  item.caption = caption;
  item.view = view;
  return item;
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
