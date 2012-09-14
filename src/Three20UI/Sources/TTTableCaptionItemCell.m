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

#import "Three20UI/TTTableCaptionItemCell.h"

// UI
#import "Three20UI/TTTableCaptionItem.h"
#import "Three20UI/UIViewAdditions.h"
#import "Three20Style/UIFontAdditions.h"
#import "Three20UI/UITableViewAdditions.h"

// Style
#import "Three20Style/TTGlobalStyle.h"
#import "Three20Style/TTDefaultStyleSheet.h"

static const CGFloat kKeySpacing = 12.0f;
static const CGFloat kKeyWidth = 75.0f;


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation TTTableCaptionItemCell


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString*)identifier {
	self = [super initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:identifier];
  if (self) {
    self.textLabel.font = TTSTYLEVAR(tableTitleFont);
    self.textLabel.textColor = TTSTYLEVAR(linkTextColor);
    self.textLabel.highlightedTextColor = TTSTYLEVAR(highlightedTextColor);
	self.textLabel.backgroundColor = TTSTYLEVAR(backgroundTextColor);
    self.textLabel.textAlignment = UITextAlignmentRight;
    self.textLabel.lineBreakMode = UILineBreakModeTailTruncation;
    self.textLabel.numberOfLines = 1;
    self.textLabel.adjustsFontSizeToFitWidth = YES;

    self.detailTextLabel.font = TTSTYLEVAR(tableSmallFont);
    self.detailTextLabel.textColor = TTSTYLEVAR(textColor);
    self.detailTextLabel.highlightedTextColor = TTSTYLEVAR(highlightedTextColor);
	self.detailTextLabel.backgroundColor = TTSTYLEVAR(backgroundTextColor);
    self.detailTextLabel.adjustsFontSizeToFitWidth = YES;
    self.detailTextLabel.minimumFontSize = 8;
    self.detailTextLabel.lineBreakMode = UILineBreakModeWordWrap;
    self.detailTextLabel.numberOfLines = 0;
  }

  return self;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark TTTableViewCell class public


///////////////////////////////////////////////////////////////////////////////////////////////////
+ (CGFloat)tableView:(UITableView*)tableView rowHeightForObject:(id)object {
  TTTableCaptionItem* item = object;

  CGFloat margin = [tableView tableCellMargin];
  CGFloat width = tableView.width - (kKeyWidth + kKeySpacing + kTableCellHPadding*2 + margin*2);

  CGSize detailTextSize = [item.text sizeWithFont:TTSTYLEVAR(tableSmallFont)
                                constrainedToSize:CGSizeMake(width, CGFLOAT_MAX)
                                    lineBreakMode:UILineBreakModeWordWrap];

  CGSize captionTextSize = [item.caption sizeWithFont:TTSTYLEVAR(tableTitleFont)
                                constrainedToSize:CGSizeMake(kKeyWidth, CGFLOAT_MAX)
                                    lineBreakMode:UILineBreakModeTailTruncation];

  return MAX(detailTextSize.height, captionTextSize.height) + kTableCellVPadding*2;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark UIView


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)layoutSubviews {
  [super layoutSubviews];

  self.textLabel.frame = CGRectMake(kTableCellHPadding, kTableCellVPadding,
                                    kKeyWidth, self.textLabel.font.ttLineHeight);

  CGFloat valueWidth = self.contentView.width - (kTableCellHPadding*2 + kKeyWidth + kKeySpacing);
  CGFloat innerHeight = self.contentView.height - kTableCellVPadding*2;
  self.detailTextLabel.frame = CGRectMake(kTableCellHPadding + kKeyWidth + kKeySpacing,
                                          kTableCellVPadding,
                                          valueWidth, innerHeight);
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark TTTableViewCell


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setObject:(id)object {
  if (_item != object) {
    [super setObject:object];

    TTTableCaptionItem* item = object;
    self.textLabel.text = item.caption;
    self.detailTextLabel.text = item.text;
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Public


///////////////////////////////////////////////////////////////////////////////////////////////////
- (UILabel*)captionLabel {
  return self.textLabel;
}


@end
