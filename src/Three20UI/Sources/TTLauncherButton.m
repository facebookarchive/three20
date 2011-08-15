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

#import "Three20UI/TTLauncherButton.h"

// UI
#import "Three20UI/TTLauncherItem.h"
#import "Three20UI/TTLabel.h"
#import "Three20UI/UIViewAdditions.h"

// Style
#import "Three20Style/TTGlobalStyle.h"
#import "Three20Style/TTStyleSheet.h"

// Core
#import "Three20Core/TTCorePreprocessorMacros.h"

static const NSInteger kMaxBadgeNumber = 99;


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@interface TTLauncherButton()

/**
 * Adds the badge view to this button and sets its display values.
 */
- (void)updateBadge;

@end


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation TTLauncherButton

@synthesize item        = _item;
@synthesize closeButton = _closeButton;
@synthesize editing     = _editing;
@synthesize dragging    = _dragging;


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithItem:(TTLauncherItem*)item {
	self = [self init];
  if (self) {
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


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];
  if (self) {
    self.isVertical = YES;
  }

  return self;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)dealloc {
  TT_RELEASE_SAFELY(_item);
  TT_RELEASE_SAFELY(_badge);
  TT_RELEASE_SAFELY(_closeButton);

  [super dealloc];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Private


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)updateBadge {
  if (_badge == nil && _item.badgeValue != nil) {
    _badge = [[TTLabel alloc] init];
    _badge.style = TTSTYLE(largeBadge);
    _badge.backgroundColor = [UIColor clearColor];
    _badge.userInteractionEnabled = NO;
    [self addSubview:_badge];
  }

  NSString *badgeText = nil;
  NSString *badgeValue = _item.badgeValue;

  if (badgeValue != nil) {
    NSRange range = [badgeValue rangeOfCharacterFromSet:[[NSCharacterSet decimalDigitCharacterSet]
                                                         invertedSet]];

    if (range.location == NSNotFound && _item.badgeNumber > kMaxBadgeNumber) {
      badgeText = [NSString stringWithFormat:@"%d+", kMaxBadgeNumber];

    } else {
      badgeText = badgeValue;
    }
  }

  _badge.text = badgeText;
  _badge.hidden = badgeValue == nil;
  [_badge sizeToFit];
  [self setNeedsLayout];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark UIResponder


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)touchesBegan:(NSSet*)touches withEvent:(UIEvent *)event {
  [super touchesBegan:touches withEvent:event];
  [[self nextResponder] touchesBegan:touches withEvent:event];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)touchesMoved:(NSSet*)touches withEvent:(UIEvent *)event {
  [super touchesMoved:touches withEvent:event];
  [[self nextResponder] touchesMoved:touches withEvent:event];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)touchesEnded:(NSSet*)touches withEvent:(UIEvent *)event {
  [super touchesEnded:touches withEvent:event];
  [[self nextResponder] touchesEnded:touches withEvent:event];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark UIControl


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)isHighlighted {
  return !_dragging && [super isHighlighted];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)isSelected {
  return !_dragging && [super isSelected];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark UIView


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)layoutSubviews {
  if (_badge || _closeButton) {
    CGRect imageRect = [self rectForImage];
    if (_badge) {
      _badge.origin = CGPointMake((imageRect.origin.x
                                   + imageRect.size.width)
                                  - (floor(_badge.width*0.7)),
                                  imageRect.origin.y - (floor(_badge.height*0.25)));
    }

    if (_closeButton) {
      _closeButton.origin = CGPointMake(imageRect.origin.x - (floor(_closeButton.width*0.4)),
                                        imageRect.origin.y - (floor(_closeButton.height*0.4)));
    }
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Public


///////////////////////////////////////////////////////////////////////////////////////////////////
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


///////////////////////////////////////////////////////////////////////////////////////////////////
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


///////////////////////////////////////////////////////////////////////////////////////////////////
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
