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

#import "Three20UI/TTTableControlCell.h"

// UI
#import "Three20UI/TTTableControlItem.h"
#import "Three20UI/TTTextEditor.h"
#import "Three20UI/UIViewAdditions.h"
#import "Three20Style/UIFontAdditions.h"

// UICommon
#import "Three20UICommon/TTGlobalUICommon.h"

// Core
#import "Three20Core/TTCorePreprocessorMacros.h"

static const CGFloat kDefaultTextViewLines = 5;
static const CGFloat kControlPadding = 8;


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation TTTableControlCell

@synthesize item    = _item;
@synthesize control = _control;


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString*)identifier {
	self = [super initWithStyle:style reuseIdentifier:identifier];
  if (self) {
    self.selectionStyle = UITableViewCellSelectionStyleNone;
  }

  return self;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)dealloc {
  TT_RELEASE_SAFELY(_item);
  TT_RELEASE_SAFELY(_control);

  [super dealloc];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Class private


///////////////////////////////////////////////////////////////////////////////////////////////////
+ (BOOL)shouldConsiderControlIntrinsicSize:(UIView*)view {
  return [view isKindOfClass:[UISwitch class]];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
+ (BOOL)shouldSizeControlToFit:(UIView*)view {
  return [view isKindOfClass:[UITextView class]]
  || [view isKindOfClass:[TTTextEditor class]];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
+ (BOOL)shouldRespectControlPadding:(UIView*)view {
  return [view isKindOfClass:[UITextField class]];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark TTTableViewCell class public


///////////////////////////////////////////////////////////////////////////////////////////////////
+ (CGFloat)tableView:(UITableView*)tableView rowHeightForObject:(id)object {
  UIView* view = nil;

  if ([object isKindOfClass:[UIView class]]) {
    view = object;

  } else {
    TTTableControlItem* controlItem = object;
    view = controlItem.control;
  }

  CGFloat height = view.height;
  if (!height) {
    if ([view isKindOfClass:[UITextView class]]) {
      UITextView* textView = (UITextView*)view;
      CGFloat ttLineHeight = textView.font.ttLineHeight;
      height = ttLineHeight * kDefaultTextViewLines;

    } else if ([view isKindOfClass:[TTTextEditor class]]) {
      TTTextEditor* textEditor = (TTTextEditor*)view;
      CGFloat ttLineHeight = textEditor.font.ttLineHeight;
      height = ttLineHeight * kDefaultTextViewLines;

    } else if ([view isKindOfClass:[UITextField class]]) {
      UITextField* textField = (UITextField*)view;
      CGFloat ttLineHeight = textField.font.ttLineHeight;
      height = ttLineHeight + kTableCellSmallMargin*2;

    } else {
      [view sizeToFit];
      height = view.height;
    }
  }

  if (height < TT_ROW_HEIGHT) {
    return TT_ROW_HEIGHT;

  } else {
    return height;
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark UIView


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)layoutSubviews {
  [super layoutSubviews];

  if ([TTTableControlCell shouldSizeControlToFit:_control]) {
    _control.frame = CGRectInset(self.contentView.bounds, 2, kTableCellSpacing / 2);

  } else {
    CGFloat minX = kControlPadding;
    CGFloat contentWidth = self.contentView.width - kControlPadding;
    if (![TTTableControlCell shouldRespectControlPadding:_control]) {
      contentWidth -= kControlPadding;
    }
    if (self.textLabel.text.length) {
      CGSize textSize = [self.textLabel sizeThatFits:self.contentView.bounds.size];
      contentWidth -= textSize.width + kTableCellSpacing;
      minX += textSize.width + kTableCellSpacing;
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
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark TTTableViewCell


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)object {
  return _item ? _item : (id)_control;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setObject:(id)object {
  if (object != _control && object != _item) {
    if (_control.superview == self.contentView) {
      //on cell reuse it is possible that another
      //cell is already the owner of _control, so
      //check if we're its superview first
      [_control removeFromSuperview];
    }

    TT_RELEASE_SAFELY(_control);
    TT_RELEASE_SAFELY(_item);

    if ([object isKindOfClass:[UIView class]]) {
      _control = [object retain];

    } else if ([object isKindOfClass:[TTTableControlItem class]]) {
      _item = [object retain];
      _control = [_item.control retain];
    }

    _control.backgroundColor = [UIColor clearColor];
    self.textLabel.text = _item.caption;

    if (_control) {
      [self.contentView addSubview:_control];
    }
  }
}


@end
