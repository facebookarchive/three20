//
// Copyright 2009 Facebook
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

#import "Three20UI/TTUnclippedView.h"


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation TTUnclippedView


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)didMoveToSuperview {
  for (UIView* p = self; p; p = p.superview) {
    // This allows the view to be shown "full screen", and not offset by the toolbar and status bar
    p.clipsToBounds = NO;
    //p.backgroundColor = self.backgroundColor;
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setFrame:(CGRect)rect {
  [super setFrame:rect];
}

@end
