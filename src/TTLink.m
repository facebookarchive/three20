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

#include "Three20/TTLink.h"
#include "Three20/TTNavigator.h"
#include "Three20/TTShape.h"
#include "Three20/TTView.h"
#include "Three20/TTDefaultStyleSheet.h"

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation TTLink

@synthesize URL = _URL;

///////////////////////////////////////////////////////////////////////////////////////////////////
// private

- (void)linkTouched {
  TTOpenURL(_URL);
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// NSObject

- (id)initWithFrame:(CGRect)frame {
  if (self = [super initWithFrame:frame]) {
    _URL = nil;
    _screenView = nil;
    
    self.userInteractionEnabled = NO;
    [self addTarget:self action:@selector(linkTouched)
          forControlEvents:UIControlEventTouchUpInside];
  }
  return self;
}

- (void)dealloc {
  TT_RELEASE_SAFELY(_URL);
  TT_RELEASE_SAFELY(_screenView);
  [super dealloc];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// UIControl

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

- (BOOL)continueTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
  if ([self pointInside:[touch locationInView:self] withEvent:event]) {
    return YES;
  } else {
    self.highlighted = NO;
    return NO;
  }
}

///////////////////////////////////////////////////////////////////////////////////////////////////

- (void)setURL:(id)URL {
  [_URL release];
  _URL = [URL retain];
  
  self.userInteractionEnabled = !!_URL;
}

@end
