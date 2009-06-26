#import "Three20/TTTableItemCell.h"
#import "Three20/TTTableItem.h"
#import "Three20/TTImageView.h"
#import "Three20/TTErrorView.h"
#import "Three20/TTStyledNode.h"
#import "Three20/TTStyledText.h"
#import "Three20/TTStyledTextLabel.h"
#import "Three20/TTActivityLabel.h"
#import "Three20/TTNavigationCenter.h"
#import "Three20/TTURLCache.h"
#import "Three20/TTDefaultStyleSheet.h"
#import "Three20/TTSearchBar.h"

///////////////////////////////////////////////////////////////////////////////////////////////////

static CGFloat kHPadding = 10;
static CGFloat kVPadding = 10;
static CGFloat kMargin = 10;
static CGFloat kSpacing = 8;
static CGFloat kGroupMargin = 10;

static CGFloat kKeySpacing = 12;
static CGFloat kKeyWidth = 75;
static CGFloat kMaxLabelHeight = 2000;
static CGFloat kDisclosureIndicatorWidth = 23;

static CGFloat kTextFieldTitleWidth = 100;
static CGFloat kTableViewFieldCellHeight = 180;

static CGFloat kDefaultIconSize = 50;

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation TTTableItemCell

+ (CGFloat)tableView:(UITableView*)tableView rowHeightForItem:(id)item {
  return TOOLBAR_HEIGHT;
}

///////////////////////////////////////////////////////////////////////////////////////////////////

- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString*)identifier {
  if (self = [super initWithFrame:frame reuseIdentifier:identifier]) {
    _field = nil;
	}
	return self;
}

- (void)dealloc {
  [_field release];
	[super dealloc];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// TTTableViewCell

- (id)object {
  return _field;
}

- (void)setObject:(id)object {
  if (_field != object) {
    [_field release];
    _field = [object retain];
  
    if (_field.URL) {
      if ([[TTNavigationCenter defaultCenter] URLIsSupported:_field.URL]) {
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

@implementation TTStyledTextTableItemCell

///////////////////////////////////////////////////////////////////////////////////////////////////
// class public

+ (CGFloat)tableView:(UITableView*)tableView rowHeightForItem:(id)item {
  TTStyledTextTableItem* field = item;
  field.styledText.font = TTSTYLEVAR(font);
  
  CGFloat padding = tableView.style == UITableViewStyleGrouped ? kGroupMargin*2 : 0;
  padding += field.padding.left + field.padding.right;
  if (field.URL) {
    padding += kDisclosureIndicatorWidth;
  }
  
  field.styledText.width = tableView.width - padding;
  
  return field.styledText.height + field.padding.top + field.padding.bottom;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// NSObject

- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString*)identifier {
  if (self = [super initWithFrame:frame reuseIdentifier:identifier]) {
    _label = [[TTStyledTextLabel alloc] initWithFrame:CGRectZero];
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
  
  TTStyledTextTableItem* field = self.object;
  _label.frame = CGRectOffset(self.contentView.bounds, field.margin.left, field.margin.top);
}

-(void)didMoveToSuperview {
  [super didMoveToSuperview];
  if (self.superview && [(UITableView*)self.superview style] == UITableViewStylePlain) {
    _label.backgroundColor = self.superview.backgroundColor;
  }
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// TTTableViewCell

- (void)setObject:(id)object {
  if (_field != object) {
    [super setObject:object];
    
    TTStyledTextTableItem* field = object;
    _label.text = field.styledText;
    _label.contentInset = field.padding;
  }  
}

@end

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation TTTextTableItemCell

///////////////////////////////////////////////////////////////////////////////////////////////////
// class public

+ (CGFloat)tableView:(UITableView*)tableView rowHeightForItem:(id)item {
  TTTextTableItem* field = item;

  CGFloat maxWidth = tableView.width - (kHPadding*2 + kMargin*2);
  UIFont* font = TTSTYLEVAR(tableFont);
  CGSize size = [field.text sizeWithFont:font
    constrainedToSize:CGSizeMake(maxWidth, CGFLOAT_MAX) lineBreakMode:UILineBreakModeWordWrap];
  if (size.height > kMaxLabelHeight) {
    size.height = kMaxLabelHeight;
  }

  return size.height + kVPadding*2;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// NSObject

- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString*)identifier {
  if (self = [super initWithFrame:frame reuseIdentifier:identifier]) {
    self.textLabel.highlightedTextColor = TTSTYLEVAR(highlightedTextColor);
	}
	return self;
}

- (void)dealloc {
	[super dealloc];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// UIView

- (void)layoutSubviews {
  [super layoutSubviews];
  
//  self.textLabel.frame = CGRectInset(self.contentView.bounds, kHPadding, kVPadding);
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// TTTableViewCell

- (void)setObject:(id)object {
  if (_field != object) {
    [super setObject:object];
  
    self.textLabel.text = _field.text;
    self.textLabel.lineBreakMode = UILineBreakModeWordWrap;
    self.textLabel.numberOfLines = 0;

    if ([object isKindOfClass:[TTButtonTableItem class]]) {
      self.textLabel.font = TTSTYLEVAR(tableButtonFont);
      self.textLabel.textColor = TTSTYLEVAR(linkTextColor);
      self.textLabel.textAlignment = UITextAlignmentCenter;
      self.accessoryType = UITableViewCellAccessoryNone;
      self.selectionStyle = UITableViewCellSelectionStyleBlue;
    } else if ([object isKindOfClass:[TTLinkTableItem class]]) {
      self.textLabel.font = TTSTYLEVAR(tableFont);
      self.textLabel.textColor = TTSTYLEVAR(linkTextColor);
      self.textLabel.textAlignment = UITextAlignmentLeft;
    } else if ([object isKindOfClass:[TTSummaryTableItem class]]) {
      self.textLabel.font = TTSTYLEVAR(tableSummaryFont);
      self.textLabel.textColor = TTSTYLEVAR(tableSubTextColor);
      self.textLabel.textAlignment = UITextAlignmentCenter;
    } else if ([object isKindOfClass:[TTGrayTextTableItem class]]) {
      self.textLabel.font = TTSTYLEVAR(font);
      self.textLabel.textColor = TTSTYLEVAR(tableSubTextColor);
      self.textLabel.textAlignment = UITextAlignmentCenter;
    } else {
      self.textLabel.font = TTSTYLEVAR(tableFont);
      self.textLabel.textColor = TTSTYLEVAR(textColor);
      self.textLabel.textAlignment = UITextAlignmentLeft;
    }
  }
}

@end

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation TTTitledTableItemCell

+ (CGFloat)tableView:(UITableView*)tableView rowHeightForItem:(id)item {
  CGFloat maxWidth = tableView.width - (kKeyWidth + kKeySpacing + kHPadding*2 + kMargin*2);
  TTTitledTableItem* field = item;

  CGSize size = [field.text sizeWithFont:TTSTYLEVAR(tableSmallFont)
    constrainedToSize:CGSizeMake(maxWidth, CGFLOAT_MAX)
    lineBreakMode:UILineBreakModeWordWrap];
  
  return size.height + kVPadding*2;
}

///////////////////////////////////////////////////////////////////////////////////////////////////

- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString*)identifier {
  if (self = [super initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:identifier]) {
	}
	return self;
}

- (void)dealloc {
	[super dealloc];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// UIView

- (void)layoutSubviews {
  [super layoutSubviews];

  CGSize titleSize = [@"M" sizeWithFont:TTSTYLEVAR(tableTitleFont)];
  self.textLabel.frame = CGRectMake(kHPadding, kVPadding, kKeyWidth, titleSize.height);

  CGFloat valueWidth = self.contentView.width - (kHPadding*2 + kKeyWidth + kKeySpacing);
  CGFloat innerHeight = self.contentView.height - kVPadding*2;
  self.detailTextLabel.frame = CGRectMake(kHPadding + kKeyWidth + kKeySpacing, kVPadding,
    valueWidth, innerHeight);
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// TTTableViewCell

- (void)setObject:(id)object {
  if (_field != object) {
    [super setObject:object];
  
    TTTitledTableItem* field = object;
    self.textLabel.text = field.title;
    self.detailTextLabel.text = field.text;

    self.textLabel.font = TTSTYLEVAR(tableTitleFont);
    self.textLabel.textColor = TTSTYLEVAR(linkTextColor);
    self.textLabel.highlightedTextColor = TTSTYLEVAR(highlightedTextColor);
    self.textLabel.textAlignment = UITextAlignmentRight;
    self.textLabel.adjustsFontSizeToFitWidth = YES;

    self.detailTextLabel.font = TTSTYLEVAR(tableSmallFont);
    self.detailTextLabel.textColor = TTSTYLEVAR(textColor);
    self.detailTextLabel.adjustsFontSizeToFitWidth = YES;
    self.detailTextLabel.minimumFontSize = 8;
    self.detailTextLabel.lineBreakMode = UILineBreakModeWordWrap;
    self.detailTextLabel.numberOfLines = 0;
  }  
}

@end

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation TTSubtextTableItemCell

+ (CGFloat)tableView:(UITableView*)tableView rowHeightForItem:(id)item {
  CGFloat maxWidth = tableView.width - kHPadding*2;
  TTSubtextTableItem* field = item;

  CGSize textSize = [field.text sizeWithFont:TTSTYLEVAR(tableSmallFont)
    constrainedToSize:CGSizeMake(maxWidth, CGFLOAT_MAX)
    lineBreakMode:UILineBreakModeWordWrap];
  CGSize subtextSize = [field.subtext sizeWithFont:TTSTYLEVAR(font)
    constrainedToSize:CGSizeMake(maxWidth, CGFLOAT_MAX) lineBreakMode:UILineBreakModeWordWrap];
  
  return kVPadding*2 + textSize.height + subtextSize.height;
}

///////////////////////////////////////////////////////////////////////////////////////////////////

- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString*)identifier {
  if (self = [super initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier]) {
    self.detailTextLabel.font = TTSTYLEVAR(font);
    self.detailTextLabel.textColor = TTSTYLEVAR(tableSubTextColor);
    self.detailTextLabel.highlightedTextColor = TTSTYLEVAR(highlightedTextColor);
    self.detailTextLabel.textAlignment = UITextAlignmentLeft;
    self.detailTextLabel.contentMode = UIViewContentModeTop;
    self.detailTextLabel.lineBreakMode = UILineBreakModeWordWrap;
    self.detailTextLabel.numberOfLines = 0;
	}
	return self;
}

- (void)dealloc {
	[super dealloc];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// UIView

- (void)layoutSubviews {
  [super layoutSubviews];

  [self.textLabel sizeToFit];
  self.textLabel.left = kHPadding;
  self.textLabel.top = kVPadding;

  CGFloat maxWidth = self.contentView.width - kHPadding*2;
  CGSize subtextSize = [self.detailTextLabel.text sizeWithFont:self.detailTextLabel.font
    constrainedToSize:CGSizeMake(maxWidth, CGFLOAT_MAX) lineBreakMode:self.detailTextLabel.lineBreakMode];
  self.detailTextLabel.frame = CGRectMake(kHPadding, self.textLabel.bottom, subtextSize.width, subtextSize.height);
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// TTTableViewCell

- (void)setObject:(id)object {
  if (_field != object) {
    [super setObject:object];
  
    TTSubtextTableItem* field = object;
    self.textLabel.text = field.text;
    self.textLabel.font = TTSTYLEVAR(tableSmallFont);
    self.textLabel.textColor = TTSTYLEVAR(textColor);
    self.textLabel.adjustsFontSizeToFitWidth = YES;

    self.detailTextLabel.text = field.subtext;

    if (field.URL) {
      if ([[TTNavigationCenter defaultCenter] URLIsSupported:field.URL]) {
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

@implementation TTMoreButtonTableItemCell

@synthesize animating = _animating;

+ (CGFloat)tableView:(UITableView*)tableView rowHeightForItem:(id)item {
  TTMoreButtonTableItem* field = item;
  
  CGFloat maxWidth = tableView.width - kHPadding*2;

  CGSize textSize = [field.text sizeWithFont:TTSTYLEVAR(tableFont)
    constrainedToSize:CGSizeMake(maxWidth, CGFLOAT_MAX) lineBreakMode:UILineBreakModeWordWrap];
  CGSize subtitleSize = field.subtitle
    ? [field.subtitle sizeWithFont:TTSTYLEVAR(font)
      constrainedToSize:CGSizeMake(maxWidth, CGFLOAT_MAX) lineBreakMode:UILineBreakModeWordWrap]
    : CGSizeMake(0, 0);
  
  CGFloat height = kVPadding*2 + textSize.height + subtitleSize.height;
  CGFloat minHeight = TOOLBAR_HEIGHT*1.5;
  if (height < minHeight) {
    return minHeight;
  } else {
    return height;
  }
}

- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString*)identifier {
  if (self = [super initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier]) {
    _spinnerView = nil;
    
    self.detailTextLabel.font = TTSTYLEVAR(font);
    self.detailTextLabel.textColor = TTSTYLEVAR(tableSubTextColor);
    self.detailTextLabel.highlightedTextColor = TTSTYLEVAR(highlightedTextColor);
    self.detailTextLabel.lineBreakMode = UILineBreakModeTailTruncation;

    self.accessoryType = UITableViewCellAccessoryNone;
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
  
  [self.textLabel sizeToFit];
  [self.detailTextLabel sizeToFit];
  
  CGFloat titleHeight = self.textLabel.height + self.detailTextLabel.height;
  CGFloat titleWidth = self.textLabel.width > self.detailTextLabel.width
    ? self.textLabel.width
    : self.detailTextLabel.width;
  
  _spinnerView.top = floor(self.contentView.height/2 - _spinnerView.height/2);
  self.textLabel.top = floor(self.contentView.height/2 - titleHeight/2);
  self.detailTextLabel.top = self.textLabel.bottom;
  
  self.textLabel.left = self.textLabel.top*2;
  self.detailTextLabel.left = self.textLabel.top*2;
  _spinnerView.left = self.textLabel.left + titleWidth + kSpacing;
}

-(void)didMoveToSuperview {
  [super didMoveToSuperview];
  if (self.superview && [(UITableView*)self.superview style] == UITableViewStylePlain) {
    self.detailTextLabel.backgroundColor = self.superview.backgroundColor;
  }
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// TTTableViewCell

- (void)setObject:(id)object {
  if (_field != object) {
    [super setObject:object];

    TTMoreButtonTableItem* field = object;

    self.textLabel.text = field.text;
    self.textLabel.font = TTSTYLEVAR(tableFont);
    self.textLabel.textColor = TTSTYLEVAR(moreLinkTextColor);

    if (field.subtitle) {
      self.detailTextLabel.text = field.subtitle;
      self.detailTextLabel.hidden = NO;
    } else {
      self.detailTextLabel.hidden = YES;
    }

    self.selectionStyle = UITableViewCellSelectionStyleBlue;
    self.animating = field.isLoading;
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

@implementation TTIconTableItemCell

+ (CGFloat)tableView:(UITableView*)tableView rowHeightForItem:(id)item {
  TTImageTableItem* field = item;

  UIImage* image = field.image ? [[TTURLCache sharedCache] imageForURL:field.image] : nil;
  
  CGFloat iconWidth = image
    ? image.size.width + kKeySpacing
    : (field.image ? kDefaultIconSize + kKeySpacing : 0);
  CGFloat iconHeight = image
    ? image.size.height
    : (field.image ? kDefaultIconSize : 0);
    
  CGFloat maxWidth = tableView.width - (iconWidth + kHPadding*2 + kMargin*2);

  CGSize textSize = [field.text sizeWithFont:TTSTYLEVAR(tableSmallFont)
    constrainedToSize:CGSizeMake(maxWidth, CGFLOAT_MAX)
    lineBreakMode:UILineBreakModeWordWrap];

  CGFloat contentHeight = textSize.height > iconHeight ? textSize.height : iconHeight;
  return contentHeight + kVPadding*2;
}

- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString*)identifier {
  if (self = [super initWithFrame:frame reuseIdentifier:identifier]) {
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

  TTImageTableItem* field = self.object;
  UIImage* image = field.image
    ? [[TTURLCache sharedCache] imageForURL:field.image]
    : nil;
  if (!image) {
    image = field.defaultImage;
  }
  if (_iconView.URL) {
      CGFloat iconWidth = image
        ? image.size.width
        : (field.image ? kDefaultIconSize : 0);
      CGFloat iconHeight = image
        ? image.size.height
        : (field.image ? kDefaultIconSize : 0);

    TTImageStyle* style = [field.imageStyle firstStyleOfClass:[TTImageStyle class]];
    if (style) {
      _iconView.contentMode = style.contentMode;
      _iconView.clipsToBounds = YES;
      _iconView.backgroundColor = [UIColor clearColor];
      if (style.size.width) {
        iconWidth = style.size.width;
      }
      if (style.size.height) {
        iconWidth = style.size.height;
      }
    }

    _iconView.frame = CGRectMake(kHPadding, floor(self.height/2 - iconHeight/2),
                                 iconWidth, iconHeight);
    
    CGFloat innerWidth = self.contentView.width - (kHPadding*2 + _iconView.width + kKeySpacing);
    CGFloat innerHeight = self.contentView.height - kVPadding*2;
    self.textLabel.frame = CGRectMake(kHPadding + _iconView.width + kKeySpacing, kVPadding,
      innerWidth, innerHeight);
  } else {
    self.textLabel.frame = CGRectInset(self.contentView.bounds, kHPadding, kVPadding);
    _iconView.frame = CGRectZero;
  }
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// TTTableViewCell

- (void)setObject:(id)object {
  if (_field != object) {
    [super setObject:object];
  
    TTImageTableItem* field = object;
    _iconView.defaultImage = field.defaultImage;
    _iconView.URL = field.image;
    _iconView.style = field.imageStyle;
  }  
}
@end

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation TTImageTableItemCell

///////////////////////////////////////////////////////////////////////////////////////////////////
// UIView

- (void)layoutSubviews {
  [super layoutSubviews];

  TTImageTableItem* field = self.object;
  UIImage* image = field.image ? [[TTURLCache sharedCache] imageForURL:field.image] : nil;
  
  CGFloat iconWidth = image
    ? image.size.width
    : (field.image ? kDefaultIconSize : 0);
  CGFloat iconHeight = image
    ? image.size.height
    : (field.image ? kDefaultIconSize : 0);
  
  if (_iconView.URL) {
    CGFloat innerWidth = self.contentView.width - (kHPadding*2 + iconWidth + kKeySpacing);
    CGFloat innerHeight = self.contentView.height - kVPadding*2;
    self.textLabel.frame = CGRectMake(kHPadding, kVPadding, innerWidth, innerHeight);

    _iconView.frame = CGRectMake(self.textLabel.right + kKeySpacing,
      floor(self.height/2 - iconHeight/2), iconWidth, iconHeight);
  } else {
    self.textLabel.frame = CGRectInset(self.contentView.bounds, kHPadding, kVPadding);
    _iconView.frame = CGRectZero;
  }
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// TTTableViewCell

- (void)setObject:(id)object {
  if (_field != object) {
    [super setObject:object];
  
    self.textLabel.font = TTSTYLEVAR(tableSmallFont);
    self.textLabel.textAlignment = UITextAlignmentCenter;
    self.accessoryType = UITableViewCellAccessoryNone;
  }  
}

@end

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation TTActivityTableItemCell

+ (CGFloat)tableView:(UITableView*)tableView rowHeightForItem:(id)item {
  TTActivityTableItem* field = item;
  if (field.sizeToFit) {
    if (tableView.style == UITableViewStyleGrouped) {
      [tableView.tableHeaderView layoutIfNeeded];
      return (tableView.height - TABLE_GROUPED_PADDING*2) - tableView.tableHeaderView.height;
    } else {
      return tableView.height - tableView.tableHeaderView.height;
    }
  } else {
    return [super tableView:tableView rowHeightForItem:item];
  }
}

- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString*)identifier {
  if (self = [super initWithFrame:frame reuseIdentifier:identifier]) {
    _activityLabel = [[TTActivityLabel alloc] initWithFrame:CGRectZero
                                              style:TTActivityLabelStyleGray];
    _activityLabel.centeredToScreen = NO;
    [self.contentView addSubview:_activityLabel];
  }
  return self;
}

- (void)dealloc {
  [_activityLabel release];
  [super dealloc];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// UIView

- (void)layoutSubviews {
  [super layoutSubviews];
  
  UITableView* tableView = (UITableView*)self.superview;
  if (tableView.style == UITableViewStylePlain) {
    _activityLabel.frame = self.contentView.bounds;
  } else {
    _activityLabel.frame = CGRectInset(self.contentView.bounds, -1, -1);
    _activityLabel.backgroundColor = self.superview.backgroundColor;
  }
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// TTTableViewCell

- (void)setObject:(id)object {
  if (_field != object) {
    [super setObject:object];
  
    TTActivityTableItem* field = object;
    _activityLabel.text = field.text;
  }  
}

@end

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation TTErrorTableItemCell

+ (CGFloat)tableView:(UITableView*)tableView rowHeightForItem:(id)item {
  TTStatusTableItem* field = item;
  if (field.sizeToFit) {
    CGFloat headerHeight = 0;
    if ([tableView.delegate respondsToSelector:@selector(tableView:heightForHeaderInSection:)]) {
      headerHeight = [tableView.delegate tableView:tableView heightForHeaderInSection:0];
    }
    return tableView.height - (tableView.tableHeaderView.height + headerHeight);
  } else {
  }

  return [super tableView:tableView rowHeightForItem:item];
}

- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString*)identifier {
  if (self = [super initWithFrame:frame reuseIdentifier:identifier]) {
    _field = nil;
    
    _errorView = [[TTErrorView alloc] initWithFrame:CGRectZero];
    [self addSubview:_errorView];

    self.accessoryType = UITableViewCellAccessoryNone;
    self.selectionStyle = UITableViewCellSelectionStyleNone;
  }
  return self;
}

- (void)dealloc {
  [_field release];
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

- (id)object {
  return _field;
}

- (void)setObject:(id)object {
  if (_field != object) {
    [_field release];
    _field = [object retain];
    
    TTErrorTableItem* emptyItem = object;
    _errorView.image = emptyItem.image;
    _errorView.title = emptyItem.text;
    _errorView.subtitle = emptyItem.subtitle;
  }  
}

@end

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation TTTextFieldTableItemCell

@synthesize textField = _textField;

- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString*)identifier {
  if (self = [super initWithFrame:frame reuseIdentifier:identifier]) {
    _textField = [[UITextField alloc] initWithFrame:CGRectZero];
    [_textField addTarget:self action:@selector(valueChanged)
      forControlEvents:UIControlEventEditingChanged];
    [self.contentView addSubview:_textField];

    self.accessoryType = UITableViewCellAccessoryNone;
    self.selectionStyle = UITableViewCellSelectionStyleNone;
  }
  return self;
}

- (void)dealloc {
  [_textField release];
  [super dealloc];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// UIView

- (void)layoutSubviews {
  [super layoutSubviews];
  
  [self.textLabel sizeToFit];
  self.textLabel.width = kTextFieldTitleWidth;
  
  _textField.frame = CGRectOffset(CGRectInset(self.contentView.bounds, 3, 0), 0, 1);
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// TTTableViewCell

- (void)setObject:(id)object {
  if (_field != object) {
    [super setObject:object];

    TTTextFieldTableItem* field = object;
    self.textLabel.text = [NSString stringWithFormat:@"  %@", field.title];

    _textField.text = field.text;
    _textField.placeholder = field.placeholder;
    _textField.font = TTSTYLEVAR(font);
    _textField.returnKeyType = field.returnKeyType;
    _textField.keyboardType = field.keyboardType;
    _textField.autocapitalizationType = field.autocapitalizationType;
    _textField.autocorrectionType = field.autocorrectionType;
    _textField.clearButtonMode = field.clearButtonMode;
    _textField.secureTextEntry = field.secureTextEntry;
    _textField.leftView = self.textLabel;
    _textField.leftViewMode = UITextFieldViewModeAlways;
    _textField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    _textField.delegate = self;
  }  
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// UIControlEvents

- (void)valueChanged {
  TTTextFieldTableItem* field = self.object;
  field.text = _textField.text;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// UITextFieldDelegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
  TTTextFieldTableItem* field = self.object;
  if ([field.delegate respondsToSelector:@selector(textFieldShouldBeginEditing:)]) {
    return [field.delegate textFieldShouldBeginEditing:textField];
  } else {
    return YES;
  }
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
//  UITableView* tableView = (UITableView*)[self firstParentOfClass:[UITableView class]];
//  NSIndexPath* indexPath = [tableView indexPathForCell:self];
//  [tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionMiddle
//    animated:YES];

  TTTextFieldTableItem* field = self.object;
  if ([field.delegate respondsToSelector:@selector(textFieldDidBeginEditing:)]) {
    [field.delegate textFieldDidBeginEditing:textField];
  }
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
  TTTextFieldTableItem* field = self.object;
  if ([field.delegate respondsToSelector:@selector(textFieldShouldEndEditing:)]) {
    return [field.delegate textFieldShouldEndEditing:textField];
  } else {
    return YES;
  }
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
  TTTextFieldTableItem* field = self.object;
  if ([field.delegate respondsToSelector:@selector(textFieldDidEndEditing:)]) {
    [field.delegate textFieldDidEndEditing:textField];
  }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range
    replacementString:(NSString *)string {
  TTTextFieldTableItem* field = self.object;
  SEL sel = @selector(textField:shouldChangeCharactersInRange:replacementString:);
  if ([field.delegate respondsToSelector:sel]) {
    return [field.delegate textField:textField shouldChangeCharactersInRange:range
      replacementString:string];
  } else {
    return YES;
  }
}

- (BOOL)textFieldShouldClear:(UITextField *)textField {
  TTTextFieldTableItem* field = self.object;
  if ([field.delegate respondsToSelector:@selector(textFieldShouldClear:)]) {
    return [field.delegate textFieldShouldClear:textField];
  } else {
    return YES;
  }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
  TTTextFieldTableItem* field = self.object;
  if ([field.delegate respondsToSelector:@selector(textFieldShouldReturn:)]) {
    return [field.delegate textFieldShouldReturn:textField];
  } else {
    return YES;
  }
}

@end

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation TTTextViewTableItemCell

@synthesize textView = _textView;

+ (CGFloat)tableView:(UITableView*)tableView rowHeightForItem:(id)item {
  return kTableViewFieldCellHeight;
}

///////////////////////////////////////////////////////////////////////////////////////////////////

- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString*)identifier {
  if (self = [super initWithFrame:frame reuseIdentifier:identifier]) {
    _field = nil;
    
    _textView = [[UITextView alloc] initWithFrame:CGRectZero];
    _textView.delegate = self;
    _textView.font = TTSTYLEVAR(font);
    _textView.scrollsToTop = NO;
    [self.contentView addSubview:_textView];

    self.accessoryType = UITableViewCellAccessoryNone;
    self.selectionStyle = UITableViewCellSelectionStyleNone;
  }
  return self;
}

- (void)dealloc {
  [_field release];
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

- (id)object {
  return _field;
}

- (void)setObject:(id)object {
  if (_field != object) {
    [_field release];
    _field = [object retain];

    TTTextFieldTableItem* field = self.object;
    _textView.text = field.text;
  }  
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// UITextViewDelegate

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
  TTTextViewTableItem* field = self.object;
  if ([field.delegate respondsToSelector:@selector(textViewShouldBeginEditing:)]) {
    return [field.delegate textViewShouldBeginEditing:textView];
  } else {
    return YES;
  }
}

- (BOOL)textViewShouldEndEditing:(UITextView *)textView {
  TTTextViewTableItem* field = self.object;
  if ([field.delegate respondsToSelector:@selector(textViewShouldEndEditing:)]) {
    return [field.delegate textViewShouldEndEditing:textView];
  } else {
    return YES;
  }
}

- (void)textViewDidBeginEditing:(UITextView *)textView {
//  UITableView* tableView = (UITableView*)[self firstParentOfClass:[UITableView class]];
//  NSIndexPath* indexPath = [tableView indexPathForCell:self];
//  [tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionMiddle
//    animated:YES];
  
  TTTextViewTableItem* field = self.object;
  if ([field.delegate respondsToSelector:@selector(textViewDidBeginEditing:)]) {
    [field.delegate textViewDidBeginEditing:textView];
  }
}

- (void)textViewDidEndEditing:(UITextView *)textView {
  TTTextViewTableItem* field = self.object;
  if ([field.delegate respondsToSelector:@selector(textViewDidEndEditing:)]) {
    [field.delegate textViewDidEndEditing:textView];
  }
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range
    replacementText:(NSString *)text {
  TTTextViewTableItem* field = self.object;
  SEL sel = @selector(textView:shouldChangeTextInRange:replacementText:);
  if ([field.delegate respondsToSelector:sel]) {
    return [field.delegate textView:textView shouldChangeTextInRange:range replacementText:text];
  } else {
    return YES;
  }
}

- (void)textViewDidChange:(UITextView *)textView {
  TTTextViewTableItem* field = self.object;
  field.text = textView.text;
  
  if ([field.delegate respondsToSelector:@selector(textViewDidChange:)]) {
    [field.delegate textViewDidChange:textView];
  }
}

- (void)textViewDidChangeSelection:(UITextView *)textView {
  TTTextViewTableItem* field = self.object;
  if ([field.delegate respondsToSelector:@selector(textViewDidChangeSelection:)]) {
    [field.delegate textViewDidChangeSelection:textView];
  }
}

@end

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation TTSwitchTableItemCell

- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString*)identifier {
  if (self = [super initWithFrame:frame reuseIdentifier:identifier]) {
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
  _switch.left = self.contentView.width - (kHPadding + _switch.width);
  _switch.top = kVPadding;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// TTTableViewCell

- (void)setObject:(id)object {
  if (_field != object) {
    [super setObject:object];

    self.textLabel.font = TTSTYLEVAR(tableSmallFont);

    TTSwitchTableItem* field = self.object;
    _switch.on = field.on;
  }  
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// UIControlEvents

- (void)valueChanged {
  TTSwitchTableItem* field = self.object;
  field.on = _switch.on;
}

@end

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation TTSearchBarTableItemCell

+ (CGFloat)tableView:(UITableView*)tableView rowHeightForItem:(id)item {
  return TOOLBAR_HEIGHT;
}

///////////////////////////////////////////////////////////////////////////////////////////////////

- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString*)identifier {
  if (self = [super initWithFrame:frame reuseIdentifier:identifier]) {
    _searchBar = nil;
	}
	return self;
}

- (void)dealloc {
  [_searchBar release];
	[super dealloc];
}

- (void)layoutSubviews {
  [super layoutSubviews];
  _searchBar.frame = self.contentView.bounds;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// TTTableViewCell

- (id)object {
  return _searchBar;
}

- (void)setObject:(id)object {
  if (_searchBar != object) {
    [_searchBar removeFromSuperview];
    [_searchBar release];
    _searchBar = [object retain];
    [self.contentView addSubview:_searchBar];
  }  
}

@end

