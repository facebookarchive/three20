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

///////////////////////////////////////////////////////////////////////////////////////////////////

static CGFloat kHPadding = 10;
static CGFloat kVPadding = 10;
static CGFloat kMargin = 10;
static CGFloat kSpacing = 8;
static CGFloat kControlPadding = 8;
static CGFloat kGroupMargin = 10;
static CGFloat kDefaultTextViewLines = 4;

static CGFloat kKeySpacing = 12;
static CGFloat kKeyWidth = 75;
static CGFloat kMaxLabelHeight = 2000;
static CGFloat kDisclosureIndicatorWidth = 23;

//static CGFloat kTextFieldTitleWidth = 100;
//static CGFloat kTableViewFieldCellHeight = 180;

static CGFloat kDefaultIconSize = 50;

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation TTTableLinkedItemCell

///////////////////////////////////////////////////////////////////////////////////////////////////

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString*)identifier {
  if (self = [super initWithStyle:style reuseIdentifier:identifier]) {
    _item = nil;
	}
	return self;
}

- (void)dealloc {
  [_item release];
	[super dealloc];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// TTTableViewCell

- (id)object {
  return _item;
}

- (void)setObject:(id)object {
  if (_item != object) {
    [_item release];
    _item = [object retain];

    TTTableLinkedItem* linkedItem = object;
    if (linkedItem.URL) {
      if ([[TTNavigationCenter defaultCenter] URLIsSupported:linkedItem.URL]) {
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

@implementation TTTableTextItemCell

+ (UIFont*)textFontForItem:(TTTableTextItem*)item {
  if ([item isKindOfClass:[TTTableLongTextItem class]]) {
    return TTSTYLEVAR(font);
  } else if ([item isKindOfClass:[TTTableGrayTextItem class]]) {
    return TTSTYLEVAR(font);
  } else {
    return TTSTYLEVAR(tableFont);
  }
}

+ (CGFloat)tableView:(UITableView*)tableView rowHeightForItem:(id)item {
  TTTableTextItem* textItem = item;

  CGFloat maxWidth = tableView.width - (kHPadding*2 + kMargin*2);
  UIFont* font = [self textFontForItem:textItem];
  CGSize size = [textItem.text sizeWithFont:font
                               constrainedToSize:CGSizeMake(maxWidth, CGFLOAT_MAX)
                               lineBreakMode:UILineBreakModeWordWrap];
  if (size.height > kMaxLabelHeight) {
    size.height = kMaxLabelHeight;
  }

  return size.height + kVPadding*2;
}

///////////////////////////////////////////////////////////////////////////////////////////////////

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString*)identifier {
  if (self = [super initWithStyle:style reuseIdentifier:identifier]) {
    self.textLabel.highlightedTextColor = TTSTYLEVAR(highlightedTextColor);
    self.textLabel.lineBreakMode = UILineBreakModeWordWrap;
    self.textLabel.numberOfLines = 0;
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
    
  self.textLabel.frame = CGRectInset(self.contentView.bounds, kHPadding, kVPadding);
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// TTTableViewCell

- (id)object {
  return _item;
}

- (void)setObject:(id)object {
  if (_item != object) {
    [super setObject:object];

    TTTableTextItem* item = object;
    self.textLabel.text = item.text;

    if ([object isKindOfClass:[TTTableButton class]]) {
      self.textLabel.font = TTSTYLEVAR(tableButtonFont);
      self.textLabel.textColor = TTSTYLEVAR(linkTextColor);
      self.textLabel.textAlignment = UITextAlignmentCenter;
      self.accessoryType = UITableViewCellAccessoryNone;
      self.selectionStyle = UITableViewCellSelectionStyleBlue;
    } else if ([object isKindOfClass:[TTTableLink class]]) {
      self.textLabel.font = TTSTYLEVAR(tableFont);
      self.textLabel.textColor = TTSTYLEVAR(linkTextColor);
      self.textLabel.textAlignment = UITextAlignmentLeft;
    } else if ([object isKindOfClass:[TTTableSummaryItem class]]) {
      self.textLabel.font = TTSTYLEVAR(tableSummaryFont);
      self.textLabel.textColor = TTSTYLEVAR(tableSubTextColor);
      self.textLabel.textAlignment = UITextAlignmentCenter;
    } else if ([object isKindOfClass:[TTTableLongTextItem class]]) {
      self.textLabel.font = TTSTYLEVAR(font);
      self.textLabel.textColor = TTSTYLEVAR(textColor);
      self.textLabel.textAlignment = UITextAlignmentLeft;
    } else if ([object isKindOfClass:[TTTableGrayTextItem class]]) {
      self.textLabel.font = TTSTYLEVAR(font);
      self.textLabel.textColor = TTSTYLEVAR(tableSubTextColor);
      self.textLabel.textAlignment = UITextAlignmentLeft;
    } else {
      self.textLabel.font = TTSTYLEVAR(tableFont);
      self.textLabel.textColor = TTSTYLEVAR(textColor);
      self.textLabel.textAlignment = UITextAlignmentLeft;
    }   
  }  
}

@end

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation TTTableCaptionedItemCell

+ (CGFloat)tableView:(UITableView*)tableView rowHeightForItem:(id)item {
  TTTableCaptionedItem* captionedItem = item;

  if ([item isKindOfClass:[TTTableRightCaptionedItem class]]) {
    return 44;
  } else if ([item isKindOfClass:[TTTableBelowCaptionedItem class]]) {
    CGFloat maxWidth = tableView.width - kHPadding*2;

    CGSize textSize = [captionedItem.text sizeWithFont:TTSTYLEVAR(tableSmallFont)
      constrainedToSize:CGSizeMake(maxWidth, CGFLOAT_MAX)
      lineBreakMode:UILineBreakModeWordWrap];
    CGSize subtextSize = [captionedItem.caption sizeWithFont:TTSTYLEVAR(font)
      constrainedToSize:CGSizeMake(maxWidth, CGFLOAT_MAX) lineBreakMode:UILineBreakModeWordWrap];
    
    return kVPadding*2 + textSize.height + subtextSize.height;
  } else {
    CGFloat maxWidth = tableView.width - (kKeyWidth + kKeySpacing + kHPadding*2 + kMargin*2);

    CGSize size = [captionedItem.text sizeWithFont:TTSTYLEVAR(tableSmallFont)
                                      constrainedToSize:CGSizeMake(maxWidth, CGFLOAT_MAX)
                                      lineBreakMode:UILineBreakModeWordWrap];
    
    return size.height + kVPadding*2;
  }
}

///////////////////////////////////////////////////////////////////////////////////////////////////

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString*)identifier {
  if (self = [super initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:identifier]) {
    _item = nil;
    
    self.textLabel.highlightedTextColor = TTSTYLEVAR(highlightedTextColor);
    self.textLabel.lineBreakMode = UILineBreakModeWordWrap;
    self.textLabel.numberOfLines = 0;

    self.detailTextLabel.highlightedTextColor = TTSTYLEVAR(highlightedTextColor);
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
    
  TTTableCaptionedItem* item = self.object;
  if ([item isKindOfClass:[TTTableRightCaptionedItem class]]) {
  } else if ([item isKindOfClass:[TTTableBelowCaptionedItem class]]) {
    if (!self.textLabel.text.length) {
      CGFloat titleHeight = self.textLabel.height + self.detailTextLabel.height;
      
      [self.detailTextLabel sizeToFit];
      self.detailTextLabel.top = floor(self.contentView.height/2 - titleHeight/2);
      self.detailTextLabel.left = self.detailTextLabel.top*2;
    } else {
      [self.detailTextLabel sizeToFit];
      self.detailTextLabel.left = kHPadding;
      self.detailTextLabel.top = kVPadding;
      
      CGFloat maxWidth = self.contentView.width - kHPadding*2;
      CGSize captionSize =
        [self.textLabel.text sizeWithFont:self.textLabel.font
                                   constrainedToSize:CGSizeMake(maxWidth, CGFLOAT_MAX)
                                   lineBreakMode:self.textLabel.lineBreakMode];
      self.textLabel.frame = CGRectMake(kHPadding, self.detailTextLabel.bottom,
                                              captionSize.width, captionSize.height);
    }
  } else {
    CGSize titleSize = [@"M" sizeWithFont:TTSTYLEVAR(tableTitleFont)];
    self.textLabel.frame = CGRectMake(kHPadding, kVPadding, kKeyWidth, titleSize.height);

    CGFloat valueWidth = self.contentView.width - (kHPadding*2 + kKeyWidth + kKeySpacing);
    CGFloat innerHeight = self.contentView.height - kVPadding*2;
    self.detailTextLabel.frame = CGRectMake(kHPadding + kKeyWidth + kKeySpacing, kVPadding,
      valueWidth, innerHeight);
  }
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// TTTableViewCell

- (id)object {
  return _item;
}

- (void)setObject:(id)object {
  if (_item != object) {
    [super setObject:object];

    TTTableCaptionedItem* item = object;
    self.textLabel.text = item.caption;
    self.detailTextLabel.text = item.text;

    if ([item isKindOfClass:[TTTableRightCaptionedItem class]]) {
    } else if ([item isKindOfClass:[TTTableBelowCaptionedItem class]]) {
      self.detailTextLabel.font = TTSTYLEVAR(tableSmallFont);
      self.detailTextLabel.textColor = TTSTYLEVAR(textColor);
      self.detailTextLabel.adjustsFontSizeToFitWidth = YES;

      self.textLabel.font = TTSTYLEVAR(font);
      self.textLabel.textColor = TTSTYLEVAR(tableSubTextColor);
      self.textLabel.highlightedTextColor = TTSTYLEVAR(highlightedTextColor);
      self.textLabel.textAlignment = UITextAlignmentLeft;
      self.textLabel.contentMode = UIViewContentModeTop;
      self.textLabel.lineBreakMode = UILineBreakModeWordWrap;
      self.textLabel.numberOfLines = 0;
    } else {
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
}

@end

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation TTTableMoreButtonCell

@synthesize animating = _animating;

+ (CGFloat)tableView:(UITableView*)tableView rowHeightForItem:(id)item {
  CGFloat height = [super tableView:tableView rowHeightForItem:item];
  CGFloat minHeight = TOOLBAR_HEIGHT*1.5;
  if (height < minHeight) {
    return minHeight;
  } else {
    return height;
  }
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString*)identifier {
  if (self = [super initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier]) {
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
  
  _spinnerView.top = floor(self.contentView.height/2 - _spinnerView.height/2);
  _spinnerView.left = self.detailTextLabel.left + self.detailTextLabel.width + kSpacing;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// TTTableViewCell

- (void)setObject:(id)object {
  if (_item != object) {
    [super setObject:object];

    TTTableMoreButton* item = object;
    self.animating = item.isLoading;

    self.detailTextLabel.textColor = TTSTYLEVAR(moreLinkTextColor);
    self.selectionStyle = UITableViewCellSelectionStyleBlue;
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

@implementation TTTableImageItemCell

+ (CGFloat)tableView:(UITableView*)tableView rowHeightForItem:(id)item {
  TTTableImageItem* imageItem = item;

  UIImage* image = imageItem.image ? [[TTURLCache sharedCache] imageForURL:imageItem.image] : nil;
  
  CGFloat iconWidth = image
    ? image.size.width + kKeySpacing
    : (imageItem.image ? kDefaultIconSize + kKeySpacing : 0);
  CGFloat iconHeight = image
    ? image.size.height
    : (imageItem.image ? kDefaultIconSize : 0);
    
  CGFloat maxWidth = tableView.width - (iconWidth + kHPadding*2 + kMargin*2);

  CGSize textSize = [imageItem.text sizeWithFont:TTSTYLEVAR(tableSmallFont)
    constrainedToSize:CGSizeMake(maxWidth, CGFLOAT_MAX)
    lineBreakMode:UILineBreakModeWordWrap];

  CGFloat contentHeight = textSize.height > iconHeight ? textSize.height : iconHeight;
  return contentHeight + kVPadding*2;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString*)identifier {
  if (self = [super initWithStyle:style reuseIdentifier:identifier]) {
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

  TTTableImageItem* item = self.object;
  UIImage* image = item.image ? [[TTURLCache sharedCache] imageForURL:item.image] : nil;
  if (!image) {
    image = item.defaultImage;
  }

  if ([_item isKindOfClass:[TTTableRightImageItem class]]) {
    CGFloat iconWidth = image
      ? image.size.width
      : (item.image ? kDefaultIconSize : 0);
    CGFloat iconHeight = image
      ? image.size.height
      : (item.image ? kDefaultIconSize : 0);
    
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
  } else {
    if (_iconView.URL) {
        CGFloat iconWidth = image
          ? image.size.width
          : (item.image ? kDefaultIconSize : 0);
        CGFloat iconHeight = image
          ? image.size.height
          : (item.image ? kDefaultIconSize : 0);

      TTImageStyle* style = [item.imageStyle firstStyleOfClass:[TTImageStyle class]];
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
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// TTTableViewCell

- (void)setObject:(id)object {
  if (_item != object) {
    [super setObject:object];
  
    TTTableImageItem* item = object;
    _iconView.defaultImage = item.defaultImage;
    _iconView.URL = item.image;
    _iconView.style = item.imageStyle;

    if ([_item isKindOfClass:[TTTableRightImageItem class]]) {
      self.textLabel.font = TTSTYLEVAR(tableSmallFont);
      self.textLabel.textAlignment = UITextAlignmentCenter;
      self.accessoryType = UITableViewCellAccessoryNone;
    } else {
      self.textLabel.font = TTSTYLEVAR(tableFont);
      self.textLabel.textAlignment = UITextAlignmentLeft;
    }
  }  
}
@end

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation TTTableActivityItemCell

+ (CGFloat)tableView:(UITableView*)tableView rowHeightForItem:(id)item {
  TTTableActivityItem* activityItem = item;
  if (activityItem.sizeToFit) {
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

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString*)identifier {
  if (self = [super initWithStyle:style reuseIdentifier:identifier]) {
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
  if (_item != object) {
    [_item release];
    _item = [object retain];
  
    TTTableActivityItem* item = object;
    _activityLabel.text = item.text;
  }  
}

@end

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation TTTableErrorItemCell

+ (CGFloat)tableView:(UITableView*)tableView rowHeightForItem:(id)item {
  TTTableErrorItem* errorItem = item;
  if (errorItem.sizeToFit) {
    CGFloat headerHeight = 0;
    if ([tableView.delegate respondsToSelector:@selector(tableView:heightForHeaderInSection:)]) {
      headerHeight = [tableView.delegate tableView:tableView heightForHeaderInSection:0];
    }
    return tableView.height - (tableView.tableHeaderView.height + headerHeight);
  } else {
  }

  return [super tableView:tableView rowHeightForItem:item];
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString*)identifier {
  if (self = [super initWithStyle:style reuseIdentifier:identifier]) {
    _item = nil;
    
    _errorView = [[TTErrorView alloc] initWithFrame:CGRectZero];
    [self addSubview:_errorView];

    self.accessoryType = UITableViewCellAccessoryNone;
    self.selectionStyle = UITableViewCellSelectionStyleNone;
  }
  return self;
}

- (void)dealloc {
  [_item release];
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
  return _item;
}

- (void)setObject:(id)object {
  if (_item != object) {
    [_item release];
    _item = [object retain];
    
    TTTableErrorItem* item = object;
    _errorView.image = item.image;
    _errorView.title = item.title;
    _errorView.subtitle = item.subtitle;
  }  
}

@end
/*
///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation TTTextFieldTableItemCell

@synthesize textField = _textField;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString*)identifier {
  if (self = [super initWithStyle:style reuseIdentifier:identifier]) {
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
  if (_item != object) {
    [super setObject:object];

    TTTextFieldTableItem* item = object;
    self.textLabel.text = [NSString stringWithFormat:@"  %@", item.title];

    _textField.text = item.text;
    _textField.placeholder = item.placeholder;
    _textField.font = TTSTYLEVAR(font);
    _textField.returnKeyType = item.returnKeyType;
    _textField.keyboardType = item.keyboardType;
    _textField.autocapitalizationType = item.autocapitalizationType;
    _textField.autocorrectionType = item.autocorrectionType;
    _textField.clearButtonMode = item.clearButtonMode;
    _textField.secureTextEntry = item.secureTextEntry;
    _textField.leftView = self.textLabel;
    _textField.leftViewMode = UITextFieldViewModeAlways;
    _textField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    _textField.delegate = self;
  }  
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// UIControlEvents

- (void)valueChanged {
  TTTextFieldTableItem* item = self.object;
  item.text = _textField.text;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// UITextFieldDelegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
  TTTextFieldTableItem* item = self.object;
  if ([item.delegate respondsToSelector:@selector(textFieldShouldBeginEditing:)]) {
    return [item.delegate textFieldShouldBeginEditing:textField];
  } else {
    return YES;
  }
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
//  UITableView* tableView = (UITableView*)[self firstParentOfClass:[UITableView class]];
//  NSIndexPath* indexPath = [tableView indexPathForCell:self];
//  [tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionMiddle
//    animated:YES];

  TTTextFieldTableItem* item = self.object;
  if ([item.delegate respondsToSelector:@selector(textFieldDidBeginEditing:)]) {
    [item.delegate textFieldDidBeginEditing:textField];
  }
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
  TTTextFieldTableItem* item = self.object;
  if ([item.delegate respondsToSelector:@selector(textFieldShouldEndEditing:)]) {
    return [item.delegate textFieldShouldEndEditing:textField];
  } else {
    return YES;
  }
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
  TTTextFieldTableItem* item = self.object;
  if ([item.delegate respondsToSelector:@selector(textFieldDidEndEditing:)]) {
    [item.delegate textFieldDidEndEditing:textField];
  }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range
    replacementString:(NSString *)string {
  TTTextFieldTableItem* item = self.object;
  SEL sel = @selector(textField:shouldChangeCharactersInRange:replacementString:);
  if ([item.delegate respondsToSelector:sel]) {
    return [item.delegate textField:textField shouldChangeCharactersInRange:range
      replacementString:string];
  } else {
    return YES;
  }
}

- (BOOL)textFieldShouldClear:(UITextField *)textField {
  TTTextFieldTableItem* item = self.object;
  if ([item.delegate respondsToSelector:@selector(textFieldShouldClear:)]) {
    return [item.delegate textFieldShouldClear:textField];
  } else {
    return YES;
  }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
  TTTextFieldTableItem* item = self.object;
  if ([item.delegate respondsToSelector:@selector(textFieldShouldReturn:)]) {
    return [item.delegate textFieldShouldReturn:textField];
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

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString*)identifier {
  if (self = [super initWithStyle:style reuseIdentifier:identifier]) {
    _item = nil;
    
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
  [_item release];
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
  return _item;
}

- (void)setObject:(id)object {
  if (_item != object) {
    [_item release];
    _item = [object retain];

    TTTextFieldTableItem* item = self.object;
    _textView.text = item.text;
  }  
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// UITextViewDelegate

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
  TTTextViewTableItem* item = self.object;
  if ([item.delegate respondsToSelector:@selector(textViewShouldBeginEditing:)]) {
    return [item.delegate textViewShouldBeginEditing:textView];
  } else {
    return YES;
  }
}

- (BOOL)textViewShouldEndEditing:(UITextView *)textView {
  TTTextViewTableItem* item = self.object;
  if ([item.delegate respondsToSelector:@selector(textViewShouldEndEditing:)]) {
    return [item.delegate textViewShouldEndEditing:textView];
  } else {
    return YES;
  }
}

- (void)textViewDidBeginEditing:(UITextView *)textView {
//  UITableView* tableView = (UITableView*)[self firstParentOfClass:[UITableView class]];
//  NSIndexPath* indexPath = [tableView indexPathForCell:self];
//  [tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionMiddle
//    animated:YES];
  
  TTTextViewTableItem* item = self.object;
  if ([item.delegate respondsToSelector:@selector(textViewDidBeginEditing:)]) {
    [item.delegate textViewDidBeginEditing:textView];
  }
}

- (void)textViewDidEndEditing:(UITextView *)textView {
  TTTextViewTableItem* item = self.object;
  if ([item.delegate respondsToSelector:@selector(textViewDidEndEditing:)]) {
    [item.delegate textViewDidEndEditing:textView];
  }
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range
    replacementText:(NSString *)text {
  TTTextViewTableItem* item = self.object;
  SEL sel = @selector(textView:shouldChangeTextInRange:replacementText:);
  if ([item.delegate respondsToSelector:sel]) {
    return [item.delegate textView:textView shouldChangeTextInRange:range replacementText:text];
  } else {
    return YES;
  }
}

- (void)textViewDidChange:(UITextView *)textView {
  TTTextViewTableItem* item = self.object;
  item.text = textView.text;
  
  if ([item.delegate respondsToSelector:@selector(textViewDidChange:)]) {
    [item.delegate textViewDidChange:textView];
  }
}

- (void)textViewDidChangeSelection:(UITextView *)textView {
  TTTextViewTableItem* item = self.object;
  if ([item.delegate respondsToSelector:@selector(textViewDidChangeSelection:)]) {
    [item.delegate textViewDidChangeSelection:textView];
  }
}

@end

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation TTSwitchTableItemCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString*)identifier {
  if (self = [super initWithStyle:style reuseIdentifier:identifier]) {
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
  if (_item != object) {
    [super setObject:object];

    self.textLabel.font = TTSTYLEVAR(tableSmallFont);

    TTSwitchTableItem* item = self.object;
    _switch.on = item.on;
  }  
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// UIControlEvents

- (void)valueChanged {
  TTSwitchTableItem* item = self.object;
  item.on = _switch.on;
}

@end
*/
///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation TTStyledTextTableItemCell

///////////////////////////////////////////////////////////////////////////////////////////////////
// class public

+ (CGFloat)tableView:(UITableView*)tableView rowHeightForItem:(id)item {
  TTTableStyledTextItem* textItem = item;
  textItem.text.font = TTSTYLEVAR(font);
  
  CGFloat padding = tableView.style == UITableViewStyleGrouped ? kGroupMargin*2 : 0;
  padding += textItem.padding.left + textItem.padding.right;
  if (textItem.URL) {
    padding += kDisclosureIndicatorWidth;
  }
  
  textItem.text.width = tableView.width - padding;
  
  return textItem.text.height + textItem.padding.top + textItem.padding.bottom;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// NSObject

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString*)identifier {
  if (self = [super initWithStyle:style reuseIdentifier:identifier]) {
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
  
  TTTableStyledTextItem* item = self.object;
  _label.frame = CGRectOffset(self.contentView.bounds, item.margin.left, item.margin.top);
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
  if (_item != object) {
    [super setObject:object];
    
    TTTableStyledTextItem* item = object;
    _label.text = item.text;
    _label.contentInset = item.padding;
  }  
}

@end

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation TTTableControlCell

@synthesize item = _item, control = _control;

///////////////////////////////////////////////////////////////////////////////////////////////////
// class public

+ (CGFloat)tableView:(UITableView*)tableView rowHeightForItem:(id)item {
  UIView* view = nil;

  if ([item isKindOfClass:[UIView class]]) {
    view = item;
  } else {
    TTTableControlItem* controlItem = item;
    view = controlItem.control;
  }
  
  CGFloat height = view.height;
  if (!height) {
    if ([view isKindOfClass:[UITextView class]]) {
      UITextView* textView = (UITextView*)view;
      CGFloat lineHeight = (textView.font.ascender - textView.font.descender) + 1;
      height = lineHeight * kDefaultTextViewLines;
    } else if ([view isKindOfClass:[UITextField class]]) {
      height = TOOLBAR_HEIGHT;
    } else {
      [view sizeToFit];
      height = view.height;
    }
  }
  
  if (height < TOOLBAR_HEIGHT) {
    return TOOLBAR_HEIGHT;
  } else {
    return height;
  }
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// private

- (BOOL)shouldSizeControlToFit {
  return ![_control isKindOfClass:[UISwitch class]];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// NSObject

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString*)identifier {
  if (self = [super initWithStyle:style reuseIdentifier:identifier]) {
    _control = nil;
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
	}
	return self;
}

- (void)dealloc {
  [_control release];
	[super dealloc];
}

- (void)layoutSubviews {
  [super layoutSubviews];
  
  if ([_control isKindOfClass:[UITextView class]]) {
    _control.frame = self.contentView.bounds;
  } else {
    CGFloat minX = kControlPadding;
    CGFloat contentWidth = self.contentView.width - kControlPadding*2;
    if (self.textLabel.text.length) {
      CGSize textSize = [self.textLabel sizeThatFits:self.contentView.bounds.size];
      contentWidth -= textSize.width + kSpacing;
      minX += textSize.width + kSpacing;
    }

    if (!_control.height) {
      [_control sizeToFit];
    }
    
    if (![self shouldSizeControlToFit]) {
      minX += contentWidth - _control.width;
    }
    
    _control.frame = CGRectMake(minX, floor(self.contentView.height/2 - _control.height/2),
                                contentWidth, _control.height);
  }
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// TTTableViewCell

- (id)object {
  return _item ? _item : (id)_control;
}

- (void)setObject:(id)object {
  if (object != _control && object != _item) {
    [_control removeFromSuperview];
    [_control release];
    [_item release];
    
    if ([object isKindOfClass:[UIView class]]) {
      _item = nil;
      _control = [object retain];
    } else if ([object isKindOfClass:[TTTableControlItem class]]) {
      _item = [object retain];
      _control = [_item.control retain];
    }
    
    if (_item.caption) {
      self.textLabel.text = _item.caption;
    }
    
    [self.contentView addSubview:_control];
  }  
}

@end

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation TTTableFlushViewCell

@synthesize item = _item, view = _view;

///////////////////////////////////////////////////////////////////////////////////////////////////
// class public

+ (CGFloat)tableView:(UITableView*)tableView rowHeightForItem:(id)item {
  return TOOLBAR_HEIGHT;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// NSObject

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString*)identifier {
  if (self = [super initWithStyle:style reuseIdentifier:identifier]) {
    _view = nil;

    self.selectionStyle = UITableViewCellSelectionStyleNone;
	}
	return self;
}

- (void)dealloc {
  [_view release];
	[super dealloc];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// UIView

- (void)layoutSubviews {
  [super layoutSubviews];
  _view.frame = self.contentView.bounds;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// TTTableViewCell

- (id)object {
  return _item ? _item : (id)_view;
}

- (void)setObject:(id)object {
  if (object != _view && object != _item) {
    [_view removeFromSuperview];
    [_view release];
    [_item release];
    
    if ([object isKindOfClass:[UIView class]]) {
      _item = nil;
      _view = [object retain];
    } else if ([object isKindOfClass:[TTTableViewItem class]]) {
      _item = [object retain];
      _view = [_item.view retain];
    }

    [self.contentView addSubview:_view];
  }  
}

@end
