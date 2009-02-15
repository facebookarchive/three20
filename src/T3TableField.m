#include "Three20/T3TableField.h"

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation T3TableField

@synthesize text = _text, href = _href;

- (id)init {
  if (self = [super init]) {
    _text = nil;
    _href = nil;
  }
  return self;
}

- (id)initWithText:(NSString*)text {
  if (self = [self init]) {
    self.text = text;
  }
  return self;
}

- (id)initWithText:(NSString*)text href:(NSString*)href {
  if (self = [self init]) {
    self.text = text;
    self.href = href;
  }
  return self;
}

- (id)initWithHref:(NSString*)href {
  if (self = [self init]) {
    self.href = href;
  }
  return self;
}

- (void)dealloc {
  [_text release];
  [_href release];
  [super dealloc];
}

@end

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation T3TextTableField
@end

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation T3GrayTextTableField
@end

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation T3SummaryTableField
@end

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation T3LinkTableField
@end

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation T3ButtonTableField
@end

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation T3MoreButtonTableField

@synthesize loading = _loading, subtitle = _subtitle;

- (id)init {
  if (self = [super init]) {
    _loading = NO;
    _subtitle = nil;
  }
  return self;
}

- (id)initWithText:(NSString*)text subtitle:(NSString*)subtitle {
  if (self = [super initWithText:text]) {
    self.subtitle = subtitle;
  }
  return self;
}

- (void)dealloc {
  [_subtitle release];
  [super dealloc];
}

@end

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation T3TitledTableField

@synthesize title = _title;

- (id)init {
  if (self = [super init]) {
    _title = nil;
  }
  return self;
}

- (id)initWithTitle:(NSString*)title text:(NSString*)text {
  if (self = [super initWithText:text]) {
    self.title = title;
  }
  return self;
}

- (id)initWithTitle:(NSString*)title text:(NSString*)text href:(NSString*)href {
  if (self = [self initWithText:text href:href]) {
    self.title = title;
  }
  return self;
}

- (void)dealloc {
  [_title release];
  [super dealloc];
}

@end

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation T3SubtextTableField

@synthesize subtext = _subtext;

- (id)init {
  if (self = [super init]) {
    _subtext = nil;
  }
  return self;
}

- (id)initWithText:(NSString*)text subtext:(NSString*)subtext {
  if (self = [super initWithText:text]) {
    self.subtext = subtext;
  }
  return self;
}

- (id)initWithText:(NSString*)text subtext:(NSString*)subtext href:(NSString*)href {
  if (self = [self initWithText:text href:href]) {
    self.subtext = subtext;
  }
  return self;
}

- (void)dealloc {
  [_subtext release];
  [super dealloc];
}

@end

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation T3ImageTableField

@synthesize defaultImage = _defaultImage, image = _image;

- (id)init {
  if (self = [super init]) {
    _defaultImage = nil;
    _image = nil;
  }
  return self;
}

- (id)initWithText:(NSString*)text href:(NSString*)href image:(NSString*)icon
    defaultImage:(UIImage*)image {
  if (self = [super initWithText:text href:href]) {
    self.image = icon;
    self.defaultImage = image;
  }
  return self;
}

- (id)initWithText:(NSString*)text href:(NSString*)href image:(NSString*)image {
  return [self initWithText:text href:href image:image defaultImage:nil];
}

- (void)dealloc {
  [_image release];
  [_defaultImage release];
  [super dealloc];
}

@end

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation T3IconTableField

@end

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation T3StatusTableField

@synthesize sizeToFit = _sizeToFit;

- (id)init {
  if (self = [super init]) {
    _sizeToFit = NO;
  }
  return self;
}

@end

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation T3ActivityTableField

@end

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation T3ErrorTableField

@synthesize subtitle = _subtitle, image = _image;

- (id)init {
  if (self = [super init]) {
    _subtitle = nil;
    _image = nil;
  }
  return self;
}

- (id)initWithText:(NSString*)text subtitle:(NSString*)subtitle image:(UIImage*)image {
  if (self = [self initWithText:text]) {
    self.subtitle = subtitle;
    self.image = image;
  }
  return self;
}

- (void)dealloc {
  [_subtitle release];
  [_image release];
  [super dealloc];
}

@end

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation T3TextFieldTableField

@synthesize delegate = _delegate, text = _text, title = _title, placeholder = _placeholder,
  returnKeyType = _returnKeyType, keyboardType = _keyboardType,
  autocorrectionType = _autocorrectionType, autocapitalizationType = _autocapitalizationType,
  clearButtonMode = _clearButtonMode, secureTextEntry = _secureTextEntry;

- (id)init {
  if (self = [super init]) {
    _delegate = nil;
    _title = nil;
    _text = nil;
    _placeholder = nil;
    _returnKeyType = UIReturnKeyDefault;
    _keyboardType = UIKeyboardTypeDefault;
    _autocapitalizationType = UITextAutocapitalizationTypeNone;
    _autocorrectionType = UITextAutocorrectionTypeDefault;
    _clearButtonMode = UITextFieldViewModeNever;
    _secureTextEntry = NO;
  }
  return self;
}

- (id)initWithTitle:(NSString*)title {
  if (self = [self init]) {
    self.title = title;
  }
  return self;
}

- (id)initWithTitle:(NSString*)title text:(NSString*)text {
  if (self = [self initWithTitle:title]) {
    self.text = text;
  }
  return self;
}

- (void)dealloc {
  [_title release];
  [_text release];
  [_placeholder release];
  [super dealloc];
}

@end

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation T3TextViewTableField

@synthesize delegate = _delegate, placeholder = _placeholder, text = _text;

- (id)initWithText:(NSString*)text {
  if (self = [self init]) {
    self.text = text;
  }
  return self;
}

- (id)init {
  if (self = [super init]) {
    _delegate = nil;
    _placeholder = nil;
    _text = nil;
  }
  return self;
}

- (void)dealloc {
  [_placeholder release];
  [super dealloc];
}

@end


///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation T3SwitchTableField

@synthesize on = _on;

- (id)initWithText:(NSString*)text on:(BOOL)on {
  if (self = [self initWithText:text]) {
    self.on = on;
  }
  return self;
}

- (id)init {
  if (self = [super init]) {
    _on = NO;
  }
  return self;
}

- (void)dealloc {
  [super dealloc];
}

@end

