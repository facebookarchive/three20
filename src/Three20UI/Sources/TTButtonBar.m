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

#import "Three20UI/TTButtonBar.h"

// UI
#import "Three20UI/TTButton.h"
#import "Three20UI/UIViewAdditions.h"

// Core
#import "Three20Core/TTCorePreprocessorMacros.h"

static CGFloat kPadding         = 10;
static CGFloat kButtonHeight    = 30;
static CGFloat kButtonMaxWidth  = 120;


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation TTButtonBar

@synthesize buttons = _buttons;
@synthesize buttonStyle = _buttonStyle;


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithFrame:(CGRect)frame {
  if (self = [super initWithFrame:frame]) {
    _buttons = [[NSMutableArray alloc] init];

    self.buttonStyle = @"toolbarButton:";
  }
  return self;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)dealloc {
  TT_RELEASE_SAFELY(_buttons);
  TT_RELEASE_SAFELY(_buttonStyle);

  [super dealloc];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark UIResponder


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)touchesBegan:(NSSet*)touches withEvent:(UIEvent*)event {
  // XXXjoe Hackish? This prevents weird things from happening when the user touches the
  // background of the button bar while it is used as the menu in a table view.
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark UIView


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)layoutSubviews {
  CGFloat buttonWidth = floor((self.width-kPadding) / _buttons.count)-kPadding;
  if (buttonWidth > kButtonMaxWidth) {
    buttonWidth = kButtonMaxWidth;
  }

  CGFloat x = kPadding + floor(self.width/2 - ((buttonWidth+kPadding)*_buttons.count)/2);
  CGFloat y = floor(self.height/2 - kButtonHeight/2);

  for (UIButton* button in _buttons) {
    button.frame = CGRectMake(x, y, buttonWidth, kButtonHeight);
    x += button.width + kPadding;
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Public


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)addButton:(NSString*)title target:(id)target action:(SEL)selector {
  TTButton* button = [TTButton buttonWithStyle:_buttonStyle];
  [button setTitle:title forState:UIControlStateNormal];
  [button addTarget:target action:selector forControlEvents:UIControlEventTouchUpInside];
  [self addSubview:button];
  [_buttons addObject:button];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)removeButtons {
  for (UIButton* button in _buttons) {
    [button removeFromSuperview];
  }
  [_buttons removeAllObjects];
}


@end
