#import "Three20/T3TableViewCells.h"
#import "Three20/T3TableItems.h"
#import "Three20/T3ImageView.h"
#import "Three20/T3ErrorView.h"
#import "Three20/T3NavigationCenter.h"

///////////////////////////////////////////////////////////////////////////////////////////////////

static CGFloat kHPadding = 10;
static CGFloat kVPadding = 10;
static CGFloat kMargin = 10;
static CGFloat kSpacing = 8;

static CGFloat kKeySpacing = 12;
static CGFloat kKeyWidth = 75;
static CGFloat kKeyHeight = 18;
static CGFloat kMaxLabelHeight = 2000;

static CGFloat kTextFieldTitleWidth = 100;

static CGFloat kIconSize = 50;

#define T3_LINK_TEXT_COLOR RGBCOLOR(87, 107, 149)

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation T3TableViewCell

@synthesize object;

+ (CGFloat)rowHeightForItem:(id)item tableView:(UITableView*)tableView {
  return TOOLBAR_HEIGHT;
}

///////////////////////////////////////////////////////////////////////////////////////////////////

- (id)initWithFrame:(CGRect)frame style:(int)style reuseIdentifier:(NSString*)identifier {
  if (self = [super initWithFrame:frame reuseIdentifier:identifier]) {
    object = nil;
  }
  return self;
}

- (void)dealloc {
  [object release];
  [super dealloc];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// UITableViewCell

- (void)prepareForReuse {
  self.object = nil;
  [super prepareForReuse];
}

@end

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation T3TitleTableViewCell

+ (CGFloat)rowHeightForItem:(id)item tableView:(UITableView*)tableView {
  return TOOLBAR_HEIGHT;
}

///////////////////////////////////////////////////////////////////////////////////////////////////

- (id)initWithFrame:(CGRect)frame style:(int)style reuseIdentifier:(NSString*)identifier {
  if (self = [super initWithFrame:frame style:style reuseIdentifier:identifier]) {
    titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    titleLabel.opaque = YES;
    titleLabel.backgroundColor = [UIColor whiteColor];
    titleLabel.highlightedTextColor = [UIColor whiteColor];
    [self.contentView addSubview:titleLabel];
	}
	return self;
}

- (void)dealloc {
  [titleLabel release];
	[super dealloc];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// UIView

- (void)layoutSubviews {
  [super layoutSubviews];

  titleLabel.frame = CGRectInset(self.contentView.bounds, kHPadding, kVPadding);
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// T3TableViewCell

- (void)setObject:(id)anObject {
  if (object != anObject) {
    [super setObject:anObject];
  
    T3TitleTableItem* item = object;
    titleLabel.text = item.title;

    if ([object isKindOfClass:[T3ButtonTableItem class]]) {
      titleLabel.font = [UIFont boldSystemFontOfSize:15];
      titleLabel.textColor = T3_LINK_TEXT_COLOR;
      titleLabel.textAlignment = UITextAlignmentCenter;
      self.accessoryType = UITableViewCellAccessoryNone;
      self.selectionStyle = UITableViewCellSelectionStyleBlue;
    } else if ([object isKindOfClass:[T3LinkTableItem class]]) {
      titleLabel.font = [UIFont boldSystemFontOfSize:16];
      titleLabel.textColor = T3_LINK_TEXT_COLOR;
      titleLabel.textAlignment = UITextAlignmentLeft;
      self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
      self.selectionStyle = UITableViewCellSelectionStyleBlue;
    } else if ([object isKindOfClass:[T3SummaryTableItem class]]) {
      titleLabel.font = [UIFont systemFontOfSize:17];
      titleLabel.textColor = [UIColor grayColor];
      titleLabel.textAlignment = UITextAlignmentCenter;
      self.accessoryType = UITableViewCellAccessoryNone;
      self.selectionStyle = UITableViewCellSelectionStyleNone;
    } else {
      titleLabel.font = [UIFont boldSystemFontOfSize:15];
      titleLabel.textColor = [UIColor blackColor];
      titleLabel.textAlignment = UITextAlignmentLeft;
      self.accessoryType = UITableViewCellAccessoryNone;
      self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
  }  
}

@end

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation T3TextTableViewCell

+ (CGFloat)rowHeightForItem:(id)item tableView:(UITableView*)tableView {
  CGRect appFrame = [UIScreen mainScreen].applicationFrame;
  CGFloat maxWidth = appFrame.size.width - (kHPadding*2 + kMargin*2);
  T3TextTableItem* tableItem = item;

  CGSize size = [tableItem.text sizeWithFont:[UIFont boldSystemFontOfSize:15]
    constrainedToSize:CGSizeMake(maxWidth, CGFLOAT_MAX)
    lineBreakMode:UILineBreakModeWordWrap];
  if (size.height > kMaxLabelHeight) {
    size.height = kMaxLabelHeight;
  }

  return size.height + kVPadding*2;
}

///////////////////////////////////////////////////////////////////////////////////////////////////

- (id)initWithFrame:(CGRect)frame style:(int)style reuseIdentifier:(NSString*)identifier {
  if (self = [super initWithFrame:frame style:style reuseIdentifier:identifier]) {
    textLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    textLabel.opaque = YES;
    textLabel.backgroundColor = [UIColor whiteColor];
    textLabel.font = [UIFont boldSystemFontOfSize:15];
    textLabel.textColor = [UIColor blackColor];
    textLabel.textAlignment = UITextAlignmentLeft;
    textLabel.lineBreakMode = UILineBreakModeWordWrap;
    textLabel.numberOfLines = 0;
    [self.contentView addSubview:textLabel];

    self.accessoryType = UITableViewCellAccessoryNone;
    self.selectionStyle = UITableViewCellSelectionStyleNone;
	}
	return self;
}

- (void)dealloc {
  [textLabel release];
	[super dealloc];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// UIView

- (void)layoutSubviews {
  [super layoutSubviews];
  
  textLabel.frame = CGRectInset(self.contentView.bounds, kHPadding, kVPadding);
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// T3TableViewCell

- (void)setObject:(id)anObject {
  if (object != anObject) {
    [super setObject:anObject];
  
    T3TextTableItem* item = object;
    textLabel.text = item.text;

    if ([object isKindOfClass:[T3MessageTableItem class]]) {
      textLabel.font = [UIFont systemFontOfSize:14];
      textLabel.textColor = [UIColor grayColor];
      textLabel.textAlignment = UITextAlignmentCenter;
    } else {
      textLabel.font = [UIFont boldSystemFontOfSize:15];
      textLabel.textColor = [UIColor blackColor];
      textLabel.textAlignment = UITextAlignmentLeft;
    }
  }
}

@end

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation T3KeyValueTableViewCell

+ (CGFloat)rowHeightForItem:(id)item tableView:(UITableView*)tableView {
  CGRect appFrame = [UIScreen mainScreen].applicationFrame;
  CGFloat maxWidth = appFrame.size.width - (kKeyWidth + kKeySpacing + kHPadding*2 + kMargin*2);
  T3KeyValueTableItem* tableItem = item;

  CGSize size = [tableItem.value sizeWithFont:[UIFont boldSystemFontOfSize:15]
    constrainedToSize:CGSizeMake(maxWidth, CGFLOAT_MAX)
    lineBreakMode:UILineBreakModeWordWrap];
  
  return size.height + kVPadding*2;
}

///////////////////////////////////////////////////////////////////////////////////////////////////

- (id)initWithFrame:(CGRect)frame style:(int)style reuseIdentifier:(NSString*)identifier {
  if (self = [super initWithFrame:frame style:style reuseIdentifier:identifier]) {
    keyLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    keyLabel.opaque = YES;
    keyLabel.backgroundColor = [UIColor whiteColor];
    keyLabel.font = [UIFont boldSystemFontOfSize:13];
    keyLabel.textColor = T3_LINK_TEXT_COLOR;
    keyLabel.highlightedTextColor = [UIColor whiteColor];
    keyLabel.textAlignment = UITextAlignmentRight;
    keyLabel.contentMode = UIViewContentModeTop;
    [self.contentView addSubview:keyLabel];
    
    valueLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    valueLabel.opaque = YES;
    valueLabel.backgroundColor = [UIColor whiteColor];
    valueLabel.font = [UIFont boldSystemFontOfSize:15];
    valueLabel.textColor = [UIColor blackColor];
    valueLabel.highlightedTextColor = [UIColor whiteColor];
    valueLabel.adjustsFontSizeToFitWidth = YES;
    valueLabel.lineBreakMode = UILineBreakModeWordWrap;
    valueLabel.numberOfLines = 0;
    [self.contentView addSubview:valueLabel];
	}
	return self;
}

- (void)dealloc {
  [keyLabel release];
  [valueLabel release];
	[super dealloc];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// UIView

- (void)layoutSubviews {
  [super layoutSubviews];

  CGFloat valueWidth = self.contentView.width - (kHPadding*2 + kKeyWidth + kKeySpacing);
  CGFloat innerHeight = self.contentView.height - kVPadding*2;
  keyLabel.frame = CGRectMake(kHPadding, kVPadding, kKeyWidth, kKeyHeight);
  valueLabel.frame = CGRectMake(kHPadding + kKeyWidth + kKeySpacing, kVPadding,
    valueWidth, innerHeight);
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// T3TableViewCell

- (void)setObject:(id)anObject {
  if (object != anObject) {
    [super setObject:anObject];
  
    T3KeyValueTableItem* item = object;
    keyLabel.text = item.title;
    valueLabel.text = item.value;
  
    if (item.href) {
      if ([[T3NavigationCenter defaultCenter] urlIsSupported:item.href]) {
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
      } else {
        self.accessoryType = UITableViewCellAccessoryNone;
      }
      self.selectionStyle = UITableViewCellSelectionStyleBlue;
    } else {
      self.accessoryType = UITableViewCellAccessoryNone;
      self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
  }  
}

@end

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation T3IconTableViewCell

+ (CGFloat)rowHeightForItem:(id)item tableView:(UITableView*)tableView {
  T3IconTableItem* iconItem = item;

  CGRect appFrame = [UIScreen mainScreen].applicationFrame;
  CGFloat iconSize = iconItem.icon ? kIconSize + kKeySpacing : 0;
  CGFloat maxWidth = appFrame.size.width - (iconSize + kHPadding*2 + kMargin*2);
  CGSize size = [iconItem.title sizeWithFont:[UIFont boldSystemFontOfSize:15]
    constrainedToSize:CGSizeMake(maxWidth, CGFLOAT_MAX)
    lineBreakMode:UILineBreakModeWordWrap];

  return (size.height > iconSize ? size.height : kIconSize) + kVPadding*2;
}

///////////////////////////////////////////////////////////////////////////////////////////////////

- (id)initWithFrame:(CGRect)frame style:(int)style reuseIdentifier:(NSString*)identifier {
  if (self = [super initWithFrame:frame style:style reuseIdentifier:identifier]) {
    titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    titleLabel.opaque = YES;
    titleLabel.backgroundColor = [UIColor whiteColor];
    titleLabel.font = [UIFont boldSystemFontOfSize:15];
    titleLabel.textColor = [UIColor blackColor];
    titleLabel.highlightedTextColor = [UIColor whiteColor];
    titleLabel.textAlignment = UITextAlignmentCenter;
    titleLabel.lineBreakMode = UILineBreakModeWordWrap;
    titleLabel.numberOfLines = 0;
    [self.contentView addSubview:titleLabel];

    iconView = [[T3ImageView alloc] initWithFrame:CGRectZero];
    [self.contentView addSubview:iconView];
	}
	return self;
}

- (void)dealloc {
  [titleLabel release];
  [iconView release];
	[super dealloc];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// UIView

- (void)layoutSubviews {
  [super layoutSubviews];
  
  if (iconView.url) {
    CGFloat innerWidth = self.contentView.width - (kHPadding*2 + kIconSize + kKeySpacing);
    CGFloat innerHeight = self.contentView.height - kVPadding*2;
    titleLabel.frame = CGRectMake(kHPadding, kVPadding, innerWidth, innerHeight);

    iconView.frame = CGRectMake(titleLabel.right + kKeySpacing,
      floor(self.height/2 - kIconSize/2), kIconSize, kIconSize);
  } else {
    titleLabel.frame = CGRectInset(self.contentView.bounds, kHPadding, kVPadding);
    iconView.frame = CGRectZero;
  }
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// T3TableViewCell

- (void)setObject:(id)anObject {
  if (object != anObject) {
    [super setObject:anObject];
  
    T3IconTableItem* item = object;
    titleLabel.text = item.title;
    iconView.defaultImage = item.defaultImage;
    iconView.url = item.icon;
  }  
}

@end

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation T3TextFieldTableViewCell

@synthesize textField;

- (id)initWithFrame:(CGRect)frame style:(int)style reuseIdentifier:(NSString*)identifier {
  if (self = [super initWithFrame:frame style:style reuseIdentifier:identifier]) {
    titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    titleLabel.font = [UIFont boldSystemFontOfSize:17];

    textField = [[UITextField alloc] initWithFrame:CGRectZero];
    textField.leftView = titleLabel;
    textField.leftViewMode = UITextFieldViewModeAlways;
    textField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    [self.contentView addSubview:textField];

    self.accessoryType = UITableViewCellAccessoryNone;
    self.selectionStyle = UITableViewCellSelectionStyleNone;
  }
  return self;
}

- (void)dealloc {
  [titleLabel release];
  [textField release];
  [super dealloc];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// UIView

- (void)layoutSubviews {
  [super layoutSubviews];
  
  [titleLabel sizeToFit];
  titleLabel.width = kTextFieldTitleWidth;

  textField.frame = CGRectOffset(CGRectInset(self.contentView.bounds, 3, 0), 0, 1);
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// T3TableViewCell

- (void)setObject:(id)anObject {
  if (object != anObject) {
    [super setObject:anObject];

    T3TextFieldTableItem* item = object;
    titleLabel.text = [NSString stringWithFormat:@"  %@", item.title];
    textField.text = item.text;
    textField.placeholder = item.placeholder;
    textField.returnKeyType = item.returnKeyType;
    textField.keyboardType = item.keyboardType;
    textField.autocapitalizationType = item.autocapitalizationType;
    textField.autocorrectionType = item.autocorrectionType;
    textField.clearButtonMode = item.clearButtonMode;
    textField.secureTextEntry = item.secureTextEntry;
    textField.delegate = item.delegate;
  }  
}

@end

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation T3TextEditorTableViewCell

@synthesize textEditor;

+ (CGFloat)rowHeightForItem:(id)item tableView:(UITableView*)tableView {
  return 180;
}

///////////////////////////////////////////////////////////////////////////////////////////////////

- (id)initWithFrame:(CGRect)frame style:(int)style reuseIdentifier:(NSString*)identifier {
  if (self = [super initWithFrame:frame style:style reuseIdentifier:identifier]) {
    self.accessoryType = UITableViewCellAccessoryNone;
    self.selectionStyle = UITableViewCellSelectionStyleNone;
  }
  return self;
}

- (void)dealloc {
  [textEditor release];
  [super dealloc];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// UIView

- (void)layoutSubviews {
  [super layoutSubviews];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// T3TableViewCell

- (void)setObject:(id)anObject {
  if (object != anObject) {
    [super setObject:anObject];
  }  
}

@end

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation T3ActivityTableViewCell

@synthesize animating;

+ (CGFloat)rowHeightForItem:(id)item tableView:(UITableView*)tableView {
  if ([item isKindOfClass:[T3StatusTableItem class]]) {
    T3StatusTableItem* statusItem = item;
    if (statusItem.sizeToFit) {
      return tableView.height - tableView.tableHeaderView.height;
    }
  }

  return [super rowHeightForItem:item tableView:tableView];
}

- (id)initWithFrame:(CGRect)frame style:(int)style reuseIdentifier:(NSString*)identifier {
  if (self = [super initWithFrame:frame style:style reuseIdentifier:identifier]) {
    spinnerView = nil;
    
    titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    titleLabel.opaque = YES;
    titleLabel.backgroundColor = [UIColor whiteColor];
    titleLabel.highlightedTextColor = [UIColor whiteColor];
    titleLabel.lineBreakMode = UILineBreakModeTailTruncation;
    [self.contentView addSubview:titleLabel];

    subtitleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    subtitleLabel.opaque = YES;
    subtitleLabel.backgroundColor = [UIColor whiteColor];
    subtitleLabel.font = [UIFont systemFontOfSize:14];
    subtitleLabel.textColor = [UIColor grayColor];
    subtitleLabel.highlightedTextColor = [UIColor whiteColor];
    subtitleLabel.lineBreakMode = UILineBreakModeTailTruncation;
    [self.contentView addSubview:subtitleLabel];

    self.accessoryType = UITableViewCellAccessoryNone;
  }
  return self;
}

- (void)dealloc {
  [spinnerView release];
  [titleLabel release];
  [subtitleLabel release];
  [super dealloc];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// UIView

- (void)layoutSubviews {
  [super layoutSubviews];
  
  [titleLabel sizeToFit];
  [subtitleLabel sizeToFit];
  
  CGFloat titleHeight = titleLabel.height + subtitleLabel.height;
  CGFloat titleWidth = titleLabel.width > subtitleLabel.width
    ? titleLabel.width
    : subtitleLabel.width;
  
  spinnerView.y = floor(self.contentView.height/2 - spinnerView.height/2);
  titleLabel.y = floor(self.contentView.height/2 - titleHeight/2);
  subtitleLabel.y = titleLabel.bottom;
  
  if ([object isKindOfClass:[T3ActivityTableItem class]]) {
    CGFloat totalWidth = titleLabel.width + kSpacing + spinnerView.width;
    spinnerView.x = floor(self.contentView.width/2 - totalWidth/2);
    titleLabel.x = spinnerView.right + kSpacing;
  } else if ([object isKindOfClass:[T3MoreLinkTableItem class]]) {
    titleLabel.x = titleLabel.y*2;
    subtitleLabel.x = titleLabel.y*2;
    spinnerView.x = titleLabel.x + titleWidth + kSpacing;
  }
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// T3TableViewCell

- (void)setObject:(id)anObject {
  if (object != anObject) {
    [super setObject:anObject];

    if ([object isKindOfClass:[T3ActivityTableItem class]]) {
      T3ActivityTableItem* item = object;

      titleLabel.text = item.title;
      titleLabel.font = [UIFont systemFontOfSize:17];
      titleLabel.textColor = [UIColor grayColor];

      subtitleLabel.hidden = YES;
      
      self.selectionStyle = UITableViewCellSelectionStyleNone;
      self.animating = YES;
    } else if ([object isKindOfClass:[T3MoreLinkTableItem class]]) {
      T3MoreLinkTableItem* item = object;

      titleLabel.text = item.title;
      titleLabel.font = [UIFont boldSystemFontOfSize:17];
      titleLabel.textColor = RGBCOLOR(36, 112, 216);

      if (item.subtitle) {
        subtitleLabel.text = item.subtitle;
        subtitleLabel.hidden = NO;
      } else {
        subtitleLabel.hidden = YES;
      }

      self.selectionStyle = UITableViewCellSelectionStyleBlue;
      self.animating = item.loading;
    }
  }  
}

- (void)setAnimating:(BOOL)isAnimating {
  animating = isAnimating;
  
  if (animating) {
    if (!spinnerView) {
      spinnerView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:
        UIActivityIndicatorViewStyleGray];
      [self.contentView addSubview:spinnerView];
    }

    [spinnerView startAnimating];
  } else {
    [spinnerView stopAnimating];
  }
  [self setNeedsLayout];
}

@end

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation T3ErrorTableViewCell

+ (CGFloat)rowHeightForItem:(id)item tableView:(UITableView*)tableView {
  if ([item isKindOfClass:[T3StatusTableItem class]]) {
    T3StatusTableItem* statusItem = item;
    if (statusItem.sizeToFit) {
      return tableView.height - tableView.tableHeaderView.height;
    }
  }

  return [super rowHeightForItem:item tableView:tableView];
}

- (id)initWithFrame:(CGRect)frame style:(int)style reuseIdentifier:(NSString*)identifier {
  if (self = [super initWithFrame:frame style:style reuseIdentifier:identifier]) {
    emptyView = [[T3ErrorView alloc] initWithFrame:CGRectZero];
    [self addSubview:emptyView];

    self.accessoryType = UITableViewCellAccessoryNone;
    self.selectionStyle = UITableViewCellSelectionStyleNone;
  }
  return self;
}

- (void)dealloc {
  [emptyView release];
  [super dealloc];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// UIView

- (void)layoutSubviews {
  [super layoutSubviews];
  
  emptyView.frame = self.bounds;
  [emptyView setNeedsLayout];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// T3TableViewCell

- (void)setObject:(id)anObject {
  if (object != anObject) {
    [super setObject:anObject];
    
    T3ErrorTableItem* emptyItem = object;
    emptyView.image = emptyItem.image;
    emptyView.title = emptyItem.title;
    emptyView.subtitle = emptyItem.subtitle;
  }  
}

@end
