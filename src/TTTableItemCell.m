#import "Three20/TTTableItemCell.h"
#import "Three20/TTTableItem.h"
#import "Three20/TTImageView.h"
#import "Three20/TTErrorView.h"
#import "Three20/TTStyledNode.h"
#import "Three20/TTStyledText.h"
#import "Three20/TTStyledTextLabel.h"
#import "Three20/TTActivityLabel.h"
#import "Three20/TTTextEditor.h"
#import "Three20/TTURLMap.h"
#import "Three20/TTNavigator.h"
#import "Three20/TTURLCache.h"
#import "Three20/TTDefaultStyleSheet.h"

///////////////////////////////////////////////////////////////////////////////////////////////////

static CGFloat kHPadding = 10;
static CGFloat kVPadding = 10;
static CGFloat kMargin = 10;
static CGFloat kSpacing = 8;
static CGFloat kControlPadding = 8;
static CGFloat kGroupMargin = 10;
static CGFloat kDefaultTextViewLines = 5;

static CGFloat kKeySpacing = 12;
static CGFloat kKeyWidth = 75;
static CGFloat kMaxLabelHeight = 2000;
static CGFloat kDisclosureIndicatorWidth = 23;

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
  TT_RELEASE_MEMBER(_item);
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
      TTNavigationMode navigationMode = [[TTNavigator navigator].URLMap
                                         navigationModeForURL:linkedItem.URL];
      if (navigationMode == TTNavigationModeCreate) {
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
    CGSize titleSize = [@"M" sizeWithFont:self.textLabel.font];
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
      // XXXjoe TODO
    } else if ([item isKindOfClass:[TTTableBelowCaptionedItem class]]) {
      self.detailTextLabel.font = TTSTYLEVAR(tableFont);
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
  TT_RELEASE_MEMBER(_spinnerView);
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
  TT_RELEASE_MEMBER(_iconView);
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

    self.accessoryType = UITableViewCellAccessoryNone;
    self.selectionStyle = UITableViewCellSelectionStyleNone;
  }
  return self;
}

- (void)dealloc {
  TT_RELEASE_MEMBER(_activityLabel);
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
  TT_RELEASE_MEMBER(_item);
  TT_RELEASE_MEMBER(_errorView);
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
    _label.contentMode = UIViewContentModeLeft;
    [self.contentView addSubview:_label];
  }
  return self;
}

- (void)dealloc {
  TT_RELEASE_MEMBER(_label);
  [super dealloc];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// UIView

- (void)layoutSubviews {
  [super layoutSubviews];
  
  TTTableStyledTextItem* item = self.object;
  _label.frame = CGRectOffset(self.contentView.bounds, item.margin.left, item.margin.top);
  [_label setNeedsLayout];
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
// class private

+ (BOOL)shouldConsiderControlIntrinsicSize:(UIView*)view {
  return [view isKindOfClass:[UISwitch class]];
}

+ (BOOL)shouldSizeControlToFit:(UIView*)view {
  return [view isKindOfClass:[UITextView class]]
         || [view isKindOfClass:[TTTextEditor class]];
}

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
    } else if ([view isKindOfClass:[TTTextEditor class]]) {
      UITextView* textView = [(TTTextEditor*)view textView];
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
// NSObject

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString*)identifier {
  if (self = [super initWithStyle:style reuseIdentifier:identifier]) {
    _item = nil;
    _control = nil;
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
	}
	return self;
}

- (void)dealloc {
  TT_RELEASE_MEMBER(_item);
  TT_RELEASE_MEMBER(_control);
	[super dealloc];
}

- (void)layoutSubviews {
  [super layoutSubviews];
  
  if ([TTTableControlCell  shouldSizeControlToFit:_control]) {
    _control.frame = CGRectInset(self.contentView.bounds, 2, 3);
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
    
    if ([TTTableControlCell shouldConsiderControlIntrinsicSize:_control]) {
      minX += contentWidth - _control.width;
    }
    
    // XXXjoe For some reason I need to re-add the control as a subview or else
    // the re-use of the cell will cause the control to fail to paint itself on occasion
    [self.contentView addSubview:_control];
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
    TT_RELEASE_MEMBER(_control);
    TT_RELEASE_MEMBER(_item);
    
    if ([object isKindOfClass:[UIView class]]) {
      _control = [object retain];
    } else if ([object isKindOfClass:[TTTableControlItem class]]) {
      _item = [object retain];
      _control = [_item.control retain];
    }
    
    self.textLabel.text = _item.caption;
    
    if (_control) {
      [self.contentView addSubview:_control];
    }
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
    _item = nil;
    _view = nil;

    self.selectionStyle = UITableViewCellSelectionStyleNone;
	}
	return self;
}

- (void)dealloc {
  TT_RELEASE_MEMBER(_item);
  TT_RELEASE_MEMBER(_view);
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
    TT_RELEASE_MEMBER(_view);
    TT_RELEASE_MEMBER(_item);
    
    if ([object isKindOfClass:[UIView class]]) {
      _view = [object retain];
    } else if ([object isKindOfClass:[TTTableViewItem class]]) {
      _item = [object retain];
      _view = [_item.view retain];
    }

    [self.contentView addSubview:_view];
  }  
}

@end
