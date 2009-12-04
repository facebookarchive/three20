/**
 * Copyright 2009 Facebook
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

// Copyright 2004-2009 Facebook. All Rights Reserved.

#import "Three20/TTLauncherButton.h"
#import "Three20/TTLauncherItem.h"
#import "Three20/TTLauncherView.h"
#import "Three20/TTLabel.h"
#import "Three20/TTDefaultStyleSheet.h"

///////////////////////////////////////////////////////////////////////////////////////////////////
// global

static const NSInteger kMaxBadgeNumber = 99;

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation TTLauncherButton

@synthesize item = _item, closeButton = _closeButton, editing = _editing, dragging = _dragging;

///////////////////////////////////////////////////////////////////////////////////////////////////
// private

- (void)updateBadge {
  if (!_badge && _item.badgeNumber) {
    _badge = [[TTLabel alloc] init];
    _badge.style = TTSTYLE(largeBadge);
    _badge.backgroundColor = [UIColor clearColor];
    _badge.userInteractionEnabled = NO;
    [self addSubview:_badge];
  }

  if (_item.badgeNumber > 0) {
    if (_item.badgeNumber <= kMaxBadgeNumber) {
      _badge.text = [NSString stringWithFormat:@"%d", _item.badgeNumber];
    } else {
      _badge.text = [NSString stringWithFormat:@"%d+", kMaxBadgeNumber];
    }
  }
  _badge.hidden = _item.badgeNumber <= 0;
  [_badge sizeToFit];
  [self setNeedsLayout];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// NSObject

- (id)initWithItem:(TTLauncherItem*)item {
  if (self = [self init]) {
    _item = [item retain];
    
    NSString* title =  [[NSBundle mainBundle] localizedStringForKey:item.title value:nil table:nil];
    [self setTitle:title forState:UIControlStateNormal];
    [self setImage:item.image forState:UIControlStateNormal];

    if (item.style) {
      [self setStylesWithSelector:item.style];
    } else {
      [self setStylesWithSelector:@"launcherButton:"];
    }
    [self updateBadge];
  }
  return self;
}

- (id)initWithFrame:(CGRect)frame {
  if (self = [super initWithFrame:frame]) {
    _item = nil;
    _badge = nil;
    _closeButton = nil;
    _dragging = NO;
    _editing = NO;

    self.isVertical = YES;
  }
  return self;
}

- (void)dealloc {
  TT_RELEASE_SAFELY(_item);
  TT_RELEASE_SAFELY(_badge);
  TT_RELEASE_SAFELY(_closeButton);
  [super dealloc];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// UIResponder

- (void)touchesBegan:(NSSet*)touches withEvent:(UIEvent *)event {
  [super touchesBegan:touches withEvent:event];
  [[self nextResponder] touchesBegan:touches withEvent:event];
}

- (void)touchesMoved:(NSSet*)touches withEvent:(UIEvent *)event {
  [super touchesMoved:touches withEvent:event];
  [[self nextResponder] touchesMoved:touches withEvent:event];
}

- (void)touchesEnded:(NSSet*)touches withEvent:(UIEvent *)event {
  [super touchesEnded:touches withEvent:event];
  [[self nextResponder] touchesEnded:touches withEvent:event];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// UIControl

- (BOOL)isHighlighted {
  return !_dragging && [super isHighlighted];
}

- (BOOL)isSelected {
  return !_dragging && [super isSelected];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// UIView

- (void)layoutSubviews {
  if (_badge || _closeButton) {
    CGRect imageRect = [self rectForImage];
    if (_badge) {
      _badge.origin = CGPointMake((imageRect.origin.x + imageRect.size.width) - (floor(_badge.width*0.7)),
                                  imageRect.origin.y - (floor(_badge.height*0.25)));
    }
    
    if (_closeButton) {
      _closeButton.origin = CGPointMake(imageRect.origin.x - (floor(_closeButton.width*0.4)),
                                        imageRect.origin.y - (floor(_closeButton.height*0.4)));
    }
  }
}

//////////////////////////////////////////////////////////////////////////////////////////////////
// public

- (TTButton*)closeButton {
  if (!_closeButton && _item.canDelete) {
    _closeButton = [[TTButton buttonWithStyle:@"launcherCloseButton:"] retain];
    [_closeButton setImage:@"bundle://Three20.bundle/images/closeButton.png"
                  forState:UIControlStateNormal];
    _closeButton.size = CGSizeMake(26,29);
    _closeButton.isVertical = YES;
  }
  return _closeButton;
}

- (void)setDragging:(BOOL)dragging {
  if (_dragging != dragging) {
    _dragging = dragging;

    if (dragging) {
      self.transform = CGAffineTransformMakeScale(1.4, 1.4);
      self.alpha = 0.7;
    } else {
      self.transform = CGAffineTransformIdentity;
      self.alpha = 1;
    }
  }
}

- (void)setEditing:(BOOL)editing {
  if (_editing != editing) {
    _editing = editing;

    if (editing) {
      [self addSubview:self.closeButton];
    } else {
      [_closeButton removeFromSuperview];
      TT_RELEASE_SAFELY(_closeButton);
    }
  }
}

@end
