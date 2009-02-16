#import "Three20/TTTableFieldCell.h"
#import "Three20/TTTableField.h"
#import "Three20/TTImageView.h"
#import "Three20/TTErrorView.h"
#import "Three20/TTNavigationCenter.h"
#import "Three20/TTURLCache.h"
#import "Three20/TTAppearance.h"

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
static CGFloat kTableViewFieldCellHeight = 180;

static CGFloat kDefaultIconSize = 50;

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation TTTableFieldCell

+ (CGFloat)rowHeightForItem:(id)item tableView:(UITableView*)tableView {
  return TOOLBAR_HEIGHT;
}

///////////////////////////////////////////////////////////////////////////////////////////////////

- (id)initWithFrame:(CGRect)frame style:(int)style reuseIdentifier:(NSString*)identifier {
  if (self = [super initWithFrame:frame style:style reuseIdentifier:identifier]) {
    _label = [[UILabel alloc] initWithFrame:CGRectZero];
    _label.highlightedTextColor = [UIColor whiteColor];
    [self.contentView addSubview:_label];
	}
	return self;
}

- (void)dealloc {
  [_label release];
	[super dealloc];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// UIView

- (void)layoutSubviews {
  [super layoutSubviews];

  _label.frame = CGRectInset(self.contentView.bounds, kHPadding, 0);
}

-(void)didMoveToSuperview {
  [super didMoveToSuperview];
  if (self.superview && [(UITableView*)self.superview style] == UITableViewStylePlain) {
    _label.backgroundColor = self.superview.backgroundColor;
  }
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// TTTableViewCell

- (void)setObject:(id)anObject {
  if (object != anObject) {
    [super setObject:anObject];
  
    TTTableField* field = object;
    _label.text = field.text;
    
    if (field.href) {
      if ([[TTNavigationCenter defaultCenter] urlIsSupported:field.href]) {
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
      } else {
        self.accessoryType = UITableViewCellAccessoryNone;
      }
      self.selectionStyle = UITableViewCellSelectionStyleBlue;
    } else {
      self.accessoryType = UITableViewCellAccessoryNone;
      self.selectionStyle = UITableViewCellSelectionStyleNone;
    }

    if ([object isKindOfClass:[TTButtonTableField class]]) {
      _label.font = [UIFont boldSystemFontOfSize:15];
      _label.textColor = [TTAppearance appearance].linkTextColor;
      _label.textAlignment = UITextAlignmentCenter;
      self.accessoryType = UITableViewCellAccessoryNone;
      self.selectionStyle = UITableViewCellSelectionStyleBlue;
    } else if ([object isKindOfClass:[TTLinkTableField class]]) {
      _label.font = [UIFont boldSystemFontOfSize:16];
      _label.textColor = [TTAppearance appearance].linkTextColor;
      _label.textAlignment = UITextAlignmentLeft;
    } else if ([object isKindOfClass:[TTSummaryTableField class]]) {
      _label.font = [UIFont systemFontOfSize:17];
      _label.textColor = [UIColor grayColor];
      _label.textAlignment = UITextAlignmentCenter;
    } else {
      _label.font = [UIFont boldSystemFontOfSize:15];
      _label.textColor = [UIColor blackColor];
      _label.textAlignment = UITextAlignmentLeft;
    }
  }  
}

@end

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation TTTextTableFieldCell

+ (CGFloat)rowHeightForItem:(id)item tableView:(UITableView*)tableView {
  CGRect appFrame = [UIScreen mainScreen].applicationFrame;
  CGFloat maxWidth = appFrame.size.width - (kHPadding*2 + kMargin*2);
  TTTextTableField* field = item;

  UIFont* font = nil;
  if ([item isKindOfClass:[TTGrayTextTableField class]]) {
    font = [UIFont systemFontOfSize:14];
  } else {
    font = [UIFont boldSystemFontOfSize:15];
  }

  CGSize size = [field.text sizeWithFont:font
    constrainedToSize:CGSizeMake(maxWidth, CGFLOAT_MAX) lineBreakMode:UILineBreakModeWordWrap];
  if (size.height > kMaxLabelHeight) {
    size.height = kMaxLabelHeight;
  }

  return size.height + kVPadding*2;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// UIView

- (void)layoutSubviews {
  [super layoutSubviews];
  
  _label.frame = CGRectInset(self.contentView.bounds, kHPadding, 0);
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// TTTableViewCell

- (void)setObject:(id)anObject {
  if (object != anObject) {
    [super setObject:anObject];
  
    TTTextTableField* field = object;
    _label.text = field.text;

    _label.lineBreakMode = UILineBreakModeWordWrap;
    _label.numberOfLines = 0;

    if ([object isKindOfClass:[TTGrayTextTableField class]]) {
      _label.font = [UIFont systemFontOfSize:14];
      _label.textColor = [UIColor grayColor];
      _label.textAlignment = UITextAlignmentCenter;
    } else {
      _label.font = [UIFont boldSystemFontOfSize:15];
      _label.textColor = [UIColor blackColor];
      _label.textAlignment = UITextAlignmentLeft;
    }

    self.accessoryType = UITableViewCellAccessoryNone;
    self.selectionStyle = UITableViewCellSelectionStyleNone;
  }
}

@end

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation TTTitledTableFieldCell

+ (CGFloat)rowHeightForItem:(id)item tableView:(UITableView*)tableView {
  CGRect appFrame = [UIScreen mainScreen].applicationFrame;
  CGFloat maxWidth = appFrame.size.width - (kKeyWidth + kKeySpacing + kHPadding*2 + kMargin*2);
  TTTitledTableField* field = item;

  CGSize size = [field.text sizeWithFont:[UIFont boldSystemFontOfSize:15]
    constrainedToSize:CGSizeMake(maxWidth, CGFLOAT_MAX)
    lineBreakMode:UILineBreakModeWordWrap];
  
  return size.height + kVPadding*2;

}

///////////////////////////////////////////////////////////////////////////////////////////////////

- (id)initWithFrame:(CGRect)frame style:(int)style reuseIdentifier:(NSString*)identifier {
  if (self = [super initWithFrame:frame style:style reuseIdentifier:identifier]) {
    _titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _titleLabel.font = [UIFont boldSystemFontOfSize:13];
    _titleLabel.textColor = [TTAppearance appearance].linkTextColor;
    _titleLabel.highlightedTextColor = [UIColor whiteColor];
    _titleLabel.textAlignment = UITextAlignmentRight;
    _titleLabel.contentMode = UIViewContentModeTop;
    [self.contentView addSubview:_titleLabel];
	}
	return self;
}

- (void)dealloc {
  [_titleLabel release];
	[super dealloc];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// UIView

- (void)layoutSubviews {
  [super layoutSubviews];

  CGFloat valueWidth = self.contentView.width - (kHPadding*2 + kKeyWidth + kKeySpacing);
  CGFloat innerHeight = self.contentView.height - kVPadding*2;
  _titleLabel.frame = CGRectMake(kHPadding, kVPadding-1, kKeyWidth, kKeyHeight);
  _label.frame = CGRectMake(kHPadding + kKeyWidth + kKeySpacing, kVPadding,
    valueWidth, innerHeight);
}

-(void)didMoveToSuperview {
  [super didMoveToSuperview];
  if (self.superview && [(UITableView*)self.superview style] == UITableViewStylePlain) {
    _titleLabel.backgroundColor = self.superview.backgroundColor;
  }
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// TTTableViewCell

- (void)setObject:(id)anObject {
  if (object != anObject) {
    [super setObject:anObject];
  
    TTTitledTableField* field = object;
    _titleLabel.text = field.title;
    _label.text = field.text;
  
    _label.font = [UIFont boldSystemFontOfSize:15];
    _label.textColor = [UIColor blackColor];
    _label.adjustsFontSizeToFitWidth = YES;
    _label.lineBreakMode = UILineBreakModeWordWrap;
    _label.numberOfLines = 0;

    if (field.href) {
      if ([[TTNavigationCenter defaultCenter] urlIsSupported:field.href]) {
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

@implementation TTSubtextTableFieldCell

+ (CGFloat)rowHeightForItem:(id)item tableView:(UITableView*)tableView {
  CGRect appFrame = [UIScreen mainScreen].applicationFrame;
  CGFloat maxWidth = appFrame.size.width - kHPadding*2;
  TTSubtextTableField* field = item;

  CGSize textSize = [field.text sizeWithFont:[UIFont boldSystemFontOfSize:15]
    constrainedToSize:CGSizeMake(maxWidth, CGFLOAT_MAX)
    lineBreakMode:UILineBreakModeWordWrap];
  CGSize subtextSize = [field.subtext sizeWithFont:[UIFont systemFontOfSize:14]
    constrainedToSize:CGSizeMake(maxWidth, CGFLOAT_MAX) lineBreakMode:UILineBreakModeWordWrap];
  
  return kVPadding*2 + textSize.height + subtextSize.height;
}

///////////////////////////////////////////////////////////////////////////////////////////////////

- (id)initWithFrame:(CGRect)frame style:(int)style reuseIdentifier:(NSString*)identifier {
  if (self = [super initWithFrame:frame style:style reuseIdentifier:identifier]) {
    _subtextLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _subtextLabel.font = [UIFont systemFontOfSize:14];
    _subtextLabel.textColor = [UIColor grayColor];
    _subtextLabel.highlightedTextColor = [UIColor whiteColor];
    _subtextLabel.textAlignment = UITextAlignmentLeft;
    _subtextLabel.contentMode = UIViewContentModeTop;
    _subtextLabel.lineBreakMode = UILineBreakModeWordWrap;
    _subtextLabel.numberOfLines = 0;
    [self.contentView addSubview:_subtextLabel];
	}
	return self;
}

- (void)dealloc {
  [_subtextLabel release];
	[super dealloc];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// UIView

- (void)layoutSubviews {
  [super layoutSubviews];

  [_label sizeToFit];
  _label.x = kHPadding;
  _label.y = kVPadding;

  CGFloat maxWidth = self.contentView.width - kHPadding*2;
  CGSize subtextSize = [_subtextLabel.text sizeWithFont:_subtextLabel.font
    constrainedToSize:CGSizeMake(maxWidth, CGFLOAT_MAX) lineBreakMode:_subtextLabel.lineBreakMode];
  _subtextLabel.frame = CGRectMake(kHPadding, _label.bottom, subtextSize.width, subtextSize.height);
}

-(void)didMoveToSuperview {
  [super didMoveToSuperview];
  if (self.superview && [(UITableView*)self.superview style] == UITableViewStylePlain) {
    _subtextLabel.backgroundColor = self.superview.backgroundColor;
  }
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// TTTableViewCell

- (void)setObject:(id)anObject {
  if (object != anObject) {
    [super setObject:anObject];
  
    TTSubtextTableField* field = object;
    _label.text = field.text;
    _label.font = [UIFont boldSystemFontOfSize:15];
    _label.textColor = [UIColor blackColor];
    _label.adjustsFontSizeToFitWidth = YES;

    _subtextLabel.text = field.subtext;

    if (field.href) {
      if ([[TTNavigationCenter defaultCenter] urlIsSupported:field.href]) {
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

@implementation TTMoreButtonTableFieldCell

@synthesize animating = _animating;

+ (CGFloat)rowHeightForItem:(id)item tableView:(UITableView*)tableView {
  TTMoreButtonTableField* field = item;
  
  CGRect appFrame = [UIScreen mainScreen].applicationFrame;
  CGFloat maxWidth = appFrame.size.width - kHPadding*2;

  CGSize textSize = [field.text sizeWithFont:[UIFont boldSystemFontOfSize:17]
    constrainedToSize:CGSizeMake(maxWidth, CGFLOAT_MAX) lineBreakMode:UILineBreakModeWordWrap];
  CGSize subtitleSize = field.subtitle
    ? [field.subtitle sizeWithFont:[UIFont systemFontOfSize:14]
      constrainedToSize:CGSizeMake(maxWidth, CGFLOAT_MAX) lineBreakMode:UILineBreakModeWordWrap]
    : CGSizeMake(0, 0);
  
  return kVPadding*2 + textSize.height + subtitleSize.height;
}

- (id)initWithFrame:(CGRect)frame style:(int)style reuseIdentifier:(NSString*)identifier {
  if (self = [super initWithFrame:frame style:style reuseIdentifier:identifier]) {
    _spinnerView = nil;
    
    _subtitleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _subtitleLabel.font = [UIFont systemFontOfSize:14];
    _subtitleLabel.textColor = [UIColor grayColor];
    _subtitleLabel.highlightedTextColor = [UIColor whiteColor];
    _subtitleLabel.lineBreakMode = UILineBreakModeTailTruncation;
    [self.contentView addSubview:_subtitleLabel];

    self.accessoryType = UITableViewCellAccessoryNone;
  }
  return self;
}

- (void)dealloc {
  [_spinnerView release];
  [_subtitleLabel release];
  [super dealloc];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// UIView

- (void)layoutSubviews {
  [super layoutSubviews];
  
  [_label sizeToFit];
  [_subtitleLabel sizeToFit];
  
  CGFloat titleHeight = _label.height + _subtitleLabel.height;
  CGFloat titleWidth = _label.width > _subtitleLabel.width
    ? _label.width
    : _subtitleLabel.width;
  
  _spinnerView.y = floor(self.contentView.height/2 - _spinnerView.height/2);
  _label.y = floor(self.contentView.height/2 - titleHeight/2);
  _subtitleLabel.y = _label.bottom;
  
  _label.x = _label.y*2;
  _subtitleLabel.x = _label.y*2;
  _spinnerView.x = _label.x + titleWidth + kSpacing;
}

-(void)didMoveToSuperview {
  [super didMoveToSuperview];
  if (self.superview && [(UITableView*)self.superview style] == UITableViewStylePlain) {
    _subtitleLabel.backgroundColor = self.superview.backgroundColor;
  }
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// TTTableViewCell

- (void)setObject:(id)anObject {
  if (object != anObject) {
    [super setObject:anObject];

    TTMoreButtonTableField* field = object;

    _label.text = field.text;
    _label.font = [UIFont boldSystemFontOfSize:17];
    _label.textColor = RGBCOLOR(36, 112, 216);

    if (field.subtitle) {
      _subtitleLabel.text = field.subtitle;
      _subtitleLabel.hidden = NO;
    } else {
      _subtitleLabel.hidden = YES;
    }

    self.selectionStyle = UITableViewCellSelectionStyleBlue;
    self.animating = field.loading;
  }  
}

- (void)setAnimating:(BOOL)isAnimating {
  _animating = isAnimating;
  
  if (_animating) {
    if (!_spinnerView) {
      _spinnerView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:
        UIActivityIndicatorViewStyleGray];
      [self.contentView addSubview:_spinnerView];
    }

    [_spinnerView startAnimating];
  } else {
    [_spinnerView stopAnimating];
  }
  [self setNeedsLayout];
}

@end

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation TTImageTableFieldCell

+ (CGFloat)rowHeightForItem:(id)item tableView:(UITableView*)tableView {
  TTImageTableField* field = item;

  UIImage* image = field.image ? [[TTURLCache sharedCache] getMediaForURL:field.image] : nil;
  
  CGFloat iconWidth = image
    ? image.size.width + kKeySpacing
    : (field.image ? kDefaultIconSize + kKeySpacing : 0);
  CGFloat iconHeight = image
    ? image.size.height
    : (field.image ? kDefaultIconSize : 0);
    
  CGRect appFrame = [UIScreen mainScreen].applicationFrame;
  CGFloat maxWidth = appFrame.size.width - (iconWidth + kHPadding*2 + kMargin*2);

  CGSize textSize = [field.text sizeWithFont:[UIFont boldSystemFontOfSize:15]
    constrainedToSize:CGSizeMake(maxWidth, CGFLOAT_MAX)
    lineBreakMode:UILineBreakModeWordWrap];

  CGFloat contentHeight = textSize.height > iconHeight ? textSize.height : iconHeight;
  return contentHeight + kVPadding*2;
}

- (id)initWithFrame:(CGRect)frame style:(int)style reuseIdentifier:(NSString*)identifier {
  if (self = [super initWithFrame:frame style:style reuseIdentifier:identifier]) {
    _iconView = [[TTImageView alloc] initWithFrame:CGRectZero];
    [self.contentView addSubview:_iconView];
	}
	return self;
}

- (void)dealloc {
  [_iconView release];
	[super dealloc];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// UIView

- (void)layoutSubviews {
  [super layoutSubviews];

  TTImageTableField* field = object;
  UIImage* image = field.image ? [[TTURLCache sharedCache] getMediaForURL:field.image] : nil;
  
  CGFloat iconWidth = image
    ? image.size.width
    : (field.image ? kDefaultIconSize : 0);
  CGFloat iconHeight = image
    ? image.size.height
    : (field.image ? kDefaultIconSize : 0);
  
  if (_iconView.url) {
    CGFloat innerWidth = self.contentView.width - (kHPadding*2 + iconWidth + kKeySpacing);
    CGFloat innerHeight = self.contentView.height - kVPadding*2;
    _label.frame = CGRectMake(kHPadding, kVPadding, innerWidth, innerHeight);

    _iconView.frame = CGRectMake(_label.right + kKeySpacing,
      floor(self.height/2 - iconHeight/2), iconWidth, iconHeight);
  } else {
    _label.frame = CGRectInset(self.contentView.bounds, kHPadding, kVPadding);
    _iconView.frame = CGRectZero;
  }
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// TTTableViewCell

- (void)setObject:(id)anObject {
  if (object != anObject) {
    [super setObject:anObject];
  
    TTImageTableField* field = object;
    _label.text = field.text;

    _label.font = [UIFont boldSystemFontOfSize:15];
    _label.textAlignment = UITextAlignmentCenter;
    _label.lineBreakMode = UILineBreakModeWordWrap;
    _label.numberOfLines = 0;

    _iconView.defaultImage = field.defaultImage;
    _iconView.url = field.image;

    self.accessoryType = UITableViewCellAccessoryNone;
  }  
}

@end

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation TTIconTableFieldCell

///////////////////////////////////////////////////////////////////////////////////////////////////
// UIView

- (void)layoutSubviews {
  [super layoutSubviews];

  TTImageTableField* field = object;
  UIImage* image = field.image ? [[TTURLCache sharedCache] getMediaForURL:field.image] : nil;
  
  if (_iconView.url) {
    CGFloat iconWidth = image
      ? image.size.width
      : (field.image ? kDefaultIconSize : 0);
    CGFloat iconHeight = image
      ? image.size.height
      : (field.image ? kDefaultIconSize : 0);

    _iconView.frame = CGRectMake(kHPadding, floor(self.height/2 - iconHeight/2),
      iconWidth, iconHeight);

    CGFloat innerWidth = self.contentView.width - (kHPadding*2 + iconWidth + kKeySpacing);
    CGFloat innerHeight = self.contentView.height - kVPadding*2;
    _label.frame = CGRectMake(kHPadding + iconWidth + kKeySpacing, kVPadding,
      innerWidth, innerHeight);
  } else {
    _label.frame = CGRectInset(self.contentView.bounds, kHPadding, kVPadding);
    _iconView.frame = CGRectZero;
  }
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// TTTableViewCell

- (void)setObject:(id)anObject {
  if (object != anObject) {
    [super setObject:anObject];
  
    _label.textAlignment = UITextAlignmentLeft;
  }  
}
@end

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation TTActivityTableFieldCell

@synthesize animating = _animating;

+ (CGFloat)rowHeightForItem:(id)item tableView:(UITableView*)tableView {
  TTActivityTableField* field = item;
  if (field.sizeToFit) {
    return tableView.height - tableView.tableHeaderView.height;
  } else {
    return [super rowHeightForItem:item tableView:tableView];
  }
}

- (id)initWithFrame:(CGRect)frame style:(int)style reuseIdentifier:(NSString*)identifier {
  if (self = [super initWithFrame:frame style:style reuseIdentifier:identifier]) {
    _spinnerView = nil;
  }
  return self;
}

- (void)dealloc {
  [_spinnerView release];
  [super dealloc];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// UIView

- (void)layoutSubviews {
  [super layoutSubviews];
  
  [_label sizeToFit];

  CGFloat totalWidth = _label.width + kSpacing + _spinnerView.width;
  _spinnerView.x = floor(self.contentView.width/2 - totalWidth/2);
  _spinnerView.y = floor(self.contentView.height/2 - _spinnerView.height/2);

  _label.x = _spinnerView.right + kSpacing;
  _label.y = floor(self.contentView.height/2 - _label.height/2);
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// TTTableViewCell

- (void)setObject:(id)anObject {
  if (object != anObject) {
    [super setObject:anObject];

    TTActivityTableField* field = object;

    _label.text = field.text;
    _label.font = [UIFont systemFontOfSize:17];
    _label.textColor = [UIColor grayColor];
    _label.highlightedTextColor = [UIColor whiteColor];
    _label.lineBreakMode = UILineBreakModeTailTruncation;
    
    self.accessoryType = UITableViewCellAccessoryNone;
    self.selectionStyle = UITableViewCellSelectionStyleNone;

    self.animating = YES;
  }  
}

- (void)setAnimating:(BOOL)isAnimating {
  _animating = isAnimating;
  
  if (_animating) {
    if (!_spinnerView) {
      _spinnerView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:
        UIActivityIndicatorViewStyleGray];
      [self.contentView addSubview:_spinnerView];
    }

    [_spinnerView startAnimating];
  } else {
    [_spinnerView stopAnimating];
  }
  [self setNeedsLayout];
}

@end

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation TTErrorTableFieldCell

+ (CGFloat)rowHeightForItem:(id)item tableView:(UITableView*)tableView {
  TTStatusTableField* field = item;
  if (field.sizeToFit) {
    return tableView.height - tableView.tableHeaderView.height;
  } else {
  }

  return [super rowHeightForItem:item tableView:tableView];
}

- (id)initWithFrame:(CGRect)frame style:(int)style reuseIdentifier:(NSString*)identifier {
  if (self = [super initWithFrame:frame style:style reuseIdentifier:identifier]) {
    _errorView = [[TTErrorView alloc] initWithFrame:CGRectZero];
    [self addSubview:_errorView];

    self.accessoryType = UITableViewCellAccessoryNone;
    self.selectionStyle = UITableViewCellSelectionStyleNone;
  }
  return self;
}

- (void)dealloc {
  [_errorView release];
  [super dealloc];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// UIView

- (void)layoutSubviews {
  [super layoutSubviews];
  
  _errorView.frame = self.bounds;
  [_errorView setNeedsLayout];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// TTTableViewCell

- (void)setObject:(id)anObject {
  if (object != anObject) {
    [super setObject:anObject];
    
    TTErrorTableField* emptyItem = object;
    _errorView.image = emptyItem.image;
    _errorView.title = emptyItem.text;
    _errorView.subtitle = emptyItem.subtitle;
  }  
}

@end

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation TTTextFieldTableFieldCell

@synthesize textField = _textField;

- (id)initWithFrame:(CGRect)frame style:(int)style reuseIdentifier:(NSString*)identifier {
  if (self = [super initWithFrame:frame style:style reuseIdentifier:identifier]) {
    _titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _titleLabel.font = [UIFont boldSystemFontOfSize:17];

    _textField = [[UITextField alloc] initWithFrame:CGRectZero];
    _textField.font = [UIFont systemFontOfSize:15];
    _textField.leftView = _titleLabel;
    _textField.leftViewMode = UITextFieldViewModeAlways;
    _textField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    [_textField addTarget:self action:@selector(valueChanged)
      forControlEvents:UIControlEventEditingChanged];
    [self.contentView addSubview:_textField];

    self.accessoryType = UITableViewCellAccessoryNone;
    self.selectionStyle = UITableViewCellSelectionStyleNone;
  }
  return self;
}

- (void)dealloc {
  [_titleLabel release];
  [_textField release];
  [super dealloc];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// UIView

- (void)layoutSubviews {
  [super layoutSubviews];
  
  [_titleLabel sizeToFit];
  _titleLabel.width = kTextFieldTitleWidth;

  _textField.frame = CGRectOffset(CGRectInset(self.contentView.bounds, 3, 0), 0, 1);
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// TTTableViewCell

- (void)setObject:(id)anObject {
  if (object != anObject) {
    [super setObject:anObject];

    TTTextFieldTableField* field = object;
    _titleLabel.text = [NSString stringWithFormat:@"  %@", field.title];

    _textField.text = field.text;
    _textField.placeholder = field.placeholder;
    _textField.returnKeyType = field.returnKeyType;
    _textField.keyboardType = field.keyboardType;
    _textField.autocapitalizationType = field.autocapitalizationType;
    _textField.autocorrectionType = field.autocorrectionType;
    _textField.clearButtonMode = field.clearButtonMode;
    _textField.secureTextEntry = field.secureTextEntry;
    _textField.delegate = self;
  }  
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// UIControlEvents

- (void)valueChanged {
  TTTextFieldTableField* field = object;
  field.text = _textField.text;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// UITextFieldDelegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
  TTTextFieldTableField* field = object;
  if ([field.delegate respondsToSelector:@selector(textFieldShouldBeginEditing:)]) {
    return [field.delegate textFieldShouldBeginEditing:textField];
  } else {
    return YES;
  }
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
  UITableView* tableView = (UITableView*)[self firstParentOfClass:[UITableView class]];
  NSIndexPath* indexPath = [tableView indexPathForCell:self];
  [tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionMiddle
    animated:YES];

  TTTextFieldTableField* field = object;
  if ([field.delegate respondsToSelector:@selector(textFieldDidBeginEditing:)]) {
    [field.delegate textFieldDidBeginEditing:textField];
  }
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
  TTTextFieldTableField* field = object;
  if ([field.delegate respondsToSelector:@selector(textFieldShouldEndEditing:)]) {
    return [field.delegate textFieldShouldEndEditing:textField];
  } else {
    return YES;
  }
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range
    replacementString:(NSString *)string {
  TTTextFieldTableField* field = object;
  SEL sel = @selector(textField:shouldChangeCharactersInRange:replacementString:);
  if ([field.delegate respondsToSelector:sel]) {
    return [field.delegate textField:textField shouldChangeCharactersInRange:range
      replacementString:string];
  } else {
    return YES;
  }
}

- (BOOL)textFieldShouldClear:(UITextField *)textField {
  TTTextFieldTableField* field = object;
  if ([field.delegate respondsToSelector:@selector(textFieldShouldClear:)]) {
    return [field.delegate textFieldShouldClear:textField];
  } else {
    return YES;
  }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
  TTTextFieldTableField* field = object;
  if ([field.delegate respondsToSelector:@selector(textFieldShouldReturn:)]) {
    return [field.delegate textFieldShouldReturn:textField];
  } else {
    return YES;
  }
}

@end

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation TTTextViewTableFieldCell

@synthesize textView = _textView;

+ (CGFloat)rowHeightForItem:(id)item tableView:(UITableView*)tableView {
  return kTableViewFieldCellHeight;
}

///////////////////////////////////////////////////////////////////////////////////////////////////

- (id)initWithFrame:(CGRect)frame style:(int)style reuseIdentifier:(NSString*)identifier {
  if (self = [super initWithFrame:frame style:style reuseIdentifier:identifier]) {
    _textView = [[UITextView alloc] initWithFrame:CGRectZero];
    _textView.delegate = self;
    _textView.font = [UIFont systemFontOfSize:15];
    _textView.scrollsToTop = NO;
    [self.contentView addSubview:_textView];

    self.accessoryType = UITableViewCellAccessoryNone;
    self.selectionStyle = UITableViewCellSelectionStyleNone;
  }
  return self;
}

- (void)dealloc {
  [_textView release];
  [super dealloc];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// UIView

- (void)layoutSubviews {
  [super layoutSubviews];
  
  _textView.frame = CGRectInset(self.contentView.bounds, 5, 5);
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// TTTableViewCell

- (void)setObject:(id)anObject {
  if (object != anObject) {
    [super setObject:anObject];

    TTTextFieldTableField* field = object;
    _textView.text = field.text;
  }  
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// UITextViewDelegate

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
  TTTextViewTableField* field = object;
  if ([field.delegate respondsToSelector:@selector(textViewShouldBeginEditing:)]) {
    return [field.delegate textViewShouldBeginEditing:textView];
  } else {
    return YES;
  }
}

- (BOOL)textViewShouldEndEditing:(UITextView *)textView {
  TTTextViewTableField* field = object;
  if ([field.delegate respondsToSelector:@selector(textViewShouldEndEditing:)]) {
    return [field.delegate textViewShouldEndEditing:textView];
  } else {
    return YES;
  }
}

- (void)textViewDidBeginEditing:(UITextView *)textView {
  UITableView* tableView = (UITableView*)[self firstParentOfClass:[UITableView class]];
  NSIndexPath* indexPath = [tableView indexPathForCell:self];
  [tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionMiddle
    animated:YES];
  
  TTTextViewTableField* field = object;
  if ([field.delegate respondsToSelector:@selector(textViewDidBeginEditing:)]) {
    [field.delegate textViewDidBeginEditing:textView];
  }
}

- (void)textViewDidEndEditing:(UITextView *)textView {
  TTTextViewTableField* field = object;
  if ([field.delegate respondsToSelector:@selector(textViewDidEndEditing:)]) {
    [field.delegate textViewDidEndEditing:textView];
  }
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range
    replacementText:(NSString *)text {
  TTTextViewTableField* field = object;
  SEL sel = @selector(textView:shouldChangeTextInRange:replacementText:);
  if ([field.delegate respondsToSelector:sel]) {
    return [field.delegate textView:textView shouldChangeTextInRange:range replacementText:text];
  } else {
    return YES;
  }
}

- (void)textViewDidChange:(UITextView *)textView {
  TTTextViewTableField* field = object;
  field.text = textView.text;
  
  if ([field.delegate respondsToSelector:@selector(textViewDidChange:)]) {
    [field.delegate textViewDidChange:textView];
  }
}

- (void)textViewDidChangeSelection:(UITextView *)textView {
  TTTextViewTableField* field = object;
  if ([field.delegate respondsToSelector:@selector(textViewDidChangeSelection:)]) {
    [field.delegate textViewDidChangeSelection:textView];
  }
}

@end

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation TTSwitchTableFieldCell

- (id)initWithFrame:(CGRect)frame style:(int)style reuseIdentifier:(NSString*)identifier {
  if (self = [super initWithFrame:frame style:style reuseIdentifier:identifier]) {
    _switch = [[UISwitch alloc] initWithFrame:CGRectZero];
    [_switch addTarget:self action:@selector(valueChanged)
      forControlEvents:UIControlEventValueChanged];
    [self.contentView addSubview:_switch];
    
    self.accessoryType = UITableViewCellAccessoryNone;
    self.selectionStyle = UITableViewCellSelectionStyleNone;
  }
  return self;
}

- (void)dealloc {
  [_switch release];
  [super dealloc];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// UIView

- (void)layoutSubviews {
  [super layoutSubviews];
  
  [_switch sizeToFit];
  _switch.x = self.contentView.width - (kHPadding + _switch.width);
  _switch.y = kVPadding;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// TTTableViewCell

- (void)setObject:(id)anObject {
  if (object != anObject) {
    [super setObject:anObject];

    TTSwitchTableField* field = object;
    _switch.on = field.on;
  }  
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// UIControlEvents

- (void)valueChanged {
  TTSwitchTableField* field = object;
  field.on = _switch.on;
}

@end

