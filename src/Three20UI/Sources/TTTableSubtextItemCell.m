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

#import "Three20UI/TTTableSubtextItemCell.h"

// UI
#import "Three20UI/TTTableSubtextItem.h"
#import "Three20UI/UITableViewAdditions.h"
#import "Three20UI/UIViewAdditions.h"

// Style
#import "Three20Style/TTGlobalStyle.h"
#import "Three20Style/TTDefaultStyleSheet.h"


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation TTTableSubtextItemCell


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString*)identifier {
  if (self = [super initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:identifier]) {
    self.detailTextLabel.font = TTSTYLEVAR(tableFont);
    self.detailTextLabel.textColor = TTSTYLEVAR(textColor);
    self.detailTextLabel.highlightedTextColor = TTSTYLEVAR(highlightedTextColor);
    self.detailTextLabel.adjustsFontSizeToFitWidth = YES;

    self.textLabel.font = TTSTYLEVAR(font);
    self.textLabel.textColor = TTSTYLEVAR(tableSubTextColor);
    self.textLabel.highlightedTextColor = TTSTYLEVAR(highlightedTextColor);
    self.textLabel.textAlignment = UITextAlignmentLeft;
    self.textLabel.contentMode = UIViewContentModeTop;
    self.textLabel.lineBreakMode = UILineBreakModeWordWrap;
    self.textLabel.numberOfLines = 0;
  }

  return self;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark TTTableViewCell class public


///////////////////////////////////////////////////////////////////////////////////////////////////
+ (CGFloat)tableView:(UITableView*)tableView rowHeightForObject:(id)object {
  TTTableSubtextItem* item = object;

  CGFloat width = tableView.width - [tableView tableCellMargin]*2 - kTableCellHPadding*2;

  CGSize detailTextSize = [item.text sizeWithFont:TTSTYLEVAR(tableFont)
                                constrainedToSize:CGSizeMake(width, CGFLOAT_MAX)
                                    lineBreakMode:UILineBreakModeTailTruncation];

  CGSize textSize = [item.caption sizeWithFont:TTSTYLEVAR(font)
                             constrainedToSize:CGSizeMake(width, CGFLOAT_MAX)
                                 lineBreakMode:UILineBreakModeWordWrap];

  return kTableCellVPadding*2 + detailTextSize.height + textSize.height;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark UIView


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)layoutSubviews {
  [super layoutSubviews];

  if (!self.textLabel.text.length) {
    CGFloat titleHeight = self.textLabel.height + self.detailTextLabel.height;

    [self.detailTextLabel sizeToFit];
    self.detailTextLabel.top = floor(self.contentView.height/2 - titleHeight/2);
    self.detailTextLabel.left = self.detailTextLabel.top*2;

  } else {
    [self.detailTextLabel sizeToFit];
    self.detailTextLabel.left = kTableCellHPadding;
    self.detailTextLabel.top = kTableCellVPadding;

    CGFloat maxWidth = self.contentView.width - kTableCellHPadding*2;
    CGSize captionSize =
    [self.textLabel.text sizeWithFont:self.textLabel.font
                    constrainedToSize:CGSizeMake(maxWidth, CGFLOAT_MAX)
                        lineBreakMode:self.textLabel.lineBreakMode];
    self.textLabel.frame = CGRectMake(kTableCellHPadding, self.detailTextLabel.bottom,
                                      captionSize.width, captionSize.height);
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

    TTTableSubtextItem* item = object;
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
