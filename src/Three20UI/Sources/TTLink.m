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

#import "Three20UI/TTLink.h"

// UI
#import "Three20UI/TTNavigator.h"
#import "Three20UI/TTView.h"

// UINavigator
#import "Three20UINavigator/TTURLAction.h"

// Style
#import "Three20Style/TTGlobalStyle.h"
#import "Three20Style/TTStyleSheet.h"
#import "Three20Style/TTShape.h"

// Core
#import "Three20Core/TTCorePreprocessorMacros.h"


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation TTLink

@synthesize URLAction = _URLAction;


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithFrame:(CGRect)frame {
  if (self = [super initWithFrame:frame]) {
    self.userInteractionEnabled = NO;
    [self addTarget: self
             action: @selector(linkTouched) forControlEvents:UIControlEventTouchUpInside];
  }

  return self;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)dealloc {
  TT_RELEASE_SAFELY(_URLAction);
  TT_RELEASE_SAFELY(_screenView);

  [super dealloc];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Private


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)linkTouched {
  [[TTBaseNavigator navigatorForView:self] openURLAction:_URLAction];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark UIControl


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setHighlighted:(BOOL)highlighted {
  [super setHighlighted:highlighted];
  if (highlighted) {
    if (!_screenView) {
      _screenView = [[TTView alloc] initWithFrame:self.bounds];
      _screenView.style = TTSTYLE(linkHighlighted);
      _screenView.backgroundColor = [UIColor clearColor];
      _screenView.userInteractionEnabled = NO;
      [self addSubview:_screenView];
    }

    _screenView.frame = self.bounds;
    _screenView.hidden = NO;

  } else {
    _screenView.hidden = YES;
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)continueTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
  if ([self pointInside:[touch locationInView:self] withEvent:event]) {
    return YES;

  } else {
    self.highlighted = NO;
    return NO;
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setURLAction:(TTURLAction*)URLAction {
  [URLAction retain];
  [_URLAction release];
  _URLAction = URLAction;

  self.userInteractionEnabled = !!URLAction;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)URL {
  return _URLAction.urlPath;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setURL:(id)URL {
  self.URLAction = [[TTURLAction actionWithURLPath:URL] applyAnimated:YES];
}


@end
