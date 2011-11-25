//
//  TTTableCheckmarkItemCell.m
//  Three20UI
//
//  Created by Joseph Smith on 4/27/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//
#import "TTTableCheckmarkCell.h"

#import "Three20UI/UIViewAdditions.h"
#import "Three20UI/UITableViewAdditions.h"

// Style
#import "Three20Style/TTDefaultStyleSheet.h"
#import "Three20Style/TTGlobalStyle.h"

#import "Three20Core/TTCorePreprocessorMacros.h"

static const CGFloat kMaxLabelHeight = 2000.0f;
static const UILineBreakMode kLineBreakMode = UILineBreakModeWordWrap;

@implementation TTTableCheckmarkCell
///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)identifier {
    if ((self = [super initWithStyle:style reuseIdentifier:identifier])) {
        self.textLabel.highlightedTextColor = TTSTYLEVAR(highlightedTextColor);
        self.textLabel.lineBreakMode = kLineBreakMode;
        self.textLabel.numberOfLines = 0;
    }

    return self;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
+ (UIFont*)textFontForItem:(TTTableCheckmarkItem *)item {
    return TTSTYLEVAR(tableFont);
}

#pragma mark -
#pragma mark TTTableViewCell
///////////////////////////////////////////////////////////////////////////////////////////////////
+ (CGFloat)tableView:(UITableView *)tableView rowHeightForObject:(id)object {
    TTTableCheckmarkItem* item = object;

    CGFloat width = tableView.width - (kTableCellHPadding*2 + [tableView tableCellMargin]*2);
    UIFont* font = [self textFontForItem:item];
    CGSize size = [item.text sizeWithFont:font
                        constrainedToSize:CGSizeMake(width, CGFLOAT_MAX)
                            lineBreakMode:kLineBreakMode];
    if (size.height > kMaxLabelHeight) {
        size.height = kMaxLabelHeight;
    }

    return size.height + kTableCellVPadding * 2;
}

#pragma mark -
#pragma mark UIView
///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)layoutSubviews {
    [super layoutSubviews];
    self.textLabel.frame = CGRectInset(self.contentView.bounds,
                                       kTableCellHPadding, kTableCellVPadding);
    self.accessoryType = self->item.checked ?
    UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setObject:(id)object {
    if (self->item != object) {
        [super setObject:object];
        self->item = [object retain];

        TTTableCheckmarkItem* newItem = object;
        self.textLabel.text = newItem.text;

        if ([object isKindOfClass:[TTTableCheckmarkItem class]]) {
            self.textLabel.font = TTSTYLEVAR(tableFont);
            self.textLabel.textColor = TTSTYLEVAR(textColor);
            self.textLabel.textAlignment = UITextAlignmentLeft;
            self.accessoryType = newItem.checked ?
            UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
            self.selectionStyle = TTSTYLEVAR(tableSelectionStyle);
        }
        else
        {
            self.accessoryType = UITableViewCellAccessoryNone;
            self.selectionStyle = UITableViewCellSelectionStyleNone;
        }
    }
}


@end
