#include "Three20/T3TableItems.h"

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation T3TableItem

@end

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation T3TextTableItem

@synthesize text;

- (id)init {
  if (self = [super init]) {
    text = nil;
  }
  return self;
}

- (id)initWithText:(NSString*)aText {
  if (self = [super init]) {
    self.text = aText;
  }
  return self;
}

- (void)dealloc {
  [text release];
  [super dealloc];
}

@end

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation T3TitleTableItem

@synthesize title;

- (id)init {
  if (self = [super init]) {
    title = nil;
  }
  return self;
}

- (id)initWithTitle:(NSString*)aTitle {
  if (self = [self init]) {
    self.title = aTitle;
  }
  return self;
}

- (void)dealloc {
  [title release];
  [super dealloc];
}

@end

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation T3MessageTableItem

@end

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation T3SummaryTableItem

@end

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation T3LinkTableItem

@synthesize href;

- (id)init {
  if (self = [super init]) {
    href = nil;
  }
  return self;
}

- (id)initWithTitle:(NSString*)aTitle href:(NSString*)aHref {
  if (self = [super initWithTitle:aTitle]) {
    self.href = aHref;
  }
  return self;
}

- (void)dealloc {
  [href release];
  [super dealloc];
}

@end

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation T3ButtonTableItem

@end

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation T3KeyValueTableItem

@synthesize value;

- (id)init {
  if (self = [super init]) {
    value = nil;
  }
  return self;
}

- (id)initWithKey:(NSString*)aKey value:(NSString*)aValue {
  if (self = [super initWithTitle:aKey]) {
    self.value = aValue;
  }
  return self;
}

- (id)initWithKey:(NSString*)aKey value:(NSString*)aValue href:(NSString*)aHref {
  if (self = [self initWithKey:aKey value:aValue]) {
    self.href = aHref;
  }
  return self;
}

- (void)dealloc {
  [value release];
  [super dealloc];
}

@end

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation T3IconTableItem

@synthesize defaultImage, icon;

- (id)init {
  if (self = [super init]) {
    defaultImage = nil;
    icon = nil;
  }
  return self;
}

- (id)initWithTitle:(NSString*)aTitle icon:(NSString*)aIcon  href:(NSString*)aHref
    defaultImage:(UIImage*)aImage {
  if (self = [super initWithTitle:aTitle href:aHref]) {
    self.icon = aIcon;
    self.defaultImage = aImage;
  }
  return self;
}

- (void)dealloc {
  [icon release];
  [defaultImage release];
  [super dealloc];
}

@end

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation T3TextFieldTableItem

@synthesize delegate = _delegate, text = _text, title, placeholder, returnKeyType, keyboardType,
  autocorrectionType, autocapitalizationType, clearButtonMode, secureTextEntry;

- (id)init {
  if (self = [super init]) {
    _delegate = nil;
    _text = nil;
    title = nil;
    placeholder = nil;
    returnKeyType = UIReturnKeyDefault;
    keyboardType = UIKeyboardTypeDefault;
    autocapitalizationType = UITextAutocapitalizationTypeNone;
    autocorrectionType = UITextAutocorrectionTypeDefault;
    clearButtonMode = UITextFieldViewModeNever;
    secureTextEntry = NO;
  }
  return self;
}

- (id)initWithTitle:(NSString*)aTitle {
  if (self = [self init]) {
    self.title = aTitle;
  }
  return self;
}

- (void)dealloc {
  [_text release];
  [title release];
  [placeholder release];
  [super dealloc];
}

@end

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation T3TextEditorTableItem

@synthesize delegate = _delegate, placeholder = _placeholder;

- (id)init {
  if (self = [super init]) {
    _delegate = nil;
    _placeholder = nil;
  }
  return self;
}

- (void)dealloc {
  [_placeholder release];
  [super dealloc];
}

@end

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation T3StatusTableItem

@synthesize sizeToFit;

- (id)init {
  if (self = [super init]) {
    sizeToFit = NO;
  }
  return self;
}

@end

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation T3ActivityTableItem

@synthesize title;

- (id)init {
  if (self = [super init]) {
    title = nil;
  }
  return self;
}

- (id)initWithTitle:(NSString*)aTitle {
  if (self = [super init]) {
    self.title = aTitle;
  }
  return self;
}

- (void)dealloc {
  [title release];
  [super dealloc];
}

@end

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation T3ErrorTableItem

@synthesize title, subtitle, image;

- (id)init {
  if (self = [super init]) {
    title = nil;
    subtitle = nil;
    image = nil;
  }
  return self;
}

- (id)initWithTitle:(NSString*)aTitle subtitle:(NSString*)aSubtitle image:(UIImage*)aImage {
  if (self = [super init]) {
    self.title = aTitle;
    self.subtitle = aSubtitle;
    self.image = aImage;
  }
  return self;
}

- (void)dealloc {
  [title release];
  [subtitle release];
  [image release];
  [super dealloc];
}

@end

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation T3MoreLinkTableItem

@synthesize loading, subtitle;

- (id)init {
  if (self = [super init]) {
    loading = NO;
    subtitle = nil;
  }
  return self;
}

- (id)initWithTitle:(NSString*)aTitle subtitle:(NSString*)aSubtitle {
  if (self = [super initWithTitle:aTitle]) {
    self.subtitle = aSubtitle;
  }
  return self;
}

- (void)dealloc {
  [subtitle release];
  [super dealloc];
}

@end
