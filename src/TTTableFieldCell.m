#import "Three20/TTTableFieldCell.h"
#import "Three20/TTTableField.h"
#import "Three20/TTImageView.h"
#import "Three20/TTErrorView.h"
#import "Three20/TTStyledNode.h"
#import "Three20/TTStyledText.h"
#import "Three20/TTStyledTextLabel.h"
#import "Three20/TTActivityLabel.h"
#import "Three20/TTNavigationCenter.h"
#import "Three20/TTURLCache.h"
#import "Three20/TTDefaultStyleSheet.h"

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

@implementation TTTableFieldCell

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
  
    if (_field.url) {
      if ([[TTNavigationCenter defaultCenter] urlIsSupported:_field.url]) {
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

@implementation TTTextTableFieldCell

///////////////////////////////////////////////////////////////////////////////////////////////////
// class public

+ (CGFloat)tableView:(UITableView*)tableView rowHeightForItem:(id)item {
  TTTitledTableField* field = item;

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
    _label = [[UILabel alloc] initWithFrame:CGRectZero];
    _label.highlightedTextColor = TTSTYLEVAR(highlightedTextColor);
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
  
  _label.frame = CGRectInset(self.contentView.bounds, kHPadding, kVPadding);
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
  
    _label.text = _field.text;
    _label.lineBreakMode = UILineBreakModeWordWrap;
    _label.numberOfLines = 0;

    if ([object isKindOfClass:[TTGrayTextTableField class]]) {
      _label.font = TTSTYLEVAR(font);
      _label.textColor = TTSTYLEVAR(tableSubTextColor);
      _label.textAlignment = UITextAlignmentCenter;
    } else if ([object isKindOfClass:[TTButtonTableField class]]) {
      _label.font = TTSTYLEVAR(tableButtonFont);
      _label.textColor = TTSTYLEVAR(linkTextColor);
      _label.textAlignment = UITextAlignmentCenter;
      self.accessoryType = UITableViewCellAccessoryNone;
      self.selectionStyle = UITableViewCellSelectionStyleBlue;
    } else if ([object isKindOfClass:[TTLinkTableField class]]) {
      _label.font = TTSTYLEVAR(tableFont);
      _label.textColor = TTSTYLEVAR(linkTextColor);
      _label.textAlignment = UITextAlignmentLeft;
    } else if ([object isKindOfClass:[TTSummaryTableField class]]) {
      _label.font = TTSTYLEVAR(tableSummaryFont);
      _label.textColor = TTSTYLEVAR(tableSubTextColor);
      _label.textAlignment = UITextAlignmentCenter;
    } else {
      _label.font = TTSTYLEVAR(tableFont);
      _label.textColor = TTSTYLEVAR(textColor);
      _label.textAlignment = UITextAlignmentLeft;
    }
  }
}

@end

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation TTStyledTextTableFieldCell

///////////////////////////////////////////////////////////////////////////////////////////////////
// class public

+ (CGFloat)tableView:(UITableView*)tableView rowHeightForItem:(id)item {
  TTStyledTextTableField* field = item;
  field.styledText.font = TTSTYLEVAR(font);
  
  CGFloat padding = tableView.style == UITableViewStyleGrouped ? kGroupMargin*2 : 0;
  if (field.url) {
    padding += kDisclosureIndicatorWidth;
  }
  
  field.styledText.width = tableView.width - padding;
  
  return field.styledText.height;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// NSObject

- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString*)identifier {
  if (self = [super initWithFrame:frame reuseIdentifier:identifier]) {
    _label = [[TTStyledTextLabel alloc] initWithFrame:CGRectZero];
    //_label.contentInset = UIEdgeInsetsMake(kVPadding, kHPadding, kVPadding, kHPadding);
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
  
  _label.frame = self.contentView.bounds;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// TTTableViewCell

- (void)setObject:(id)object {
  if (_field != object) {
    [super setObject:object];
    
    TTStyledTextTableField* field = object;
    _label.text = field.styledText;
  }  
}

@end

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation TTTitledTableFieldCell

+ (CGFloat)tableView:(UITableView*)tableView rowHeightForItem:(id)item {
  CGFloat maxWidth = tableView.width - (kKeyWidth + kKeySpacing + kHPadding*2 + kMargin*2);
  TTTitledTableField* field = item;

  CGSize size = [field.text sizeWithFont:TTSTYLEVAR(tableSmallFont)
    constrainedToSize:CGSizeMake(maxWidth, CGFLOAT_MAX)
    lineBreakMode:UILineBreakModeWordWrap];
  
  return size.height + kVPadding*2;

}

///////////////////////////////////////////////////////////////////////////////////////////////////

- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString*)identifier {
  if (self = [super initWithFrame:frame reuseIdentifier:identifier]) {
    _titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _titleLabel.font = TTSTYLEVAR(tableTitleFont);
    _titleLabel.textColor = TTSTYLEVAR(linkTextColor);
    _titleLabel.highlightedTextColor = TTSTYLEVAR(highlightedTextColor);
    _titleLabel.textAlignment = UITextAlignmentRight;
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

  CGSize titleSize = [@"M" sizeWithFont:TTSTYLEVAR(tableTitleFont)];
  _titleLabel.frame = CGRectMake(kHPadding, kVPadding, kKeyWidth, titleSize.height);

  CGFloat valueWidth = self.contentView.width - (kHPadding*2 + kKeyWidth + kKeySpacing);
  CGFloat innerHeight = self.contentView.height - kVPadding*2;
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

- (void)setObject:(id)object {
  if (_field != object) {
    [super setObject:object];
  
    TTTitledTableField* field = object;
    _titleLabel.text = field.title;
    _label.text = field.text;
  
    _label.font = TTSTYLEVAR(tableSmallFont);
    _label.textColor = TTSTYLEVAR(textColor);
    _label.adjustsFontSizeToFitWidth = YES;
    _label.lineBreakMode = UILineBreakModeWordWrap;
    _label.numberOfLines = 0;

    if (field.url) {
      if ([[TTNavigationCenter defaultCenter] urlIsSupported:field.url]) {
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

+ (CGFloat)tableView:(UITableView*)tableView rowHeightForItem:(id)item {
  CGFloat maxWidth = tableView.width - kHPadding*2;
  TTSubtextTableField* field = item;

  CGSize textSize = [field.text sizeWithFont:TTSTYLEVAR(tableSmallFont)
    constrainedToSize:CGSizeMake(maxWidth, CGFLOAT_MAX)
    lineBreakMode:UILineBreakModeWordWrap];
  CGSize subtextSize = [field.subtext sizeWithFont:TTSTYLEVAR(font)
    constrainedToSize:CGSizeMake(maxWidth, CGFLOAT_MAX) lineBreakMode:UILineBreakModeWordWrap];
  
  return kVPadding*2 + textSize.height + subtextSize.height;
}

///////////////////////////////////////////////////////////////////////////////////////////////////

- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString*)identifier {
  if (self = [super initWithFrame:frame reuseIdentifier:identifier]) {
    _subtextLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _subtextLabel.font = TTSTYLEVAR(font);
    _subtextLabel.textColor = TTSTYLEVAR(tableSubTextColor);
    _subtextLabel.highlightedTextColor = TTSTYLEVAR(highlightedTextColor);
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
  _label.left = kHPadding;
  _label.top = kVPadding;

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

- (void)setObject:(id)object {
  if (_field != object) {
    [super setObject:object];
  
    TTSubtextTableField* field = object;
    _label.text = field.text;
    _label.font = TTSTYLEVAR(tableSmallFont);
    _label.textColor = TTSTYLEVAR(textColor);
    _label.adjustsFontSizeToFitWidth = YES;

    _subtextLabel.text = field.subtext;

    if (field.url) {
      if ([[TTNavigationCenter defaultCenter] urlIsSupported:field.url]) {
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

+ (CGFloat)tableView:(UITableView*)tableView rowHeightForItem:(id)item {
  TTMoreButtonTableField* field = item;
  
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
  if (self = [super initWithFrame:frame reuseIdentifier:identifier]) {
    _spinnerView = nil;
    
    _subtitleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _subtitleLabel.font = TTSTYLEVAR(font);
    _subtitleLabel.textColor = TTSTYLEVAR(tableSubTextColor);
    _subtitleLabel.highlightedTextColor = TTSTYLEVAR(highlightedTextColor);
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
  
  _spinnerView.top = floor(self.contentView.height/2 - _spinnerView.height/2);
  _label.top = floor(self.contentView.height/2 - titleHeight/2);
  _subtitleLabel.top = _label.bottom;
  
  _label.left = _label.top*2;
  _subtitleLabel.left = _label.top*2;
  _spinnerView.left = _label.left + titleWidth + kSpacing;
}

-(void)didMoveToSuperview {
  [super didMoveToSuperview];
  if (self.superview && [(UITableView*)self.superview style] == UITableViewStylePlain) {
    _subtitleLabel.backgroundColor = self.superview.backgroundColor;
  }
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// TTTableViewCell

- (void)setObject:(id)object {
  if (_field != object) {
    [super setObject:object];

    TTMoreButtonTableField* field = object;

    _label.text = field.text;
    _label.font = TTSTYLEVAR(tableFont);
    _label.textColor = TTSTYLEVAR(moreLinkTextColor);

    if (field.subtitle) {
      _subtitleLabel.text = field.subtitle;
      _subtitleLabel.hidden = NO;
    } else {
      _subtitleLabel.hidden = YES;
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

@implementation TTIconTableFieldCell

+ (CGFloat)tableView:(UITableView*)tableView rowHeightForItem:(id)item {
  TTImageTableField* field = item;

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

  TTImageTableField* field = self.object;
  UIImage* image = field.image
    ? [[TTURLCache sharedCache] imageForURL:field.image]
    : nil;
  if (!image) {
    image = field.defaultImage;
  }
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

- (void)setObject:(id)object {
  if (_field != object) {
    [super setObject:object];
  
    TTImageTableField* field = object;
    _iconView.defaultImage = field.defaultImage;
    _iconView.url = field.image;
  }  
}
@end

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation TTImageTableFieldCell

///////////////////////////////////////////////////////////////////////////////////////////////////
// UIView

- (void)layoutSubviews {
  [super layoutSubviews];

  TTImageTableField* field = self.object;
  UIImage* image = field.image ? [[TTURLCache sharedCache] imageForURL:field.image] : nil;
  
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

- (void)setObject:(id)object {
  if (_field != object) {
    [super setObject:object];
  
    _label.font = TTSTYLEVAR(tableSmallFont);
    _label.textAlignment = UITextAlignmentCenter;
    self.accessoryType = UITableViewCellAccessoryNone;
  }  
}

@end

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation TTActivityTableFieldCell

+ (CGFloat)tableView:(UITableView*)tableView rowHeightForItem:(id)item {
  TTActivityTableField* field = item;
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
  
    TTActivityTableField* field = object;
    _activityLabel.text = field.text;
  }  
}

@end

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation TTErrorTableFieldCell

+ (CGFloat)tableView:(UITableView*)tableView rowHeightForItem:(id)item {
  TTStatusTableField* field = item;
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
  
  [_label sizeToFit];
  _label.width = kTextFieldTitleWidth;
  
  _textField.frame = CGRectOffset(CGRectInset(self.contentView.bounds, 3, 0), 0, 1);
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// TTTableViewCell

- (void)setObject:(id)object {
  if (_field != object) {
    [super setObject:object];

    TTTextFieldTableField* field = object;
    _label.text = [NSString stringWithFormat:@"  %@", field.title];

    _textField.text = field.text;
    _textField.placeholder = field.placeholder;
    _textField.font = TTSTYLEVAR(font);
    _textField.returnKeyType = field.returnKeyType;
    _textField.keyboardType = field.keyboardType;
    _textField.autocapitalizationType = field.autocapitalizationType;
    _textField.autocorrectionType = field.autocorrectionType;
    _textField.clearButtonMode = field.clearButtonMode;
    _textField.secureTextEntry = field.secureTextEntry;
    _textField.leftView = _label;
    _textField.leftViewMode = UITextFieldViewModeAlways;
    _textField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    _textField.delegate = self;
  }  
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// UIControlEvents

- (void)valueChanged {
  TTTextFieldTableField* field = self.object;
  field.text = _textField.text;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// UITextFieldDelegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
  TTTextFieldTableField* field = self.object;
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

  TTTextFieldTableField* field = self.object;
  if ([field.delegate respondsToSelector:@selector(textFieldDidBeginEditing:)]) {
    [field.delegate textFieldDidBeginEditing:textField];
  }
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
  TTTextFieldTableField* field = self.object;
  if ([field.delegate respondsToSelector:@selector(textFieldShouldEndEditing:)]) {
    return [field.delegate textFieldShouldEndEditing:textField];
  } else {
    return YES;
  }
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
  TTTextFieldTableField* field = self.object;
  if ([field.delegate respondsToSelector:@selector(textFieldDidEndEditing:)]) {
    [field.delegate textFieldDidEndEditing:textField];
  }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range
    replacementString:(NSString *)string {
  TTTextFieldTableField* field = self.object;
  SEL sel = @selector(textField:shouldChangeCharactersInRange:replacementString:);
  if ([field.delegate respondsToSelector:sel]) {
    return [field.delegate textField:textField shouldChangeCharactersInRange:range
      replacementString:string];
  } else {
    return YES;
  }
}

- (BOOL)textFieldShouldClear:(UITextField *)textField {
  TTTextFieldTableField* field = self.object;
  if ([field.delegate respondsToSelector:@selector(textFieldShouldClear:)]) {
    return [field.delegate textFieldShouldClear:textField];
  } else {
    return YES;
  }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
  TTTextFieldTableField* field = self.object;
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

    TTTextFieldTableField* field = self.object;
    _textView.text = field.text;
  }  
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// UITextViewDelegate

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
  TTTextViewTableField* field = self.object;
  if ([field.delegate respondsToSelector:@selector(textViewShouldBeginEditing:)]) {
    return [field.delegate textViewShouldBeginEditing:textView];
  } else {
    return YES;
  }
}

- (BOOL)textViewShouldEndEditing:(UITextView *)textView {
  TTTextViewTableField* field = self.object;
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
  
  TTTextViewTableField* field = self.object;
  if ([field.delegate respondsToSelector:@selector(textViewDidBeginEditing:)]) {
    [field.delegate textViewDidBeginEditing:textView];
  }
}

- (void)textViewDidEndEditing:(UITextView *)textView {
  TTTextViewTableField* field = self.object;
  if ([field.delegate respondsToSelector:@selector(textViewDidEndEditing:)]) {
    [field.delegate textViewDidEndEditing:textView];
  }
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range
    replacementText:(NSString *)text {
  TTTextViewTableField* field = self.object;
  SEL sel = @selector(textView:shouldChangeTextInRange:replacementText:);
  if ([field.delegate respondsToSelector:sel]) {
    return [field.delegate textView:textView shouldChangeTextInRange:range replacementText:text];
  } else {
    return YES;
  }
}

- (void)textViewDidChange:(UITextView *)textView {
  TTTextViewTableField* field = self.object;
  field.text = textView.text;
  
  if ([field.delegate respondsToSelector:@selector(textViewDidChange:)]) {
    [field.delegate textViewDidChange:textView];
  }
}

- (void)textViewDidChangeSelection:(UITextView *)textView {
  TTTextViewTableField* field = self.object;
  if ([field.delegate respondsToSelector:@selector(textViewDidChangeSelection:)]) {
    [field.delegate textViewDidChangeSelection:textView];
  }
}

@end

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation TTSwitchTableFieldCell

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

    _label.font = TTSTYLEVAR(tableSmallFont);

    TTSwitchTableField* field = self.object;
    _switch.on = field.on;
  }  
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// UIControlEvents

- (void)valueChanged {
  TTSwitchTableField* field = self.object;
  field.on = _switch.on;
}

@end
