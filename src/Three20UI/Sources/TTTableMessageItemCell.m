//
// Copyright 2009-2011 Facebook
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//    http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

#import "Three20UI/TTTableMessageItemCell.h"

// UI
#import "Three20UI/TTImageView.h"
#import "Three20UI/TTTableMessageItem.h"
#import "Three20UI/UIViewAdditions.h"
#import "Three20UI/UITableViewAdditions.h"

// Style
#import "Three20Style/TTGlobalStyle.h"
#import "Three20Style/TTDefaultStyleSheet.h"
#import "Three20Style/TTDefaultStyleSheet+Tables.h"
#import "Three20Style/UIFontAdditions.h"

// Core
#import "Three20Core/TTCorePreprocessorMacros.h"
#import "Three20Core/TTGlobalCore.h"
#import "Three20Core/NSDateAdditions.h"
#import "Three20Core/NSStringAdditions.h"


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation TTTableMessageItemCell


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString*)identifier {
  if (self = [super initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:identifier]) {
    self.textLabel.font = TTSTYLEVAR(tableMessageItemSubtitleFont);
    self.textLabel.textColor = TTSTYLEVAR(textColor);
    self.textLabel.highlightedTextColor = TTSTYLEVAR(highlightedTextColor);
    self.textLabel.textAlignment = UITextAlignmentLeft;
    self.textLabel.lineBreakMode = UILineBreakModeTailTruncation;
    self.textLabel.adjustsFontSizeToFitWidth = YES;
    self.textLabel.contentMode = UIViewContentModeLeft;
    self.textLabel.numberOfLines = TTSTYLEVAR(tableMessageItemSubtitleNumberOfLines);

    self.detailTextLabel.font = TTSTYLEVAR(tableMessageItemMessageFont);
    self.detailTextLabel.textColor = TTSTYLEVAR(tableSubTextColor);
    self.detailTextLabel.highlightedTextColor = TTSTYLEVAR(highlightedTextColor);
    self.detailTextLabel.textAlignment = UITextAlignmentLeft;
    self.detailTextLabel.contentMode = UIViewContentModeTop;
    self.detailTextLabel.lineBreakMode = UILineBreakModeTailTruncation;
    self.detailTextLabel.numberOfLines = TTSTYLEVAR(tableMessageItemMessageNumberOfLines);
    self.detailTextLabel.contentMode = UIViewContentModeLeft;
  }

  return self;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)dealloc {
  TT_RELEASE_SAFELY(_titleLabel);
  TT_RELEASE_SAFELY(_timestampLabel);
  TT_RELEASE_SAFELY(_imageView2);

  [super dealloc];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark TTTableViewCell class public


///////////////////////////////////////////////////////////////////////////////////////////////////
/**
 * TODO (jverkoey April 7, 2011): Make this a utility method.
 */
+ (CGFloat)heightForFont: (UIFont*)font
                    text: (NSString*)text
                maxWidth: (CGFloat)maxWidth
           numberOfLines: (NSInteger)numberOfLines
           lineBreakMode: (UILineBreakMode)lineBreakMode {
  CGFloat maxHeight;
  if (numberOfLines > 0) {
    maxHeight = font.ttLineHeight * numberOfLines;

  } else {
    maxHeight = CGFLOAT_MAX;
  }

  return [text sizeWithFont: font
          constrainedToSize: CGSizeMake(maxWidth, maxHeight)
              lineBreakMode: lineBreakMode].height;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
+ (CGFloat)tableView:(UITableView*)tableView rowHeightForObject:(id)object {
  TTTableMessageItem* item = object;

  CGFloat cellWidth = tableView.width - [tableView tableCellMargin] * 2;

  CGSize iconSize = TTSTYLEVAR(tableMessageItemIconSize);

  CGFloat left = 0;
  if (TTIsStringWithAnyText(item.imageURL)) {
    left += kTableCellSmallMargin + iconSize.width + kTableCellSmallMargin;

  } else {
    left = kTableCellMargin;
  }

  CGFloat textWidth = cellWidth - left;
  CGFloat textHeight = 0;

  if (TTIsStringWithAnyText(item.title)) {
    CGFloat numberOfLines = TTSTYLEVAR(tableMessageItemTitleNumberOfLines);
    UIFont* font = TTSTYLEVAR(tableMessageItemTitleFont);
    CGFloat labelHeight = [self heightForFont: font
                                         text: item.title
                                     maxWidth: textWidth
                                numberOfLines: numberOfLines
                                lineBreakMode: UILineBreakModeTailTruncation];
    textHeight += labelHeight;
  }

  if (TTIsStringWithAnyText(item.caption)) {
    CGFloat numberOfLines = TTSTYLEVAR(tableMessageItemSubtitleNumberOfLines);
    UIFont* font = TTSTYLEVAR(tableMessageItemSubtitleFont);
    CGFloat labelHeight = [self heightForFont: font
                                         text: item.caption
                                     maxWidth: textWidth
                                numberOfLines: numberOfLines
                                lineBreakMode: UILineBreakModeTailTruncation];
    textHeight += labelHeight;
  }

  if (TTIsStringWithAnyText(item.text)) {
    CGFloat numberOfLines = TTSTYLEVAR(tableMessageItemMessageNumberOfLines);
    UIFont* font = TTSTYLEVAR(tableMessageItemMessageFont);
    CGFloat labelHeight = [self heightForFont: font
                                         text: item.text
                                     maxWidth: textWidth
                                numberOfLines: numberOfLines
                                lineBreakMode: UILineBreakModeTailTruncation];
    textHeight += labelHeight;
  }

  return MAX(iconSize.height, textHeight) + kTableCellSmallMargin * 2;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark UIView


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)prepareForReuse {
  [super prepareForReuse];
  [_imageView2 unsetImage];
  _titleLabel.text = nil;
  _timestampLabel.text = nil;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
/**
 * TODO (jverkoey April 7, 2011): Make this a utility method.
 */
- (CGFloat)heightForLabel:(UILabel*)label maxWidth:(CGFloat)maxWidth {
  return [[self class] heightForFont: label.font
                                text: label.text
                            maxWidth: maxWidth
                       numberOfLines: label.numberOfLines
                       lineBreakMode: label.lineBreakMode];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)layoutSubviews {
  [super layoutSubviews];

  CGFloat left = 0;
  if (_imageView2) {
    CGSize iconSize = TTSTYLEVAR(tableMessageItemIconSize);
    _imageView2.frame = CGRectMake(kTableCellSmallMargin, kTableCellSmallMargin,
                                   iconSize.width, iconSize.height);
    left += kTableCellSmallMargin + iconSize.width + kTableCellSmallMargin;

  } else {
    left = kTableCellMargin;
  }

  CGFloat width = self.contentView.width - left;
  CGFloat top = kTableCellSmallMargin;

  if (_titleLabel.text.length) {
    _titleLabel.frame = CGRectMake(left, top, width,
                                   [self heightForLabel:_titleLabel maxWidth:width]);

    top += _titleLabel.height;

  } else {
    _titleLabel.frame = CGRectZero;
  }

  if (self.captionLabel.text.length) {
    self.captionLabel.frame = CGRectMake(left, top, width,
                                         [self heightForLabel: self.captionLabel
                                                     maxWidth: width]);

    top += self.captionLabel.height;

  } else {
    self.captionLabel.frame = CGRectZero;
  }

  if (self.detailTextLabel.text.length) {
    self.detailTextLabel.frame = CGRectMake(left, top, width,
                                         [self heightForLabel: self.detailTextLabel
                                                     maxWidth: width]);

  } else {
    self.detailTextLabel.frame = CGRectZero;
  }

  if (_timestampLabel.text.length) {
    _timestampLabel.alpha = !self.showingDeleteConfirmation;
    [_timestampLabel sizeToFit];
    _timestampLabel.left = self.contentView.width - (_timestampLabel.width + kTableCellSmallMargin);
    _timestampLabel.top = _titleLabel.top;
    _titleLabel.width -= _timestampLabel.width + kTableCellSmallMargin*2;

  } else {
    _timestampLabel.frame = CGRectZero;
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)didMoveToSuperview {
  [super didMoveToSuperview];

  if (self.superview) {
    _imageView2.backgroundColor = self.backgroundColor;
    _titleLabel.backgroundColor = self.backgroundColor;
    _timestampLabel.backgroundColor = self.backgroundColor;
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark TTTableViewCell


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setObject:(id)object {
  if (_item != object) {
    [super setObject:object];

    TTTableMessageItem* item = object;
    if (item.title.length) {
      self.titleLabel.text = item.title;
    }
    if (item.caption.length) {
      self.captionLabel.text = item.caption;
    }
    if (item.text.length) {
      self.detailTextLabel.text = item.text;
    }
    if (item.timestamp) {
      self.timestampLabel.text = [item.timestamp formatShortTime];
    }
    if (item.imageURL) {
      self.imageView2.urlPath = item.imageURL;
    }
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Public


///////////////////////////////////////////////////////////////////////////////////////////////////
- (UILabel*)titleLabel {
  if (!_titleLabel) {
    _titleLabel = [[UILabel alloc] init];
    _titleLabel.textColor = [UIColor blackColor];
    _titleLabel.highlightedTextColor = [UIColor whiteColor];
    _titleLabel.font = TTSTYLEVAR(tableMessageItemTitleFont);
    _titleLabel.contentMode = UIViewContentModeLeft;
    _titleLabel.numberOfLines = TTSTYLEVAR(tableMessageItemTitleNumberOfLines);
    [self.contentView addSubview:_titleLabel];
  }
  return _titleLabel;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (UILabel*)captionLabel {
  return self.textLabel;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (UILabel*)timestampLabel {
  if (!_timestampLabel) {
    _timestampLabel = [[UILabel alloc] init];
    _timestampLabel.font = TTSTYLEVAR(tableMessageItemTimestampFont);
    _timestampLabel.textColor = TTSTYLEVAR(timestampTextColor);
    _timestampLabel.highlightedTextColor = [UIColor whiteColor];
    _timestampLabel.contentMode = UIViewContentModeLeft;
    _timestampLabel.numberOfLines = 1;
    [self.contentView addSubview:_timestampLabel];
  }
  return _timestampLabel;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (TTImageView*)imageView2 {
  if (!_imageView2) {
    _imageView2 = [[TTImageView alloc] init];
    //    _imageView2.defaultImage = TTSTYLEVAR(personImageSmall);
    //    _imageView2.style = TTSTYLE(threadActorIcon);
    [self.contentView addSubview:_imageView2];
  }
  return _imageView2;
}


@end
